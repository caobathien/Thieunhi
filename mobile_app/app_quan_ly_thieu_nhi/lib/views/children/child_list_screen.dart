import 'package:flutter/material.dart';
import '../../services/child_service.dart';
import '../../theme/app_theme.dart';
import 'child_form_screen.dart';
import 'child_detail_screen.dart';
import '../attendances/attendance_qr_screen.dart';

class ChildListScreen extends StatefulWidget {
  final String? userRole;
  final Map<String, dynamic>? userProfile;

  const ChildListScreen({super.key, this.userRole, this.userProfile});

  @override
  State<ChildListScreen> createState() => _ChildListScreenState();
}

class _ChildListScreenState extends State<ChildListScreen> {
  final ChildService _childService = ChildService();
  List<dynamic> _children = [];
  List<dynamic> _filteredChildren = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchChildren();
  }

  Future<void> _fetchChildren() async {
    setState(() => _isLoading = true);
    
    Map<String, dynamic> res;
    // Nếu là leader thường, chỉ lấy thiếu nhi trong lớp của mình
    if (widget.userRole == 'leader' && widget.userProfile != null) {
      final assignedId = widget.userProfile!['assigned_class_id'];
      if (assignedId != null) {
        res = await _childService.getChildrenByClass(assignedId.toString());
      } else {
        res = {"success": true, "data": []};
      }
    } else {
      res = await _childService.getAllChildren();
    }

    if (res['success']) {
      setState(() {
        _children = res['data'] ?? [];
        _filteredChildren = _children;
      });
    }
    setState(() => _isLoading = false);
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filteredChildren = _children.where((child) {
        final fullName = "${child['baptismal_name'] ?? ''} ${child['last_name'] ?? ''} ${child['first_name'] ?? ''}".toLowerCase();
        final maQr = (child['ma_qr'] ?? '').toString().toLowerCase();
        final q = query.toLowerCase();
        return fullName.contains(q) || maQr == q;
      }).toList();
    });
  }

  void _scanQRCode() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (c) => AttendanceQRScreen(
          onScan: (code) {
            setState(() {
              _searchController.text = code;
              _onSearchChanged(code);
            });
            
            // Nếu tìm thấy đúng 1 đứa, tự động mở chi tiết luôn
            if (_filteredChildren.length == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => ChildDetailScreen(
                  childData: _filteredChildren[0],
                  userRole: widget.userRole,
                  userProfile: widget.userProfile,
                )),
              );
            }
          },
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Hồ sơ Thiếu nhi"),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.titleMedium.copyWith(fontSize: 18, color: AppColors.textPrimary),
      ),
      body: Column(
        children: [
          // ── Search Bar ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: "Tìm kiếm tên thiếu nhi...",
                      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty 
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textLight),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged("");
                            },
                          )
                        : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary),
                    onPressed: () => _scanQRCode(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _filteredChildren.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_off_rounded, size: 52, color: AppColors.navInactive),
                            const SizedBox(height: 12),
                            const Text("Không tìm thấy thiếu nhi", style: TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredChildren.length,
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
                        itemBuilder: (context, index) {
                          final child = _filteredChildren[index];
                          final String fullName = "${child['baptismal_name'] ?? ''} ${child['last_name'] ?? ''} ${child['first_name'] ?? ''}".trim();
                          final String initial = child['first_name']?[0] ?? "?";

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Text(
                                    initial.toUpperCase(),
                                    style: AppTextStyles.titleLarge.copyWith(
                                      color: AppColors.primaryDeep,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(fullName, style: AppTextStyles.titleSmall.copyWith(fontSize: 16)),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceVariant,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        child['ma_qr'] ?? 'No ID',
                                        style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      child['sex'] == true ? "Nam" : "Nữ",
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ),
                              ),
                              trailing: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (c) => ChildDetailScreen(
                                      childData: child,
                                      userRole: widget.userRole,
                                      userProfile: widget.userProfile,
                                    )),
                                  ).then((_) => _fetchChildren()),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColors.border),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
                                  ),
                                ),
                              ),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (c) => ChildDetailScreen(
                                  childData: child,
                                  userRole: widget.userRole,
                                  userProfile: widget.userProfile,
                                )),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: (widget.userRole == 'admin' || widget.userRole == 'leader-vip' || (widget.userRole == 'leader' && widget.userProfile?['assigned_class_id'] != null)) 
        ? FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => const ChildFormScreen()),
            ).then((_) => _fetchChildren()),
            backgroundColor: AppColors.primary,
            elevation: 4,
            child: const Icon(Icons.add, color: Colors.white),
          )
        : null,
    );
  }
}