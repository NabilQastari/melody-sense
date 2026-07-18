import 'package:flutter/material.dart';

enum ChallengeDifficulty { beginner, intermediate, advanced }

extension ChallengeDifficultyLabel on ChallengeDifficulty {
  String get label => switch (this) {
        ChallengeDifficulty.beginner => 'BEGINNER',
        ChallengeDifficulty.intermediate => 'INTERMEDIATE',
        ChallengeDifficulty.advanced => 'ADVANCE',
      };
}

/// Describes one entry in the "Pick a Challenge" list (Practice tab).
///
/// Lives in the presentation layer on purpose — it's a navigation/display
/// concern (which screen to push, which icon to show), not domain data.
/// The domain layer (`PracticeRepository`, `TrainingMode`, etc.) stays
/// untouched.
class ChallengeInfo {
  const ChallengeInfo({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.difficulty,
    required this.enabled,
    this.builder,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final ChallengeDifficulty difficulty;

  /// False for challenges that don't have a screen yet (e.g. Rhythm Match).
  /// The card renders disabled + "COMING SOON" instead of the difficulty badge.
  final bool enabled;

  /// Builds the destination screen. Null when [enabled] is false.
  final WidgetBuilder? builder;
}