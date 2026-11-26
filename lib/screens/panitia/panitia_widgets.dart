import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../models/event_proposal.dart';
import '../../models/ormawa_account.dart';
import '../../viewmodels/proposal_viewmodel.dart';
import '../mahasiswa/mahasiswa_widgets.dart';
import '../umum/form_widgets.dart';
import 'daftar_peserta_page.dart';
import 'form_proposal_page.dart';
import 'kelola_event_page.dart';

// ---------------------------------------------------------------------------
// Navigasi modul Ormawa
// ---------------------------------------------------------------------------

void openProposalForm(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute<void>(builder: (_) => const FormProposalPage()),
  );
}

/// Edit Informasi Event menerima [proposal] lewat constructor.
void openEditEvent(BuildContext context, EventProposal proposal) {
  Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => KelolaEventPage(proposal: proposal),
    ),
  );
}

void openParticipants(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute<void>(builder: (_) => const DaftarPesertaPage()),
  );
}

/// Simulasi unggah ulang proposal yang diminta revisi.
Future<void> resubmitRevision(
  BuildContext context,
  EventProposal proposal,
) async {
  final ProposalViewModel vm = context.read<ProposalViewModel>();
  final bool ok = await confirmDialog(
    context,
    title: 'Unggah revisi proposal?',
    message:
        'Berkas revisi untuk "${proposal.title}" akan dikirim ulang ke '
        'BKA dan statusnya kembali menjadi Menunggu Review.',
    confirmLabel: 'Unggah & Kirim',
  );
  if (!ok || !context.mounted) return;
  final String base = proposal.fileName.replaceAll('.pdf', '');
  vm.resubmitProposal(proposal, fileName: '${base}_revisi.pdf');
  showSnack(context, 'Revisi terkirim. Menunggu review BKA.');
}

// ---------------------------------------------------------------------------
// Header identitas Ormawa
// ---------------------------------------------------------------------------

class OrmawaAvatar extends StatelessWidget {
  const OrmawaAvatar({super.key, required this.label, this.size = 44});

  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Text(
        label,
        maxLines: 1,
        style: TextStyle(
          fontFamily: AppFonts.heading,
          fontSize: size * 0.3,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Kartu identitas Ormawa: logo, nama, fakultas, status verifikasi.
class OrmawaIdentityCard extends StatelessWidget {
  const OrmawaIdentityCard({super.key, required this.ormawa});

  final OrmawaAccount ormawa;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Row(
        children: [
          OrmawaAvatar(label: ormawa.initials, size: 52),
          const SizedBox(width: 14),
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
                          fontSize: 17,
                          letterSpacing: -0.2,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (ormawa.status == AccountStatus.terverifikasi) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified_rounded,
                        size: 16,
                        color: AppColors.glow,
                      ),
                    ],
                  ],
                ),
                Text(
                  ormawa.fullName,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  ormawa.faculty,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          PillBadge(
            text: ormawa.type,
            background: AppColors.primaryTint,
            foreground: AppColors.glow,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Kartu proposal (Dashboard & Status Pengajuan)
// ---------------------------------------------------------------------------

/// Kartu proposal milik Ormawa. Isi dan tombol menyesuaikan statusnya.
///
/// [detailed] = true menampilkan timeline tahapan (halaman Status Pengajuan).
class ProposalCard extends StatelessWidget {
  const ProposalCard({
    super.key,
    required this.proposal,
    this.detailed = false,
    this.onOpenStatus,
  });

  final EventProposal proposal;
  final bool detailed;

  /// Dipanggil tombol "Detail Status" (hanya di Dashboard).
  final VoidCallback? onOpenStatus;

  @override
  Widget build(BuildContext context) {
    final bool revision = proposal.status == ProposalStatus.perluRevisi;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: revision ? const Color(0xFFF5C2BC) : AppColors.surfaceHigh,
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 4,
                  children: [
                    _MetaText(Icons.event_rounded, proposal.dateLabel),
                    _MetaText(Icons.place_outlined, proposal.location),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ProposalStatusBadge(status: proposal.status),
          const SizedBox(height: 8),
          Text(
            proposal.title,
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
            '${proposal.code} • ${proposal.quotaLabel}',
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.glow,
            ),
          ),
          const SizedBox(height: 16),
          ..._statusBody(context),
        ],
      ),
    );
  }

  List<Widget> _statusBody(BuildContext context) {
    switch (proposal.status) {
      case ProposalStatus.menungguReview:
        return [
          if (detailed)
            _TimelineBox(proposal: proposal)
          else
            const _MiniProgress(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Diajukan ${proposal.submittedLabel}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              if (onOpenStatus != null)
                TextButton.icon(
                  onPressed: onOpenStatus,
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(Icons.chevron_right_rounded, size: 18),
                  label: const Text('Detail Status'),
                )
              else
                OutlinedButton.icon(
                  onPressed: () => showComingSoon(context, 'Lihat PDF'),
                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                  label: const Text('Lihat PDF'),
                ),
            ],
          ),
        ];
      case ProposalStatus.disetujui:
        return [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Pendaftaran peserta',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      '${proposal.registered}/${proposal.quota} Terdaftar',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.glow,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: AnimatedProgress(
                    value: proposal.registrationRatio,
                    minHeight: 6,
                    backgroundColor: AppColors.surfaceHigh,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                InfoLine(
                  icon: Icons.schedule_rounded,
                  text: '${proposal.timeLabel} • ${proposal.format}',
                ),
              ],
            ),
          ),
          if (detailed) ...[
            const SizedBox(height: 12),
            _TimelineBox(proposal: proposal),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => openEditEvent(context, proposal),
                  child: const Text('Edit Event'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () => openParticipants(context),
                  child: const Text('Kelola Peserta'),
                ),
              ),
            ],
          ),
        ];
      case ProposalStatus.perluRevisi:
      case ProposalStatus.ditolak:
        final bool rejected = proposal.status == ProposalStatus.ditolak;
        return [
          NoteBox.danger(
            title: 'Catatan Revisi BKA',
            text: proposal.reviewNote ?? 'Tidak ada catatan dari BKA.',
          ),
          if (detailed) ...[
            const SizedBox(height: 12),
            _TimelineBox(proposal: proposal),
          ],
          if (!rejected) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => resubmitRevision(context, proposal),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.danger,
                ),
                icon: const Icon(Icons.upload_rounded, size: 18),
                label: const Text('Unggah Revisi Proposal'),
              ),
            ),
          ],
        ];
    }
  }
}

class _MetaText extends StatelessWidget {
  const _MetaText(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}

/// Ringkasan 3 tahap: Dosen Pembina → BKA → Publikasi.
class _MiniProgress extends StatelessWidget {
  const _MiniProgress();

  @override
  Widget build(BuildContext context) {
    Widget dot(String label, Color color, IconData icon) {
      return Expanded(
        child: Row(
          children: [
            CircleAvatar(
              radius: 10,
              backgroundColor: color,
              child: Icon(icon, size: 12, color: Colors.white),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          dot('Dosen Pembina', AppColors.success, Icons.check_rounded),
          dot('Review BKA', AppColors.primary, Icons.more_horiz_rounded),
          dot('Publikasi', AppColors.outline, Icons.circle_outlined),
        ],
      ),
    );
  }
}

class _TimelineBox extends StatelessWidget {
  const _TimelineBox({required this.proposal});

  final EventProposal proposal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PROGRES PENGAJUAN & VERIFIKASI',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          StepTimeline(steps: proposalSteps(proposal)),
        ],
      ),
    );
  }
}
