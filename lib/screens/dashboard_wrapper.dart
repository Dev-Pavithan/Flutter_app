import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../app_theme.dart';
import 'class_list_screen.dart';
import 'history_screen.dart';

class DashboardWrapper extends StatefulWidget {
  const DashboardWrapper({super.key});

  @override
  State<DashboardWrapper> createState() => _DashboardWrapperState();
}

class _DashboardWrapperState extends State<DashboardWrapper> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const ClassListScreen(),
    const HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) => setState(() => _selectedIndex = index),
            backgroundColor: AppTheme.surfaceColor,
            indicatorColor: AppTheme.primaryColor.withOpacity(0.2),
            destinations: const [
              NavigationDestination(
                icon: Icon(LucideIcons.layoutGrid, color: Colors.white38),
                selectedIcon: Icon(LucideIcons.layoutGrid, color: AppTheme.primaryColor),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(LucideIcons.history, color: Colors.white38),
                selectedIcon: Icon(LucideIcons.history, color: AppTheme.primaryColor),
                label: 'History',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
