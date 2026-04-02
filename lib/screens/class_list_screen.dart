import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:universal_html/html.dart' as html;
import '../app_theme.dart';
import '../mock_data.dart';
import 'attendance_screen.dart';
import 'login_screen.dart';
import '../widgets/custom_app_bar.dart';

class ClassListScreen extends StatefulWidget {
  const ClassListScreen({super.key});

  @override
  State<ClassListScreen> createState() => _ClassListScreenState();
}

class _ClassListScreenState extends State<ClassListScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                
                // Greeting
                Text(
                  'Hello, Teacher 👋',
                  style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                ),
                Text(
                  'Classes for today',
                  style: GoogleFonts.inter(fontSize: 16, color: isDark ? Colors.white38 : Colors.black45),
                ),
                const SizedBox(height: 24),
                
                // Dashboard Stats
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        (isDark ? AppTheme.darkAccent : AppTheme.lightAccent).withOpacity(0.4), 
                        isDark ? AppTheme.darkBg : Colors.white,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: (isDark ? AppTheme.darkAccent : AppTheme.lightAccent).withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Total Students', '38', isDark),
                      _buildStatItem('Active Class', '1', isDark),
                      _buildStatItem('Avg %', '94%', isDark),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),

                // Quick Actions section
                Text(
                  'Quick Actions',
                  style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                ),
                const SizedBox(height: 16),
                
                _buildActionCard(
                  'Record Attendance',
                  'Start marking students for today',
                  LucideIcons.userCheck,
                  isDark ? AppTheme.darkAccent : AppTheme.lightAccent,
                  isDark,
                  () {
                    // Navigate to students tab or attendance
                  },
                ),
                const SizedBox(height: 16),
                _buildActionCard(
                  'View History',
                  'Check past records and trends',
                  LucideIcons.calendar,
                  const Color(0xFF8B5CF6),
                  isDark,
                  () {
                    // Navigate to history tab
                  },
                ),
                const SizedBox(height: 16),
                _buildActionCard(
                  'Class Summary',
                  'Detailed performance analytics',
                  LucideIcons.barChart3,
                  const Color(0xFFF59E0B),
                  isDark,
                  () {
                    // Navigate to summary tab
                  },
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: isDark ? Colors.white54 : Colors.black45)),
      ],
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, Color color, bool isDark, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: isDark ? null : Border.all(color: Colors.grey.shade100),
          boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: isDark ? Colors.white38 : Colors.black45)),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, color: isDark ? Colors.white24 : Colors.grey.shade300, size: 20),
          ],
        ),
      ),
    );
  }
}
