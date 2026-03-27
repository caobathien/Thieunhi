import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'child_qr_view.dart';
import 'child_form_screen.dart';
import '../../services/token_service.dart';

class ChildDetailScreen extends StatefulWidget {
  final Map<String, dynamic> childData;
  final String? userRole;
  final Map<String, dynamic>? userProfile;

  const ChildDetailScreen({
    super.key, 
    required this.childData,
    this.userRole,
    this.userProfile,
  });

  @override
  State<ChildDetailScreen> createState() => _ChildDetailScreenState();
}

class _ChildDetailScreenState extends State<ChildDetailScreen> {
  final TokenService _tokenService = TokenService();
  String _userRole = 'user';

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    if (widget.userRole != null) {
      setState(() => _userRole = widget.userRole!.toLowerCase());
      return;
    }
    final role = await _tokenService.getUserRole();
    if (mounted) {
      setState(() => _userRole = role?.toLowerCase() ?? 'user');
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "---";
    try {
      DateTime dt = DateTime.parse(dateStr);
      return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String fullName = "${widget.childData['baptismal_name'] ?? ''} ${widget.childData['last_name'] ?? ''} ${widget.childData['first_name'] ?? ''}".trim();
    
    // logic phân quyền sửa: admin, leader-vip, hoặc leader được phân công lớp đó
    bool canEdit = _userRole == 'admin' || _userRole == 'leader-vip';
    if (_userRole == 'leader' && widget.userProfile != null) {
      final assignedId = widget.userProfile!['assigned_class_id'];
      final childClassId = widget.childData['class_id'];
      if (assignedId != null && childClassId != null && assignedId.toString() == childClassId.toString()) {
        canEdit = true;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Hồ sơ Thiếu nhi"),
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => ChildFormScreen(childData: widget.childData)),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Profile Overview Card ──
            Container(
              padding: const EdgeInsets.all(24),
              decoration: AppDecorations.card,
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: widget.childData['avatar_url'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.network(widget.childData['avatar_url'], fit: BoxFit.cover),
                          )
                        : Icon(Icons.person_outline, size: 48, color: AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(fullName, style: AppTextStyles.titleLarge),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.childData['status']?.toString().toUpperCase() ?? 'ACTIVE',
                      style: AppTextStyles.labelLarge.copyWith(color: AppColors.success, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── QR Quick Action ──
            InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => ChildQRView(childData: widget.childData))),
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: AppDecorations.card,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.qr_code_2_rounded, color: AppColors.secondary, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Thẻ điểm danh", style: AppTextStyles.titleSmall),
                          Text("Xem và tải mã QR định danh", style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textLight),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Information Sections ──
            _buildSection(
              "Thông tin cá nhân",
              [
                _buildInfoTile("Giới tính", (widget.childData['gender'] == "true" || widget.childData['gender'] == true) ? "Nam" : "Nữ"),
                _buildInfoTile("Ngày sinh", _formatDate(widget.childData['birth_date'])),
                _buildInfoTile("Hộ khẩu", widget.childData['address'] ?? "N/A", isLast: true),
              ],
            ),
            const SizedBox(height: 24),

            _buildSection(
              "Thông tin gia đình",
              [
                _buildInfoTile("Họ tên Cha", "${widget.childData['ten_thanh_bo'] ?? ''} ${widget.childData['ho_va_ten_bo'] ?? '---'}".trim()),
                _buildInfoTile("SĐT Cha", widget.childData['sdt_bo'] ?? "---"),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1, color: AppColors.border),
                ),
                _buildInfoTile("Họ tên Mẹ", "${widget.childData['ten_thanh_me'] ?? ''} ${widget.childData['ho_va_ten_me'] ?? '---'}".trim()),
                _buildInfoTile("SĐT Mẹ", widget.childData['sdt_me'] ?? "---", isLast: true),
              ],
            ),
            const SizedBox(height: 32),
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

  Widget _buildInfoTile(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight)),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.titleSmall.copyWith(fontSize: 14),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}