import 'package:flutter/material.dart';
import '../../services/feedback_service.dart';
import '../../theme/app_theme.dart';

class AdminFeedbackListScreen extends StatefulWidget {
  const AdminFeedbackListScreen({super.key});

  @override
  State<AdminFeedbackListScreen> createState() => _AdminFeedbackListScreenState();
}

class _AdminFeedbackListScreenState extends State<AdminFeedbackListScreen> {
  final FeedbackService _feedbackService = FeedbackService();
  List<dynamic> _feedbacks = [];
  bool _isLoading = true;
  String _filterStatus = "all"; // all, pending, resolved

  @override
  void initState() {
    super.initState();
    _fetchFeedbacks();
  }

  Future<void> _fetchFeedbacks() async {
    // Chỉ hiện loading xoay ở giữa màn hình nếu danh sách đang rỗng (lần đầu load)
    if (_feedbacks.isEmpty) {
      if (mounted) {
        setState(() => _isLoading = true);
      }
    }

    final res = await _feedbackService.getAllFeedbacks();
    if (res['success'] == true) {
      if (mounted) {
        setState(() {
          _feedbacks = res['data'] ?? [];
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<dynamic> get _filteredFeedbacks {
    if (_filterStatus == "all") return _feedbacks;
    return _feedbacks.where((f) => f['status'] == _filterStatus).toList();
  }

  int get _pendingCount => _feedbacks.where((f) => f['status'] == 'pending').length;

  void _showRespondDialog(dynamic feedback) {
    final noteController = TextEditingController(text: feedback['admin_note'] ?? "");
    String selectedStatus = feedback['status'] ?? "pending";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text("Phản hồi ý kiến", style: AppTextStyles.titleMedium),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(feedback['title'] ?? "Không có tiêu đề", style: AppTextStyles.titleSmall),
                      const SizedBox(height: 8),
                      Text(feedback['content'] ?? "", style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  initialValue: selectedStatus,
                  decoration: AppDecorations.inputDecoration(label: "Trạng thái", prefixIcon: Icons.flag_outlined),
                  items: const [
                    DropdownMenuItem(value: "pending", child: Text("Đang chờ xử lý")),
                    DropdownMenuItem(value: "resolved", child: Text("Đã giải quyết")),
                  ],
                  onChanged: (v) => setDialogState(() => selectedStatus = v!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: AppDecorations.inputDecoration(label: "Ghi chú của Admin", prefixIcon: Icons.notes_rounded),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
            ElevatedButton(
              onPressed: () async {
                await _feedbackService.respondToFeedback(
                  id: feedback['id'],
                  status: selectedStatus,
                  adminNote: noteController.text,
                );
                if (!context.mounted) return;
                Navigator.pop(context);
                _fetchFeedbacks();
              },
              child: const Text("Cập nhật"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Phản hồi hệ thống"),
      ),
      body: Column(
        children: [
          // ── Summary & Filter ──
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Danh sách góp ý", style: AppTextStyles.titleSmall),
                    if (_pendingCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.error.withAlpha(20), borderRadius: BorderRadius.circular(12)),
                        child: Text("$_pendingCount chờ xử lý", style: AppTextStyles.caption.copyWith(color: AppColors.error, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _filterChip("Tất cả", "all"),
                    const SizedBox(width: 8),
                    _filterChip("Chờ xử lý", "pending"),
                    const SizedBox(width: 8),
                    _filterChip("Đã xử lý", "resolved"),
                  ],
                ),
              ],
            ),
          ),

          // ── List ──
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredFeedbacks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inbox_outlined, size: 64, color: AppColors.primaryLight),
                            const SizedBox(height: 16),
                            Text("Không có phản hồi nào", style: AppTextStyles.bodyMedium),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchFeedbacks,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(24),
                          itemCount: _filteredFeedbacks.length,
                          separatorBuilder: (c, i) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final item = _filteredFeedbacks[index];
                            final bool isResolved = item['status'] == 'resolved';

                            return Container(
                              decoration: AppDecorations.card,
                              child: InkWell(
                                onTap: () => _showRespondDialog(item),
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isResolved ? AppColors.success.withAlpha(20) : AppColors.warning.withAlpha(20),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              isResolved ? "SOLVED" : "PENDING",
                                              style: TextStyle(
                                                color: isResolved ? AppColors.success : AppColors.warning,
                                                fontSize: 10, fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 20),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(item['title'] ?? 'No Title', style: AppTextStyles.titleSmall),
                                      const SizedBox(height: 4),
                                      Text(item['content'] ?? '', style: AppTextStyles.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                                      if (item['admin_note'] != null && item['admin_note'].toString().isNotEmpty) ...[
                                        const SizedBox(height: 16),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Icon(Icons.reply_rounded, size: 16, color: AppColors.primary),
                                              const SizedBox(width: 8),
                                              Expanded(child: Text(item['admin_note'], style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary))),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
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

  Widget _filterChip(String label, String status) {
    final bool isSelected = _filterStatus == status;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) => setState(() => _filterStatus = status),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.primaryLight.withAlpha(30),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.primary,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
      showCheckmark: false,
    );
  }
}