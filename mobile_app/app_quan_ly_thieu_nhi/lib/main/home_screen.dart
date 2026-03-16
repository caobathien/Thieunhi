import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/activity_list_screen.dart';
// Import các màn hình cho grid category
import '../views/term/term_summary_screen.dart';
import '../views/feedback/admin_feedback_list_screen.dart';
import '../views/feedback/feedback_submit_screen.dart';
import '../views/user/user_management_screen.dart';
import '../views/assignment/class_assignment_screen.dart';
import '../views/classes/class_list_screen.dart';
import '../views/children/child_list_screen.dart';
import '../views/attendances/attendance_selection_screen.dart';
import '../services/leader_profile_service.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? userProfile;
  final String? userRole;

  const HomeScreen({super.key, this.userProfile, this.userRole});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LeaderProfileService _leaderService = LeaderProfileService();
  final TextEditingController _searchController = TextEditingController();
  late Future<Map<String, dynamic>> _leadersFuture;

  @override
  void initState() {
    super.initState();
    _leadersFuture = _leaderService.getAllLeaders();
  }

  @override
  Widget build(BuildContext context) {
    // Kiểm tra phân quyền RBAC
    final bool isSuperAdmin = widget.userRole == 'admin';
    final bool isManagement = widget.userRole == 'admin' || widget.userRole == 'leader-vip';
    final bool isLeader = widget.userRole == 'leader';
    final bool hasAssignedClass = widget.userProfile?['assigned_class_id'] != null;
    final bool canAccessMgmt = isManagement || (isLeader && hasAssignedClass);

    final List<Map<String, dynamic>> categories = [
      {'icon': Icons.auto_graph_outlined, 'title': 'Kết quả học tập', 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (c) => const TermSummaryScreen()))},
      {'icon': Icons.campaign_outlined, 'title': 'Hoạt động', 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ActivityListScreen()))},
      {'icon': Icons.forum_outlined, 'title': 'Phản hồi', 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (c) => isManagement ? const AdminFeedbackListScreen() : const FeedbackSubmitScreen()))},
      // HIỂN THỊ PHÂN CÔNG CHO ADMIN VÀ LEADER-VIP
      if (isManagement) {'icon': Icons.assignment_ind_outlined, 'title': 'Phân công', 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ClassAssignmentScreen()))},
      // CHỈ ADMIN MỚI CÓ QUYỀN QUẢN LÝ TÀI KHOẢN
      if (isSuperAdmin) {'icon': Icons.group_outlined, 'title': 'Quản lý tài khoản', 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (c) => const UserManagementScreen()))},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          setState(() {
            _leadersFuture = _leaderService.getAllLeaders();
          });
          await _leadersFuture;
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header với background màu xanh, lời chào, tên user, avatar, notification ──
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
                decoration: BoxDecoration(
                  color: AppColors.primary, // Màu xanh tươi sáng giống ảnh
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24), // Bo góc mềm mại
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // PHẢI THAY THẾ BẰNG ẢNH THỰC TẾ CỦA USER
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.primaryLight,
                                child: Text(
                                  (widget.userProfile?['full_name']?[0] ?? "H").toUpperCase(),
                                  style: AppTextStyles.labelLarge.copyWith(color: AppColors.primaryDeep, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_getGreeting(), style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
                                Text(widget.userProfile?['full_name'] ?? widget.userProfile?['account_full_name'] ?? "Thành viên", style: AppTextStyles.titleMedium.copyWith(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Thanh tìm kiếm modern
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: AppTextStyles.bodyMedium,
                        decoration: InputDecoration(
                          hintText: "Tìm kiếm (huynh trưởng, sự kiện, v.v.)",
                          hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
                          border: InputBorder.none,
                          icon: const Icon(Icons.search, color: AppColors.textHint, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Grid Categories (phân quyền) ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Chức năng chính", style: AppTextStyles.sectionHeader),
                        TextButton(
                          onPressed: () {}, // Mở màn hình tất cả categories
                          child: Text("Tất cả", style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // 3 cột giống ảnh
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.85, // Tỷ lệ card modern
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        return _buildCategoryCard(
                          icon: categories[index]['icon'],
                          title: categories[index]['title'],
                          onTap: categories[index]['onTap'],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ── Title section: "Trưởng/Phó Huynh Trưởng" ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text("Trưởng/Phó Huynh Trưởng", style: AppTextStyles.sectionHeader),
              ),
            ),

            // ── Danh sách Trưởng/Phó Huynh Trưởng ──
            FutureBuilder<Map<String, dynamic>>(
              future: _leadersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                  );
                }
                
                final List leaders = snapshot.data?['data'] ?? [];
                if (leaders.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(child: Text("Chưa có danh sách nhân sự", style: AppTextStyles.bodyMedium)),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _buildLeaderCard(context, leaders[index]);
                      },
                      childCount: leaders.length,
                    ),
                  ),
                );
              },
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  // Helper function to build a modern category card
  Widget _buildCategoryCard({required IconData icon, required String title, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primaryDeep, size: 24),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  title,
                  style: AppTextStyles.labelLarge.copyWith(fontSize: 12, color: AppColors.textPrimary, height: 1.3),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build a modern leader card
  Widget _buildLeaderCard(BuildContext context, Map<String, dynamic> leader) {
    final String fullName = leader['full_name'] ?? leader['account_full_name'] ?? 'Huynh Trưởng';
    final String christianName = leader['christian_name'] ?? '';
    final String displayName = christianName.isNotEmpty ? "$christianName $fullName" : fullName;
    final String? avatarUrl = leader['avatar_url'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showLeaderDetail(context, leader),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                    image: (avatarUrl != null && avatarUrl.isNotEmpty)
                        ? DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover)
                        : null,
                  ),
                  child: (avatarUrl == null || avatarUrl.isEmpty)
                      ? Center(child: Text(fullName[0].toUpperCase(), style: AppTextStyles.titleMedium.copyWith(color: AppColors.primaryDeep)))
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayName, style: AppTextStyles.titleSmall.copyWith(fontSize: 16, color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(leader['position'] ?? leader['rank'] ?? 'Trưởng', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          leader['status'] ?? 'Đang công tác',
                          style: AppTextStyles.caption.copyWith(color: AppColors.primaryDeep, fontWeight: FontWeight.bold, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textLight),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLeaderDetail(BuildContext context, Map<String, dynamic> leader) {
    final String fullName = leader['full_name'] ?? leader['account_full_name'] ?? 'Huynh Trưởng';
    final String christianName = leader['christian_name'] ?? '';
    final String displayName = christianName.isNotEmpty ? "$christianName $fullName" : fullName;
    final String? avatarUrl = leader['avatar_url'];
    final String? phone = leader['phone'] ?? leader['account_phone'];
    final String? email = leader['gmail'] ?? leader['account_gmail'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              // Profile Header
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primaryLight,
                backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) ? NetworkImage(avatarUrl) : null,
                child: (avatarUrl == null || avatarUrl.isEmpty)
                    ? Text(fullName[0].toUpperCase(), style: AppTextStyles.displayLarge.copyWith(color: AppColors.primaryDeep))
                    : null,
              ),
              const SizedBox(height: 16),
              Text(displayName, style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
              Text(leader['position'] ?? 'Huynh Trưởng', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 32),
              // Contact Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildContactButton(
                        icon: Icons.phone_rounded,
                        label: "Gọi điện",
                        color: const Color(0xFF4CAF50),
                        onTap: () => _launchURL('tel:$phone'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildContactButton(
                        icon: Icons.email_rounded,
                        label: "Gửi Email",
                        color: AppColors.primary,
                        onTap: () => _launchURL('mailto:$email'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Info Sections
              _buildDetailItem(Icons.workspace_premium_outlined, "Cấp bậc", leader['rank'] ?? 'Dự trưởng'),
              _buildDetailItem(Icons.info_outline_rounded, "Trạng thái", leader['status'] ?? 'Đang công tác'),
              if (phone != null) _buildDetailItem(Icons.phone_iphone_rounded, "Số điện thoại", phone),
              if (email != null) _buildDetailItem(Icons.alternate_email_rounded, "Gmail", email),
              const SizedBox(height: 24), // Bottom padding for scroll
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.primaryDeep, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
              Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Chào buổi sáng,";
    if (hour < 18) return "Chào buổi chiều,";
    return "Chào buổi tối,";
  }
}