import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';

class CameraAttendanceScreen extends StatefulWidget {
  final bool isClockIn;

  const CameraAttendanceScreen({
    super.key,
    this.isClockIn = true,
  });

  @override
  State<CameraAttendanceScreen> createState() => _CameraAttendanceScreenState();
}

class _CameraAttendanceScreenState extends State<CameraAttendanceScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isFrontCamera = true;
  bool _isScanning = false;
  bool _isSuccess = false;
  late bool _isClockInMode;

  late AnimationController _scanAnimationController;
  late Animation<double> _scanAnimation;
  Timer? _clockTimer;
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _isClockInMode = widget.isClockIn;
    _initScannerAnimation();
    _startClock();
    _setupCamera();
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    _clockTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  void _initScannerAnimation() {
    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.1, end: 0.9).animate(
      CurvedAnimation(parent: _scanAnimationController, curve: Curves.easeInOut),
    );
  }

  void _startClock() {
    _updateClock();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateClock());
  }

  void _updateClock() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');
    if (mounted) {
      setState(() {
        _currentTime = '$hour:$minute:$second WIB';
      });
    }
  }

  Future<void> _setupCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        final frontCamera = _cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras.first,
        );
        await _initCameraController(frontCamera);
      } else {
        if (mounted) setState(() => _isCameraInitialized = false);
      }
    } catch (_) {
      // Graceful fallback for Windows/Emulator without physical camera device
      if (mounted) setState(() => _isCameraInitialized = false);
    }
  }

  Future<void> _initCameraController(CameraDescription cameraDescription) async {
    final controller = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await controller.initialize();
      if (mounted) {
        setState(() {
          _cameraController = controller;
          _isCameraInitialized = true;
          _isFrontCamera = cameraDescription.lensDirection == CameraLensDirection.front;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isCameraInitialized = false);
    }
  }

  void _switchCamera() async {
    if (_cameras.length < 2) return;
    final nextIndex = _isFrontCamera ? 0 : 1;
    await _cameraController?.dispose();
    _cameraController = null;
    await _initCameraController(_cameras[nextIndex]);
  }

  void _processBiometricAttendance() async {
    if (_isScanning || _isSuccess) return;

    setState(() {
      _isScanning = true;
    });

    // Simulasi verifikasi biometrik wajah & GPS
    await Future.delayed(const Duration(milliseconds: 1800));

    // Simpan status presensi ke SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} WIB';

    if (_isClockInMode) {
      await prefs.setBool('today_clocked_in', true);
      await prefs.setString('today_clock_in_time', timeStr);
    } else {
      await prefs.setBool('today_clocked_out', true);
      await prefs.setString('today_clock_out_time', timeStr);
    }

    if (mounted) {
      setState(() {
        _isScanning = false;
        _isSuccess = true;
      });

      _showSuccessDialog(timeStr);
    }
  }

  void _showSuccessDialog(String timeStr) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.successLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 48),
            ),
            const SizedBox(height: 16),
            Text(
              _isClockInMode ? 'Absen Masuk Berhasil!' : 'Absen Pulang Berhasil!',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isClockInMode
                  ? 'Kehadiran Anda telah dicatat pada sistem SSI tepat waktu.'
                  : 'Presensi kepulangan Anda telah diverifikasi. Selamat beristirahat!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.peachSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Text(
                'Waktu: $timeStr • Kantor Pusat SSI',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryCoral,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryCoral,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop(true); // Return success to reload home
                },
                child: const Text('Kembali ke Beranda', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Camera Preview or Fallback Simulator
            Positioned.fill(
              child: _isCameraInitialized && _cameraController != null
                  ? CameraPreview(_cameraController!)
                  : _buildSimulatorCameraView(),
            ),

            // 2. Scan Oval Guideline Overlay
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _scanAnimationController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: BiometricScanPainter(
                      progress: _scanAnimation.value,
                      isScanning: _isScanning,
                    ),
                  );
                },
              ),
            ),

            // 3. Header Bar with Back Button & Title
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: 0.5),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _isClockInMode ? 'Absen Masuk (Clock In)' : 'Absen Pulang (Clock Out)',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: 0.5),
                    child: IconButton(
                      icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white, size: 20),
                      onPressed: _switchCamera,
                    ),
                  ),
                ],
              ),
            ),

            // 4. Mode Switcher (Absen Masuk vs Pulang)
            Positioned(
              top: 76,
              left: 20,
              right: 20,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildModeTab('Masuk', _isClockInMode, () => setState(() => _isClockInMode = true)),
                      _buildModeTab('Pulang', !_isClockInMode, () => setState(() => _isClockInMode = false)),
                    ],
                  ),
                ),
              ),
            ),

            // 5. Bottom Control Panel
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primaryCoral),
                        const SizedBox(width: 6),
                        Text(
                          _currentTime,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Posisikan wajah Anda tegak lurus di dalam bingkai scanner',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isScanning ? null : _processBiometricAttendance,
                        icon: _isScanning
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.camera_alt_rounded, color: Colors.white),
                        label: Text(
                          _isScanning
                              ? 'Memverifikasi Biometrik...'
                              : (_isClockInMode ? 'Konfirmasi Absen Masuk' : 'Konfirmasi Absen Pulang'),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isClockInMode ? AppColors.success : AppColors.primaryCoral,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeTab(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryCoral : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSimulatorCameraView() {
    return Container(
      color: const Color(0xFF1F2937),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryCoral.withValues(alpha: 0.6), width: 3),
              ),
              child: const Icon(Icons.person, size: 80, color: Colors.white54),
            ),
            const SizedBox(height: 16),
            const Text(
              'Simulasi Kamera Biometrik SSI',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Kamera aktif dalam mode emulator/testing',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class BiometricScanPainter extends CustomPainter {
  final double progress;
  final bool isScanning;

  BiometricScanPainter({required this.progress, required this.isScanning});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.42);
    final rect = Rect.fromCenter(center: center, width: 240, height: 320);

    // Frame Corner Paint
    final cornerPaint = Paint()
      ..color = isScanning ? AppColors.success : AppColors.primaryCoral
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    const cornerLength = 32.0;

    // Top-Left
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(cornerLength, 0), cornerPaint);
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(0, cornerLength), cornerPaint);

    // Top-Right
    canvas.drawLine(rect.topRight, rect.topRight + const Offset(-cornerLength, 0), cornerPaint);
    canvas.drawLine(rect.topRight, rect.topRight + const Offset(0, cornerLength), cornerPaint);

    // Bottom-Left
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + const Offset(cornerLength, 0), cornerPaint);
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + const Offset(0, -cornerLength), cornerPaint);

    // Bottom-Right
    canvas.drawLine(rect.bottomRight, rect.bottomRight + const Offset(-cornerLength, 0), cornerPaint);
    canvas.drawLine(rect.bottomRight, rect.bottomRight + const Offset(0, -cornerLength), cornerPaint);

    // Laser scanning line
    final scanY = rect.top + (rect.height * progress);
    final scanPaint = Paint()
      ..color = (isScanning ? AppColors.success : AppColors.primaryCoral).withValues(alpha: 0.8)
      ..strokeWidth = 2.5;

    canvas.drawLine(Offset(rect.left + 8, scanY), Offset(rect.right - 8, scanY), scanPaint);
  }

  @override
  bool shouldRepaint(covariant BiometricScanPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isScanning != isScanning;
  }
}
