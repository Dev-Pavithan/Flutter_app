import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_theme.dart';
import '../main.dart';
import '../screens/dashboard_wrapper.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? subtitle;
  final bool showLogo;

  const CustomAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.showLogo = true,
  });

  void _showNotifications(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Notifications', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.x)),
              ],
            ),
            const SizedBox(height: 16),
            _buildNotificationItem(context, 'Attendance Sheet Ready', 'Period 4 attendance is ready to be recorded.', LucideIcons.fileText, isDark),
            _buildNotificationItem(context, 'Monthly Report', 'Your monthly summary for September is available.', LucideIcons.pieChart, isDark),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, String title, String sub, IconData icon, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: isDark ? AppTheme.darkAccent : AppTheme.lightAccent),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(sub, style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileFlow(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=teacher'),
            ),
            const SizedBox(height: 16),
            Text('Mr. John Anderson', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
            Text('Senior Mathematics Teacher', style: GoogleFonts.inter(color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary)),
            const SizedBox(height: 32),
            _buildProfileOption(context, LucideIcons.user, 'My Profile', isDark),
            _buildProfileOption(context, LucideIcons.settings, 'Settings', isDark),
            _buildProfileOption(context, LucideIcons.logOut, 'Logout', isDark, isLast: true, color: Colors.redAccent),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(BuildContext context, IconData icon, String label, bool isDark, {bool isLast = false, Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? (isDark ? Colors.white70 : Colors.black87)),
      title: Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: color)),
      onTap: () async {
        if (label == 'My Profile') {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
        } else if (isLast && label == 'Logout') {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', false);
          if (context.mounted) {
            Navigator.pop(context);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          }
        } else {
          Navigator.pop(context);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      leadingWidth: 140,
      leading: showLogo
          ? Padding(
              padding: const EdgeInsets.only(left: 20),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const DashboardWrapper()),
                    (route) => false,
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkAccent.withOpacity(0.1) : AppTheme.lightAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(LucideIcons.wind, color: isDark ? AppTheme.darkAccent : AppTheme.lightAccent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'WSTSC',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.darkAccent : AppTheme.lightAccent,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
      title: title != null 
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title!, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
              if (subtitle != null)
                Text(subtitle!, style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary)),
            ],
          )
        : null,
      actions: [
        IconButton(
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            themeNotifier.value = themeNotifier.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
            await prefs.setBool('isDarkMode', themeNotifier.value == ThemeMode.dark);
          },
          icon: Icon(themeNotifier.value == ThemeMode.dark ? LucideIcons.moon : LucideIcons.sun, size: 20),
        ),
        IconButton(
          onPressed: () => _showNotifications(context),
          icon: const Icon(LucideIcons.bell, size: 20),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 20, left: 8),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: (isDark ? AppTheme.darkAccent : AppTheme.lightAccent).withOpacity(0.2), width: 2),
              ),
              child: const CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=teacher'),
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
