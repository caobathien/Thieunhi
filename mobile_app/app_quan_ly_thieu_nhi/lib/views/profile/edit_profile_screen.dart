import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/leader_profile_service.dart';
import '../../services/user_profile_service.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const EditProfileScreen({super.key, this.initialData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final LeaderProfileService _leaderService = LeaderProfileService();
  final UserProfileService _userService = UserProfileService();
  bool _isSaving = false;

  late TextEditingController _christianNameController;
  late TextEditingController _fullNameController;
  late TextEditingController _dobController;
  late TextEditingController _genderController;
  late TextEditingController _addressController;
  late TextEditingController _bioController;
  String? _avatarUrl;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _christianNameController = TextEditingController(text: d?['christian_name'] ?? '');
    _fullNameController = TextEditingController(text: d?['full_name'] ?? d?['account_full_name'] ?? '');
    _dobController = TextEditingController(text: d?['dob'] ?? '');
    _genderController = TextEditingController(text: d?['gender'] ?? '');
    _addressController = TextEditingController(text: d?['address'] ?? '');
    _bioController = TextEditingController(text: d?['bio'] ?? '');
    _avatarUrl = d?['avatar_url'] ?? '';
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final String rawRole = widget.initialData?['role'] ?? widget.initialData?['account_role'] ?? 'user';
    final bool isUserOnly = rawRole.toLowerCase() == 'user';

    final Map<String, dynamic> data = {
      'christian_name': _christianNameController.text.trim(),
      'avatar_url': _avatarUrl?.trim() ?? '',
    };

    if (isUserOnly) {
      data.addAll({
        'dob': _dobController.text.trim(),
        'gender': _genderController.text.trim(),
        'address': _addressController.text.trim(),
        'bio': _bioController.text.trim(),
      });
    } else {
      data['full_name'] = _fullNameController.text.trim();
    }

    final res = isUserOnly 
        ? await _userService.updateMyProfile(data)
        : await _leaderService.upsertProfile(data);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cập nhật hồ sơ thành công!")),
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
    final String rawRole = widget.initialData?['role'] ?? widget.initialData?['account_role'] ?? 'user';
    final bool isAdmin = rawRole.toLowerCase() == 'admin';
    final bool isUserOnly = rawRole.toLowerCase() == 'user';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Chỉnh sửa hồ sơ"),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Avatar Upload Section ──
              Center(
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary.withAlpha(50), width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.primaryLight,
                        backgroundImage: _avatarUrl != null && _avatarUrl!.isNotEmpty ? NetworkImage(_avatarUrl!) : null,
                        child: _avatarUrl == null || _avatarUrl!.isEmpty
                            ? Icon(Icons.person_outline, size: 48, color: AppColors.primary)
                            : null,
                      ),
                    ),
                    if (_isUploadingImage)
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                        ),
                      ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: InkWell(
                        onTap: _isUploadingImage ? null : _pickAvatar,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [BoxShadow(color: Colors.black.withAlpha(50), blurRadius: 4, offset: const Offset(0, 2))],
                          ),
                          child: const Icon(Icons.camera_alt_rounded, size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Basic Info Section ──
              Text("Thông tin cá nhân", style: AppTextStyles.sectionHeader),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppDecorations.card,
                child: Column(
                  children: [
                    if (!isUserOnly) ...[
                      _buildTextField(_christianNameController, "Tên Thánh", Icons.church_outlined),
                      const SizedBox(height: 20),
                    ],
                    if (!isUserOnly) ...[
                      _buildTextField(_fullNameController, "Họ và tên", Icons.person_outline),
                    ],
                    if (isUserOnly) ...[
                      _buildTextField(_dobController, "Ngày sinh (VD: 2000-01-01)", Icons.cake_outlined),
                      const SizedBox(height: 20),
                      _buildTextField(_genderController, "Giới tính", Icons.wc_outlined),
                      const SizedBox(height: 20),
                      _buildTextField(_addressController, "Địa chỉ", Icons.home_outlined),
                      const SizedBox(height: 20),
                      _buildTextField(_bioController, "Giới thiệu", Icons.info_outline, maxLines: 3),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Protected Info ──
              if (!isAdmin && !isUserOnly) ...[
                Text("Thông tin hệ thống", style: AppTextStyles.sectionHeader),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppDecorations.card.copyWith(color: AppColors.primaryLight.withAlpha(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          const Text("Thông tin chỉ đọc", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.primary)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildReadOnlyItem("Cấp bậc", widget.initialData?['rank']),
                      const SizedBox(height: 12),
                      _buildReadOnlyItem("Chức vụ", widget.initialData?['position']),
                      const SizedBox(height: 12),
                      _buildReadOnlyItem("Ngày tham gia", widget.initialData?['join_date']),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  child: _isSaving
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text("CẬP NHẬT HỒ SƠ"),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAvatar() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _isUploadingImage = true);
      final uploadedUrl = await ApiConfig.uploadImage(image.path);
      if (uploadedUrl != null) {
        setState(() => _avatarUrl = uploadedUrl);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Tải ảnh thất bại! Vui lòng thử lại.")),
          );
        }
      }
      setState(() => _isUploadingImage = false);
    }
  }

  Widget _buildReadOnlyItem(String label, String? value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textLight)),
        Text(value ?? "---", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: AppDecorations.inputDecoration(label: label, prefixIcon: icon),
      validator: (v) => v == null || v.isEmpty ? "Vui lòng nhập $label" : null,
    );
  }
}