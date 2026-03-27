import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/theme_controller.dart';
import '../../services/leader_profile_service.dart';
import '../../services/user_profile_service.dart';
import '../../services/spiritual_notification_service.dart';
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
        body: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
      );
    }

    final String rawRole = _profileData?['account_role'] ?? _profileData?['role'] ?? 'user';
    final bool isAdmin = rawRole.toLowerCase() == 'admin';
    final bool isUser = rawRole.toLowerCase() == 'user';
    final bool hasLeaderProfile = !isUser && _profileData?['id'] != null; 
    final String avatarUrl = _profileData?['avatar_url'] ?? '';
    final String accountName = _profileData?['account_full_name'] ?? _profileData?['full_name'] ?? '---';
    final String leaderFullName = _profileData?['full_name'] ?? '';
    final String christianName = _profileData?['christian_name'] ?? '';
    
    final String displayFullName = (!hasLeaderProfile) 
        ? accountName.trim()
        : "$christianName $leaderFullName".trim();

    final String displayRole = isAdmin 
        ? "Quản trị viên" 
        : (hasLeaderProfile 
            ? "${_profileData?['rank'] ?? 'Huynh trưởng'} • ${_profileData?['position'] ?? 'Giáo lý viên'}"
            : "Người dùng hệ thống");

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Navy Gradient Profile Header ──
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.only(top: 60, bottom: 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F2440), Color(0xFF1E3A5F)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  // ── Top Bar ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 48),
                        Text("Tài khoản", style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
                        IconButton(
                          icon: Icon(Icons.settings_outlined, color: Colors.white.withValues(alpha: 0.7)),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // ── Avatar with Gold Ring ──
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.6), width: 2.5),
                    ),
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                      child: avatarUrl.isEmpty 
                          ? Icon(Icons.person_outline, size: 40, color: Colors.white.withValues(alpha: 0.7)) 
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(displayFullName, style: AppTextStyles.titleLarge.copyWith(color: Colors.white)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(displayRole, style: AppTextStyles.caption.copyWith(color: AppColors.accent, fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 24),
                  // ── Quick Actions ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
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
                  ),
                ],
              ),
            ),
          ),

          // ── Body Sections ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
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
                  const SizedBox(height: 20),

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
                    const SizedBox(height: 20),
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
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(theme.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: AppColors.primary, size: 18),
                                ),
                                const SizedBox(width: 14),
                                Text("Chế độ tối", style: AppTextStyles.titleSmall.copyWith(fontSize: 14)),
                              ],
                            ),
                            Switch(
                              value: theme.isDarkMode,
                              onChanged: (_) => theme.toggleTheme(),
                              activeColor: AppColors.accent,
                              activeTrackColor: AppColors.accentLight,
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1, color: AppColors.divider),
                      ),
                      // ── Notification Toggle ──
                      FutureBuilder<bool>(
                        future: SpiritualNotificationService.isEnabled(),
                        builder: (context, snapshot) {
                          final isEnabled = snapshot.data ?? true;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentLight,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(Icons.menu_book_rounded, color: AppColors.accent, size: 18),
                                  ),
                                  const SizedBox(width: 14),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Lời Chúa hằng ngày", style: AppTextStyles.titleSmall.copyWith(fontSize: 14)),
                                      Text("Kinh sáng 5h • Lời Chúa 7h • Kinh tối 22h",  style: AppTextStyles.caption.copyWith(fontSize: 10, color: AppColors.textLight)),
                                    ],
                                  ),
                                ],
                              ),
                              Switch(
                                value: isEnabled,
                                onChanged: (val) async {
                                  await SpiritualNotificationService.setEnabled(val);
                                  setState(() {});
                                },
                                activeColor: AppColors.accent,
                                activeTrackColor: AppColors.accentLight,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (!isAdmin && hasLeaderProfile) ...[
                    _buildSection(
                      "Ghi chú & Thành tích",
                      [
                        _buildInfoTile(Icons.stars_outlined, "Khen thưởng", _profileData?['award_notes']),
                        _buildInfoTile(Icons.notes_rounded, "Ghi chú thêm", _profileData?['notes'], isLast: true),
                      ],
                    ),
                    const SizedBox(height: 28),
                  ],

                  // ── Logout Button ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton.icon(
                      onPressed: widget.onLogout,
                      icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                      label: const Text("Đăng xuất"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        textStyle: AppTextStyles.labelLarge.copyWith(
                          color: Colors.white,
                          inherit: true,
                        ),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
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
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Icon(icon, color: AppColors.accent, size: 22),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.caption.copyWith(color: Colors.white.withValues(alpha: 0.9), fontSize: 11)),
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
          child: Text(title, style: AppTextStyles.sectionHeader.copyWith(color: AppColors.textSecondary)),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textLight, fontSize: 11)),
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