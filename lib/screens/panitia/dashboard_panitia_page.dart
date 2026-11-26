import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../models/event_proposal.dart';
import '../../models/ormawa_account.dart';
import '../../viewmodels/presensi_viewmodel.dart';
import '../../viewmodels/proposal_viewmodel.dart';
import '../mahasiswa/mahasiswa_widgets.dart';
import '../umum/form_widgets.dart';
import 'panitia_widgets.dart';

/// View: Dashboard Ormawa ("Pusat Kendali Panitia").
///
/// Ringkasan event aktif, peserta, kehadiran, dan daftar proposal milik
/// Ormawa yang difilter per status. Data dari [ProposalViewModel] dan
/// [PresensiViewModel].
class DashboardPanitiaPage extends StatefulWidget {
  const DashboardPanitiaPage({super.key, this.onOpenStatus});

  /// Pindah ke tab Proposal (Status Pengajuan) di [OrmawaShell].
  final VoidCallback? onOpenStatus;

  @override
  State<DashboardPanitiaPage> createState() => _DashboardPanitiaPageState();
}

class _DashboardPanitiaPageState extends State<DashboardPanitiaPage> {
  /// null = Semua.
  ProposalStatus? _filter;

  static const List<ProposalStatus?> _filters = [
    null,
    ProposalStatus.menungguReview,
    ProposalStatus.perluRevisi,
    ProposalStatus.disetujui,
  ];

  String _filterLabel(ProposalStatus? status) => switch (status) {
    null => 'Semua',
    ProposalStatus.menungguReview => 'Menunggu Review',
    ProposalStatus.perluRevisi => 'Revisi',
    ProposalStatus.disetujui => 'Disetujui',
    ProposalStatus.ditolak => 'Ditolak',
  };

  @override
  Widget build(BuildContext context) {
    final ProposalViewModel vm = context.watch<ProposalViewModel>();
    final PresensiViewModel presensi = context.watch<PresensiViewModel>();
    final OrmawaAccount ormawa = vm.myOrmawa;
    final List<EventProposal> proposals = vm.myProposalsBy(_filter);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: HeroHeader(
                    leading: _Header(ormawa: ormawa),
                    actions: [
                      CircleIconButton(
                        icon: Icons.notifications_none_rounded,
                        tooltip: 'Notifikasi',
                        badge: 1,
                        onPressed: () => showComingSoon(context, 'Notifikasi'),
                      ),
                    ],
                    eyebrow: ormawa.skNumber == null
                        ? 'Belum terverifikasi'
                        : 'Terverifikasi • Periode 2025/2026',
                    title: 'Pusat Kendali Panitia',
                    subtitle:
                        'Ajukan proposal, kelola peserta, dan catat '
                        'presensi event dari satu tempat.',
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 40),
                  sliver: SliverList.list(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: StatTile(
                              label: 'Event Aktif',
                              value: '${vm.myActiveEvents.length}',
                              icon: Icons.event_available_rounded,
                              caption: 'Disetujui BKA',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatTile(
                              label: 'Peserta',
                              value: '${vm.myTotalRegistered}',
                              icon: Icons.groups_rounded,
                              caption: 'Terdaftar',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatTile(
                              label: 'Kehadiran',
                              value: '${presensi.attendancePercent}%',
                              icon: Icons.how_to_reg_rounded,
                              caption: 'Event berjalan',
                              valueColor: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: () => openProposalForm(context),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: buttonShape,
                            textStyle: const TextStyle(
                              fontFamily: AppFonts.body,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          icon: const Icon(Icons.add_circle_outline_rounded),
                          label: const Text('Ajukan Proposal Event Baru'),
                        ),
                      ),
                      const SizedBox(height: 40),
                      SectionHeader(
                        eyebrow: 'Pengajuan',
                        title: 'Proposal Kegiatan',
                        trailingText: 'Lihat Status',
                        onTrailingTap: widget.onOpenStatus,
                      ),
                      const Text(
                        'Pantau proses verifikasi BKA dan kelola event yang sudah '
                        'disetujui.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final ProposalStatus? status in _filters) ...[
                              ChoiceChip(
                                label: Text(
                                  '${_filterLabel(status)} '
                                  '(${vm.myProposalsBy(status).length})',
                                ),
                                selected: _filter == status,
                                onSelected: (_) =>
                                    setState(() => _filter = status),
                                showCheckmark: false,
                                selectedColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _filter == status
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                                side: const BorderSide(color: AppColors.border),
                                shape: buttonShape,
                              ),
                              const SizedBox(width: 8),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (proposals.isEmpty)
                        const EmptyState(
                          icon: Icons.inbox_outlined,
                          title: 'Belum ada proposal',
                          message:
                              'Proposal dengan status ini akan muncul di sini.',
                        ),
                      for (final (int i, EventProposal p)
                          in proposals.indexed) ...[
                        Reveal(
                          index: i,
                          child: ProposalCard(
                            proposal: p,
                            onOpenStatus: widget.onOpenStatus,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      const _GuideCard(),
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

class _Header extends StatelessWidget {
  const _Header({required this.ormawa});

  final OrmawaAccount ormawa;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        OrmawaAvatar(label: ormawa.initials),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      ormawa.shortName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppFonts.heading,
                        fontSize: 18,
                        letterSpacing: -0.2,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.verified_rounded,
                    size: 16,
                    color: AppColors.glow,
                  ),
                ],
              ),
              Text(
                ormawa.faculty,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => showComingSoon(context, 'Panduan Pengajuan SKKM 2025'),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.surface,
                child: Icon(Icons.menu_book_rounded, color: AppColors.glow),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Panduan Pengajuan SKKM 2025',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.glow,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Syarat berkas, batas anggaran, dan alur verifikasi BKA.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
