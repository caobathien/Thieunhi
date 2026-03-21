import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/attendance_service.dart';
import '../../theme/app_theme.dart';

class AttendanceQRScreen extends StatefulWidget {
  final String? classId;
  final DateTime? date;
  final Function(String)? onScan;

  const AttendanceQRScreen({super.key, this.classId, this.date, this.onScan});

  @override
  State<AttendanceQRScreen> createState() => _AttendanceQRScreenState();
}

class _AttendanceQRScreenState extends State<AttendanceQRScreen> with WidgetsBindingObserver {
  final AttendanceService _attendanceService = AttendanceService();
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;
  bool _hasPermission = false;
  late MobileScannerController _scannerController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Khởi tạo controller với cấu hình tối giản cho Web
    _scannerController = MobileScannerController(
      detectionSpeed: kIsWeb ? DetectionSpeed.normal : DetectionSpeed.noDuplicates,
      facing: CameraFacing.back, // Sử dụng back làm mặc định cho tất cả
      torchEnabled: false,
    );
    
    if (kIsWeb) {
      _hasPermission = true; // Web manages this natively
    } else {
      _checkPermission();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Không cần gọi stop() vì dispose() đã handle
    _scannerController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (kIsWeb) return; // Bỏ qua trên Web
    if (state == AppLifecycleState.resumed && _hasPermission) {
      _scannerController.start();
    } else if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
        _scannerController.stop();
    }
  }

  Future<void> _checkPermission() async {
    if (kIsWeb) return;
    try {
      final status = await Permission.camera.request();
      if (mounted) {
        setState(() {
          _hasPermission = status.isGranted;
        });
      }
    } catch (e) {
      debugPrint("Lỗi phân quyền: $e");
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _processImage(image.path);
      }
    } catch (e) {
      _showNotify("LỖI", "Không thể truy cập thư viện ảnh", AppColors.error);
    }
  }

  Future<void> _processImage(String path) async {
    setState(() => _isProcessing = true);
    try {
      // mobile_scanner 3.x analyzeImage
      final bool success = await _scannerController.analyzeImage(path);
      if (!success && mounted) {
        _showNotify("LỖI", "Không tìm thấy mã QR trong ảnh", AppColors.error);
        setState(() => _isProcessing = false);
      }
    } catch (e) {
      if (mounted) {
        _showNotify("LỖI", "Lỗi xử lý hình ảnh: $e", AppColors.error);
        setState(() => _isProcessing = false);
      }
    }
  }

  void _handleQRScan(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() => _isProcessing = true);

        final String qrContent = barcode.rawValue!;
        
        if (widget.onScan != null) {
          widget.onScan!(qrContent);
          Navigator.pop(context);
          return;
        }

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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(msg),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return Scaffold(
        appBar: AppBar(title: const Text("Quét QR")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.camera_alt_outlined, size: 64, color: AppColors.textLight),
              const SizedBox(height: 16),
              const Text("Ứng dụng cần quyền Camera để quét mã QR"),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _checkPermission,
                style: AppDecorations.primaryButton,
                child: const Text("Cấp quyền Camera"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Scanner View ──
          MobileScanner(
            controller: _scannerController,
            onDetect: _handleQRScan,
            errorBuilder: (context, error, child) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        _getErrorMessage(error),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _pickFromGallery,
                        icon: const Icon(Icons.image),
                        label: const Text("Chọn ảnh từ thư viện"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // ── Semi-transparent Overlay ──
          _buildOverlay(context),

          // ── UI Controls ──
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                const Spacer(),
                _buildBottomControls(),
              ],
            ),
          ),

          if (_isProcessing)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
    );
  }

  String _getErrorMessage(MobileScannerException error) {
    String msg = error.errorDetails?.message ?? "";
    if (msg.contains("Null check operator")) {
      return "Trình duyệt chưa sẵn sàng hoặc không hỗ trợ camera này. Hãy thử sử dụng 'Chọn ảnh từ thư viện'.";
    }
    
    switch (error.errorCode) {
      case MobileScannerErrorCode.permissionDenied:
        return "Bạn đã từ chối quyền truy cập camera.";
      case MobileScannerErrorCode.unsupported:
        return "Thiết bị không hỗ trợ tính năng này.";
      default:
        return "Lỗi camera: ${msg.isNotEmpty ? msg : 'Vui lòng thử lại'}";
    }
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.black38,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Expanded(
            child: Text(
              "Quét mã QR",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 40), // Balance the close button
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    if (kIsWeb) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: ElevatedButton.icon(
            onPressed: _pickFromGallery,
            icon: const Icon(Icons.photo_library),
            label: const Text("CHỌN ẢNH TỪ THƯ VIỆN"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 8,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Flashlight
          _buildControlButton(
            icon: ValueListenableBuilder(
              valueListenable: _scannerController.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.white);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            onPressed: () => _scannerController.toggleTorch(),
          ),
          // Gallery (Center)
          Container(
            height: 64, width: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.8),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2)
              ]
            ),
            child: IconButton(
              icon: const Icon(Icons.photo_library, color: Colors.white),
              iconSize: 32,
              onPressed: _pickFromGallery,
            ),
          ),
          // Switch Camera
          _buildControlButton(
            icon: ValueListenableBuilder(
              valueListenable: _scannerController.cameraFacingState,
              builder: (context, state, child) {
                switch (state) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front, color: Colors.white);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear, color: Colors.white);
                }
              },
            ),
            onPressed: () => _scannerController.switchCamera(),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({required Widget icon, required VoidCallback onPressed}) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black38,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: icon,
        iconSize: 28,
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanAreaSize = size.width * 0.7;

    return Stack(
      children: [
        // Darken the area outside the scan area
        ColorFilteredOverlay(
          overlayColor: Colors.black.withOpacity(0.5),
          child: Stack(
            children: [
              Container(decoration: const BoxDecoration(color: Colors.black)),
              Center(
                child: Container(
                  width: scanAreaSize,
                  height: scanAreaSize,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Draw the focus frame
        Center(
          child: Container(
            width: scanAreaSize,
            height: scanAreaSize,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary, width: 2),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        // Help Text
        Positioned(
          top: (size.height / 2) + (scanAreaSize / 2) + 24,
          left: 0, right: 0,
          child: const Text(
            "Đặt mã QR vào khung để quét",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
      ],
    );
  }
}

class ColorFilteredOverlay extends StatelessWidget {
  final Color overlayColor;
  final Widget child;

  const ColorFilteredOverlay({super.key, required this.overlayColor, required this.child});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(colors: [overlayColor, overlayColor]).createShader(bounds);
      },
      blendMode: BlendMode.dstOut,
      child: child,
    );
  }
}