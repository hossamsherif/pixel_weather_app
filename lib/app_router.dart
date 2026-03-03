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
            builder: (context, state) => const ForecastScreen(),
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
