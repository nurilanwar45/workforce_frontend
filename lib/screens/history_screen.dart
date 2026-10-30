import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/top_app_bar.dart';

class AttendanceRecord {
  final String date;
  final String dayName;
  final String checkIn;
  final String checkOut;
  final String status; // 'Hadir', 'Izin', 'Sakit', 'Terlambat'
  final String location;
  final String duration;

  const AttendanceRecord({
    required this.date,
    required this.dayName,
    required this.checkIn,
    required this.checkOut,
    required this.status,
    required this.location,
    required this.duration,
  });
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'Semua';
  final int _selectedYear = 2026;

  final List<AttendanceRecord> _records = const [
    AttendanceRecord(
      date: '30 Okt 2026',
      dayName: 'Jumat',
      checkIn: '07:58 WIB',
      checkOut: '17:02 WIB',
      status: 'Hadir',
      location: 'Kantor Pusat SSI - Lantai 5',
      duration: '9 Jam 4 Menit',
    ),
    AttendanceRecord(
      date: '29 Okt 2026',
      dayName: 'Kamis',
      checkIn: '07:50 WIB',
      checkOut: '17:15 WIB',
      status: 'Hadir',
      location: 'Kantor Pusat SSI - Lantai 5',
      duration: '9 Jam 25 Menit',
    ),
    AttendanceRecord(
      date: '28 Okt 2026',
      dayName: 'Rabu',
      checkIn: '08:12 WIB',
      checkOut: '17:30 WIB',
      status: 'Terlambat',
      location: 'Kantor Pusat SSI - Lantai 5',
      duration: '9 Jam 18 Menit',
    ),
    AttendanceRecord(
      date: '27 Okt 2026',
      dayName: 'Selasa',
      checkIn: '-',
      checkOut: '-',
      status: 'Izin',
      location: 'Izin Keperluan Mendesak',
      duration: '0 Jam',
    ),
    AttendanceRecord(
      date: '26 Okt 2026',
      dayName: 'Senin',
      checkIn: '07:45 WIB',
      checkOut: '17:00 WIB',
      status: 'Hadir',
      location: 'Kantor Pusat SSI - Lantai 5',
      duration: '9 Jam 15 Menit',
    ),
    AttendanceRecord(
      date: '23 Okt 2026',
      dayName: 'Jumat',
      checkIn: '-',
      checkOut: '-',
      status: 'Sakit',
      location: 'Surat Keterangan Dokter',
      duration: '0 Jam',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _records.where((r) {
      if (_selectedFilter == 'Semua') return true;
      return r.status.toLowerCase() == _selectedFilter.toLowerCase();
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.peachBackground,
      appBar: const TopAppBar(
        title: 'Riwayat Presensi',
        subtitle: 'Laporan Kehadiran Staff SSI',
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Mini Calendar Selector (from wireframe)
            _buildMonthCalendarCard(),

            const SizedBox(height: 18),

            // 2. Filter Pills
            _buildFilterTabs(),

            const SizedBox(height: 18),

            // 3. Attendance Records List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = filtered[index];
                return _buildRecordCard(item);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthCalendarCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Oktober $_selectedYear',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, color: AppColors.primaryCoral),
                    onPressed: () {},
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, color: AppColors.primaryCoral),
                    onPressed: () {},
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Day initials
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Text('Min', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.danger)),
              Text('Sen', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
              Text('Sel', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
              Text('Rab', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
              Text('Kam', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
              Text('Jum', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
              Text('Sab', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 10),
          // Sample days grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDayDot('25', isPast: true),
              _buildDayDot('26', statusColor: AppColors.success),
              _buildDayDot('27', statusColor: AppColors.warning),
              _buildDayDot('28', statusColor: Colors.orange),
              _buildDayDot('29', statusColor: AppColors.success),
              _buildDayDot('30', statusColor: AppColors.success, isToday: true),
              _buildDayDot('31', isWeekend: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayDot(String day, {Color? statusColor, bool isToday = false, bool isPast = false, bool isWeekend = false}) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isToday ? AppColors.primaryCoral : Colors.transparent,
            shape: BoxShape.circle,
            border: isToday ? null : Border.all(color: Colors.transparent),
          ),
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                color: isToday
                    ? Colors.white
                    : (isWeekend ? AppColors.danger : (isPast ? AppColors.textMuted : AppColors.textPrimary)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: statusColor ?? Colors.transparent,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    final filters = ['Semua', 'Hadir', 'Izin', 'Sakit', 'Terlambat'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(f),
              selected: isSelected,
              onSelected: (val) {
                if (val) setState(() => _selectedFilter = f);
              },
              selectedColor: AppColors.primaryCoral,
              backgroundColor: AppColors.cardWhite,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide(
                color: isSelected ? AppColors.primaryCoral : AppColors.borderLight,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecordCard(AttendanceRecord item) {
    Color badgeColor = AppColors.success;
    if (item.status == 'Izin') badgeColor = AppColors.warning;
    if (item.status == 'Sakit') badgeColor = AppColors.danger;
    if (item.status == 'Terlambat') badgeColor = Colors.orange;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${item.dayName}, ${item.date}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.status,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: badgeColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTimeBox('Jam Masuk', item.checkIn, Icons.login_rounded, AppColors.success),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTimeBox('Jam Pulang', item.checkOut, Icons.logout_rounded, AppColors.primaryCoral),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  item.location,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                item.duration,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBox(String label, String time, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.peachSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              Text(time, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }
}
