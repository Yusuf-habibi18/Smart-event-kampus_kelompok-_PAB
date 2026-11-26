import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/event_proposal.dart';
import '../../models/ormawa_account.dart';
import '../mahasiswa/mahasiswa_widgets.dart';

// Widget bersama untuk modul Ormawa (Panitia) dan Admin (BKA):
// badge status, kartu statistik, kartu bagian formulir, berkas, timeline.

// ---------------------------------------------------------------------------
// Badge status
// ---------------------------------------------------------------------------

class ProposalStatusBadge extends StatelessWidget {
  const ProposalStatusBadge({super.key, required this.status});

  final ProposalStatus status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ProposalStatus.menungguReview:
        return PillBadge.warning(
          text: status.label,
          icon: Icons.hourglass_top_rounded,
        );
      case ProposalStatus.perluRevisi:
        return PillBadge(
          text: status.label,
          icon: Icons.error_outline_rounded,
          background: AppColors.dangerSoft,
          foreground: AppColors.danger,
        );
      case ProposalStatus.disetujui:
        return PillBadge.success(
          text: status.label,
          icon: Icons.verified_rounded,
        );
      case ProposalStatus.ditolak:
        return PillBadge(
          text: status.label,
          icon: Icons.block_rounded,
          background: AppColors.surfaceHigh,
          foreground: AppColors.textSecondary,
        );
    }
  }
}

class AccountStatusBadge extends StatelessWidget {
  const AccountStatusBadge({super.key, required this.status});

  final AccountStatus status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case AccountStatus.menunggu:
        return PillBadge.warning(
          text: status.label,
          icon: Icons.hourglass_top_rounded,
        );
      case AccountStatus.perluRevisi:
        return PillBadge(
          text: status.label,
          icon: Icons.error_outline_rounded,
          background: AppColors.dangerSoft,
          foreground: AppColors.danger,
        );
      case AccountStatus.terverifikasi:
        return PillBadge.success(
          text: status.label,
          icon: Icons.verified_rounded,
        );
      case AccountStatus.ditolak:
        return PillBadge(
          text: status.label,
          icon: Icons.block_rounded,
          background: AppColors.surfaceHigh,
          foreground: AppColors.textSecondary,
        );
    }
  }
}

// ---------------------------------------------------------------------------
// Statistik
// ---------------------------------------------------------------------------

/// Kotak angka kecil (Event Aktif, Peserta, Kehadiran, dll).
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.caption,
    this.valueColor = AppColors.primary,
  });

  final String label;
  final String value;
  final IconData icon;

  /// Nilai angka (mis. "8" atau "50%") dianimasikan menghitung naik.
  Widget _value() {
    final TextStyle style = TextStyle(
      fontFamily: AppFonts.heading,
      fontSize: 22,
      letterSpacing: -0.2,
      fontWeight: FontWeight.w700,
      color: valueColor,
    );
    final RegExpMatch? m = RegExp(r'^(\d+)(\D*)$').firstMatch(value);
    if (m == null) return Text(value, style: style);
    return CountUp(
      value: int.parse(m.group(1)!),
      suffix: m.group(2)!,
      style: style,
    );
  }

  final String? caption;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: AppDecorations.card(radius: AppRadius.md + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: valueColor == AppColors.primary
                  ? AppColors.primarySoft
                  : valueColor.withAlpha(36),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: valueColor),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: _value(),
          ),
          if (caption != null)
            Text(
              caption!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Formulir
// ---------------------------------------------------------------------------

/// Kartu satu bagian formulir dengan ikon/nomor + judul.
class FormSectionCard extends StatelessWidget {
  const FormSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: AppColors.glow),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: AppFonts.heading,
                    fontSize: 15.5,
                    letterSpacing: -0.1,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const Divider(height: 28),
          ...children,
        ],
      ),
    );
  }
}

/// Label di atas field formulir, dengan tanda * untuk field wajib.
class FieldLabel extends StatelessWidget {
  const FieldLabel(
    this.text, {
    super.key,
    this.required = false,
    this.trailing,
  });

  final String text;
  final bool required;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                text: text,
                children: [
                  if (required)
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: AppColors.danger),
                    ),
                ],
              ),
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Kotak info kecil berlatar lembut (catatan, peringatan, panduan).
class NoteBox extends StatelessWidget {
  const NoteBox({
    super.key,
    required this.text,
    this.title,
    this.icon = Icons.info_outline_rounded,
    this.background = AppColors.surfaceLow,
    this.foreground = AppColors.textSecondary,
  });

  const NoteBox.warning({super.key, required this.text, this.title})
    : icon = Icons.warning_amber_rounded,
      background = AppColors.warningSoft,
      foreground = AppColors.warning;

  const NoteBox.danger({super.key, required this.text, this.title})
    : icon = Icons.feedback_outlined,
      background = AppColors.dangerSoft,
      foreground = AppColors.danger;

  const NoteBox.success({super.key, required this.text, this.title})
    : icon = Icons.check_circle_rounded,
      background = AppColors.successSoft,
      foreground = AppColors.success;

  final String text;
  final String? title;
  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: foreground),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: foreground,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: title == null ? foreground : AppColors.textSecondary,
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

/// Baris berkas terunggah (PDF) dengan aksi di kanan.
class FileTile extends StatelessWidget {
  const FileTile({
    super.key,
    required this.fileName,
    this.caption = 'PDF • 2,4 MB',
    this.trailing,
  });

  final String fileName;
  final String caption;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.dangerSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.picture_as_pdf_rounded,
              color: AppColors.danger,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  caption,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Area unggah berkas (simulasi). [onTap] dipanggil saat diketuk.
class UploadBox extends StatelessWidget {
  const UploadBox({
    super.key,
    required this.label,
    required this.onTap,
    this.hint = 'Format PDF, maksimal 5 MB',
  });

  final String label;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primarySoft,
                child: Icon(
                  Icons.upload_file_rounded,
                  color: AppColors.glow,
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.glow,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                hint,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bilah tombol tetap di bawah halaman formulir.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key, required this.children, this.footnote});

  final List<Widget> children;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: children),
              if (footnote != null) ...[
                const SizedBox(height: 8),
                Text(
                  footnote!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Timeline proses pengajuan
// ---------------------------------------------------------------------------

enum TimelineState { done, current, upcoming, failed }

class TimelineStep {
  const TimelineStep(this.title, this.caption, this.state);

  final String title;
  final String caption;
  final TimelineState state;
}

/// Tahapan proposal sesuai statusnya, dipakai Ormawa & Admin.
List<TimelineStep> proposalSteps(EventProposal p) {
  final bool approved = p.status == ProposalStatus.disetujui;
  final bool revision = p.status == ProposalStatus.perluRevisi;
  final bool rejected = p.status == ProposalStatus.ditolak;
  return [
    TimelineStep(
      '1. Pengajuan Dikirim',
      'Proposal diunggah oleh ${p.ormawa} • ${p.submittedLabel}',
      TimelineState.done,
    ),
    TimelineStep('2. Persetujuan Dosen Pembina', p.advisor, TimelineState.done),
    TimelineStep(
      '3. Verifikasi Proposal oleh BKA',
      revision
          ? 'Dikembalikan untuk revisi'
          : rejected
          ? 'Proposal ditolak BKA'
          : approved
          ? 'Disetujui Biro Kemahasiswaan & Alumni'
          : 'Sedang ditinjau Biro Kemahasiswaan & Alumni',
      approved
          ? TimelineState.done
          : (revision || rejected)
          ? TimelineState.failed
          : TimelineState.current,
    ),
    TimelineStep(
      '4. Penerbitan & Publikasi Otomatis',
      approved
          ? 'Event tampil di Beranda mahasiswa'
          : 'Event dipublikasikan setelah disetujui',
      approved ? TimelineState.done : TimelineState.upcoming,
    ),
  ];
}

class StepTimeline extends StatelessWidget {
  const StepTimeline({super.key, required this.steps});

  final List<TimelineStep> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < steps.length; i++)
          _StepRow(step: steps[i], isLast: i == steps.length - 1),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step, required this.isLast});

  final TimelineStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final (Color color, IconData icon) = switch (step.state) {
      TimelineState.done => (AppColors.success, Icons.check_rounded),
      TimelineState.current => (AppColors.primary, Icons.more_horiz_rounded),
      TimelineState.failed => (AppColors.danger, Icons.priority_high_rounded),
      TimelineState.upcoming => (AppColors.outline, Icons.circle_outlined),
    };
    final bool muted = step.state == TimelineState.upcoming;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: muted ? AppColors.surface : color,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 1.5),
                ),
                child: Icon(
                  icon,
                  size: 14,
                  color: muted ? color : Colors.white,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: AppColors.surfaceHigh),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14, top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: muted
                          ? AppColors.textMuted
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.caption,
                    style: const TextStyle(
                      fontSize: 11.5,
                      height: 1.4,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pasangan label kecil + nilai tebal (dipakai di kartu detail).
class LabeledValue extends StatelessWidget {
  const LabeledValue({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.valueColor = AppColors.textPrimary,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppColors.glow),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: valueColor,
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
