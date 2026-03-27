import 'package:flutter/material.dart';
import '../../services/leader_profile_service.dart';
import '../../theme/app_theme.dart';

class AddLeaderScreen extends StatefulWidget {
  const AddLeaderScreen({super.key});

  @override
  State<AddLeaderScreen> createState() => _AddLeaderScreenState();
}

class _AddLeaderScreenState extends State<AddLeaderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _leaderService = LeaderProfileService();
  bool _isLoading = false;

  Future<void> _createLeader() async {
    if (_phoneController.text.trim().isEmpty && _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập ít nhất Số điện thoại hoặc Email")),
      );
      return;
    }

    setState(() => _isLoading = true);
    final res = await _leaderService.createLeader(
      _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      final tempPassword = res['data']['tempPassword'];
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("Tạo Huynh Trưởng thành công"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Tài khoản đã được tạo."),
              const SizedBox(height: 8),
              Text("Mật khẩu tạm thời: $tempPassword", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              const SizedBox(height: 8),
              const Text("Hãy cung cấp mật khẩu này cho Huynh Trưởng để đăng nhập."),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, true); // Return to list
              },
              child: const Text("ĐỒNG Ý"),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? "Lỗi tạo Huynh Trưởng"), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thêm Huynh Trưởng"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Thông tin đăng ký",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Admin chỉ cần nhập Số điện thoại hoặc Email. Các thông tin khác Huynh Trưởng sẽ tự cập nhật sau khi đăng nhập.",
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: AppDecorations.card,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _phoneController,
                      decoration: AppDecorations.inputDecoration(
                        label: "Số điện thoại",
                        prefixIcon: Icons.phone_android_rounded,
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 24),
                    const Text("HOẶC", style: TextStyle(color: AppColors.textHint, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      decoration: AppDecorations.inputDecoration(
                        label: "Gmail / Email",
                        prefixIcon: Icons.email_outlined,
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createLeader,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("TẠO HUYNH TRƯỞNG"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
