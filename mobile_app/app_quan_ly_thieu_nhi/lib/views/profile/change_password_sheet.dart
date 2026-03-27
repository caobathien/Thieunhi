import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../../theme/app_theme.dart';

class ChangePasswordSheet extends StatefulWidget {
  const ChangePasswordSheet({super.key});

  @override
  State<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _isObscure = true;
  bool _isSaving = false;

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    final res = await _userService.changePassword(
      _oldPassController.text.trim(),
      _newPassController.text.trim(),
    );
    
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đổi mật khẩu thành công!")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? "Lỗi: Không thể đổi mật khẩu"),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24, right: 24, top: 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Đổi mật khẩu", style: AppTextStyles.titleMedium),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Mật khẩu mới phải bao gồm các ký tự bảo mật để bảo vệ tài khoản.",
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 24),
            _buildPasswordField(_oldPassController, "Mật khẩu hiện tại"),
            const SizedBox(height: 16),
            _buildPasswordField(_newPassController, "Mật khẩu mới"),
            const SizedBox(height: 16),
            _buildPasswordField(_confirmPassController, "Xác nhận mật khẩu mới", isConfirm: true),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _handleUpdate,
                child: _isSaving 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text("CẬP NHẬT MẬT KHẨU"),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label, {bool isConfirm = false}) {
    return TextFormField(
      controller: controller,
      obscureText: _isObscure,
      decoration: AppDecorations.inputDecoration(
        label: label,
        prefixIcon: Icons.lock_outline_rounded,
        suffixIcon: IconButton(
          icon: Icon(
            _isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.textLight,
            size: 20,
          ),
          onPressed: () => setState(() => _isObscure = !_isObscure),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return "Vui lòng nhập mật khẩu";
        if (isConfirm && v != _newPassController.text) return "Mật khẩu không khớp";
        return null;
      },
    );
  }
}