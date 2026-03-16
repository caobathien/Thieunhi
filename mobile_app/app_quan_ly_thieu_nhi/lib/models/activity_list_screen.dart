import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../theme/notification_controller.dart';
import '../models/activity_model.dart';
import '../services/activity_service.dart';
import '../services/token_service.dart';
import '../services/user_service.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class ActivityListScreen extends StatefulWidget {
  const ActivityListScreen({super.key});

  @override
  State<ActivityListScreen> createState() => _ActivityListScreenState();
}

class _ActivityListScreenState extends State<ActivityListScreen> {
  final ActivityService _activityService = ActivityService();
  final TokenService _tokenService = TokenService();
  final UserService _userService = UserService();

  List<Activity> _activities = [];
  String? _userRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final profileRes = await _userService.getMyProfile();
    if (profileRes['success'] == true && profileRes['data'] != null) {
      _userRole = profileRes['data']['role']?.toString().toLowerCase();
      if (_userRole != null) {
        await _tokenService.saveUserRole(_userRole!);
      }
    } else {
      _userRole = (await _tokenService.getUserRole())?.toLowerCase();
    }
    await _fetchActivities();
  }

  Future<void> _fetchActivities() async {
    setState(() => _isLoading = true);
    final res = await _activityService.getActivities();

    if (res['success'] == true) {
      final List rawList = res['data'] ?? [];
      setState(() {
        _activities = rawList.map((json) => Activity.fromJson(json)).toList();
        _activities.sort((a, b) {
          if (b.isFeatured != a.isFeatured) return b.isFeatured ? 1 : -1;
          return (b.id ?? 0).compareTo(a.id ?? 0);
        });
        _isLoading = false;
      });
    }
  }

  Future<void> _handleDelete(int id) async {
    final res = await _activityService.deleteActivity(id);
    if (res['success']) {
      _fetchActivities();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Đã xóa tin thành công!"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = _userRole == 'admin' || _userRole == 'leader-vip';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Thông báo & Sự kiện"),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.titleMedium,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _fetchActivities,
              color: AppColors.primary,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                physics: const BouncingScrollPhysics(),
                itemCount: _activities.length,
                itemBuilder: (context, index) => _buildModernActivityCard(_activities[index], isAdmin),
              ),
            ),
      floatingActionButton: isAdmin ? _buildFAB() : null,
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () => _showActivityForm(),
      backgroundColor: AppColors.primary,
      icon: const Icon(Icons.add_comment_rounded, color: Colors.white),
      label: const Text("ĐĂNG TIN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildModernActivityCard(Activity activity, bool isAdmin) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (activity.imageUrl != null && activity.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Image.network(
                activity.imageUrl!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 160,
                  width: double.infinity,
                  color: AppColors.surface,
                  child: const Icon(Icons.image_not_supported_outlined, color: AppColors.textHint, size: 40),
                ),
              ),
            )
          else
            Container(
              height: 160,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFE8EBFA),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: const Icon(Icons.campaign_outlined, color: AppColors.primary, size: 48),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (activity.isFeatured)
                      Padding(
                        padding: const EdgeInsets.only(top: 2, right: 6),
                        child: Icon(Icons.push_pin_rounded, color: AppColors.warning, size: 18),
                      ),
                    Expanded(
                      child: Text(
                        activity.title,
                        style: AppTextStyles.titleSmall,
                      ),
                    ),
                    if (isAdmin) _buildAdminMenu(activity),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  activity.summary ?? activity.content,
                  style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1, color: AppColors.divider)),
                Row(
                  children: [
                    _buildInfoTag(Icons.calendar_today_rounded, activity.startTime ?? "Đang cập nhật", AppColors.primary),
                    const SizedBox(width: 12),
                    _buildInfoTag(Icons.access_time_rounded, activity.createdAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(activity.createdAt!)) : "", AppColors.textHint),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminMenu(Activity activity) {
    return PopupMenuButton(
      icon: const Icon(Icons.more_vert_rounded, color: AppColors.textHint),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (value) {
        if (value == 'edit') _showActivityForm(activity: activity);
        if (value == 'delete') _confirmDelete(activity.id!);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18, color: AppColors.primary), SizedBox(width: 8), Text("Sửa")])),
        const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, color: AppColors.error, size: 18), SizedBox(width: 8), Text("Xóa", style: TextStyle(color: AppColors.error))])),
      ],
    );
  }

  Widget _buildInfoTag(IconData icon, String label, Color color) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Expanded(child: Text(label, style: AppTextStyles.caption, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  void _showActivityForm({Activity? activity}) {
    final titleCtrl = TextEditingController(text: activity?.title);
    final summaryCtrl = TextEditingController(text: activity?.summary);
    final contentCtrl = TextEditingController(text: activity?.content);
    final locationCtrl = TextEditingController(text: activity?.location);
    String? currentImageUrl = activity?.imageUrl;
    bool isFeatured = activity?.isFeatured ?? false;
    bool isUploadingImage = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) => StatefulBuilder(
        builder: (context, setST) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 20),
                Text(
                  activity == null ? "Đăng thông báo mới" : "Chỉnh sửa thông báo",
                  style: AppTextStyles.titleLarge,
                ),
                const SizedBox(height: 24),
                _buildInput(titleCtrl, "Tiêu đề", Icons.title),
                const SizedBox(height: 16),
                _buildInput(contentCtrl, "Nội dung chi tiết", Icons.subject, maxLines: 4),
                const SizedBox(height: 16),
                _buildInput(locationCtrl, "Địa điểm", Icons.location_on_outlined),
                const SizedBox(height: 16),
                
                // --- Thay thế URL text input bằng Image Picker ---
                GestureDetector(
                  onTap: isUploadingImage
                      ? null
                      : () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                          if (image != null) {
                            setST(() => isUploadingImage = true);
                            final uploadedUrl = await ApiConfig.uploadImage(image.path);
                            if (uploadedUrl != null) {
                              setST(() => currentImageUrl = uploadedUrl);
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Tải ảnh thất bại! Vui lòng thử lại.")),
                                );
                              }
                            }
                            setST(() => isUploadingImage = false);
                          }
                        },
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: currentImageUrl != null && currentImageUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(currentImageUrl!, fit: BoxFit.cover),
                          )
                        : (isUploadingImage
                            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined, size: 40, color: AppColors.textHint),
                                  SizedBox(height: 8),
                                  Text("Nhấn để tải ảnh minh họa", style: TextStyle(color: AppColors.textHint)),
                                ],
                              )),
                  ),
                ),
                
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text("Ghim lên đầu trang chủ"),
                  activeColor: AppColors.primary,
                  value: isFeatured,
                  onChanged: (v) => setST(() => isFeatured = v!),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: AppDecorations.primaryButton,
                    onPressed: () async {
                      final body = {
                        "title": titleCtrl.text,
                        "summary": summaryCtrl.text,
                        "content": contentCtrl.text,
                        "location": locationCtrl.text,
                        "image_url": currentImageUrl ?? "",
                        "is_featured": isFeatured,
                        "start_time": DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
                      };
                      if (activity == null) {
                        final res = await _activityService.createActivity(body);
                        if (res['success'] == true && context.mounted) {
                          Provider.of<NotificationController>(context, listen: false).broadcast(
                            "Thông báo mới!",
                            titleCtrl.text,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.campaign_rounded, color: Colors.white),
                                  SizedBox(width: 12),
                                  Expanded(child: Text("Đã gửi thông báo đến tất cả mọi người!")),
                                ],
                              ),
                              backgroundColor: AppColors.secondary,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 4),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        }
                      } else {
                        await _activityService.updateActivity(activity.id!, body);
                      }
                      if (!c.mounted) return;
                      Navigator.pop(c);
                      _fetchActivities();
                    },
                    child: const Text(
                      "LƯU THÔNG BÁO",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 1.0),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String label, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: AppDecorations.inputDecoration(label: label, prefixIcon: icon),
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Xác nhận xóa", style: AppTextStyles.titleMedium),
        content: const Text("Thông báo này sẽ biến mất vĩnh viễn. Bạn chắc chứ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("HỦY", style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(c);
              _handleDelete(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("XÓA", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}