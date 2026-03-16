import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../../theme/app_theme.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final UserService _userService = UserService();
  bool _isBusy = false;
  bool _obscureOld = true;
  bool _obscureNew = true;

  @override
  void dispose() {
    _oldPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isBusy = true);

    final res = await _userService.changePassword(
      _oldPassController.text,
      _newPassController.text,
    );

    if (mounted) {
      setState(() => _isBusy = false);
      if (res['success'] == true) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đổi mật khẩu thành công!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? "Thất bại"), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Đổi mật khẩu"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _oldPassController,
                obscureText: _obscureOld,
                decoration: AppDecorations.inputDecoration(
                  label: "Mật khẩu hiện tại",
                  prefixIcon: Icons.lock_outline_rounded,
                ).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_obscureOld ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                    onPressed: () => setState(() => _obscureOld = !_obscureOld),
                  ),
                ),
                validator: (v) => v == null || v.isEmpty ? "Cần nhập mật khẩu hiện tại" : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _newPassController,
                obscureText: _obscureNew,
                decoration: AppDecorations.inputDecoration(
                  label: "Mật khẩu mới",
                  prefixIcon: Icons.vpn_key_outlined,
                ).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
                validator: (v) => v != null && v.length < 6 ? "Mật khẩu tối thiểu 6 ký tự" : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _confirmPassController,
                obscureText: _obscureNew,
                decoration: AppDecorations.inputDecoration(
                  label: "Xác nhận mật khẩu mới",
                  prefixIcon: Icons.lock_reset_rounded,
                ),
                validator: (v) => v != _newPassController.text ? "Mật khẩu xác nhận không khớp" : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Hủy"),
        ),
        ElevatedButton(
          onPressed: _isBusy ? null : _handleUpdate,
          child: _isBusy
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text("CẬP NHẬT"),
        ),
      ],
    );
  }
}