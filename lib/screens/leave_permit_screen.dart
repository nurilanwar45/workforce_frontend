import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/top_app_bar.dart';

class LeavePermitScreen extends StatefulWidget {
  const LeavePermitScreen({super.key});

  @override
  State<LeavePermitScreen> createState() => _LeavePermitScreenState();
}

class _LeavePermitScreenState extends State<LeavePermitScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  String _selectedType = 'Izin Sakit';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _permitHistory = [
    {
      'type': 'Izin Keperluan Keluarga',
      'dates': '27 Okt 2026',
      'duration': '1 Hari',
      'status': 'Disetujui',
      'statusColor': AppColors.success,
      'notes': 'Menghadiri acara keluarga mendesak',
    },
    {
      'type': 'Izin Sakit',
      'dates': '23 Okt 2026',
      'duration': '1 Hari',
      'status': 'Disetujui',
      'statusColor': AppColors.success,
      'notes': 'Flu dan demam, surat dokter terlampir',
    },
    {
      'type': 'Cuti Tahunan',
      'dates': '10 Nov - 12 Nov 2026',
      'duration': '3 Hari',
      'status': 'Menunggu Persetujuan',
      'statusColor': AppColors.warning,
      'notes': 'Cuti tahunan sisa kuota',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitPermit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _permitHistory.insert(0, {
        'type': _selectedType,
        'dates': '${_startDate.day}/${_startDate.month}/${_startDate.year}',
        'duration': '1 Hari',
        'status': 'Menunggu Persetujuan',
        'statusColor': AppColors.warning,
        'notes': _notesController.text,
      });
      _notesController.clear();
      _tabController.animateTo(1);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Pengajuan izin berhasil dikirim ke HRD!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.peachBackground,
      appBar: const TopAppBar(
        title: 'Izin & Cuti',
        subtitle: 'Pengajuan Dispensasi Staff SSI',
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Tab Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: AppColors.softShadow,
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: AppColors.primaryCoral,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  tabs: const [
                    Tab(text: 'Buat Pengajuan'),
                    Tab(text: 'Riwayat Izin'),
                  ],
                ),
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFormTab(),
                  _buildHistoryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      child: Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(22),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Formulir Izin / Cuti',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              const Text(
                'Lengkapi keterangan pengajuan untuk verifikasi atasan',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),

              // Dropdown Jenis Izin
              const Text('Jenis Pengajuan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.peachSurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedType,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primaryCoral),
                    items: const [
                      DropdownMenuItem(value: 'Izin Sakit', child: Text('Izin Sakit (Medical)')),
                      DropdownMenuItem(value: 'Cuti Tahunan', child: Text('Cuti Tahunan (Annual Leave)')),
                      DropdownMenuItem(value: 'Izin Keperluan Keluarga', child: Text('Izin Keperluan Keluarga')),
                      DropdownMenuItem(value: 'Izin Khusus / Dinas', child: Text('Izin Khusus / Tugas Luar')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedType = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tanggal
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tanggal Mulai', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        _buildDateButton(_startDate, (d) => setState(() => _startDate = d)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tanggal Selesai', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        _buildDateButton(_endDate, (d) => setState(() => _endDate = d)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Alasan / Keterangan
              const Text('Alasan Pengajuan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Tuliskan alasan pengajuan secara jelas...',
                  hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  filled: true,
                  fillColor: AppColors.peachSurface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.all(14),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Alasan wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Upload File Surat / Bukti
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primaryCoral.withValues(alpha: 0.5), style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(14),
                  color: AppColors.peachAccent.withValues(alpha: 0.3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.cloud_upload_outlined, color: AppColors.primaryCoral, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Unggah Surat Dokter / Bukti (Opsional)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryCoral),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitPermit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryCoral,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Kirimkan Pengajuan Izin', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateButton(DateTime current, ValueChanged<DateTime> onPicked) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: current,
          firstDate: DateTime(2025),
          lastDate: DateTime(2028),
        );
        if (picked != null) onPicked(picked);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.peachSurface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primaryCoral),
            const SizedBox(width: 8),
            Text('${current.day}/${current.month}/${current.year}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      itemCount: _permitHistory.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _permitHistory[index];
        final Color statusColor = item['statusColor'];

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
                    item['type'],
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item['status'],
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Periode: ${item['dates']} (${item['duration']})',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryCoral),
              ),
              const SizedBox(height: 4),
              Text(
                item['notes'],
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        );
      },
    );
  }
}
