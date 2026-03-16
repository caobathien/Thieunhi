import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final result = await _authService.login(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['token'] != null || result['success'] == true) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Đăng nhập thất bại'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.softBlueGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Header / Logo ──
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.church_rounded, size: 32, color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Chào mừng trở lại",
                    style: AppTextStyles.displayLarge.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Đăng nhập để quản lý giáo xứ hiệu quả",
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // ── Login Card ──
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tên đăng nhập / Email / Số điện thoại",
                            style: AppTextStyles.labelLarge.copyWith(fontSize: 14, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _usernameController,
                            style: AppTextStyles.bodyLarge,
                            decoration: AppDecorations.inputDecoration(
                              label: "Tên đăng nhập, Email hoặc SĐT",
                              prefixIcon: Icons.alternate_email_rounded,
                            ).copyWith(
                              fillColor: AppColors.background,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            ),
                            validator: (v) => v == null || v.isEmpty ? "Vui lòng nhập tài khoản" : null,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Mật khẩu",
                            style: AppTextStyles.labelLarge.copyWith(fontSize: 14, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: AppTextStyles.bodyLarge,
                            decoration: AppDecorations.inputDecoration(
                              label: "Nhập mật khẩu",
                              prefixIcon: Icons.lock_outline_rounded,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  size: 20,
                                  color: AppColors.textLight,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ).copyWith(
                              fillColor: AppColors.background,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            ),
                            validator: (v) => v == null || v.isEmpty ? "Vui lòng nhập mật khẩu" : null,
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: Text(
                                "Quên mật khẩu?",
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryDeep, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Action Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                    )
                                  : Text(
                                      "ĐĂNG NHẬP",
                                      style: AppTextStyles.titleSmall.copyWith(color: Colors.white, letterSpacing: 1.0),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // ── Register Link ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Bạn chưa có tài khoản?", style: AppTextStyles.bodyMedium),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/register'),
                        child: Text(
                          "Đăng ký ngay",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primaryDeep,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}