import 'package:go_router/go_router.dart';

import '../ui/layout/main_layout.dart';
import '../ui/screens/dashboard_screen.dart';
import '../ui/screens/guests_screen.dart';
import '../ui/screens/rooms_screen.dart';
import '../ui/screens/reservations_screen.dart';
import '../ui/screens/checkout_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/guests',
          builder: (context, state) => const GuestsScreen(),
        ),
        GoRoute(
          path: '/rooms',
          builder: (context, state) => const RoomsScreen(),
        ),
        GoRoute(
          path: '/reservations',
          builder: (context, state) => const ReservationsScreen(),
        ),
        GoRoute(
          path: '/checkout',
          builder: (context, state) => const CheckoutScreen(),
        ),
      ],
    ),
  ],
);
