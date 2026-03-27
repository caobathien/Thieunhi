import 'package:flutter/material.dart';
import '../../services/attendance_service.dart';
import '../../services/token_service.dart';
import '../../theme/app_theme.dart';
import 'package:intl/intl.dart';

class AttendanceStatsScreen extends StatefulWidget {
  final int classId;
  final String className;

  const AttendanceStatsScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  State<AttendanceStatsScreen> createState() => _AttendanceStatsScreenState();
}

class _AttendanceStatsScreenState extends State<AttendanceStatsScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  final TokenService _tokenService = TokenService();

  bool _isLoading = true;
  String _userRole = 'user';
  DateTime _currentWeekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));

  List<Map<String, dynamic>> _studentsList = [];
  final Map<String, Map<String, dynamic>> _attendanceDict = {};
  final Map<String, String> _lessonTopics = {};
  List<DateTime> _weekDays = [];

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _loadWeekData(_currentWeekStart);
  }

  Future<void> _loadUserRole() async {
    final role = await _tokenService.getUserRole();
    setState(() => _userRole = role?.toLowerCase() ?? 'user');
  }

  void _generateWeekDays(DateTime start) {
    _weekDays = List.generate(7, (index) => start.add(Duration(days: index)));
  }

  Future<void> _loadWeekData(DateTime weekStart) async {
    setState(() {
      _isLoading = true;
      _currentWeekStart = weekStart;
      _generateWeekDays(weekStart);
    });

    final startDateStr = DateFormat('yyyy-MM-dd').format(_weekDays.first);
    final endDateStr = DateFormat('yyyy-MM-dd').format(_weekDays.last);

    final response = await _attendanceService.getAttendanceStats(widget.classId, startDateStr, endDateStr);

    if (response['success'] == true) {
      final List<dynamic> data = response['data'] ?? [];
      Map<String, Map<String, dynamic>> uniqueStudents = {};
      _attendanceDict.clear();
      _lessonTopics.clear();

      for (var record in data) {
        String childIdStr = record['child_id'].toString();
        if (!uniqueStudents.containsKey(childIdStr)) {
          uniqueStudents[childIdStr] = {
            'child_id': childIdStr,
            'baptismal_name': record['baptismal_name'] ?? '',
            'first_name': record['first_name'] ?? '',
            'last_name': record['last_name'] ?? '',
          };
        }
        if (record['attendance_date'] != null) {
          DateTime rDate = DateTime.parse(record['attendance_date']);
          String dateKey = DateFormat('yyyy-MM-dd').format(rDate);
          _attendanceDict['${childIdStr}_$dateKey'] = {
            'status': record['status'],
            'is_present': record['is_present'],
            'reason': record['reason'],
          };
          if (record['lesson_topic'] != null && record['lesson_topic'].toString().isNotEmpty) {
            _lessonTopics[dateKey] = record['lesson_topic'].toString();
          }
        }
      }

      setState(() {
        _studentsList = uniqueStudents.values.toList();
        _studentsList.sort((a, b) => (a['first_name']).compareTo(b['first_name']));
        _isLoading = false;
      });
    } else {
      setState(() {
        _studentsList = [];
        _attendanceDict.clear();
        _isLoading = false;
      });
    }
  }

  void _changeWeek(int offsetDays) {
    _loadWeekData(_currentWeekStart.add(Duration(days: offsetDays)));
  }

  void _showEditSheet(String childId, String dateKey, String studentName) {
    bool isAdminOrLeader = _userRole == 'admin' || _userRole == 'leader';
    if (!isAdminOrLeader) return;

    final record = _attendanceDict['${childId}_$dateKey'];
    bool isPresent = record?['is_present'] ?? false;
    String status = record?['status'] ?? 'Có mặt';
    String absenceType = (status == 'Vắng có phép') ? 'Vắng có phép' : 'Vắng không phép';
    TextEditingController notesCtrl = TextEditingController(text: record?['reason'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom, left: 24, right: 24, top: 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: StatefulBuilder(
          builder: (context, setBS) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Cập nhật điểm danh", style: AppTextStyles.titleMedium),
              const SizedBox(height: 8),
              Text(studentName, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
              Text("Ngày: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(dateKey))}", style: AppTextStyles.caption),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _buildTypeButton(
                      label: "CÓ MẶT",
                      icon: Icons.check_circle_rounded,
                      isSelected: isPresent,
                      color: AppColors.success,
                      onTap: () => setBS(() {
                        isPresent = true;
                        status = "Có mặt";
                      }),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTypeButton(
                      label: "VẮNG",
                      icon: Icons.cancel_rounded,
                      isSelected: !isPresent,
                      color: AppColors.error,
                      onTap: () => setBS(() {
                        isPresent = false;
                        status = absenceType;
                      }),
                    ),
                  ),
                ],
              ),
              if (!isPresent) ...[
                const SizedBox(height: 24),
                Text("Hình thức vắng", style: AppTextStyles.sectionHeader),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildAbsenceOption("Có phép", "Vắng có phép", absenceType, (v) => setBS(() {
                      absenceType = v;
                      status = v;
                    })),
                    const SizedBox(width: 12),
                    _buildAbsenceOption("Không phép", "Vắng không phép", absenceType, (v) => setBS(() {
                      absenceType = v;
                      status = v;
                    })),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              TextField(
                controller: notesCtrl,
                maxLines: 2,
                decoration: AppDecorations.inputDecoration(label: "Ghi chú thêm (nếu có)", prefixIcon: Icons.notes_rounded),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    final res = await _attendanceService.manualMark(
                      childId: childId,
                      classId: widget.classId,
                      isPresent: isPresent,
                      status: status,
                      reason: notesCtrl.text,
                      attendanceDate: dateKey,
                    );
                    if (res['success'] == true) {
                      if (!c.mounted) return;
                      Navigator.pop(c);
                      _loadWeekData(_currentWeekStart);
                    }
                  },
                  child: const Text("LƯU THAY ĐỔI"),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditTopicSheet(String dateKey, String currentTopic) {
    bool isAdminOrLeader = _userRole == 'admin' || _userRole == 'leader';
    if (!isAdminOrLeader) return;

    TextEditingController topicCtrl = TextEditingController(text: currentTopic == "-" ? "" : currentTopic);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom, left: 24, right: 24, top: 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Cập nhật bài dạy", style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            Text("Ngày: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(dateKey))}", style: AppTextStyles.caption),
            const SizedBox(height: 24),
            TextField(
              controller: topicCtrl,
              maxLines: 2,
              decoration: AppDecorations.inputDecoration(label: "Chủ đề bài dạy", prefixIcon: Icons.menu_book_rounded),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  final res = await _attendanceService.updateLessonTopic(
                    classId: widget.classId,
                    date: dateKey,
                    topic: topicCtrl.text.trim(),
                  );
                  if (res['success'] == true) {
                    if (!c.mounted) return;
                    Navigator.pop(c);
                    _loadWeekData(_currentWeekStart);
                  } else {
                    if (!c.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? "Lỗi cập nhật")));
                  }
                },
                child: const Text("LƯU THAY ĐỔI"),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton({required String label, required IconData icon, required bool isSelected, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? color : AppColors.border, width: 2),
          boxShadow: isSelected ? [BoxShadow(color: color.withAlpha(40), blurRadius: 8, offset: const Offset(0, 4))] : [],
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: isSelected ? Colors.white : color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildAbsenceOption(String label, String value, String groupValue, Function(String) onChanged) {
    final bool isSelected = value == groupValue;
    return Expanded(
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.className),
        elevation: 0,
      ),
      body: Column(
        children: [
          // ── Header Summary ──
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("THỜI GIAN", style: AppTextStyles.sectionHeader),
                        Text(
                          "${DateFormat('dd/MM').format(_weekDays.first)} - ${DateFormat('dd/MM').format(_weekDays.last)}",
                          style: AppTextStyles.titleMedium,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _navBtn(Icons.chevron_left_rounded, () => _changeWeek(-7)),
                        const SizedBox(width: 12),
                        _navBtn(Icons.chevron_right_rounded, () => _changeWeek(7)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _studentsList.isEmpty
                    ? _buildEmptyState()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Container(
                          decoration: AppDecorations.card,
                          clipBehavior: Clip.antiAlias,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowHeight: 64,
                              dataRowMinHeight: 56,
                              dataRowMaxHeight: 56,
                              horizontalMargin: 20,
                              columnSpacing: 24,
                              headingTextStyle: AppTextStyles.labelLarge.copyWith(fontSize: 11, color: AppColors.textSecondary),
                              columns: [
                                const DataColumn(label: Text("HỌ VÀ TÊN")),
                                ..._weekDays.map((d) => DataColumn(
                                  label: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(_getWeekdayName(d.weekday), style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text(DateFormat('dd/MM').format(d), style: const TextStyle(fontSize: 9)),
                                      ],
                                    ),
                                  ),
                                )),
                              ],
                              rows: [
                                // ── Lesson Topic Row ──
                                DataRow(
                                  color: MaterialStateProperty.all(AppColors.background),
                                  cells: [
                                    const DataCell(
                                      Text("BÀI DẠY", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12)),
                                    ),
                                    ..._weekDays.map((d) {
                                      String dateKey = DateFormat('yyyy-MM-dd').format(d);
                                      String topic = _lessonTopics[dateKey] ?? "-";
                                      return DataCell(
                                        Center(
                                          child: Tooltip(
                                            message: topic,
                                            child: Container(
                                              constraints: const BoxConstraints(maxWidth: 100),
                                              child: Text(
                                                topic,
                                                style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                        onTap: () => _showEditTopicSheet(dateKey, topic),
                                      );
                                    }).toList(),
                                  ],
                                ),
                                // ── Student Rows ──
                                ..._studentsList.map((s) {
                                  String cId = s['child_id'];
                                  String name = "${s['last_name']} ${s['first_name']}";
                                  return DataRow(cells: [
                                    DataCell(
                                      Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                    ),
                                    ..._weekDays.map((d) {
                                      String dateKey = DateFormat('yyyy-MM-dd').format(d);
                                      return DataCell(
                                        _buildStatusWidget(_attendanceDict['${cId}_$dateKey']),
                                        onTap: () => _showEditSheet(cId, dateKey, name),
                                      );
                                    }),
                                  ]);
                                }).toList(),
                              ],
                            ),
                          ),
                        ),
                      ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _navBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(border: Border.all(color: AppColors.divider), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: AppColors.primary, size: 24),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note_rounded, size: 64, color: AppColors.primaryLight.withAlpha(50)),
          const SizedBox(height: 16),
          Text("Chưa có dữ liệu cho tuần này", style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildStatusWidget(Map<String, dynamic>? record) {
    if (record == null) return const Center(child: Text("-", style: TextStyle(color: AppColors.textHint)));
    
    bool isPresent = record['is_present'];
    String status = record['status'] ?? '';
    
    if (isPresent) {
      return const Center(child: Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22));
    }
    
    bool isAuthorized = status.contains("có phép");
    return Center(
      child: Icon(
        isAuthorized ? Icons.info_rounded : Icons.cancel_rounded,
        color: isAuthorized ? AppColors.warning : AppColors.error,
        size: 22,
      ),
    );
  }

  String _getWeekdayName(int w) {
    final list = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"];
    return list[w - 1];
  }
}
