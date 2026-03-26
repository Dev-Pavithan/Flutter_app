import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:universal_html/html.dart' as html;
import '../app_theme.dart';
import '../mock_data.dart';
import 'attendance_screen.dart';
import 'login_screen.dart';

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

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Logout'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', false);
              if (mounted) {
                Navigator.pop(context);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
              }
            },
            child: const Text('Logout', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard', style: AppTheme.darkTheme.textTheme.headlineMedium),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Hero(
            tag: 'app_logo',
            child: Icon(LucideIcons.school, color: AppTheme.primaryColor, size: 32),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, color: Colors.white70, size: 20),
            onPressed: () => html.window.location.reload(),
            tooltip: 'Refresh App',
          ),
          IconButton(
            icon: const Icon(LucideIcons.logOut, color: Colors.white70),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                
                // Greeting
                Text(
                  'Hello, Teacher 👋',
                  style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'Classes for today',
                  style: GoogleFonts.inter(fontSize: 16, color: Colors.white38),
                ),
                const SizedBox(height: 24),
                
                // Dashboard Stats
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryColor.withOpacity(0.4), AppTheme.backgroundColor],
                    ),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Total', mockClasses.length.toString()),
                      _buildStatItem('Active', '2'),
                      _buildStatItem('Avg %', '94%'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                Text(
                  'My Classrooms',
                  style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 16),
                
                Expanded(
                  child: ListView.separated(
                    itemCount: mockClasses.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final classItem = mockClasses[index];
                      return _buildClassCard(context, classItem, index);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.white54)),
      ],
    );
  }

  Widget _buildClassCard(BuildContext context, ClassRoom classItem, int index) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => AttendanceScreen(classRoom: classItem),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(animation),
                child: child,
              );
            },
          ),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(LucideIcons.layout, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(classItem.name, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('${classItem.students.length} Students • ${classItem.teacherName}', style: GoogleFonts.inter(fontSize: 13, color: Colors.white54)),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}
