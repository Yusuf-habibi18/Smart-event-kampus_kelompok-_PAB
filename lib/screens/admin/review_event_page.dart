import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../models/event_proposal.dart';
import '../../models/ormawa_account.dart';
import '../../viewmodels/proposal_viewmodel.dart';
import '../mahasiswa/mahasiswa_widgets.dart';
import '../umum/form_widgets.dart';
import 'admin_widgets.dart';

enum _StatusFilter { semua, urgent, menunggu, selesai }

extension on _StatusFilter {
  String get label => switch (this) {
    _StatusFilter.semua => 'Semua',
    _StatusFilter.urgent => 'Perlu Verifikasi Urgent',
    _StatusFilter.menunggu => 'Menunggu',
    _StatusFilter.selesai => 'Sudah Diputuskan',
  };
}

/// View: Daftar Pengajuan Masuk (Admin / BKA).
///
/// Dua tab: pengajuan akun Ormawa dan proposal event. Mendukung pencarian
/// dan filter status. Tombol "Review & Verifikasi" membuka detail keputusan.
class ReviewEventPage extends StatefulWidget {
  const ReviewEventPage({super.key});

  @override
  State<ReviewEventPage> createState() => _ReviewEventPageState();
}

class _ReviewEventPageState extends State<ReviewEventPage> {
  final TextEditingController _search = TextEditingController();
  String _query = '';
  _StatusFilter _filter = _StatusFilter.semua;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _passAccount(OrmawaAccount a) {
    final bool pending = a.status == AccountStatus.menunggu;
    final bool ok = switch (_filter) {
      _StatusFilter.semua => true,
      _StatusFilter.urgent => pending && a.urgent,
      _StatusFilter.menunggu => pending,
      _StatusFilter.selesai => !pending,
    };
    return ok && a.matches(_query);
  }

  bool _passProposal(EventProposal p) {
    final bool pending = p.status == ProposalStatus.menungguReview;
    final bool ok = switch (_filter) {
      _StatusFilter.semua => true,
      _StatusFilter.urgent => pending && p.urgent,
      _StatusFilter.menunggu => pending,
      _StatusFilter.selesai => !pending,
    };
    return ok && p.matches(_query);
  }

  @override
  Widget build(BuildContext context) {
    final ProposalViewModel vm = context.watch<ProposalViewModel>();
    final List<OrmawaAccount> accounts = vm.accountApplications
        .where(_passAccount)
        .toList();
    final List<EventProposal> proposals =
        vm.allProposals.where(_passProposal).toList()
          ..sort((EventProposal a, EventProposal b) {
            final int pa = a.status == ProposalStatus.menungguReview ? 0 : 1;
            final int pb = b.status == ProposalStatus.menungguReview ? 0 : 1;
            if (pa != pb) return pa - pb;
            if (a.urgent != b.urgent) return a.urgent ? -1 : 1;
            return b.id.compareTo(a.id);
          });
    final int pendingTotal =
        vm.pendingAccounts.length + vm.pendingProposals.length;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            HeroHeader(
              eyebrow: '$pendingTotal antrean menunggu',
              title: 'Daftar Pengajuan',
              subtitle:
                  'Verifikasi akun Ormawa dan proposal event yang '
                  'masuk.',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: SegmentTabBar(
                labels: [
                  'Akun Ormawa (${vm.pendingAccounts.length})',
                  'Proposal (${vm.pendingProposals.length})',
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: TextField(
                controller: _search,
                onChanged: (String v) => setState(() => _query = v.trim()),
                textInputAction: TextInputAction.search,
                decoration: appInputDecoration(
                  hint: 'Cari ormawa, event, atau ID...',
                  prefixIcon: Icons.search_rounded,
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Hapus pencarian',
                          onPressed: () {
                            _search.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
            ),
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                children: [
                  for (final _StatusFilter f in _StatusFilter.values) ...[
                    ChoiceChip(
                      label: Text(f.label),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                      showCheckmark: false,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _filter == f
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
            Expanded(
              child: TabBarView(
                children: [
                  _ResultList(
                    emptyMessage: 'Tidak ada pengajuan akun yang cocok.',
                    children: [
                      for (final OrmawaAccount a in accounts)
                        _AccountCard(account: a),
                    ],
                  ),
                  _ResultList(
                    emptyMessage: 'Tidak ada proposal yang cocok.',
                    children: [
                      for (final EventProposal p in proposals)
                        _ProposalCard(proposal: p),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultList extends StatelessWidget {
  const _ResultList({required this.children, required this.emptyMessage});

  final List<Widget> children;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: children.isEmpty
            ? ListView(
                children: [
                  EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'Tidak ada hasil',
                    message: emptyMessage,
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                itemCount: children.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, int i) => Reveal(index: i, child: children[i]),
              ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.account});

  final OrmawaAccount account;

  @override
  Widget build(BuildContext context) {
    final OrmawaAccount a = account;
    final bool pending = a.status == AccountStatus.menunggu;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: a.urgent && pending
              ? const Color(0xFFF2DDB4)
              : AppColors.surfaceHigh,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primaryTint,
                child: Text(
                  a.initials,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.glow,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID REG-AKN-${a.id.toString().padLeft(3, '0')}',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      '${a.shortName} - ${a.fullName}',
                      style: const TextStyle(
                        fontFamily: AppFonts.heading,
                        fontSize: 15.5,
                        letterSpacing: -0.1,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              AccountStatusBadge(status: a.status),
              if (a.urgent && pending)
                const PillBadge(
                  text: 'Urgent',
                  background: AppColors.dangerSoft,
                  foreground: AppColors.danger,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                InfoLine(
                  icon: Icons.category_outlined,
                  text:
                      'Tipe: ${a.type} • Pengajuan akun baru periode '
                      '2025/2026',
                ),
                const SizedBox(height: 6),
                const InfoLine(
                  icon: Icons.task_alt_rounded,
                  text: 'SK kepengurusan & surat rekomendasi: lengkap',
                  color: AppColors.success,
                ),
                const SizedBox(height: 6),
                InfoLine(icon: Icons.apartment_rounded, text: a.faculty),
              ],
            ),
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  'PIC: ${a.picName}\n${a.submittedLabel}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    height: 1.4,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: () => showAccountReview(context, a),
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: Text(pending ? 'Review & Verifikasi' : 'Lihat Detail'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProposalCard extends StatelessWidget {
  const _ProposalCard({required this.proposal});

  final EventProposal proposal;

  @override
  Widget build(BuildContext context) {
    final EventProposal p = proposal;
    final bool pending = p.status == ProposalStatus.menungguReview;

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${p.code} • ${p.ormawa}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              if (p.urgent && pending)
                const PillBadge(
                  text: 'Urgent',
                  background: AppColors.dangerSoft,
                  foreground: AppColors.danger,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            p.title,
            style: const TextStyle(
              fontFamily: AppFonts.heading,
              fontSize: 16,
              letterSpacing: -0.2,
              fontWeight: FontWeight.w700,
              height: 1.3,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ProposalStatusBadge(status: p.status),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: LabeledValue(
                  label: 'Anggaran',
                  value: p.budgetLabel,
                  valueColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: LabeledValue(label: 'Tanggal', value: p.dateLabel),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Diajukan ${p.submittedLabel}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: () => openProposalReview(context, p),
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: Text(pending ? 'Review & Verifikasi' : 'Lihat Detail'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
