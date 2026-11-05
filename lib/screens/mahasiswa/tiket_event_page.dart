import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../models/event_ticket.dart';
import '../../models/student_profile.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'mahasiswa_widgets.dart';

/// View: E-Tiket & QR presensi.
///
/// [ticket] dikirim dari halaman asal lewat constructor (Navigator.push),
/// termasuk data input formulir pendaftaran (WhatsApp, jalur, track).
class TiketEventPage extends StatelessWidget {
  const TiketEventPage({super.key, required this.ticket});

  final EventTicket ticket;

  @override
  Widget build(BuildContext context) {
    final StudentProfile student = context.watch<AuthViewModel>().student;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScreenAppBar(
        title: 'E-Tiket & Presensi',
        subtitle: 'Detail Informasi Acara',
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                    children: [
                      _TicketCard(ticket: ticket, student: student),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: () =>
                            showComingSoon(context, 'Unduh Tiket (PDF)'),
                        icon: const Icon(Icons.picture_as_pdf_rounded, size: 20),
                        label: const Text('Unduh Tiket (PDF)'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: AppFonts.body,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => showComingSoon(
                          context,
                          'Tambah ke Google Calendar',
                        ),
                        icon: const Icon(Icons.edit_calendar_rounded, size: 20),
                        label: const Text('Tambah ke Google Calendar'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          foregroundColor: AppColors.navy,
                          side: const BorderSide(color: AppColors.outline),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: AppFonts.body,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const _GateGuide(),
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

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket, required this.student});

  final EventTicket ticket;
  final StudentProfile student;

  @override
  Widget build(BuildContext context) {
    final String? phone = ticket.phone;
    final String? participation = ticket.participation;
    final String? track = ticket.track;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceHigh),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Kepala tiket
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.navyLight, AppColors.navy],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ticket.verified
                        ? const PillBadge.success(
                            text: 'Tiket Terverifikasi',
                            icon: Icons.verified_rounded,
                          )
                        : const PillBadge(
                            text: 'Terdaftar (Tiket Siap)',
                            icon: Icons.confirmation_number_rounded,
                          ),
                    const PillBadge.glass(text: 'Reg. Fast-Pass'),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  ticket.title,
                  style: const TextStyle(
                    fontFamily: AppFonts.heading,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    letterSpacing: -0.3,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ticket.organizer,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.periwinkle,
                  ),
                ),
              ],
            ),
          ),
          // Info peserta
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _Field(
                        label: 'Peserta Terdaftar',
                        value: student.name,
                        sub: 'NIM: ${student.nim}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    _Field(
                      label: 'Alokasi Kursi',
                      value: ticket.seat,
                      sub: 'Reguler',
                      big: true,
                      alignEnd: true,
                    ),
                  ],
                ),
                if (phone != null || participation != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _Field(
                          label: 'Kontak WhatsApp',
                          value: phone ?? '-',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Field(
                          label: 'Jalur Partisipasi',
                          value: participation ?? '-',
                        ),
                      ),
                    ],
                  ),
                ],
                if (track != null) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: _Field(label: 'Peminatan', value: track),
                  ),
                ],
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.radio_button_checked_rounded,
                        size: 18,
                        color: AppColors.success,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: 'Status presensi: ',
                            children: [
                              TextSpan(
                                text: 'Siap Scan di Lokasi',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _Field(
                        label: 'Jadwal Sesi',
                        value: ticket.timeLabel,
                        sub: ticket.dateLabel,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Field(
                        label: 'Fasilitas',
                        value: ticket.facilities,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const _TicketDivider(),
          // QR
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              children: [
                const Text(
                  'Tiket Presensi',
                  style: TextStyle(
                    fontFamily: AppFonts.heading,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.outline, width: 2),
                  ),
                  child: QrCodeView(data: ticket.ticketId, size: 190),
                ),
                const SizedBox(height: 14),
                Text(
                  'Tunjukkan QR ini ke panitia di pintu masuk '
                  '${ticket.location}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Smart Pass ID',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                const SizedBox(height: 2),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: ticket.ticketId));
                    showSnack(context, 'Smart Pass ID disalin.');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          ticket.ticketId,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: AppColors.navy,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.copy_rounded,
                          size: 16,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Ref ID: ${ticket.refId} • Sistem Terintegrasi SIAKAD',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Validasi Otomatis Smart Campus • Anti-Duplikasi',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.value,
    this.sub,
    this.big = false,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final String? sub;
  final bool big;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontFamily: big ? AppFonts.heading : null,
            fontSize: big ? 26 : 14,
            fontWeight: FontWeight.w800,
            height: 1.25,
            color: big ? AppColors.navy : AppColors.textPrimary,
          ),
        ),
        if (sub != null)
          Text(
            sub!,
            style: const TextStyle(
              fontSize: 12,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }
}

/// Garis putus-putus dengan lekukan di sisi kiri dan kanan seperti tiket.
class _TicketDivider extends StatelessWidget {
  const _TicketDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final int count = (constraints.maxWidth / 12).floor();
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List<Widget>.generate(
                      count,
                      (int _) => Container(
                        width: 6,
                        height: 2,
                        color: AppColors.outline,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const Positioned(left: -12, top: 0, child: _Notch()),
          const Positioned(right: -12, top: 0, child: _Notch()),
        ],
      ),
    );
  }
}

class _Notch extends StatelessWidget {
  const _Notch();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: AppColors.background,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _GateGuide extends StatelessWidget {
  const _GateGuide();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentSoft.withAlpha(110),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.accentDark),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Panduan Gate Masuk',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accentDark,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Pintu dibuka 30 menit sebelum acara dimulai. Pastikan '
                  'kecerahan layar ponsel Anda maksimal saat pemindaian kode '
                  'QR.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: AppColors.accentDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}