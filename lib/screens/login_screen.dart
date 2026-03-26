import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../app_theme.dart';
import '../mock_data.dart';
import '../pwa_interop.dart';
import 'dashboard_wrapper.dart';

class LoginScreen extends StatefulWidget {
  final bool showInstallPrompt;

  const LoginScreen({super.key, this.showInstallPrompt = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Use the real PWA check from JS
    if (!isPWAInstalled()) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showInstallPopup());
    }
  }

  Future<void> _triggerPWAInstall() async {
    final result = await installPWA();
    if (result == true && mounted) {
      Navigator.pop(context); // Close popup
    }
  }

  void _showInstallPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        title: Row(
          children: const [
            Icon(LucideIcons.smartphone, color: AppTheme.primaryColor),
            SizedBox(width: 12),
            Text('Install App', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'For the full product experience and offline access, please install WSTSC Attendance.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _triggerPWAInstall,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                minimumSize: const Size.fromHeight(56),
              ),
              child: const Text('Install Now', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Maybe Later', style: TextStyle(color: Colors.white38)),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogin() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    
    if (_emailController.text == mockEmail && _passwordController.text == mockPassword) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const DashboardWrapper(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid credentials. Use $mockEmail / $mockPassword'), backgroundColor: AppTheme.errorColor, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20, color: AppTheme.primaryColor),
      labelStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.white.withOpacity(0.03),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
    );
  }

  void _showForgotPassword() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 32, top: 32, left: 24, right: 24),
        decoration: const BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            Text('Forgot Password?', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            TextField(decoration: _buildInputDecoration('Email Address', LucideIcons.mail), keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reset link sent!'), backgroundColor: AppTheme.successColor, behavior: SnackBarBehavior.floating));
              },
              child: const Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: 'app_logo',
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(LucideIcons.school, size: 64, color: AppTheme.primaryColor),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('WSTSC Attendance', style: AppTheme.darkTheme.textTheme.displayLarge?.copyWith(fontSize: 40)),
                    Text('WSTSC Student Management', style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(color: Colors.white54)),
                    const SizedBox(height: 48),
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(32), border: Border.all(color: Colors.white.withOpacity(0.1))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(controller: _emailController, decoration: _buildInputDecoration('Email Address', LucideIcons.mail), style: const TextStyle(color: Colors.white)),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(color: Colors.white),
                            decoration: _buildInputDecoration('Password', LucideIcons.lock).copyWith(
                              suffixIcon: IconButton(icon: Icon(_obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff, size: 20), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
                            ),
                          ),
                          Align(alignment: Alignment.centerRight, child: TextButton(onPressed: _showForgotPassword, child: Text('Forgot Password?', style: GoogleFonts.inter(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)))),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(60)),
                            child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Row(mainAxisAlignment: MainAxisAlignment.center, children: const [Text('Sign In'), SizedBox(width: 12), Icon(LucideIcons.arrowRight, size: 20)]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (!isPWAInstalled()) 
                      TextButton(onPressed: _showInstallPopup, child: const Text('Install App for Home Screen', style: TextStyle(color: AppTheme.primaryColor, decoration: TextDecoration.underline))),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() => Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppTheme.backgroundColor, Color(0xFF1E1B4B), AppTheme.backgroundColor])));
}
