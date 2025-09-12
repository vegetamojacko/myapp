import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import './screens/auth_screen.dart';
import './screens/banking_details_screen.dart';
import './screens/subscription_screen.dart';
import './screens/splash_screen.dart';
import 'main.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
       GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: '/subscription',
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: '/banking-details',
        builder: (context, state) => const BankingDetailsScreen(),
      ),
    ],
    errorPageBuilder: (context, state) => MaterialPage(
      child: Scaffold(
        body: Center(
          child: Text('Page not found: ${state.error}'),
        ),
      ),
    ),
  );
}
