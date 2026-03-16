import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/theme_controller.dart';
import '../../services/leader_profile_service.dart';
import '../../services/user_profile_service.dart';
import '../../theme/app_theme.dart';
import 'edit_profile_screen.dart';
import 'edit_account_screen.dart';
import 'change_password_sheet.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? userProfile;
  final VoidCallback? onLogout;

  const ProfileScreen({super.key, this.userProfile, this.onLogout});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final LeaderProfileService _leaderService = LeaderProfileService();
  final UserProfileService _userProfileService = UserProfileService();
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.userProfile != null) {
      _profileData = widget.userProfile;
      _isLoading = false;
    }
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    if (_profileData == null) {
      setState(() => _isLoading = true);
    }
    
    // Kiểm tra role từ widget hoặc cached data nếu có
    final String role = widget.userProfile?['role'] ?? widget.userProfile?['account_role'] ?? 'user';
    final bool isUserOnly = role.toLowerCase() == 'user';

    final res = isUserOnly 
        ? await _userProfileService.getMyProfile()
        : await _leaderService.getMyProfile();

    if (res['success'] == true) {
      if (mounted) {
        setState(() {
          _profileData = res['data'];
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    final String rawRole = _profileData?['account_role'] ?? _profileData?['role'] ?? 'user';
    final bool isAdmin = rawRole.toLowerCase() == 'admin';
    final bool isUser = rawRole.toLowerCase() == 'user';
    
    // hasLeaderProfile chỉ true nếu là leader/admin và có dữ liệu ID từ bảng leaders_profile
    final bool hasLeaderProfile = !isUser && _profileData?['id'] != null; 
    final String avatarUrl = _profileData?['avatar_url'] ?? '';
    
    // Logic hiển thị tên:
    // Nếu là admin: ưu tiên lấy từ bảng users (account_full_name)
    // Nếu là leader: lấy Christian Name + Full Name (LP)
    final String accountName = _profileData?['account_full_name'] ?? _profileData?['full_name'] ?? '---';
    final String leaderFullName = _profileData?['full_name'] ?? '';
    final String christianName = _profileData?['christian_name'] ?? '';
    
    final String displayFullName = (!hasLeaderProfile) 
        ? accountName.trim()
        : "$christianName $leaderFullName".trim();

    if (displayFullName.isEmpty || displayFullName == '---') {
        // Fallback cuối cùng nếu mọi thứ đều trống
    }
    
    final String displayRole = isAdmin 
        ? "Quản trị viên" 
        : (hasLeaderProfile 
            ? "${_profileData?['rank'] ?? 'Huynh trưởng'} • ${_profileData?['position'] ?? 'Giáo lý viên'}"
            : "Người dùng hệ thống");

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Tài khoản"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {}, // Future settings
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // ── Profile Header Card ──
            Container(
              padding: const EdgeInsets.all(24),
              decoration: AppDecorations.card,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withAlpha(50), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primaryLight,
                      backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                      child: avatarUrl.isEmpty ? Icon(Icons.person_outline, size: 40, color: AppColors.primary) : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(displayFullName, style: AppTextStyles.titleLarge),
                  const SizedBox(height: 6),
                  Text(displayRole, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (hasLeaderProfile) ...[
                        _buildQuickAction(
                          icon: Icons.badge_outlined,
                          label: "Hồ sơ",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => EditProfileScreen(initialData: _profileData)),
                            ).then((value) {
                              if (value == true) _fetchProfile();
                            });
                          },
                        ),
                        const SizedBox(width: 24),
                      ],
                      _buildQuickAction(
                        icon: Icons.manage_accounts_outlined,
                        label: "Tài khoản",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => EditAccountScreen(initialData: _profileData)),
                          ).then((value) {
                            if (value == true) _fetchProfile();
                          });
                        },
                      ),
                      const SizedBox(width: 24),
                      _buildQuickAction(
                        icon: Icons.lock_reset_rounded,
                        label: "Mật khẩu",
                        onTap: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const ChangePasswordSheet(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Account Sections ──
            _buildSection(
              "Tài khoản hệ thống",
              [
                _buildInfoTile(Icons.person_pin_rounded, "Họ và tên đăng ký", _profileData?['account_full_name'] ?? _profileData?['full_name']),
                _buildInfoTile(Icons.alternate_email_rounded, "Tên đăng nhập", _profileData?['username']),
                _buildInfoTile(Icons.phone_outlined, "Số điện thoại đăng ký", _profileData?['account_phone'] ?? _profileData?['phone']),
                _buildInfoTile(Icons.email_outlined, "Email tài khoản", _profileData?['account_gmail'] ?? _profileData?['gmail']),
                _buildInfoTile(Icons.calendar_month_rounded, "Ngày tham gia", _profileData?['account_created_at'] ?? _profileData?['created_at'], isLast: true),
              ],
            ),
            const SizedBox(height: 24),

            if (!isAdmin && hasLeaderProfile) ...[
              _buildSection(
                "Thông tin Huynh trưởng",
                [
                  _buildInfoTile(Icons.church_outlined, "Tên Thánh", _profileData?['christian_name']),
                  _buildInfoTile(Icons.military_tech_outlined, "Cấp bậc", _profileData?['rank']),
                  _buildInfoTile(Icons.work_outline_rounded, "Chức vụ", _profileData?['position']),
                  _buildInfoTile(Icons.cake_outlined, "Ngày sinh", _profileData?['dob']),
                  _buildInfoTile(Icons.calendar_today_outlined, "Ngày nhận việc", _profileData?['join_date'], isLast: true),
                ],
              ),
              const SizedBox(height: 24),
            ],

            _buildSection(
              "Cài đặt & Giao diện",
              [
                Consumer<ThemeController>(
                  builder: (context, theme, _) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(theme.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: AppColors.primary),
                          const SizedBox(width: 16),
                          Text("Chế độ tối", style: AppTextStyles.titleSmall.copyWith(fontSize: 14)),
                        ],
                      ),
                      Switch(
                        value: theme.isDarkMode,
                        onChanged: (_) => theme.toggleTheme(),
                        activeThumbColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (!isAdmin && hasLeaderProfile) ...[
              _buildSection(
                "Ghi chú & Thành tích",
                [
                  _buildInfoTile(Icons.stars_outlined, "Khen thưởng", _profileData?['award_notes']),
                  _buildInfoTile(Icons.notes_rounded, "Ghi chú thêm", _profileData?['notes'], isLast: true),
                ],
              ),
              const SizedBox(height: 32),
            ],

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ElevatedButton.icon(
                onPressed: widget.onLogout,
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                label: const Text("Đăng xuất"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  textStyle: AppTextStyles.labelLarge.copyWith(
                    color: Colors.white,
                    inherit: true, // Đảm bảo đồng nhất thuộc tính inherit để tránh lỗi interpolation khi đổi theme
                  ),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.labelLarge.copyWith(fontSize: 12)),
        ],
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

  Widget _buildInfoTile(IconData icon, String label, String? value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: AppColors.textLight, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value ?? "Chưa cập nhật", style: AppTextStyles.titleSmall.copyWith(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}