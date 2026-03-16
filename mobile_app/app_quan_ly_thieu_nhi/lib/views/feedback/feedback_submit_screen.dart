import 'package:flutter/material.dart';
import '../../services/feedback_service.dart';
import '../../theme/app_theme.dart';

class FeedbackSubmitScreen extends StatefulWidget {
  const FeedbackSubmitScreen({super.key});

  @override
  State<FeedbackSubmitScreen> createState() => _FeedbackSubmitScreenState();
}

class _FeedbackSubmitScreenState extends State<FeedbackSubmitScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final FeedbackService _feedbackService = FeedbackService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isSubmitting = false;

  late TabController _tabController;
  List<dynamic> _myFeedbacks = [];
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMyFeedbacks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadMyFeedbacks() async {
    setState(() => _isLoadingHistory = true);
    final res = await _feedbackService.getMyFeedbacks();
    if (res['success'] == true) {
      setState(() => _myFeedbacks = res['data'] ?? []);
    }
    setState(() => _isLoadingHistory = false);
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final res = await _feedbackService.submitFeedback(
      _titleController.text,
      _contentController.text,
    );

    setState(() => _isSubmitting = false);

    if (res['success'] == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gửi phản hồi thành công!")),
      );
      _titleController.clear();
      _contentController.clear();
      _loadMyFeedbacks();
      _tabController.animateTo(1);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text("Gửi phản hồi thất bại"), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Góp ý hệ thống"),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: "Gửi góp ý"),
            Tab(text: "Lịch sử"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSubmitTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildSubmitTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppDecorations.card,
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline_rounded, color: AppColors.warning, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Bạn có ý tưởng mới?", style: AppTextStyles.titleSmall),
                        Text("Đóng góp ý kiến để giúp hệ thống hoàn thiện hơn.", style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text("Chi tiết góp ý", style: AppTextStyles.sectionHeader),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: AppDecorations.inputDecoration(label: "Tiêu đề", prefixIcon: Icons.title_rounded),
              validator: (v) => v!.isEmpty ? "Vui lòng nhập tiêu đề" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              maxLines: 5,
              decoration: AppDecorations.inputDecoration(label: "Nội dung phản hồi"),
              validator: (v) => v!.isEmpty ? "Vui lòng nhập nội dung" : null,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                child: _isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text("GỬI PHẢN HỒI"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_isLoadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_myFeedbacks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_toggle_off_rounded, size: 48, color: AppColors.textLight.withAlpha(100)),
            const SizedBox(height: 16),
            Text("Chưa có lịch sử góp ý", style: AppTextStyles.bodyMedium),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMyFeedbacks,
      child: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: _myFeedbacks.length,
        separatorBuilder: (c, i) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final item = _myFeedbacks[index];
          final bool isResolved = item['status'] == 'resolved';

          return Container(
            decoration: AppDecorations.card,
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
                        isResolved ? "ĐÃ GIẢI QUYẾT" : "ĐANG CHỜ",
                        style: TextStyle(
                          color: isResolved ? AppColors.success : AppColors.warning,
                          fontSize: 10, fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text("ID: #${item['id'].toString().padLeft(4, '0')}", style: AppTextStyles.caption),
                  ],
                ),
                const SizedBox(height: 12),
                Text(item['title'] ?? 'No Title', style: AppTextStyles.titleSmall),
                const SizedBox(height: 4),
                Text(item['content'] ?? '', style: AppTextStyles.bodyMedium),
                if (item['admin_note'] != null && item['admin_note'].toString().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Phản hồi từ Admin:", style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
                        const SizedBox(height: 4),
                        Text(item['admin_note'], style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}