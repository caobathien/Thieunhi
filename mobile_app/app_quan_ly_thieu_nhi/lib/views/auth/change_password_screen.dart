import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    final res = await _authService.changePassword(
      _oldPasswordController.text,
      _newPasswordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        ChipsErrorSnackBar(
          message: "Đổi mật khẩu thành công!",
          isSuccess: true,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        ChipsErrorSnackBar(
          message: res['message'] ?? "Lỗi đổi mật khẩu",
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đổi mật khẩu"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Để bảo mật, vui lòng nhập mật khẩu hiện tại cùng với mật khẩu mới bạn muốn đổi.",
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              
              _buildPasswordField(
                controller: _oldPasswordController,
                label: "Mật khẩu hiện tại",
                obscure: _obscureOld,
                onToggle: () => setState(() => _obscureOld = !_obscureOld),
                validator: (v) => v!.isEmpty ? "Vui lòng nhập mật khẩu cũ" : null,
              ),
              const SizedBox(height: 20),
              
              _buildPasswordField(
                controller: _newPasswordController,
                label: "Mật khẩu mới",
                obscure: _obscureNew,
                onToggle: () => setState(() => _obscureNew = !_obscureNew),
                validator: (v) {
                  if (v!.isEmpty) return "Vui lòng nhập mật khẩu mới";
                  if (v.length < 6) return "Mật khẩu phải từ 6 ký tự";
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              _buildPasswordField(
                controller: _confirmPasswordController,
                label: "Xác nhận mật khẩu mới",
                obscure: _obscureConfirm,
                onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (v) {
                  if (v != _newPasswordController.text) return "Mật khẩu xác nhận không khớp";
                  return null;
                },
              ),
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleChangePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Text("CẬP NHẬT MẬT KHẨU", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          decoration: AppDecorations.inputDecoration(
            label: "Nhập $label",
            prefixIcon: Icons.lock_outline,
          ).copyWith(
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
              onPressed: onToggle,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}

class ChipsErrorSnackBar extends SnackBar {
  final String message;
  final bool isSuccess;

  ChipsErrorSnackBar({
    super.key,
    required this.message,
    this.isSuccess = false,
  }) : super(
          content: Text(message),
          backgroundColor: isSuccess ? Colors.green : AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        );
}
