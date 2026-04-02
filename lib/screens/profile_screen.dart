import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_theme.dart';
import '../main.dart';
import '../widgets/custom_app_bar.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _biometricsEnabled = true;

  void _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Header Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: isDark ? null : Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: (isDark ? AppTheme.darkAccent : AppTheme.lightAccent).withOpacity(0.3), width: 2),
                        ),
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage('https://i.pravatar.cc/300?u=teacher'),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkAccent : AppTheme.lightAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.camera, size: 16, color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Mr. John Anderson', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('anderson.j@wstsc.edu.au', style: GoogleFonts.inter(color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.darkSuccess.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('Senior Teacher', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.darkSuccess)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Settings Sections
            _buildSectionHeader('Appearance'),
            _buildSettingTile(
              'Dark Mode',
              'Adjust the app color theme',
              LucideIcons.moon,
              trailing: Switch(
                value: isDark,
                activeColor: AppTheme.darkAccent,
                onChanged: (val) async {
                  final prefs = await SharedPreferences.getInstance();
                  themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                  await prefs.setBool('isDarkMode', val);
                },
              ),
            ),

            const SizedBox(height: 24),
            _buildSectionHeader('Security'),
            _buildSettingTile(
              'Biometric Login',
              'Use FaceID or TouchID',
              LucideIcons.fingerprint,
              trailing: Switch(
                value: _biometricsEnabled,
                activeColor: AppTheme.darkAccent,
                onChanged: (val) => setState(() => _biometricsEnabled = val),
              ),
            ),
            _buildSettingTile(
              'Change Passcode',
              'Update your numeric PIN',
              LucideIcons.lock,
              onTap: () {},
            ),

            const SizedBox(height: 24),
            _buildSectionHeader('Notifications'),
            _buildSettingTile(
              'Push Notifications',
              'Stay updated with class alerts',
              LucideIcons.bell,
              trailing: Switch(
                value: _notificationsEnabled,
                activeColor: AppTheme.darkAccent,
                onChanged: (val) => setState(() => _notificationsEnabled = val),
              ),
            ),

            const SizedBox(height: 32),

            // Logout Button
            ElevatedButton(
              onPressed: _handleLogout,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.red.withOpacity(0.1) : Colors.red.shade50,
                foregroundColor: Colors.redAccent,
                minimumSize: const Size.fromHeight(60),
                elevation: 0,
                side: BorderSide(color: Colors.redAccent.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(LucideIcons.logOut, size: 20),
                  SizedBox(width: 12),
                  Text('Logout Account', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
        ),
      ),
    );
  }

  Widget _buildSettingTile(String title, String subtitle, IconData icon, {Widget? trailing, VoidCallback? onTap}) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? null : Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (isDark ? AppTheme.darkAccent : AppTheme.lightAccent).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: isDark ? AppTheme.darkAccent : AppTheme.lightAccent, size: 20),
        ),
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary)),
        trailing: trailing ?? const Icon(LucideIcons.chevronRight, size: 18, color: Colors.white24),
      ),
    );
  }
}
