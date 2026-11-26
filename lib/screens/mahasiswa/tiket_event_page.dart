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
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                    children: [
                      _TicketCard(ticket: ticket, student: student),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () =>
                            showComingSoon(context, 'Unduh Tiket (PDF)'),
                        icon: const Icon(
                          Icons.picture_as_pdf_rounded,
                          size: 20,
                        ),
                        label: const Text('Unduh Tiket (PDF)'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          shape: buttonShape,
                          textStyle: const TextStyle(
                            fontFamily: AppFonts.body,
                            fontWeight: FontWeight.w700,
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
                          foregroundColor: AppColors.glow,
                          side: const BorderSide(color: AppColors.border),
                          shape: buttonShape,
                          textStyle: const TextStyle(
                            fontFamily: AppFonts.body,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
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
            decoration: AppDecorations.brandPanel(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              shadow: false,
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
                    const PillBadge.glass(text: 'Masuk Tanpa Antre'),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  ticket.title,
                  style: const TextStyle(
                    fontFamily: AppFonts.heading,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    letterSpacing: -0.1,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ticket.organizer,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xD9FFFFFF),
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
                        sub: student.isMahasiswa
                            ? 'NIM: ${student.nim}'
                            : student.email,
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
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: _Field(label: 'Peminatan', value: track),
                  ),
                ],
                const SizedBox(height: 20),
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
                                style: TextStyle(fontWeight: FontWeight.w700),
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
                const SizedBox(height: 20),
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
                    letterSpacing: -0.2,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 16),
                PopIn(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.outline, width: 2),
                    ),
                    child: QrCodeView(data: ticket.ticketId, size: 190),
                  ),
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 20),
                const Text(
                  'Kode Tiket',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                const SizedBox(height: 2),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: ticket.ticketId));
                    showSnack(context, 'Kode tiket disalin.');
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
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: AppColors.glow,
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
                  'No. Referensi: ${ticket.refId}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Satu tiket hanya berlaku untuk satu orang.',
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
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
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
            fontWeight: FontWeight.w700,
            height: 1.25,
            color: big ? AppColors.primary : AppColors.textPrimary,
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primarySoft.withAlpha(110),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.glow),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Panduan Gate Masuk',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.glow,
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
                    color: AppColors.glow,
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
