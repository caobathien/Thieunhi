import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/attendance_service.dart';
import '../../theme/app_theme.dart';

class AttendanceQRScreen extends StatefulWidget {
  final String classId;
  final DateTime date;

  const AttendanceQRScreen({super.key, required this.classId, required this.date});

  @override
  State<AttendanceQRScreen> createState() => _AttendanceQRScreenState();
}

class _AttendanceQRScreenState extends State<AttendanceQRScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  bool _isProcessing = false;

  void _handleQRScan(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() => _isProcessing = true);

        final String qrContent = barcode.rawValue!;
        final result = await _attendanceService.scanQR(qrContent);

        if (mounted) {
          if (result['success'] == true) {
            final String checkInTime = result['data']?['check_in_time'] ??
                TimeOfDay.now().format(context);
            final String name = result['data']?['full_name'] ?? "Thiếu nhi";

            _showNotify("ĐÃ ĐIỂM DANH", "$name\nGiờ vào: $checkInTime", AppColors.success);
          } else {
            _showNotify("LỖI", result['message'] ?? "Mã không hợp lệ", AppColors.error);
          }
        }

        await Future.delayed(const Duration(seconds: 2));
        if (mounted) setState(() => _isProcessing = false);
        break;
      }
    }
  }

  void _showNotify(String title, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$title: $msg", style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quét QR Tự động"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.white),
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: _handleQRScan,
            controller: MobileScannerController(
              detectionSpeed: DetectionSpeed.noDuplicates,
            ),
          ),
          Center(
            child: Container(
              width: 260, height: 260,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isProcessing ? AppColors.warning : AppColors.primary,
                  width: 4,
                ),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
          ),
          if (_isProcessing)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          Positioned(
            bottom: 50, left: 20, right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(140),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                "Đang điểm danh lớp: ${widget.classId}\nNgày: ${widget.date.day.toString().padLeft(2, '0')}/${widget.date.month.toString().padLeft(2, '0')}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}