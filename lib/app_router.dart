import 'package:go_router/go_router.dart';

import 'app_routes.dart';
import 'presentation/screens/favorites_screen.dart';
import 'presentation/screens/forecast_screen.dart';
import 'presentation/screens/search_screen.dart';
import 'presentation/shell/app_shell.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/forecast',
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/forecast',
                name: AppRoutes.forecast,
                builder: (context, state) => const ForecastScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/favorites',
                name: AppRoutes.favorites,
                builder: (context, state) => const FavoritesScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/search',
        name: AppRoutes.search,
        builder: (context, state) => const SearchScreen(),
      ),
    ],
  );
}
