import 'package:flutter/material.dart';
import '../../services/leader_profile_service.dart';
import '../../services/user_service.dart';
import '../../theme/app_theme.dart';
import '../../models/leader_profile_model.dart';

class AdminLeaderEditScreen extends StatefulWidget {
  final LeaderProfile leader;

  const AdminLeaderEditScreen({super.key, required this.leader});

  @override
  State<AdminLeaderEditScreen> createState() => _AdminLeaderEditScreenState();
}

class _AdminLeaderEditScreenState extends State<AdminLeaderEditScreen> {
  final LeaderProfileService _profileService = LeaderProfileService();
  final UserService _userService = UserService();

  late TextEditingController _rankController;
  late TextEditingController _positionController;
  late TextEditingController _awardNotesController;
  late TextEditingController _notesController;

  bool _isSaving = false;
  late String _selectedRole;

  @override
  void initState() {
    super.initState();
    _rankController = TextEditingController(text: widget.leader.rank);
    _positionController = TextEditingController(text: widget.leader.position);
    _awardNotesController = TextEditingController(text: widget.leader.awardNotes);
    _notesController = TextEditingController(text: widget.leader.notes);
    _selectedRole = widget.leader.accountRole?.toLowerCase() ?? 'leader';
  }

  @override
  void dispose() {
    _rankController.dispose();
    _positionController.dispose();
    _awardNotesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    
    final updateData = {
      'rank': _rankController.text.trim(),
      'position': _positionController.text.trim(),
      'award_notes': _awardNotesController.text.trim(),
      'notes': _notesController.text.trim(),
    };

    final res = await _profileService.adminUpdateProfile(widget.leader.userId, updateData);
    
    // Update role if changed
    if (_selectedRole != widget.leader.accountRole?.toLowerCase()) {
      await _userService.updateUserRole(widget.leader.userId, _selectedRole);
    }

    if (mounted) {
      setState(() => _isSaving = false);
      if (res['success']) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cập nhật thành công")));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? "Lỗi cập nhật")));
      }
    }
  }

  void _showResetPasswordDialog() {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Thiết lập lại mật khẩu"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Nhập mật khẩu mới cho tài khoản này:"),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: AppDecorations.inputDecoration(label: "Mật khẩu mới", prefixIcon: Icons.lock_outline),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              if (passwordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mật khẩu phải ít nhất 6 ký tự")));
                return;
              }
              final res = await _userService.adminResetPassword(widget.leader.userId, passwordController.text.trim());
              if (!context.mounted) return;
              if (res['success']) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã đổi mật khẩu thành công")));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? "Lỗi")));
              }
            },
            child: const Text("Xác nhận"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final leader = widget.leader;
    final String avatarUrl = leader.avatarUrl ?? '';
    final String displayName = (leader.fullName != null && leader.fullName!.isNotEmpty)
        ? "${leader.christianName} ${leader.fullName}"
        : leader.christianName;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Quản lý Huynh Trưởng"),
        actions: [
          if (_isSaving)
            const Center(child: Padding(padding: EdgeInsets.only(right: 16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))))
          else
            TextButton(
              onPressed: _saveChanges,
              child: const Text("LƯU", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDeep)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: AppDecorations.card,
              child: Row(
                children: [
                   CircleAvatar(
                    radius: 35,
                    backgroundColor: AppColors.primaryLight,
                    backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl.isEmpty ? const Icon(Icons.person, size: 30, color: AppColors.primary) : null,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(displayName, style: AppTextStyles.titleMedium),
                        const SizedBox(height: 4),
                        Text("@${leader.username ?? 'No username'}", style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Administrative Actions
            _buildSection(
              "Thông tin hành chính",
              [
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: AppDecorations.inputDecoration(label: "Vai trò hiện tại", prefixIcon: Icons.admin_panel_settings_outlined),
                  items: const [
                    DropdownMenuItem(value: "admin", child: Text("Quản trị viên")),
                    DropdownMenuItem(value: "leader-vip", child: Text("Huynh trưởng cấp cao")),
                    DropdownMenuItem(value: "leader", child: Text("Huynh trưởng")),
                    DropdownMenuItem(value: "teacher", child: Text("Giáo lý viên")),
                    DropdownMenuItem(value: "user", child: Text("Thành viên")),
                  ],
                  onChanged: (v) => setState(() => _selectedRole = v!),
                ),
                const SizedBox(height: 16),
                _buildTextField(Icons.military_tech_outlined, "Cấp bậc", _rankController),
                const SizedBox(height: 16),
                _buildTextField(Icons.work_outline_rounded, "Chức vụ", _positionController),
                const SizedBox(height: 16),
                _buildTextField(Icons.stars_outlined, "Khen thưởng", _awardNotesController, maxLines: 3),
                const SizedBox(height: 16),
                _buildTextField(Icons.notes_rounded, "Ghi chú thêm", _notesController, maxLines: 3),
              ],
            ),
            const SizedBox(height: 24),

            // Account Security
            _buildSection(
              "Bảo mật tài khoản",
              [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.lock_reset_rounded, color: AppColors.primary),
                  title: const Text("Thiết lập lại mật khẩu", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text("Đặt mật khẩu mới cho tài khoản này", style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: _showResetPasswordDialog,
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(title, style: AppTextStyles.sectionHeader),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppDecorations.card,
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildTextField(IconData icon, String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: AppDecorations.inputDecoration(
        label: label,
        prefixIcon: icon,
      ),
      style: AppTextStyles.bodyMedium,
    );
  }
}
