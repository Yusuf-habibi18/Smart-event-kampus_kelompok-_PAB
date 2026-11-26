import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../core/formatters.dart';
import '../../models/event_proposal.dart';
import '../../models/ormawa_account.dart';
import '../../viewmodels/proposal_viewmodel.dart';
import '../mahasiswa/mahasiswa_widgets.dart';
import '../umum/form_widgets.dart';
import 'admin_widgets.dart';

enum _Queue {
  mendesak('Prioritas Mendesak', Icons.priority_high_rounded),
  proposal('Proposal Baru', Icons.description_outlined),
  akun('Akun Ormawa', Icons.badge_outlined);

  const _Queue(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// View: Dashboard Admin (BKA Kampus).
///
/// Ringkasan eksekutif, filter antrean, dan panel review proposal teratas
/// yang bisa langsung disetujui / dikembalikan dari dashboard.
class DashboardAdminPage extends StatefulWidget {
  const DashboardAdminPage({super.key, this.onOpenQueue});

  /// Pindah ke tab Pengajuan di [AdminShell].
  final VoidCallback? onOpenQueue;

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> {
  _Queue _queue = _Queue.mendesak;

  @override
  Widget build(BuildContext context) {
    final ProposalViewModel vm = context.watch<ProposalViewModel>();
    final List<EventProposal> pending = vm.pendingProposals;
    final List<EventProposal> shown = _queue == _Queue.mendesak
        ? pending.where((EventProposal p) => p.urgent).toList()
        : pending;
    final int totalPending = pending.length + vm.pendingAccounts.length;

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
                    leading: const _Header(),
                    actions: [
                      CircleIconButton(
                        icon: Icons.notifications_none_rounded,
                        tooltip: 'Notifikasi',
                        badge: 1,
                        onPressed: () => showComingSoon(context, 'Notifikasi'),
                      ),
                    ],
                    eyebrow: formatTanggal(DateTime.now()),
                    title: 'Ringkasan Eksekutif',
                    subtitle:
                        'Semester Genap 2025 • pantau dan putuskan '
                        'pengajuan yang masuk.',
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 40),
                  sliver: SliverList.list(
                    children: [
                      const SizedBox(height: 10),
                      _UrgentCard(
                        total: totalPending,
                        urgent: vm.urgentCount,
                        onTap: widget.onOpenQueue,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: StatTile(
                              label: 'Event Aktif',
                              value: '${vm.totalApproved}',
                              icon: Icons.event_available_rounded,
                              caption: 'Disetujui semester ini',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatTile(
                              label: 'Partisipan',
                              value: '${vm.totalParticipants}',
                              icon: Icons.groups_rounded,
                              caption: 'Mahasiswa terdaftar',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SectionHeader(
                        eyebrow: 'Verifikasi',
                        title: 'Filter Antrean',
                        trailingText: 'Lihat Semua',
                        onTrailingTap: widget.onOpenQueue,
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final _Queue q in _Queue.values) ...[
                              ChoiceChip(
                                avatar: Icon(
                                  q.icon,
                                  size: 16,
                                  color: _queue == q
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                                label: Text(q.label),
                                selected: _queue == q,
                                onSelected: (_) => setState(() => _queue = q),
                                showCheckmark: false,
                                selectedColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _queue == q
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
                      const SizedBox(height: 20),
                      if (_queue == _Queue.akun)
                        ..._accountQueue(vm.pendingAccounts)
                      else
                        ..._proposalQueue(shown),
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

  List<Widget> _proposalQueue(List<EventProposal> list) {
    if (list.isEmpty) {
      return const [
        EmptyState(
          icon: Icons.task_alt_rounded,
          title: 'Antrean bersih',
          message: 'Tidak ada proposal yang menunggu di kategori ini.',
        ),
      ];
    }
    return [
      Row(
        children: [
          const Icon(Icons.circle, size: 8, color: AppColors.glow),
          const SizedBox(width: 6),
          const Expanded(
            child: Text(
              'SEDANG DITINJAU',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            '1 dari ${list.length}',
            style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
          ),
        ],
      ),
      const SizedBox(height: 10),
      ProposalReviewPanel(proposal: list.first),
      if (list.length > 1) ...[
        const SizedBox(height: 24),
        const SectionHeader(title: 'Antrean Berikutnya'),
        const SizedBox(height: 10),
        for (final EventProposal p in list.skip(1)) ...[
          _QueueTile(
            title: p.title,
            subtitle: '${p.ormawa} • ${p.submittedLabel}',
            icon: Icons.description_outlined,
            urgent: p.urgent,
            onTap: () => openProposalReview(context, p),
          ),
          const SizedBox(height: 8),
        ],
      ],
    ];
  }

  List<Widget> _accountQueue(List<OrmawaAccount> list) {
    if (list.isEmpty) {
      return const [
        EmptyState(
          icon: Icons.task_alt_rounded,
          title: 'Antrean bersih',
          message: 'Tidak ada pengajuan akun yang menunggu.',
        ),
      ];
    }
    return [
      for (final OrmawaAccount a in list) ...[
        _QueueTile(
          title: a.fullName,
          subtitle: 'PIC ${a.picName} • ${a.submittedLabel}',
          icon: Icons.badge_outlined,
          urgent: a.urgent,
          onTap: () => showAccountReview(context, a),
        ),
        const SizedBox(height: 8),
      ],
    ];
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.account_balance_rounded, color: Colors.white),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BKA Kampus',
                style: TextStyle(
                  fontFamily: AppFonts.heading,
                  fontSize: 18,
                  letterSpacing: -0.2,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              Text(
                'Biro Kemahasiswaan & Alumni',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UrgentCard extends StatelessWidget {
  const _UrgentCard({
    required this.total,
    required this.urgent,
    required this.onTap,
  });

  final int total;
  final int urgent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.warningSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$total',
                          style: const TextStyle(
                            fontFamily: AppFonts.heading,
                            fontSize: 26,
                            letterSpacing: -0.3,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (urgent > 0)
                          PillBadge(
                            text: '$urgent Urgent',
                            background: AppColors.dangerSoft,
                            foreground: AppColors.danger,
                          ),
                      ],
                    ),
                    const Text(
                      'Pengajuan menunggu verifikasi',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QueueTile extends StatelessWidget {
  const _QueueTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.urgent,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool urgent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.primarySoft,
          child: Icon(icon, color: AppColors.glow, size: 20),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: urgent
            ? const PillBadge(
                text: 'Urgent',
                background: AppColors.dangerSoft,
                foreground: AppColors.danger,
              )
            : const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
