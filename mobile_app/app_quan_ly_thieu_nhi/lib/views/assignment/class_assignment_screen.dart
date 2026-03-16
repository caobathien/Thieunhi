import 'package:flutter/material.dart';
import '../../services/leader_profile_service.dart';
import '../../services/class_assignment_service.dart';
import '../../services/class_service.dart';
import '../../services/user_service.dart';
import '../../theme/app_theme.dart';
import '../../models/leader_profile_model.dart';
import '../../models/class_assignment_model.dart';
import 'admin_leader_edit_screen.dart';

class ClassAssignmentScreen extends StatefulWidget {
  const ClassAssignmentScreen({super.key});

  @override
  State<ClassAssignmentScreen> createState() => _ClassAssignmentScreenState();
}

class _ClassAssignmentScreenState extends State<ClassAssignmentScreen> {
  final LeaderProfileService _profileService = LeaderProfileService();
  final ClassAssignmentService _assignmentService = ClassAssignmentService();
  final ClassService _classService = ClassService();
  final UserService _userService = UserService();

  List<LeaderProfile> _leaders = [];
  List<ClassAssignment> _assignments = [];
  List<dynamic> _classes = [];
  String _searchQuery = "";
  String _filterStatus = "Tất cả";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final leadersRes = await _profileService.getAllLeaders();
    final assignmentsRes = await _assignmentService.getAllAssignments();
    final classesRes = await _classService.getAllClasses();

    if (mounted) {
      setState(() {
        if (leadersRes['success']) {
          _leaders = (leadersRes['data'] as List).map((e) => LeaderProfile.fromJson(e)).toList();
        }
        if (assignmentsRes['success']) {
          _assignments = (assignmentsRes['data'] as List).map((e) => ClassAssignment.fromJson(e)).toList();
        }
        _classes = classesRes['data'] ?? [];
        _isLoading = false;
      });
    }
  }

  // Tìm assignment của leader trong list
  ClassAssignment? _getAssignmentForLeader(String userId) {
    try {
      return _assignments.firstWhere((a) => a.userId == userId);
    } catch (_) {
      return null;
    }
  }

  void _showAssignDialog(LeaderProfile leader) {
    int? selectedClassId;
    final currentAssignment = _getAssignmentForLeader(leader.userId);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(currentAssignment == null ? "Phân công công tác" : "Điều chuyển lớp", style: AppTextStyles.titleMedium),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(leader.fullName ?? leader.christianName, style: AppTextStyles.bodyMedium),
              const SizedBox(height: 24),
              DropdownButtonFormField<int>(
                decoration: AppDecorations.inputDecoration(label: "Lớp học", prefixIcon: Icons.class_outlined),
                items: _classes.map((c) => DropdownMenuItem<int>(
                  value: c['id'],
                  child: Text(c['class_name'] ?? "N/A"),
                )).toList(),
                onChanged: (val) => selectedClassId = val,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
            ElevatedButton(
              onPressed: () async {
                if (selectedClassId != null) {
                  Map<String, dynamic> res;
                  if (currentAssignment == null) {
                    res = await _assignmentService.createAssignment(leader.userId, selectedClassId!);
                  } else {
                    res = await _assignmentService.updateAssignment(currentAssignment.id!, selectedClassId!);
                  }
                  
                  if (!context.mounted) return;
                  if (res['success']) {
                    Navigator.pop(context);
                    _loadData();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? "Lỗi")));
                  }
                }
              },
              child: const Text("Xác nhận"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAssignment(int assignmentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Gỡ phân công?"),
        content: const Text("Bạn có chắc chắn muốn gỡ Huynh Trưởng ra khỏi lớp này?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("HỦY")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("GỠ", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      final res = await _assignmentService.deleteAssignment(assignmentId);
      if (res['success'] && mounted) {
        _loadData();
      }
    }
  }

  void _showAddLeaderDialog() {
    final phoneController = TextEditingController();
    final gmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Thêm Huynh Trưởng mới", style: AppTextStyles.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: phoneController,
              decoration: AppDecorations.inputDecoration(label: "Số điện thoại", prefixIcon: Icons.phone),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: gmailController,
              decoration: AppDecorations.inputDecoration(label: "Gmail", prefixIcon: Icons.email_outlined),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              if (phoneController.text.isEmpty && gmailController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập SĐT hoặc Gmail")));
                return;
              }
              final res = await _profileService.createLeader(
                phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                gmailController.text.trim().isEmpty ? null : gmailController.text.trim(),
              );
              if (!context.mounted) return;
              if (res['success']) {
                Navigator.pop(context);
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã tạo Huynh Trưởng. Mật khẩu tạm: ${res['tempPassword'] ?? 'N/A'}"), duration: const Duration(seconds: 10)));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? "Lỗi")));
              }
            },
            child: const Text("Tạo mới"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteLeader(LeaderProfile leader) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xóa Huynh Trưởng?"),
        content: Text("Bạn có chắc chắn muốn xóa hồ sơ và tài khoản của ${leader.fullName ?? leader.christianName}?\nHành động này không thể hoàn tác."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("HỦY")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("XÓA VĨNH VIỄN", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
        ],
      ),
    );

    if (confirm == true) {
      final res = await _userService.deleteUser(leader.userId);
      if (mounted) {
        if (res['success']) {
          _loadData();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã xóa Huynh Trưởng thành công")));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? "Lỗi khi xóa")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredLeaders = _leaders.where((l) {
      final matchesSearch = (l.fullName ?? "").toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            (l.christianName).toLowerCase().contains(_searchQuery.toLowerCase());
      
      final assignment = _getAssignmentForLeader(l.userId);
      bool matchesFilter = true;
      if (_filterStatus == "Đã có lớp") matchesFilter = assignment != null;
      if (_filterStatus == "Chưa có lớp") matchesFilter = assignment == null;
      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Phân công nhân sự"),
      ),
      body: Column(
        children: [
          // ── Search & Filter ──
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  decoration: AppDecorations.inputDecoration(label: "Tìm kiếm huynh trưởng", prefixIcon: Icons.search_rounded),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ["Tất cả", "Đã có lớp", "Chưa có lớp"].map((status) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(status),
                        selected: _filterStatus == status,
                        onSelected: (val) => setState(() => _filterStatus = status),
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.primaryLight.withAlpha(30),
                        labelStyle: TextStyle(
                          color: _filterStatus == status ? Colors.white : AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
                        showCheckmark: false,
                      ),
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),

          // ── List ──
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredLeaders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.assignment_ind_outlined, size: 48, color: AppColors.textLight.withAlpha(100)),
                            const SizedBox(height: 16),
                            Text("Không có dữ liệu phù hợp", style: AppTextStyles.bodyMedium),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(24),
                        itemCount: filteredLeaders.length,
                        separatorBuilder: (c, i) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final leader = filteredLeaders[index];
                          final assignment = _getAssignmentForLeader(leader.userId);
                          final hasClass = assignment != null;

                          return Container(
                            decoration: AppDecorations.card,
                            child: InkWell(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AdminLeaderEditScreen(leader: leader),
                                  ),
                                );
                                if (result == true) {
                                  _loadData();
                                }
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor: hasClass ? AppColors.success.withAlpha(30) : AppColors.warning.withAlpha(30),
                                  child: Icon(
                                    hasClass ? Icons.badge_outlined : Icons.person_outline_rounded,
                                    color: hasClass ? AppColors.success : AppColors.warning,
                                  ),
                                ),
                                title: Text(leader.fullName ?? leader.christianName, style: AppTextStyles.titleSmall),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    hasClass ? "Lớp: ${assignment.className}" : "Chưa phân lớp",
                                    style: TextStyle(
                                      color: hasClass ? AppColors.success : AppColors.warning,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (hasClass)
                                      IconButton(
                                        icon: const Icon(Icons.link_off, color: Colors.orange, size: 20),
                                        onPressed: () => _deleteAssignment(assignment.id!),
                                        tooltip: "Gỡ phân công",
                                      ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_forever_outlined, color: Colors.redAccent, size: 20),
                                      onPressed: () => _deleteLeader(leader),
                                      tooltip: "Xóa hồ sơ Huynh Trưởng",
                                    ),
                                    TextButton(
                                      onPressed: () => _showAssignDialog(leader),
                                      child: Text(hasClass ? "ĐỔI LỚP" : "PHÂN CÔNG", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddLeaderDialog,
        icon: const Icon(Icons.add),
        label: const Text("THÊM HUYNH TRƯỞNG"),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}