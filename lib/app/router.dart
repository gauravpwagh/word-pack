import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../ui/explore/explorer_screen.dart';
import '../ui/import/import_preview_screen.dart';
import '../ui/learn/learn_screen.dart';
import '../ui/settings/manage_categories_screen.dart';
import '../ui/settings/settings_screen.dart';
import '../ui/shell/adaptive_shell.dart';
import '../ui/wordlist/learn_home_screen.dart';
import '../ui/wordlist/wordlist_home_screen.dart';

/// Routes from `docs/UI_UX.md` §2, all inside the adaptive shell.
GoRouter buildRouter({String initialLocation = '/'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            AdaptiveShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const LearnHomeScreen(),
          ),
          GoRoute(
            path: '/import',
            builder: (context, state) => const ImportPreviewScreen(),
          ),
          GoRoute(
            path: '/lists/:id',
            builder: (context, state) =>
                WordlistHomeScreen(wordlistId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/learn/:packId',
            builder: (context, state) => LearnScreen(
              packId: state.pathParameters['packId']!,
              direction: state.uri.queryParameters['dir'],
            ),
          ),
          GoRoute(
            path: '/explore',
            builder: (context, state) => const ExplorerScreen(),
            routes: [
              GoRoute(
                path: ':nodeId',
                builder: (context, state) =>
                    ExplorerScreen(nodeId: state.pathParameters['nodeId']),
              ),
            ],
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'categories',
                builder: (context, state) => const ManageCategoriesScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final router = buildRouter();
  ref.onDispose(router.dispose);
  return router;
});
