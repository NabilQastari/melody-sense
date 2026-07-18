/// Definisi achievement bawaan, dipakai untuk seeding lewat
/// ProgressionRepository.seedDefaultAchievementsIfEmpty(). Domain layer
/// sengaja tidak tahu soal Drift/AchievementsCompanion — itu urusan data
/// layer (lihat ProgressionRepositoryImpl).
///
/// Daftar ini masih draft tim, gampang direvisi: tinggal ubah/tambah entri
/// di `defaultAchievementDefinitions`. Judulnya dipakai sebagai kunci
/// pencocokan (lihat AchievementTitles) karena tabel Achievements tidak
/// punya kolom "key" terpisah — kalau judul diubah, pastikan referensinya
/// di ProgressionRepositoryImpl.completeSession() ikut disesuaikan.
class AchievementTitles {
  static const firstNotes = 'First Notes';
  static const dedicatedLearner = 'Dedicated Learner';
  static const noteMaster = 'Note Master';
  static const perfectRound = 'Perfect Round';
  static const centuryScorer = 'Century Scorer';
  static const onFire = 'On Fire';
}

class AchievementDefinition {
  final String title;
  final int progressTarget;

  const AchievementDefinition({
    required this.title,
    required this.progressTarget,
  });
}

const defaultAchievementDefinitions = <AchievementDefinition>[
  // Achievement akumulatif — progress-nya cuma nambah seiring waktu,
  // di-increment lewat AchievementDao.incrementProgress().
  AchievementDefinition(title: AchievementTitles.firstNotes, progressTarget: 1),
  AchievementDefinition(
      title: AchievementTitles.dedicatedLearner, progressTarget: 5),
  AchievementDefinition(title: AchievementTitles.noteMaster, progressTarget: 100),

  // Achievement berbasis kondisi satu sesi — di-set langsung ke target
  // begitu syaratnya terpenuhi, lewat AchievementDao.setProgress().
  AchievementDefinition(title: AchievementTitles.perfectRound, progressTarget: 1),
  AchievementDefinition(
      title: AchievementTitles.centuryScorer, progressTarget: 1),

  // Achievement berbasis streak — nilainya bisa naik-turun, juga lewat
  // setProgress() (di-set absolut ke streak saat ini, bukan di-increment).
  AchievementDefinition(title: AchievementTitles.onFire, progressTarget: 3),
];
