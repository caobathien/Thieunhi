import 'package:flutter/material.dart';
import '../../services/token_service.dart';
import '../../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  final TokenService _tokenService = TokenService();

  late AnimationController _mainController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Tăng thời gian animation lên một chút cho mượt mà (1500ms)
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0, 0.5, curve: Curves.easeIn)),
    );

    // Dùng Curves.easeOutCubic để logo nảy lên mềm mại hơn thay vì giật mạnh
    _scaleAnimation = Tween<double>(begin: 0.6, end: 1).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic)),
    );

    _mainController.forward();
    _navigateToNext();
  }

  void _navigateToNext() async {
    // Thời gian chờ ở splash screen
    await Future.delayed(const Duration(milliseconds: 2500));
    final token = await _tokenService.getToken();
    if (!mounted) return;
    
    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Modern Logo Icon ──
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        blurRadius: 40,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1), 
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.church_rounded,
                        size: 44,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // ── App Branding ──
                Text(
                  "TNTT MANAGER",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDeep,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Phụng sự để yêu thương",
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                const SizedBox(height: 60),
                const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    strokeCap: StrokeCap.round,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}