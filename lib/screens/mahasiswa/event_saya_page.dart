import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_routes.dart';
import '../../core/app_theme.dart';
import '../../models/completed_event.dart';
import '../../models/event_ticket.dart';
import '../../viewmodels/ticket_viewmodel.dart';
import 'mahasiswa_widgets.dart';

/// View: tab "Event Saya".
///
/// [TabBar] memisahkan tiket berdasarkan status: Mendatang, Selesai, dan
/// Dibatalkan. Seluruh datanya dibaca dari [TicketViewModel].
class EventSayaPage extends StatelessWidget {
  const EventSayaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TicketViewModel vm = context.watch<TicketViewModel>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Column(
          children: [
            const HeroHeader(
              eyebrow: 'Tiket kamu',
              title: 'Event Saya',
              subtitle: 'Tiket, QR presensi, dan riwayat kegiatan kamu.',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Gap.page, 12, Gap.page, 0),
              child: SegmentTabBar(
                labels: [
                  'Mendatang (${vm.totalActive})',
                  'Selesai (${vm.totalCompleted})',
                  'Dibatalkan (${vm.totalCancelled})',
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [_UpcomingTab(), _HistoryTab(), _CancelledTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kerangka list yang dipakai ketiga tab.
class _TabList extends StatelessWidget {
  const _TabList({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          children: children,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 1: Mendatang
// ---------------------------------------------------------------------------

class _UpcomingTab extends StatelessWidget {
  const _UpcomingTab();

  Future<void> _cancel(BuildContext context, EventTicket ticket) async {
    final TicketViewModel vm = context.read<TicketViewModel>();
    final bool ok = await confirmDialog(
      context,
      title: 'Batalkan pendaftaran?',
      message: 'Tiket "${ticket.title}" akan dipindahkan ke tab Dibatalkan.',
      confirmLabel: 'Batalkan',
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    vm.cancelTicket(ticket);
    showSnack(context, 'Pendaftaran dibatalkan.');
  }

  @override
  Widget build(BuildContext context) {
    final TicketViewModel vm = context.watch<TicketViewModel>();
    final List<EventTicket> tickets = vm.activeTickets;

    return _TabList(
      children: [
        SectionHeader(
          eyebrow: 'Mendatang',
          title: 'Tiket Acara Terdekat',
          trailingText: '${vm.totalActive} Tiket Aktif',
        ),
        const SizedBox(height: 12),
        if (tickets.isEmpty)
          const EmptyState(
            icon: Icons.confirmation_number_outlined,
            title: 'Belum ada tiket aktif',
            message:
                'Daftar event dari Beranda atau Cari Event, tiketnya '
                'akan muncul di sini.',
          ),
        for (final (int i, EventTicket ticket) in tickets.indexed) ...[
          Reveal(
            index: i,
            child: _UpcomingCard(
              ticket: ticket,
              onCancel: () => _cancel(context, ticket),
            ),
          ),
          const SizedBox(height: 20),
        ],
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 18,
                color: AppColors.textMuted,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'QR Tiket dapat dibuka kembali tanpa internet saat offline '
                  'menjelang acara dimulai. Pastikan baterai ponsel mencukupi.',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 2: Selesai
// ---------------------------------------------------------------------------

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  Future<void> _review(BuildContext context, CompletedEvent event) async {
    final TicketViewModel vm = context.read<TicketViewModel>();
    final EventReview? result = await showModalBottomSheet<EventReview>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
          child: _ReviewSheet(title: event.title, initial: vm.reviewFor(event)),
        );
      },
    );
    if (result == null || !context.mounted) return;
    vm.submitReview(event, rating: result.rating, comment: result.comment);
    showSnack(context, 'Terima kasih, ulasan Anda sudah disimpan.');
  }

  @override
  Widget build(BuildContext context) {
    final TicketViewModel vm = context.watch<TicketViewModel>();

    return _TabList(
      children: [
        SectionHeader(
          title: 'Riwayat Kegiatan Selesai',
          trailingText: '${vm.totalSkpiPoints} Poin SKPI',
        ),
        const SizedBox(height: 12),
        for (final CompletedEvent event in vm.completedEvents) ...[
          _HistoryCard(
            event: event,
            review: vm.reviewFor(event),
            onReview: () => _review(context, event),
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 3: Dibatalkan
// ---------------------------------------------------------------------------

class _CancelledTab extends StatelessWidget {
  const _CancelledTab();

  @override
  Widget build(BuildContext context) {
    final List<EventTicket> tickets = context
        .watch<TicketViewModel>()
        .cancelledTickets;

    return _TabList(
      children: [
        if (tickets.isEmpty)
          const EmptyState(
            icon: Icons.event_busy_rounded,
            title: 'Tidak ada event dibatalkan',
            message: 'Event yang Anda batalkan akan muncul di sini.',
          ),
        for (final EventTicket ticket in tickets) ...[
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              leading: const CircleAvatar(
                backgroundColor: AppColors.primarySoft,
                child: Icon(Icons.event_busy_rounded, color: AppColors.danger),
              ),
              title: Text(
                ticket.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Text('${ticket.dateLabel} • ${ticket.location}'),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Widget pendukung
// ---------------------------------------------------------------------------

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard({required this.ticket, required this.onCancel});

  final EventTicket ticket;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final bool ready = !ticket.verified;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Kepala kartu: foto event penuh dengan judul di atasnya.
          SizedBox(
            height: 190,
            child: Stack(
              fit: StackFit.expand,
              children: [
                EventImage(
                  path: ticket.image,
                  color: AppColors.primary,
                  icon: Icons.confirmation_number_rounded,
                  semanticLabel: 'Foto ${ticket.title}',
                ),
                const PhotoScrim(strength: 0xE6),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: ticket.verified
                                ? const PillBadge.overlay(
                                    text: 'Terverifikasi',
                                    icon: Icons.verified_rounded,
                                  )
                                : const PillBadge.overlay(
                                    text: 'Tiket Siap',
                                    icon: Icons.confirmation_number_rounded,
                                  ),
                          ),
                          const Spacer(),
                          PillBadge.overlay(text: 'Kursi: ${ticket.seat}'),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        ticket.organizer.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                          color: Color(0xD9FFFFFF),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ticket.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppFonts.heading,
                          fontSize: 19,
                          letterSpacing: -0.3,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _LabelValue(
                        label: 'Jadwal',
                        value: ticket.dateLabel,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _LabelValue(
                        label: 'Lokasi',
                        value: ticket.location,
                      ),
                    ),
                  ],
                ),
                if (ready) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTint.withAlpha(150),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.qr_code_2_rounded, color: AppColors.glow),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'QR Tiket Siap Digunakan',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.glow,
                                ),
                              ),
                              Text(
                                'Tunjukkan ke panitia di pintu gerbang',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                ready
                    ? FilledButton(
                        onPressed: () => openTicket(context, ticket),
                        style: _buttonStyle(filled: true),
                        child: const Text('Buka QR Tiket Presensi'),
                      )
                    : OutlinedButton(
                        onPressed: () => openTicket(context, ticket),
                        style: _buttonStyle(filled: false),
                        child: const Text('Lihat E-Tiket'),
                      ),
                const SizedBox(height: 4),
                Center(
                  child: TextButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Batalkan Pendaftaran'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.danger,
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
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.event,
    required this.review,
    required this.onReview,
  });

  final CompletedEvent event;
  final EventReview? review;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final EventReview? review = this.review;

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              const PillBadge.success(
                text: 'Presensi Terverifikasi (100%)',
                icon: Icons.check_circle_rounded,
              ),
              PillBadge(text: '+${event.points} Poin SKPI'),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            event.title,
            style: const TextStyle(
              fontFamily: AppFonts.heading,
              fontSize: 16,
              letterSpacing: -0.2,
              fontWeight: FontWeight.w700,
              height: 1.3,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Dilaksanakan pada ${event.heldOn}',
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.shield_rounded,
                  size: 20,
                  color: AppColors.success,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No. SKPI: ${event.skpiNumber}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Text(
                        'Tervalidasi oleh BAAK Kemahasiswaan',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (review != null) ...[
            const SizedBox(height: 12),
            _ReviewSummary(review: review),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: FilledButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.sertifikat),
                  style: _buttonStyle(filled: true),
                  child: const Text('Unduh E-Sertifikat'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: OutlinedButton(
                  onPressed: onReview,
                  style: _buttonStyle(filled: false),
                  child: Text(review == null ? 'Beri Ulasan' : 'Ubah Ulasan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Menampilkan ulasan yang sudah diisi mahasiswa (hasil input).
class _ReviewSummary extends StatelessWidget {
  const _ReviewSummary({required this.review});

  final EventReview review;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primarySoft.withAlpha(110),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Ulasan Anda',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.glow,
                ),
              ),
              const SizedBox(width: 8),
              for (int i = 0; i < 5; i++)
                Icon(
                  i < review.rating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 16,
                  color: AppColors.glow,
                ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '"${review.comment}"',
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                fontStyle: FontStyle.italic,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

ButtonStyle _buttonStyle({required bool filled}) {
  final RoundedRectangleBorder shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
  );
  const TextStyle text = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );

  return filled
      ? FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(46),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: shape,
          textStyle: text,
        )
      : OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(46),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          foregroundColor: AppColors.glow,
          side: const BorderSide(color: AppColors.border),
          shape: shape,
          textStyle: text,
        );
}

class _LabelValue extends StatelessWidget {
  const _LabelValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            height: 1.35,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet ulasan. Input komentar dibaca lewat [TextEditingController]
/// lalu dikembalikan ke halaman pemanggil sebagai [EventReview].
class _ReviewSheet extends StatefulWidget {
  const _ReviewSheet({required this.title, this.initial});

  final String title;
  final EventReview? initial;

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  late final TextEditingController _comment = TextEditingController(
    text: widget.initial?.comment ?? '',
  );
  late int _rating = widget.initial?.rating ?? 0;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  void _send() {
    Navigator.of(context)
        .pop(EventReview(rating: _rating, comment: _comment.text));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Beri Ulasan',
              style: TextStyle(
                fontFamily: AppFonts.heading,
                fontSize: 18,
                letterSpacing: -0.2,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < 5; i++)
                  IconButton(
                    tooltip: '${i + 1} bintang',
                    iconSize: 36,
                    icon: Icon(
                      i < _rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: AppColors.glow,
                    ),
                    onPressed: () => setState(() => _rating = i + 1),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _comment,
              maxLines: 3,
              textInputAction: TextInputAction.newline,
              decoration: appInputDecoration(
                hint: 'Ceritakan pengalaman Anda (opsional)',
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _rating == 0 ? null : _send,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: buttonShape,
              ),
              child: const Text('Kirim Ulasan'),
            ),
          ],
        ),
      ),
    );
  }
}
