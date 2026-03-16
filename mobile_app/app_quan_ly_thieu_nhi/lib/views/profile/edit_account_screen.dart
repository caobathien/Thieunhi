import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../../theme/app_theme.dart';

class EditAccountScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const EditAccountScreen({super.key, this.initialData});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();
  bool _isSaving = false;

  late TextEditingController _usernameController;
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _gmailController;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _usernameController = TextEditingController(text: d?['username'] ?? '');
    _fullNameController = TextEditingController(text: d?['full_name'] ?? d?['account_full_name'] ?? '');
    _phoneController = TextEditingController(text: d?['phone'] ?? d?['account_phone'] ?? '');
    _gmailController = TextEditingController(text: d?['gmail'] ?? d?['account_gmail'] ?? '');
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final Map<String, dynamic> data = {
      'username': _usernameController.text.trim(),
      'full_name': _fullNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'gmail': _gmailController.text.trim(),
    };

    // Note: Since this is "My Profile", we use updateProfile in UserService or similar.
    // However, the user specifically asked for "the one from users", so we might need a specific "updateMyAccount"
    // For now, let's assume updateMyProfile in the backend handles these fields if passed.
    // Wait, in users.ts controller, updateMyProfile calls UsersService.updateProfile which filters out 'username'.
    // I might need to update the backend to allow updating username/phone/email for the logged in user if they are owner.
    
    final res = await _userService.updateMyAccount(data);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cập nhật tài khoản thành công!")),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? "Lỗi cập nhật"), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Chỉnh sửa tài khoản"),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Thông tin đăng nhập & Liên hệ", style: AppTextStyles.sectionHeader),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppDecorations.card,
                child: Column(
                  children: [
                    _buildTextField(_usernameController, "Tên đăng nhập (Username)", Icons.person_outline),
                    const SizedBox(height: 20),
                    _buildTextField(_fullNameController, "Họ và tên đăng ký", Icons.badge_outlined),
                    const SizedBox(height: 20),
                    _buildTextField(_phoneController, "Số điện thoại", Icons.phone_android_rounded, keyboardType: TextInputType.phone),
                    const SizedBox(height: 20),
                    _buildTextField(_gmailController, "Email", Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  child: _isSaving
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text("LƯU THAY ĐỔI"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: AppDecorations.inputDecoration(label: label, prefixIcon: icon),
      validator: (v) => v == null || v.isEmpty ? "Vui lòng nhập $label" : null,
    );
  }
}
