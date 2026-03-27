import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../../theme/app_theme.dart';
import 'change_password_dialog.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _EditUserScreenState extends State<UserManagementScreen> {
  final UserService _userService = UserService();
  List<dynamic> _users = [];
  String _searchQuery = "";
  String _filterRole = "all"; // all, Admin, Leader, Teacher
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    // Chỉ hiện loading xoay ở giữa màn hình nếu danh sách đang rỗng (lần đầu load)
    if (_users.isEmpty) {
      if (mounted) setState(() => _isLoading = true);
    }

    final res = await _userService.getAllUsers();
    if (res['success'] == true) {
      if (mounted) setState(() => _users = res['data'] ?? []);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  List<dynamic> get _filteredUsers {
    return _users.where((u) {
      final fullName = u['full_name']?.toString().toLowerCase() ?? "";
      final email = u['email']?.toString().toLowerCase() ?? "";
      final matchesSearch = fullName.contains(_searchQuery.toLowerCase()) ||
          email.contains(_searchQuery.toLowerCase());
      final matchesRole = _filterRole == "all" || u['role']?.toString().toLowerCase() == _filterRole.toLowerCase();
      return matchesSearch && matchesRole;
    }).toList();
  }

  // ── Sửa thông tin ──
  void _showEditUserDialog(dynamic user) {
    final TextEditingController usernameController = TextEditingController(text: user['username']);
    final TextEditingController fullNameController = TextEditingController(text: user['full_name']);
    final TextEditingController phoneController = TextEditingController(text: user['phone']);
    final TextEditingController gmailController = TextEditingController(text: user['gmail']);
    String selectedRole = user['role'] ?? "Teacher";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text("Chỉnh sửa tài khoản", style: AppTextStyles.titleMedium),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: AppDecorations.inputDecoration(label: "Tên tài khoản", prefixIcon: Icons.person_outline),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: fullNameController,
                  decoration: AppDecorations.inputDecoration(label: "Họ và tên", prefixIcon: Icons.badge_outlined),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: AppDecorations.inputDecoration(label: "Số điện thoại", prefixIcon: Icons.phone_outlined),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: gmailController,
                  decoration: AppDecorations.inputDecoration(label: "Email", prefixIcon: Icons.email_outlined),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole.toLowerCase(),
                  decoration: AppDecorations.inputDecoration(label: "Vai trò", prefixIcon: Icons.admin_panel_settings_outlined),
                  items: const [
                    DropdownMenuItem(value: "admin", child: Text("Quản trị viên")),
                    DropdownMenuItem(value: "leader-vip", child: Text("Huynh trưởng cấp cao")),
                    DropdownMenuItem(value: "leader", child: Text("Huynh trưởng")),
                    DropdownMenuItem(value: "teacher", child: Text("Giáo lý viên")),
                    DropdownMenuItem(value: "user", child: Text("Thành viên")),
                  ],
                  onChanged: (v) => setDialogState(() => selectedRole = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
            ElevatedButton(
              onPressed: () async {
                final Map<String, dynamic> updateData = {
                  'username': usernameController.text.trim(),
                  'full_name': fullNameController.text.trim(),
                  'phone': phoneController.text.trim(),
                  'gmail': gmailController.text.trim(),
                  'role': selectedRole,
                };

                final res = await _userService.adminUpdateUser(user['id'].toString(), updateData);
                if (!context.mounted) return;
                Navigator.pop(context);
                if (res['success'] == true) {
                  _fetchUsers();
                  _showSnackbar("Đã cập nhật thông tin thành công!", AppColors.success);
                } else {
                  _showSnackbar(res['message'] ?? "Lỗi cập nhật", AppColors.error);
                }
              },
              child: const Text("Lưu thay đổi"),
            ),
          ],
        ),
      ),
    );
  }

  // ── Phân quyền ──
  void _showRoleDialog(dynamic user) {
    String selectedRole = user['role'] ?? "Teacher";
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text("Phân quyền người dùng", style: AppTextStyles.titleMedium),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user['full_name'], style: AppTextStyles.bodyMedium),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedRole.toLowerCase(),
                decoration: AppDecorations.inputDecoration(label: "Vai trò", prefixIcon: Icons.admin_panel_settings_outlined),
                items: const [
                  DropdownMenuItem(value: "admin", child: Text("Quản trị viên")),
                  DropdownMenuItem(value: "leader-vip", child: Text("Huynh trưởng cấp cao")),
                  DropdownMenuItem(value: "leader", child: Text("Huynh trưởng")),
                  DropdownMenuItem(value: "teacher", child: Text("Giáo lý viên")),
                  DropdownMenuItem(value: "user", child: Text("Thành viên")),
                ],
                onChanged: (v) => setDialogState(() => selectedRole = v!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
            ElevatedButton(
              onPressed: () async {
                final res = await _userService.updateUserRole(user['id'].toString(), selectedRole);
                if (!context.mounted) return;
                Navigator.pop(context);
                if (res['success'] == true) {
                  _fetchUsers();
                  _showSnackbar("Đã cập nhật quyền thành công!", AppColors.success);
                }
              },
              child: const Text("Cập nhật"),
            ),
          ],
        ),
      ),
    );
  }

  // ── Khóa/mở khóa ──
  Future<void> _toggleStatus(dynamic user) async {
    final bool currentActive = user['is_active'] != false;
    final res = await _userService.toggleUserStatus(user['id'].toString(), !currentActive);
    if (res['success'] == true) {
      _fetchUsers();
      _showSnackbar(
        currentActive ? "Đã khóa tài khoản thành công" : "Đã mở khóa tài khoản thành công",
        currentActive ? AppColors.warning : AppColors.success,
      );
    }
  }

  // ── Xóa ──
  void _confirmDelete(dynamic user) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Xác nhận xóa tài khoản"),
        content: Text("Bạn có chắc chắn muốn xóa tài khoản ${user['full_name']}? Thao tác này không thể hoàn tác."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(c);
              final res = await _userService.deleteUser(user['id'].toString());
              if (res['success'] == true) {
                _fetchUsers();
                _showSnackbar("Đã xóa tài khoản vĩnh viễn", AppColors.success);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text("Xóa vĩnh viễn", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSnackbar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Color _getRoleBadgeColor(String? role) {
    if (role == null) return AppColors.textLight;
    switch (role.toLowerCase()) {
      case 'admin': return AppColors.error;
      case 'leader-vip': return Colors.purple;
      case 'leader': return AppColors.primary;
      case 'teacher': return AppColors.secondary;
      default: return AppColors.textLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = _filteredUsers;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Quản trị Người dùng"),
      ),
      body: Column(
        children: [
          // ── Search + Filter ──
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  decoration: AppDecorations.inputDecoration(
                    label: "Tìm theo tên hoặc email",
                    prefixIcon: Icons.search_rounded,
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildRoleFilterChip("Tất cả", "all"),
                      const SizedBox(width: 8),
                      _buildRoleFilterChip("Admin", "admin"),
                      const SizedBox(width: 8),
                      _buildRoleFilterChip("HT Cấp Cao", "leader-vip"),
                      const SizedBox(width: 8),
                      _buildRoleFilterChip("Huynh trưởng", "leader"),
                      const SizedBox(width: 8),
                      _buildRoleFilterChip("Giáo lý viên", "teacher"),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── List ──
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : users.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_off_rounded, size: 48, color: AppColors.textLight.withAlpha(100)),
                            const SizedBox(height: 16),
                            Text("Không tìm thấy kết quả", style: AppTextStyles.bodyMedium),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchUsers,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(24),
                          itemCount: users.length,
                          separatorBuilder: (c, i) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final user = users[index];
                            final bool isLocked = user['is_active'] == false;
                            final roleColor = _getRoleBadgeColor(user['role']);

                            return Container(
                              decoration: AppDecorations.card,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                leading: CircleAvatar(
                                  backgroundColor: roleColor.withAlpha(30),
                                  child: Text(
                                    (user['full_name']?[0] ?? "U").toUpperCase(),
                                    style: TextStyle(color: roleColor, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(child: Text(user['full_name'] ?? "User", style: AppTextStyles.titleSmall)),
                                    if (isLocked)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: AppColors.error.withAlpha(20), borderRadius: BorderRadius.circular(4)),
                                        child: const Text("Khóa", style: TextStyle(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ),
                                  ],
                                ),
                                subtitle: Text(user['email'] ?? "---", style: AppTextStyles.bodySmall),
                                trailing: PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert_rounded),
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(children: [Icon(Icons.edit_outlined, size: 20), SizedBox(width: 12), Text("Sửa thông tin")]),
                                    ),
                                    const PopupMenuItem(
                                      value: 'role',
                                      child: Row(children: [Icon(Icons.admin_panel_settings_outlined, size: 20), SizedBox(width: 12), Text("Phân quyền")]),
                                    ),
                                    const PopupMenuItem(
                                      value: 'password',
                                      child: Row(children: [Icon(Icons.lock_reset_rounded, size: 20), SizedBox(width: 12), Text("Đặt lại mật khẩu")]),
                                    ),
                                    PopupMenuItem(
                                      value: 'lock',
                                      child: Row(children: [Icon(isLocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded, size: 20), SizedBox(width: 12), Text(isLocked ? "Mở khóa" : "Khóa tài khoản")]),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(children: [Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20), SizedBox(width: 12), Text("Xóa tài khoản", style: TextStyle(color: AppColors.error))]),
                                    ),
                                  ],
                                  onSelected: (val) {
                                    if (val == 'edit') _showEditUserDialog(user);
                                    if (val == 'role') _showRoleDialog(user);
                                    if (val == 'password') showDialog(context: context, builder: (_) => const ChangePasswordDialog());
                                    if (val == 'lock') _toggleStatus(user);
                                    if (val == 'delete') _confirmDelete(user);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleFilterChip(String label, String role) {
    final bool isActive = _filterRole == role;
    return GestureDetector(
      onTap: () => setState(() => _filterRole = role),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.primaryLight.withAlpha(30),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _UserManagementScreenState extends _EditUserScreenState {}