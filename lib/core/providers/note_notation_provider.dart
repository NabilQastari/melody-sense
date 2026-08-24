import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/entities/note_notation.dart';

class NoteNotationNotifier extends StateNotifier<NoteNotation> {
  NoteNotationNotifier() : super(NoteNotation.solfege) {
    _loadFromPrefs();
  }

  static const _key = 'note_notation';

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final valueStr = prefs.getString(_key);
    if (valueStr == 'scientific') {
      state = NoteNotation.scientific;
    } else {
      state = NoteNotation.solfege;
    }
  }

  Future<void> setNotation(NoteNotation notation) async {
    state = notation;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, notation.name);
  }
}

final noteNotationProvider =
    StateNotifierProvider<NoteNotationNotifier, NoteNotation>((ref) {
  return NoteNotationNotifier();
});
