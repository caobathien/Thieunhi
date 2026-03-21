import 'package:flutter/material.dart';
import '../../models/leader_profile_model.dart';
import '../../services/leader_profile_service.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';

class LeaderProfileScreen extends StatefulWidget {
  final String userId;
  final bool isOwnProfile;

  const LeaderProfileScreen({
    super.key,
    required this.userId,
    this.isOwnProfile = false,
  });

  @override
  State<LeaderProfileScreen> createState() => _LeaderProfileScreenState();
}

class _LeaderProfileScreenState extends State<LeaderProfileScreen> {
  final _leaderService = LeaderProfileService();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploading = false;
  LeaderProfile? _profile;

  late TextEditingController _christianNameController;
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _gmailController;
  late TextEditingController _notesController;
  late TextEditingController _usernameController;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final res = await _leaderService.getProfile(widget.userId);
    if (!mounted) return;

    if (res['success'] == true) {
      final profile = LeaderProfile.fromJson(res['data']);
      setState(() {
        _profile = profile;
        _christianNameController = TextEditingController(text: profile.christianName);
        _fullNameController = TextEditingController(text: profile.fullName);
        _phoneController = TextEditingController(text: profile.phone);
        _gmailController = TextEditingController(text: profile.gmail);
        _notesController = TextEditingController(text: profile.notes);
        _usernameController = TextEditingController(text: profile.username);
        _avatarUrl = profile.avatarUrl;
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? "Lỗi tải hồ sơ")),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _isUploading = true);
      final url = await ApiConfig.uploadImage(image);
      if (mounted) {
        setState(() {
          if (url != null) _avatarUrl = url;
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    final data = {
      'christian_name': _christianNameController.text.trim(),
      'full_name': _fullNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'gmail': _gmailController.text.trim(),
      'notes': _notesController.text.trim(),
      'username': _usernameController.text.trim(),
      'avatar_url': _avatarUrl,
    };

    final res = await _leaderService.updateMyProfile(data);
    
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cập nhật hồ sơ thành công")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? "Lỗi cập nhật")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_profile == null) {
      return const Scaffold(body: Center(child: Text("Không tìm thấy hồ sơ")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hồ sơ Huynh Trưởng"),
        actions: widget.isOwnProfile ? [
          IconButton(
            onPressed: _isSaving ? null : _saveProfile,
            icon: _isSaving 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.check_rounded),
          )
        ] : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildPersonalSection(),
              const SizedBox(height: 24),
              _buildSystemSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.primaryLight,
            backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
            child: _avatarUrl == null 
              ? const Icon(Icons.person, size: 60, color: AppColors.primary)
              : null,
          ),
          if (widget.isOwnProfile)
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _isUploading ? null : _pickAvatar,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: _isUploading 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPersonalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Thông tin cá nhân", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppDecorations.card,
          child: Column(
            children: [
              _buildTextField(_christianNameController, "Tên Thánh", Icons.church_outlined, enabled: widget.isOwnProfile),
              const SizedBox(height: 16),
              _buildTextField(_fullNameController, "Họ và tên", Icons.person_outline, enabled: widget.isOwnProfile),
              const SizedBox(height: 16),
              _buildTextField(_phoneController, "Số điện thoại", Icons.phone_android, enabled: widget.isOwnProfile),
              const SizedBox(height: 16),
              _buildTextField(_gmailController, "Email", Icons.email_outlined, enabled: widget.isOwnProfile),
              const SizedBox(height: 16),
              _buildTextField(_usernameController, "Tên tài khoản (Username)", Icons.alternate_email_rounded, enabled: widget.isOwnProfile),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSystemSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Thông tin hệ thống", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppDecorations.card.copyWith(color: AppColors.background),
          child: Column(
            children: [
              _buildInfoRow("Cấp bậc", _profile!.rank),
              const Divider(height: 24),
              _buildInfoRow("Chức vụ", _profile!.position),
              const Divider(height: 24),
              _buildInfoRow("Trạng thái", _profile!.status),
              if (widget.isOwnProfile) ...[
                const Divider(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.lock_reset_rounded, color: AppColors.primary),
                    title: const Text("Đổi mật khẩu", style: TextStyle(fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.pushNamed(context, '/change-password'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool enabled = true}) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: AppDecorations.inputDecoration(label: label, prefixIcon: icon),
      validator: (v) => v!.isEmpty ? "Vui lòng nhập $label" : null,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
