import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import 'camera_attendance.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToHistory;
  final VoidCallback? onNavigateToPermit;
  final VoidCallback? onNavigateToProfile;

  const HomeScreen({
    super.key,
    this.onNavigateToHistory,
    this.onNavigateToPermit,
    this.onNavigateToProfile,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _staffName = 'Adnan Ayu Puji Asrori';
  String _staffNip = 'SSI-2026-088';
  String _currentTime = '';
  String _currentDate = '';
  Timer? _clockTimer;

  bool _hasClockedIn = false;
  String? _clockInTime;

  @override
  void initState() {
    super.initState();
    _loadStaffData();
    _startLiveClock();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadStaffData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _staffName = prefs.getString('staff_name') ?? 'Adnan Ayu Puji Asrori';
      _staffNip = prefs.getString('staff_nip') ?? 'SSI-2026-088';
      _hasClockedIn = prefs.getBool('today_clocked_in') ?? false;
      _clockInTime = prefs.getString('today_clock_in_time');
    });
  }

  void _startLiveClock() {
    _updateTime();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');

    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];

    if (mounted) {
      setState(() {
        _currentTime = '$hour:$minute:$second';
        _currentDate = '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
      });
    }
  }

  void _openCameraAttendance(bool isClockIn) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CameraAttendanceScreen(isClockIn: isClockIn),
      ),
    );

    if (result == true) {
      _loadStaffData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.peachBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Header SSI & Notification
              _buildTopBar(),

              const SizedBox(height: 18),

              // 2. Staff Profile Card (from wireframe)
              _buildProfileCard(),

              const SizedBox(height: 18),

              // 3. Attendance Counter Mini Cards (Hadir, Izin, Sakit, Alfa)
              _buildStatsGrid(),

              const SizedBox(height: 20),

              // 4. Live Digital Clock & GPS Office Location Card
              _buildClockAndLocationCard(),

              const SizedBox(height: 20),

              // 5. Dual Action Buttons: Absen Masuk & Absen Pulang
              _buildAttendanceActionCards(),

              const SizedBox(height: 24),

              // 6. Menu Akses Cepat (Quick Access)
              _buildQuickAccessSection(),

              const SizedBox(height: 20),

              // 7. Riwayat Kehadiran Hari Ini
              _buildTodayLogCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppColors.cardShadow,
              ),
              child: Row(
                children: const [
                  Text(
                    'SSI',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryCoral,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'STAFF PRESENSI',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            shape: BoxShape.circle,
            boxShadow: AppColors.softShadow,
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary, size: 22),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.peachAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryCoral, width: 2),
                ),
                child: const Center(
                  child: Icon(Icons.person, size: 36, color: AppColors.primaryCoral),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _hasClockedIn ? AppColors.success : AppColors.warning,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Info Name & Role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _staffName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'NIP: $_staffNip • Staff Operasional',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: _hasClockedIn ? AppColors.successLight : AppColors.peachAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _hasClockedIn ? '● Sudah Absen Masuk' : '○ Belum Absen Masuk',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _hasClockedIn ? AppColors.success : AppColors.primaryCoral,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        _buildStatBox(label: 'Hadir', value: '21', color: AppColors.success, icon: Icons.check_circle_outline_rounded),
        const SizedBox(width: 10),
        _buildStatBox(label: 'Izin', value: '2', color: AppColors.warning, icon: Icons.event_available_rounded),
        const SizedBox(width: 10),
        _buildStatBox(label: 'Sakit', value: '1', color: AppColors.danger, icon: Icons.medical_services_outlined),
        const SizedBox(width: 10),
        _buildStatBox(label: 'Alfa', value: '0', color: AppColors.textMuted, icon: Icons.cancel_outlined),
      ],
    );
  }

  Widget _buildStatBox({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClockAndLocationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Text(
            _currentDate.isNotEmpty ? _currentDate : 'Memuat tanggal...',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          // Large digital time (from wireframe)
          Text(
            _currentTime.isNotEmpty ? _currentTime : '07:23:00',
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryCoral,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 14),
          // GPS Location verification badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.peachSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.location_on_rounded, size: 16, color: AppColors.success),
                SizedBox(width: 6),
                Text(
                  'Kantor Pusat SSI • Dalam Radius (5m)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceActionCards() {
    return Row(
      children: [
        // 1. Absen Masuk Card
        Expanded(
          child: GestureDetector(
            onTap: () => _openCameraAttendance(true),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.login_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Absen Masuk',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Jadwal: 08:00 WIB',
                    style: TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 14),

        // 2. Absen Pulang Card
        Expanded(
          child: GestureDetector(
            onTap: () => _openCameraAttendance(false),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF5733), Color(0xFFD93815)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF5733).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.logout_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Absen Pulang',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Jadwal: 17:00 WIB',
                    style: TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Layanan Staff SSI',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildServiceIcon(
              icon: Icons.calendar_today_rounded,
              label: 'Riwayat',
              color: AppColors.primaryCoral,
              onTap: widget.onNavigateToHistory,
            ),
            _buildServiceIcon(
              icon: Icons.assignment_turned_in_outlined,
              label: 'Izin / Cuti',
              color: AppColors.warning,
              onTap: widget.onNavigateToPermit,
            ),
            _buildServiceIcon(
              icon: Icons.qr_code_scanner_rounded,
              label: 'Scan QR',
              color: AppColors.success,
              onTap: () => _openCameraAttendance(true),
            ),
            _buildServiceIcon(
              icon: Icons.account_circle_outlined,
              label: 'Profil',
              color: AppColors.info,
              onTap: widget.onNavigateToProfile,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceIcon({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppColors.cardShadow,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayLogCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Log Presensi Hari Ini',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: widget.onNavigateToHistory,
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryCoral),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _hasClockedIn ? AppColors.successLight : AppColors.peachAccent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _hasClockedIn ? Icons.check_circle_rounded : Icons.schedule_rounded,
                  color: _hasClockedIn ? AppColors.success : AppColors.primaryCoral,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _hasClockedIn
                          ? 'Absen Masuk: ${_clockInTime ?? "07:58 WIB"}'
                          : 'Belum melakukan absensi hari ini',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _hasClockedIn
                          ? 'Terverifikasi Biometrik Wajah • Tepat Waktu'
                          : 'Silakan klik "Absen Masuk" saat tiba di kantor',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
