import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../models/participant.dart';
import '../../viewmodels/presensi_viewmodel.dart';
import '../mahasiswa/mahasiswa_widgets.dart';
import 'daftar_peserta_page.dart';

/// View: Pemindai QR Presensi (tema gelap).
///
/// Kamera belum terhubung: ketuk area pemindai untuk mensimulasikan
/// pembacaan QR peserta berikutnya lewat [PresensiViewModel.simulateScan].
/// TODO: ganti area pemindai dengan `MobileScanner` dari paket
/// `mobile_scanner` lalu kirim NIM hasil scan ke `vm.checkIn(nim)`.
class ScanQrPage extends StatefulWidget {
  const ScanQrPage({super.key});

  @override
  State<ScanQrPage> createState() => _ScanQrPageState();
}

class _ScanQrPageState extends State<ScanQrPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _line = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  bool _flash = false;
  CheckInResult? _result;

  @override
  void initState() {
    super.initState();
    _line.repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<PresensiViewModel>().clearLastScanned();
    });
  }

  @override
  void dispose() {
    _line.dispose();
    super.dispose();
  }

  void _scan() {
    final PresensiViewModel vm = context.read<PresensiViewModel>();
    final CheckInResult? result = vm.simulateScan();
    if (result == null) {
      showSnack(context, 'Semua peserta sudah tercatat hadir.');
      return;
    }
    _line.stop();
    setState(() => _result = result);
  }

  void _continue() {
    context.read<PresensiViewModel>().clearLastScanned();
    setState(() => _result = null);
    _line.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    final PresensiViewModel vm = context.watch<PresensiViewModel>();
    final Participant? scanned = vm.lastScanned;

    return Scaffold(
      backgroundColor: AppColors.scannerBg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _TopBar(
                  flash: _flash,
                  onToggleFlash: () => setState(() => _flash = !_flash),
                ),
                const SizedBox(height: 12),
                _EventStrip(vm: vm),
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: _result == null ? _scan : null,
                    child: Semantics(
                      button: true,
                      label: 'Area pemindai QR. Ketuk untuk simulasi scan.',
                      child: _ScannerFrame(
                        animation: _line,
                        paused: _result != null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _result == null
                      ? 'Arahkan kamera ke QR Code E-Tiket peserta.\n'
                            '(Ketuk area pemindai untuk simulasi)'
                      : 'Pemindaian dijeda',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.5,
                    color: Color(0xB3FFFFFF),
                  ),
                ),
                const SizedBox(height: 16),
                if (_result != null && scanned != null) ...[
                  _ResultCard(
                    participant: scanned,
                    result: _result!,
                    onContinue: _continue,
                  ),
                  const SizedBox(height: 14),
                ],
                OutlinedButton.icon(
                  onPressed: () => showManualCheckIn(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0x40FFFFFF)),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  icon: const Icon(
                    Icons.keyboard_alt_outlined,
                    color: AppColors.primaryOnDark,
                  ),
                  label: const Text('QR Rusak? Input NIM Manual'),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _DarkStat(
                        label: 'Sudah Hadir',
                        value: vm.presentCount,
                        icon: Icons.how_to_reg_rounded,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DarkStat(
                        label: 'Belum Hadir',
                        value: vm.absentCount,
                        icon: Icons.person_outline_rounded,
                        color: AppColors.primaryOnDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.scannerSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: AppColors.primaryOnDark,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tetap bisa dipakai tanpa internet. Data hadir '
                          'terkirim otomatis saat online.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Color(0xB3FFFFFF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.flash, required this.onToggleFlash});

  final bool flash;
  final VoidCallback onToggleFlash;

  @override
  Widget build(BuildContext context) {
    ButtonStyle round() => IconButton.styleFrom(
      backgroundColor: AppColors.scannerSurface,
      foregroundColor: Colors.white,
    );

    return Row(
      children: [
        IconButton(
          tooltip: 'Kembali',
          style: round(),
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pemindai QR Presensi',
                style: TextStyle(
                  fontFamily: AppFonts.heading,
                  fontSize: 17,
                  letterSpacing: -0.2,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                'Panitia • Gerbang Masuk',
                style: TextStyle(fontSize: 11.5, color: Color(0x99FFFFFF)),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: flash ? 'Matikan senter' : 'Nyalakan senter',
          style: round(),
          onPressed: onToggleFlash,
          icon: Icon(
            flash ? Icons.flash_on_rounded : Icons.flash_off_rounded,
            color: flash ? AppColors.primaryOnDark : Colors.white,
          ),
        ),
      ],
    );
  }
}

class _EventStrip extends StatelessWidget {
  const _EventStrip({required this.vm});

  final PresensiViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.scannerSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.event_rounded,
                size: 18,
                color: AppColors.primaryOnDark,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  vm.eventTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const PillBadge(
                text: 'Aktif',
                background: AppColors.primaryOnDark,
                foreground: AppColors.onLight,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.place_outlined,
                size: 16,
                color: Color(0x99FFFFFF),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  vm.eventLocation,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xB3FFFFFF),
                  ),
                ),
              ),
              Text(
                '${vm.presentCount}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryOnDark,
                ),
              ),
              Text(
                ' / ${vm.total} hadir',
                style: const TextStyle(fontSize: 12, color: Color(0xB3FFFFFF)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScannerFrame extends StatelessWidget {
  const _ScannerFrame({required this.animation, required this.paused});

  final Animation<double> animation;
  final bool paused;

  static const double _size = 240;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0x14FFFFFF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                paused
                    ? Icons.check_circle_outline_rounded
                    : Icons.qr_code_2_rounded,
                size: 72,
                color: const Color(0x33FFFFFF),
              ),
            ),
          ),
          const Positioned.fill(child: CustomPaint(painter: _CornerPainter())),
          if (!paused)
            AnimatedBuilder(
              animation: animation,
              builder: (BuildContext context, Widget? child) {
                return Positioned(
                  left: 18,
                  right: 18,
                  top: 18 + (_size - 40) * animation.value,
                  child: child!,
                );
              },
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.primaryOnDark,
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: const [
                    BoxShadow(color: AppColors.primaryOnDark, blurRadius: 12),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  const _CornerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppColors.primaryOnDark
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    const double l = 34;
    final double w = size.width;
    final double h = size.height;

    canvas
      ..drawLine(Offset.zero, const Offset(l, 0), paint)
      ..drawLine(Offset.zero, const Offset(0, l), paint)
      ..drawLine(Offset(w, 0), Offset(w - l, 0), paint)
      ..drawLine(Offset(w, 0), Offset(w, l), paint)
      ..drawLine(Offset(0, h), Offset(l, h), paint)
      ..drawLine(Offset(0, h), Offset(0, h - l), paint)
      ..drawLine(Offset(w, h), Offset(w - l, h), paint)
      ..drawLine(Offset(w, h), Offset(w, h - l), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.participant,
    required this.result,
    required this.onContinue,
  });

  final Participant participant;
  final CheckInResult result;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final bool success = result == CheckInResult.berhasil;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              success
                  ? const PillBadge.success(
                      text: 'Presensi Berhasil Tercatat',
                      icon: Icons.check_circle_rounded,
                    )
                  : const PillBadge(
                      text: 'Sudah Tercatat Sebelumnya',
                      icon: Icons.info_outline_rounded,
                    ),
              const Spacer(),
              Text(
                '${participant.checkInTime} WIB',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nama Mahasiswa',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      participant.name,
                      style: const TextStyle(
                        fontFamily: AppFonts.heading,
                        fontSize: 19,
                        letterSpacing: -0.2,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'NIM ${participant.nim}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      participant.program,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Kursi',
                      style: TextStyle(fontSize: 10.5, color: AppColors.glow),
                    ),
                    Text(
                      participant.seat,
                      style: const TextStyle(
                        fontFamily: AppFonts.heading,
                        fontSize: 22,
                        letterSpacing: -0.2,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const InfoLine(
            icon: Icons.inventory_2_outlined,
            text: 'Fasilitas: E-Sertifikat & Snack Box Panitia',
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: onContinue,
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: const Text('Verifikasi & Lanjut Scan'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DarkStat extends StatelessWidget {
  const _DarkStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.scannerSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withAlpha(50),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Color(0x99FFFFFF)),
              ),
              Text(
                '$value Org',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
