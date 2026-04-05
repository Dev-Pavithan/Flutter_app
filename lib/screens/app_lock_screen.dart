import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../app_theme.dart';
import '../services/biometric_service.dart';

class AppLockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;
  const AppLockScreen({super.key, required this.onUnlocked});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    // Auto-authenticate on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleAuth();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (_isAuthenticating) return;
    
    setState(() => _isAuthenticating = true);
    final authenticated = await BiometricService.authenticate();
    setState(() => _isAuthenticating = false);

    if (mounted && authenticated) {
      widget.onUnlocked();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        color: (isDark ? AppTheme.darkBg : AppTheme.lightBg).withOpacity(0.85),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Glowing Animated Fingerprint Icon
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.darkAccent.withOpacity(0.2 * _controller.value),
                          blurRadius: 40,
                          spreadRadius: 10 * _controller.value,
                        )
                      ],
                      border: Border.all(
                        color: AppTheme.darkAccent.withOpacity(0.1 + (0.3 * _controller.value)),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      LucideIcons.fingerprint,
                      size: 72,
                      color: AppTheme.darkAccent.withOpacity(0.5 + (0.5 * _controller.value)),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 48),
              
              Text(
                'WSTSC Locked',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Use biometrics to securely unlock your app',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
              
              const SizedBox(height: 64),
              
              // Secondary Unlock Button
              ElevatedButton.icon(
                onPressed: _handleAuth,
                icon: Icon(LucideIcons.shieldCheck, size: 20, color: isDark ? AppTheme.darkBg : Colors.white),
                label: Text(_isAuthenticating ? 'Authenticating...' : 'Unlock Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.darkAccent,
                  foregroundColor: isDark ? AppTheme.darkBg : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 10,
                  shadowColor: AppTheme.darkAccent.withOpacity(0.4),
                ),
              ),

              const SizedBox(height: 24),
              // PIN Fallback Option
              TextButton(
                onPressed: _handleAuth, // local_auth provides PIN fallback automatically if configured
                child: Text(
                  'Use Screen Lock PIN',
                  style: GoogleFonts.inter(
                    color: AppTheme.darkAccent.withOpacity(0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
