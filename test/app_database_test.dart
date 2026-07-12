import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:melody_sense/core/data/local/app_database.dart';

void main() {
  late AppDatabase db;

  // Setiap test dapat database in-memory yang fresh — tidak menyentuh
  // file sqlite asli, dan otomatis kebuang setelah test selesai.
  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('SessionDao', () {
    test('startSession lalu finishSession menyimpan data dengan benar', () async {
      final id = await db.sessionDao.startSession(mode: 'note_recognition');

      var sessions = await db.sessionDao.getSessionsByMode('note_recognition');
      expect(sessions, hasLength(1));
      expect(sessions.first.endedAt, isNull);

      await db.sessionDao.finishSession(sessionId: id, xpEarned: 50, score: 120);

      sessions = await db.sessionDao.getSessionsByMode('note_recognition');
      expect(sessions.first.endedAt, isNotNull);
      expect(sessions.first.xpEarned, 50);
      expect(sessions.first.score, 120);
    });

    test('getTotalXp menjumlahkan xp dari semua sesi (bukan kolom terpisah)',
        () async {
      final id1 = await db.sessionDao.startSession(mode: 'note_recognition');
      final id2 = await db.sessionDao.startSession(mode: 'interval_training');

      await db.sessionDao.finishSession(sessionId: id1, xpEarned: 30, score: 100);
      await db.sessionDao.finishSession(sessionId: id2, xpEarned: 20, score: 80);

      final totalXp = await db.sessionDao.getTotalXp();
      expect(totalXp, 50);
    });

    test('getTotalXp mengembalikan 0 kalau belum ada sesi sama sekali', () async {
      final totalXp = await db.sessionDao.getTotalXp();
      expect(totalXp, 0);
    });
  });

  group('AttemptDao', () {
    test('logAttempt tersimpan dan terhubung ke session yang benar', () async {
      final sessionId = await db.sessionDao.startSession(mode: 'note_recognition');

      await db.attemptDao.logAttempt(
        sessionId: sessionId,
        note: 'C4',
        isCorrect: true,
        responseTimeMs: 850,
      );
      await db.attemptDao.logAttempt(
        sessionId: sessionId,
        note: 'D4',
        isCorrect: false,
        responseTimeMs: 1200,
      );

      final attempts = await db.attemptDao.getAttemptsBySession(sessionId);
      expect(attempts, hasLength(2));
    });

    test('getAccuracyPerNote menghitung persentase benar per nada', () async {
      final sessionId = await db.sessionDao.startSession(mode: 'note_recognition');

      // C4: 2 benar, 1 salah -> akurasi 2/3
      await db.attemptDao.logAttempt(
          sessionId: sessionId, note: 'C4', isCorrect: true, responseTimeMs: 500);
      await db.attemptDao.logAttempt(
          sessionId: sessionId, note: 'C4', isCorrect: true, responseTimeMs: 600);
      await db.attemptDao.logAttempt(
          sessionId: sessionId, note: 'C4', isCorrect: false, responseTimeMs: 700);

      // D4: 1 salah -> akurasi 0/1
      await db.attemptDao.logAttempt(
          sessionId: sessionId, note: 'D4', isCorrect: false, responseTimeMs: 900);

      final stats = await db.attemptDao.getAccuracyPerNote();
      final c4 = stats.firstWhere((s) => s.note == 'C4');
      final d4 = stats.firstWhere((s) => s.note == 'D4');

      expect(c4.totalAttempts, 3);
      expect(c4.correctAttempts, 2);
      expect(c4.accuracy, closeTo(2 / 3, 0.001));

      expect(d4.totalAttempts, 1);
      expect(d4.correctAttempts, 0);
      expect(d4.accuracy, 0);
    });

    test('menghapus session ikut menghapus attempts-nya (cascade)', () async {
      final sessionId = await db.sessionDao.startSession(mode: 'note_recognition');
      await db.attemptDao.logAttempt(
          sessionId: sessionId, note: 'C4', isCorrect: true, responseTimeMs: 500);

      await (db.delete(db.sessions)..where((s) => s.id.equals(sessionId))).go();

      final attempts = await db.attemptDao.getAttemptsBySession(sessionId);
      expect(attempts, isEmpty);
    });
  });

  group('PersonalBestDao', () {
    test('submitScore menyimpan rekor pertama', () async {
      final isNewRecord =
          await db.personalBestDao.submitScore(mode: 'note_recognition', score: 100);

      expect(isNewRecord, isTrue);
      final best = await db.personalBestDao.getBest('note_recognition');
      expect(best!.bestScore, 100);
    });

    test('submitScore menolak skor yang lebih rendah dari rekor', () async {
      await db.personalBestDao.submitScore(mode: 'note_recognition', score: 100);
      final isNewRecord =
          await db.personalBestDao.submitScore(mode: 'note_recognition', score: 80);

      expect(isNewRecord, isFalse);
      final best = await db.personalBestDao.getBest('note_recognition');
      expect(best!.bestScore, 100); // tetap 100, tidak ketiban 80
    });

    test('submitScore menerima skor yang lebih tinggi dan menimpa rekor lama',
        () async {
      await db.personalBestDao.submitScore(mode: 'note_recognition', score: 100);
      final isNewRecord =
          await db.personalBestDao.submitScore(mode: 'note_recognition', score: 150);

      expect(isNewRecord, isTrue);
      final best = await db.personalBestDao.getBest('note_recognition');
      expect(best!.bestScore, 150);
    });
  });

  group('AchievementDao', () {
    test('seedIfEmpty mengisi data hanya kalau tabel masih kosong', () async {
      await db.achievementDao.seedIfEmpty([
        AchievementsCompanion.insert(title: 'Nada Pertama', progressTarget: 1),
        AchievementsCompanion.insert(title: '10 Sesi', progressTarget: 10),
      ]);

      var all = await db.achievementDao.getAll();
      expect(all, hasLength(2));

      // Panggil lagi -> tidak boleh dobel karena tabel sudah tidak kosong.
      await db.achievementDao.seedIfEmpty([
        AchievementsCompanion.insert(title: 'Harusnya Tidak Masuk', progressTarget: 1),
      ]);
      all = await db.achievementDao.getAll();
      expect(all, hasLength(2));
    });

    test('incrementProgress menambah progress tanpa unlock kalau belum capai target',
        () async {
      final id = await db.into(db.achievements).insert(
            AchievementsCompanion.insert(title: '10 Sesi', progressTarget: 10),
          );

      await db.achievementDao.incrementProgress(id, 3);

      final all = await db.achievementDao.getAll();
      final achievement = all.firstWhere((a) => a.id == id);
      expect(achievement.progressCurrent, 3);
      expect(achievement.unlocked, isFalse);
    });

    test('incrementProgress otomatis unlock saat progress capai target', () async {
      final id = await db.into(db.achievements).insert(
            AchievementsCompanion.insert(title: 'Nada Pertama', progressTarget: 5),
          );

      await db.achievementDao.incrementProgress(id, 5);

      final all = await db.achievementDao.getAll();
      final achievement = all.firstWhere((a) => a.id == id);
      expect(achievement.progressCurrent, 5);
      expect(achievement.unlocked, isTrue);
      expect(achievement.unlockedAt, isNotNull);
    });

    test('incrementProgress tidak menambah lagi setelah unlocked', () async {
      final id = await db.into(db.achievements).insert(
            AchievementsCompanion.insert(title: 'Nada Pertama', progressTarget: 5),
          );

      await db.achievementDao.incrementProgress(id, 5); // unlock
      await db.achievementDao.incrementProgress(id, 3); // harusnya diabaikan

      final all = await db.achievementDao.getAll();
      final achievement = all.firstWhere((a) => a.id == id);
      expect(achievement.progressCurrent, 5); // bukan 8
    });
  });
}
