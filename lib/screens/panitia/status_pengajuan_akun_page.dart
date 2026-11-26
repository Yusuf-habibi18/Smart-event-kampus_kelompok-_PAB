import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../models/event_proposal.dart';
import '../../models/ormawa_account.dart';
import '../../viewmodels/proposal_viewmodel.dart';
import '../mahasiswa/mahasiswa_widgets.dart';
import '../umum/form_widgets.dart';
import 'panitia_widgets.dart';

enum _Segment { akun, proposal }

/// View: Status Pengajuan Ormawa.
///
/// Dua segmen: status legalitas akun Ormawa dan progres verifikasi setiap
/// proposal event. Keputusan Admin (BKA) langsung terlihat di sini karena
/// datanya dari [ProposalViewModel] yang sama.
class StatusPengajuanPage extends StatefulWidget {
  const StatusPengajuanPage({super.key});

  @override
  State<StatusPengajuanPage> createState() => _StatusPengajuanPageState();
}

class _StatusPengajuanPageState extends State<StatusPengajuanPage> {
  _Segment _segment = _Segment.proposal;

  @override
  Widget build(BuildContext context) {
    final ProposalViewModel vm = context.watch<ProposalViewModel>();
    final OrmawaAccount ormawa = vm.myOrmawa;
    final List<EventProposal> proposals = vm.myProposals;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: HeroHeader(
                  leading: Navigator.of(context).canPop()
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: CircleIconButton(
                            icon: Icons.arrow_back_rounded,
                            tooltip: MaterialLocalizations.of(context)
                                .backButtonTooltip,
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                        )
                      : null,
                  eyebrow: 'Legalitas & proposal',
                  title: 'Status Pengajuan',
                  subtitle:
                      'Pantau verifikasi akun Ormawa dan proposal '
                      'kegiatan oleh BKA.',
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 12, 20, 40),
                sliver: SliverList.list(
                  children: [
                    OrmawaIdentityCard(ormawa: ormawa),
                    const SizedBox(height: 16),
                    SegmentedButton<_Segment>(
                      showSelectedIcon: false,
                      segments: [
                        const ButtonSegment(
                          value: _Segment.akun,
                          icon: Icon(Icons.badge_outlined, size: 18),
                          label: Text('Akun Ormawa'),
                        ),
                        ButtonSegment(
                          value: _Segment.proposal,
                          icon: const Icon(
                            Icons.description_outlined,
                            size: 18,
                          ),
                          label: Text('Proposal (${proposals.length})'),
                        ),
                      ],
                      selected: {_segment},
                      onSelectionChanged: (Set<_Segment> s) =>
                          setState(() => _segment = s.first),
                    ),
                    const SizedBox(height: 20),
                    if (_segment == _Segment.akun)
                      ..._accountSection(ormawa)
                    else
                      ..._proposalSection(proposals),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _accountSection(OrmawaAccount ormawa) {
    final bool verified = ormawa.status == AccountStatus.terverifikasi;
    return [
      SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.shield_outlined, color: AppColors.glow),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Legalitas Ormawa Periode 2025/2026',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                AccountStatusBadge(status: ormawa.status),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: LabeledValue(
                    label: 'Nomor SK',
                    value: ormawa.skNumber ?? '-',
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: LabeledValue(
                    label: 'Berlaku hingga',
                    value: '31 Agustus 2026',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      SurfaceCard(
        child: StepTimeline(
          steps: [
            TimelineStep(
              '1. Pengajuan Akun Dikirim',
              'Oleh ${ormawa.picName} • ${ormawa.submittedLabel}',
              TimelineState.done,
            ),
            const TimelineStep(
              '2. Validasi Dokumen Legalitas',
              'SK kepengurusan & surat rekomendasi pembina',
              TimelineState.done,
            ),
            TimelineStep(
              '3. Verifikasi BKA',
              verified ? 'Disetujui, nomor SK diterbitkan' : 'Sedang ditinjau',
              verified ? TimelineState.done : TimelineState.current,
            ),
            TimelineStep(
              '4. Akses Penyelenggara Aktif',
              'Dapat mengajukan proposal & mengelola presensi',
              verified ? TimelineState.done : TimelineState.upcoming,
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      const SectionHeader(title: 'Penanggung Jawab'),
      const SizedBox(height: 10),
      SurfaceCard(
        child: Column(
          children: [
            InfoLine(
              icon: Icons.person_outline_rounded,
              text: '${ormawa.picName} • NIM ${ormawa.picNim}',
            ),
            const SizedBox(height: 8),
            InfoLine(icon: Icons.mail_outline_rounded, text: ormawa.email),
            const SizedBox(height: 8),
            InfoLine(icon: Icons.phone_outlined, text: ormawa.phone),
            const SizedBox(height: 8),
            InfoLine(
              icon: Icons.school_outlined,
              text: 'Pembina: ${ormawa.advisor}',
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _proposalSection(List<EventProposal> proposals) {
    return [
      SectionHeader(
        eyebrow: 'Proposal',
        title: 'Daftar Proposal Kegiatan',
        trailingText: '${proposals.length} Event',
      ),
      const SizedBox(height: 12),
      if (proposals.isEmpty)
        const EmptyState(
          icon: Icons.description_outlined,
          title: 'Belum ada proposal',
          message: 'Ajukan proposal event pertama Anda untuk diverifikasi BKA.',
        ),
      for (final (int i, EventProposal p) in proposals.indexed) ...[
        Reveal(
          index: i,
          child: ProposalCard(proposal: p, detailed: true),
        ),
        const SizedBox(height: 16),
      ],
      const NoteBox(
        title: 'Panduan Pengajuan Proposal BKA',
        text:
            'Setiap proposal wajib disetujui Dosen Pembina sebelum '
            'ditinjau BKA. Ajukan paling lambat 14 hari sebelum kegiatan.',
        icon: Icons.info_outline_rounded,
        background: AppColors.primaryTint,
        foreground: AppColors.glow,
      ),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        height: 50,
        child: FilledButton.icon(
          onPressed: () => openProposalForm(context),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Ajukan Event Baru'),
        ),
      ),
    ];
  }
}
