import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../import/welcome_screen.dart';
import 'wordlist_home_screen.dart';

/// The Learn tab: Welcome until something is imported, then the most recently
/// imported wordlist's home.
class LearnHomeScreen extends ConsumerWidget {
  const LearnHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(wordlistsProvider)) {
      AsyncData(value: final lists) when lists.isNotEmpty => WordlistHomeScreen(
        wordlistId: lists.first.id,
      ),
      AsyncData() => const WelcomeScreen(),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}
