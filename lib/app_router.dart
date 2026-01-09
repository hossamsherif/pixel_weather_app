import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';
import 'presentation/screens/favorites_screen.dart';
import 'presentation/screens/forecast_screen.dart';
import 'presentation/screens/search_screen.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/forecast',
    routes: <RouteBase>[
      GoRoute(
        path: '/forecast',
        name: AppRoutes.forecast,
        builder: (context, state) => const ForecastScreen(),
      ),
      GoRoute(
        path: '/favorites',
        name: AppRoutes.favorites,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const FavoritesScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final Animation<double> curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1).animate(curved),
                alignment: Alignment.topLeft,
                child: child,
              ),
            );
          },
        ),
      ),
      GoRoute(
        path: '/search',
        name: AppRoutes.search,
        builder: (context, state) => const SearchScreen(),
      ),
    ],
  );
}
