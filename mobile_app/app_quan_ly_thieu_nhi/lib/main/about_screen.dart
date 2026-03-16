import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../theme/app_theme.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) => setState(() => _packageInfo = info));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ──
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF9F7AEA), Color(0xFFB794F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withAlpha(50), width: 2.5),
                        ),
                        child: const Center(
                          child: Icon(Icons.church_rounded, size: 44, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "TNTT Manager",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Phiên bản ${_packageInfo?.version ?? '1.0.0'}",
                          style: TextStyle(
                            color: Colors.white.withAlpha(200),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Content ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // ── About ──
                  _buildCard(
                    icon: Icons.info_outline_rounded,
                    title: "Giới thiệu",
                    body: "Ứng dụng quản lý Xứ đoàn Thiếu Nhi Thánh Thể giúp các Huynh trưởng quản lý dữ liệu em thiếu nhi, điểm danh, quản lý lớp học và đánh giá kết quả học tập một cách hiệu quả.",
                  ),
                  const SizedBox(height: 14),

                  // ── Features ──
                  _buildFeatureCard(),
                  const SizedBox(height: 14),

                  // ── Contact ──
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppDecorations.card,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "LIÊN HỆ & HỖ TRỢ",
                          style: AppTextStyles.sectionHeader.copyWith(color: AppColors.primary),
                        ),
                        const SizedBox(height: 16),
                        _contactRow(Icons.email_rounded, "Email", "support@tntt.app"),
                        const Divider(height: 20, color: AppColors.divider),
                        _contactRow(Icons.language_rounded, "Website", "www.tntt.app"),
                        const Divider(height: 20, color: AppColors.divider),
                        _contactRow(Icons.phone_android, "Hotline", "0123 456 789"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Legal ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: AppDecorations.cardSubtle,
                    child: Column(
                      children: [
                        const Text(
                          "Được phát triển với ❤️ cho cộng đồng TNTT",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "© 2025 TNTT Manager. All rights reserved.",
                          style: AppTextStyles.caption,
                          textAlign: TextAlign.center,
                        ),
                      ],
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

  Widget _buildCard({required IconData icon, required String title, required String body}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 14),
              Text(title, style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: 14),
          Text(body, style: AppTextStyles.bodyMedium.copyWith(height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildFeatureCard() {
    final features = [
      {"icon": Icons.child_care_rounded, "title": "Quản lý Thiếu nhi", "desc": "Hồ sơ, QR code, phân lớp"},
      {"icon": Icons.qr_code_scanner_rounded, "title": "Điểm danh thông minh", "desc": "QR & thủ công"},
      {"icon": Icons.assessment_rounded, "title": "Báo cáo & Tổng kết", "desc": "Thống kê, xuất Excel"},
      {"icon": Icons.people_rounded, "title": "Phân công HT", "desc": "Quản lý huynh trưởng"},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TÍNH NĂNG NỔI BẬT",
            style: AppTextStyles.sectionHeader.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(f['icon'] as IconData, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f['title'] as String, style: AppTextStyles.titleSmall.copyWith(fontSize: 14)),
                      Text(f['desc'] as String, style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String label, String value) {
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                Text(value, style: AppTextStyles.titleSmall.copyWith(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}