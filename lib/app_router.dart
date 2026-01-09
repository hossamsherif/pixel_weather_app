import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';
import 'presentation/screens/favorites_screen.dart';
import 'presentation/screens/forecast_screen.dart';
import 'presentation/screens/search_screen.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/favorites/forecast',
    routes: <RouteBase>[
      GoRoute(
        path: '/favorites',
        name: AppRoutes.favorites,
        builder: (context, state) => const FavoritesScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: 'forecast',
            name: AppRoutes.forecast,
            pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: const ForecastScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    final Animation<double> curved = CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    );
                    return FadeTransition(
                      opacity: curved,
                      child: ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.92,
                          end: 1,
                        ).animate(curved),
                        alignment: Alignment.topLeft,
                        child: child,
                      ),
                    );
                  },
            ),
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
