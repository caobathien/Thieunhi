import 'package:flutter/material.dart';
import '../../services/class_service.dart';
import '../../theme/app_theme.dart';
import 'class_detail_screen.dart';
import 'class_form_screen.dart';

class ClassListScreen extends StatefulWidget {
  final String? userRole;
  final Map<String, dynamic>? userProfile;

  const ClassListScreen({super.key, this.userRole, this.userProfile});

  @override
  State<ClassListScreen> createState() => _ClassListScreenState();
}

class _ClassListScreenState extends State<ClassListScreen> {
  final ClassService _classService = ClassService();
  List<dynamic> _classes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  @override
  void didUpdateWidget(covariant ClassListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userProfile != oldWidget.userProfile || widget.userRole != oldWidget.userRole) {
      _fetchClasses();
    }
  }

  Future<void> _fetchClasses() async {
    setState(() => _isLoading = true);
    final result = await _classService.getAllClasses();
    if (result['success'] == true) {
      List<dynamic> allClass = result['data'] ?? [];
      
      // Nếu là Leader thường, chỉ hiện lớp được phân công
      if (widget.userRole == 'leader' && widget.userProfile != null) {
        final assignedId = widget.userProfile!['assigned_class_id'];
        if (assignedId != null) {
          allClass = allClass.where((c) => c['id'] == assignedId).toList();
        } else {
          allClass = []; // Chưa phân lớp thì không thấy gì
        }
      }
      
      setState(() => _classes = allClass);
    }
    setState(() => _isLoading = false);
  }

  void _confirmDelete(int id, String className) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Xóa lớp học", style: AppTextStyles.titleMedium),
        content: Text("Dữ liệu về lớp '$className' sẽ bị xóa vĩnh viễn?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("HỦY", style: AppTextStyles.labelLarge.copyWith(color: AppColors.textLight)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              final navigator = Navigator.of(context);
              await _classService.deleteClass(id);
              navigator.pop();
              _fetchClasses();
            },
            child: const Text("XÓA"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Quản lý Lớp học"),
        actions: [
          if (widget.userRole == 'admin' || widget.userRole == 'leader-vip')
            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const ClassFormScreen()),
              ).then((_) => _fetchClasses()),
              icon: const Icon(Icons.add_rounded),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : _classes.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _classes.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = _classes[index];
                    final String name = item['class_name'] ?? "Lớp học";
                    final int current = item['student_count'] ?? 0;
                    final int total = item['total_capacity'] ?? 40;
                    final double ratio = total > 0 ? current / total : 0;

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ClassDetailScreen(classId: item['id'], className: name),
                            ),
                          ),
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Text(
                                      name.isNotEmpty ? name[0].toUpperCase() : "?",
                                      style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontSize: 24),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              name,
                                              style: AppTextStyles.titleMedium,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (widget.userRole == 'admin' || widget.userRole == 'leader-vip')
                                            _buildPopupMenu(item, name),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.meeting_room_outlined, size: 14, color: AppColors.textSecondary),
                                          const SizedBox(width: 4),
                                          Text(
                                            "Phòng: ${item['room_number'] ?? 'N/A'}",
                                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                                          ),
                                          const SizedBox(width: 12),
                                          const Icon(Icons.calendar_month_outlined, size: 14, color: AppColors.textSecondary),
                                          const SizedBox(width: 4),
                                          Text(
                                            item['academic_year'] ?? 'N/A',
                                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                                          ),
                                        ],
                                      ),
                                      if (item['leader_name'] != null) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.person_outline, size: 14, color: AppColors.primary),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                "${item['leader_name']} ${item['leader_phone'] != null ? '(${item['leader_phone']})' : ''}",
                                                style: AppTextStyles.bodyMedium.copyWith(
                                                  color: AppColors.primaryDeep,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(6),
                                              child: LinearProgressIndicator(
                                                value: ratio.clamp(0.0, 1.0),
                                                minHeight: 8,
                                                backgroundColor: AppColors.border.withValues(alpha: 0.5),
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  ratio >= 0.9 ? AppColors.error : AppColors.primary,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: ratio >= 0.9 ? AppColors.error.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              "$current/$total",
                                              style: AppTextStyles.labelLarge.copyWith(
                                                fontSize: 12,
                                                color: ratio >= 0.9 ? AppColors.error : AppColors.primaryDeep,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 64, color: AppColors.textLight.withAlpha(50)),
          const SizedBox(height: 16),
          Text("Chưa có lớp học nào", style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildPopupMenu(dynamic item, String name) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_horiz, size: 20, color: AppColors.textLight),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (val) {
        if (val == 'edit') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => ClassFormScreen(classData: item)),
          ).then((_) => _fetchClasses());
        } else if (val == 'delete') {
          _confirmDelete(item['id'], name);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(children: [
            Icon(Icons.edit_outlined, size: 18),
            SizedBox(width: 10),
            Text("Chỉnh sửa"),
          ]),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(Icons.delete_outline, color: AppColors.error, size: 18),
            SizedBox(width: 10),
            Text("Xóa", style: TextStyle(color: AppColors.error)),
          ]),
        ),
      ],
    );
  }
}