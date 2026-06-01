import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: AppTheme.primaryNavy,
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Icon(
                  Icons.hotel,
                  color: AppTheme.primaryGold,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'SingaHotel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                _SidebarItem(
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  onTap: () => context.go('/'),
                  isSelected: GoRouterState.of(context).uri.toString() == '/',
                ),
                _SidebarItem(
                  icon: Icons.people,
                  title: 'Huéspedes',
                  onTap: () => context.go('/guests'),
                  isSelected: GoRouterState.of(context).uri.toString() == '/guests',
                ),
                _SidebarItem(
                  icon: Icons.meeting_room,
                  title: 'Habitaciones',
                  onTap: () => context.go('/rooms'),
                  isSelected: GoRouterState.of(context).uri.toString() == '/rooms',
                ),
                _SidebarItem(
                  icon: Icons.book_online,
                  title: 'Reservas',
                  onTap: () => context.go('/reservations'),
                  isSelected: GoRouterState.of(context).uri.toString() == '/reservations',
                ),
                _SidebarItem(
                  icon: Icons.logout,
                  title: 'Check-out',
                  onTap: () => context.go('/checkout'),
                  isSelected: GoRouterState.of(context).uri.toString() == '/checkout',
                ),
              ],
            ),
          ),
          // Contenido principal
          Expanded(
            child: Container(
              color: AppTheme.backgroundLight,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isSelected;

  const _SidebarItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: AppTheme.primaryGold.withValues(alpha: 0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isSelected ? AppTheme.primaryGold : Colors.transparent,
                width: 4,
              ),
            ),
            color: isSelected ? Colors.white.withValues(alpha: 0.05) : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? AppTheme.primaryGold : Colors.white70,
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? AppTheme.primaryGold : Colors.white70,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
