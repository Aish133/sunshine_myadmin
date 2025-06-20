import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';
import 'home.dart';
import 'dashboard.dart'; // Add your DashboardScreen import here

final GoRouter router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
      
    ),
  ],
  redirect: (context, state) async {
    final prefs = await SharedPreferences.getInstance();
    final hasToken = prefs.getString('jwt_token') != null;

    final isLoggingIn = state.uri.toString() == '/login';

    if (!hasToken && !isLoggingIn) {
      return '/login';
    }

    if (hasToken && isLoggingIn) {
      return '/home';
    }

    return null;
  },
);
