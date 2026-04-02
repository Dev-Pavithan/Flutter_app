import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../app_theme.dart';
import 'attendance_screen.dart';
import 'class_list_screen.dart';
import 'history_screen.dart';
import 'summary_screen.dart';
import '../mock_data.dart';

class DashboardWrapper extends StatefulWidget {
  const DashboardWrapper({super.key});

  @override
  State<DashboardWrapper> createState() => _DashboardWrapperState();
}

class _DashboardWrapperState extends State<DashboardWrapper> {
  int _selectedIndex = 0; // Default to DASHBOARD
  
  final List<Widget> _screens = [
    const ClassListScreen(),
    AttendanceScreen(classRoom: mockClasses.last),
    const HistoryScreen(),
    const SummaryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        height: 100,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Flexible(
                child: _buildNavItem(0, LucideIcons.layoutGrid, 'DASHBOARD', isDark),
              ),
              Flexible(
                child: _buildNavItem(1, LucideIcons.users, 'STUDENTS', isDark),
              ),
              Flexible(
                child: _buildNavItem(2, LucideIcons.history, 'HISTORY', isDark),
              ),
              Flexible(
                child: _buildNavItem(3, LucideIcons.barChart3, 'SUMMARY', isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isDark) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        color: Colors.transparent, // Ensure hit testing works on the whole area
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: isSelected 
                ? BoxDecoration(
                    color: isDark ? AppTheme.darkAccent : AppTheme.lightAccent,
                    borderRadius: BorderRadius.circular(20),
                  )
                : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon, 
                    size: 20, 
                    color: isSelected 
                      ? (isDark ? Colors.black : Colors.white) 
                      : (isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary)
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label, 
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 9, 
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700, 
                      color: isSelected 
                        ? (isDark ? Colors.black : Colors.white) 
                        : (isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary)
                    )
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlaceholderWidget extends StatelessWidget {
  final String title;
  const PlaceholderWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(title, style: Theme.of(context).textTheme.displayLarge));
  }
}
