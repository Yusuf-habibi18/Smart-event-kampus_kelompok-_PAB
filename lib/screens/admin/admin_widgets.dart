import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../models/event_proposal.dart';
import '../../models/ormawa_account.dart';
import '../../viewmodels/proposal_viewmodel.dart';
import '../mahasiswa/mahasiswa_widgets.dart';
import '../panitia/panitia_widgets.dart';
import '../umum/form_widgets.dart';

// ---------------------------------------------------------------------------
// Navigasi
// ---------------------------------------------------------------------------

/// Membuka halaman review proposal. [proposal] dikirim lewat constructor.
void openProposalReview(BuildContext context, EventProposal proposal) {
  Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => ReviewProposalPage(proposalId: proposal.id),
    ),
  );
}

/// Bottom sheet keputusan revisi / tolak. Mengembalikan catatan yang diisi,
/// atau null jika dibatalkan.
Future<(ProposalStatus, String)?> _askRevisionOrReject(
  BuildContext context, {
  required String initialNote,
}) {
  return showModalBottomSheet<(ProposalStatus, String)>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _DecisionSheet(initialNote: initialNote),
  );
}

// ---------------------------------------------------------------------------
// Panel review proposal (Dashboard & halaman review)
// ---------------------------------------------------------------------------

/// Detail proposal untuk diverifikasi BKA beserta tombol keputusan.
class ProposalReviewPanel extends StatefulWidget {
  const ProposalReviewPanel({
    super.key,
    required this.proposal,
    this.onDecided,
  });

  final EventProposal proposal;

  /// Dipanggil setelah keputusan disimpan (mis. untuk menutup halaman).
  final ValueChanged<ProposalStatus>? onDecided;

  @override
  State<ProposalReviewPanel> createState() => _ProposalReviewPanelState();
}

class _ProposalReviewPanelState extends State<ProposalReviewPanel> {
  final TextEditingController _note = TextEditingController();

  @override
  void didUpdateWidget(covariant ProposalReviewPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.proposal.id != widget.proposal.id) _note.clear();
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _approve() async {
    final ProposalViewModel vm = context.read<ProposalViewModel>();
    final EventProposal p = widget.proposal;
    final bool ok = await confirmDialog(
      context,
      title: 'Setujui & terbitkan?',
      message:
          '"${p.title}" akan disetujui dan otomatis tampil di Beranda '
          'mahasiswa.',
      confirmLabel: 'Setujui',
    );
    if (!ok || !mounted) return;
    vm.reviewProposal(p, ProposalStatus.disetujui, note: _note.text);
    showSnack(context, 'Proposal ${p.code} disetujui & diterbitkan.');
    widget.onDecided?.call(ProposalStatus.disetujui);
  }

  Future<void> _reviseOrReject() async {
    final ProposalViewModel vm = context.read<ProposalViewModel>();
    final EventProposal p = widget.proposal;
    final (ProposalStatus, String)? decision = await _askRevisionOrReject(
      context,
      initialNote: _note.text,
    );
    if (decision == null || !mounted) return;
    final (ProposalStatus status, String note) = decision;
    vm.reviewProposal(p, status, note: note);
    showSnack(
      context,
      status == ProposalStatus.ditolak
          ? 'Proposal ${p.code} ditolak.'
          : 'Permintaan revisi dikirim ke ${p.ormawa}.',
    );
    widget.onDecided?.call(status);
  }

  @override
  Widget build(BuildContext context) {
    final EventProposal p = widget.proposal;
    final bool pending = p.status == ProposalStatus.menungguReview;

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              OrmawaAvatar(
                label: p.ormawa.length <= 4
                    ? p.ormawa
                    : p.ormawa.substring(0, 2).toUpperCase(),
                size: 40,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.ormawa,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Diajukan ${p.submittedLabel}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              ProposalStatusBadge(status: p.status),
            ],
          ),
          const SizedBox(height: 16),
          if (p.urgent) ...[
            const PillBadge(
              text: 'Prioritas Mendesak',
              icon: Icons.priority_high_rounded,
              background: AppColors.dangerSoft,
              foreground: AppColors.danger,
            ),
            const SizedBox(height: 8),
          ],
          Text(
            p.title,
            style: const TextStyle(
              fontFamily: AppFonts.heading,
              fontSize: 18,
              letterSpacing: -0.2,
              fontWeight: FontWeight.w700,
              height: 1.3,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${p.code} • ${p.category}',
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.glow,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            p.description,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints c) {
              final double w = (c.maxWidth - 10) / 2;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SizedBox(
                    width: w,
                    child: LabeledValue(
                      label: 'Tanggal Pelaksanaan',
                      value: '${p.dateLabel}\n${p.timeLabel}',
                      icon: Icons.event_rounded,
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: LabeledValue(
                      label: 'Tempat Acara',
                      value: '${p.location}\n(${p.format})',
                      icon: Icons.place_outlined,
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: LabeledValue(
                      label: 'Estimasi Peserta',
                      value: '${p.quotaLabel}\n${p.audienceLabel}',
                      icon: Icons.groups_outlined,
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: LabeledValue(
                      label: 'Pengajuan Anggaran',
                      value: p.budgetLabel,
                      icon: Icons.payments_outlined,
                      valueColor: AppColors.primary,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'LAMPIRAN DOKUMEN PROPOSAL',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          FileTile(
            fileName: p.fileName,
            caption: 'PDF • Disetujui Dosen Pembina',
            trailing: TextButton.icon(
              onPressed: () => showComingSoon(context, 'Buka PDF'),
              icon: const Icon(Icons.open_in_new_rounded, size: 16),
              label: const Text('Buka'),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'RIWAYAT VERIFIKASI',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          StepTimeline(steps: proposalSteps(p)),
          if (p.reviewNote != null && !pending) ...[
            const SizedBox(height: 12),
            NoteBox.danger(title: 'Catatan BKA', text: p.reviewNote!),
          ],
          if (pending) ...[
            const Divider(height: 28),
            const FieldLabel('Catatan Verifikasi BKA (opsional)'),
            TextField(
              controller: _note,
              minLines: 2,
              maxLines: 4,
              decoration: appInputDecoration(
                hint: 'Tulis catatan atau syarat tambahan untuk penyelenggara',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _reviseOrReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Tolak / Revisi'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _approve,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.success,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    icon: const Icon(Icons.check_circle_rounded, size: 18),
                    label: const Text('Setujui'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DecisionSheet extends StatefulWidget {
  const _DecisionSheet({required this.initialNote});

  final String initialNote;

  @override
  State<_DecisionSheet> createState() => _DecisionSheetState();
}

class _DecisionSheetState extends State<_DecisionSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _note = TextEditingController(
    text: widget.initialNote,
  );
  ProposalStatus _decision = ProposalStatus.perluRevisi;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop((_decision, _note.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Keputusan Verifikasi',
              style: TextStyle(
                fontFamily: AppFonts.heading,
                fontSize: 18,
                letterSpacing: -0.2,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<ProposalStatus>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: ProposalStatus.perluRevisi,
                    icon: Icon(Icons.edit_note_rounded),
                    label: Text('Minta Revisi'),
                  ),
                  ButtonSegment(
                    value: ProposalStatus.ditolak,
                    icon: Icon(Icons.block_rounded),
                    label: Text('Tolak'),
                  ),
                ],
                selected: {_decision},
                onSelectionChanged: (Set<ProposalStatus> s) =>
                    setState(() => _decision = s.first),
              ),
            ),
            const SizedBox(height: 16),
            const FieldLabel(
              'Alasan / catatan untuk penyelenggara',
              required: true,
            ),
            TextFormField(
              controller: _note,
              autofocus: true,
              minLines: 3,
              maxLines: 5,
              decoration: appInputDecoration(
                hint: 'mis. Lengkapi rincian RAB transportasi',
              ),
              validator: (String? v) => (v ?? '').trim().length < 10
                  ? 'Catatan minimal 10 karakter'
                  : null,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.danger,
                ),
                child: Text(
                  _decision == ProposalStatus.ditolak
                      ? 'Tolak Proposal'
                      : 'Kirim Permintaan Revisi',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// View: halaman review satu proposal.
///
/// Menerima [proposalId] lalu membaca proposal terbaru dari
/// [ProposalViewModel] agar status yang tampil selalu mutakhir.
class ReviewProposalPage extends StatelessWidget {
  const ReviewProposalPage({super.key, required this.proposalId});

  final int proposalId;

  @override
  Widget build(BuildContext context) {
    final EventProposal? p = context.watch<ProposalViewModel>().proposalById(
      proposalId,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScreenAppBar(
        title: 'Review Proposal',
        subtitle: 'Verifikasi Biro Kemahasiswaan & Alumni',
      ),
      body: p == null
          ? const EmptyState(
              icon: Icons.search_off_rounded,
              title: 'Proposal tidak ditemukan',
              message: 'Proposal mungkin sudah dihapus.',
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                  children: [
                    ProposalReviewPanel(
                      proposal: p,
                      onDecided: (_) => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Review akun Ormawa (bottom sheet)
// ---------------------------------------------------------------------------

Future<void> showAccountReview(BuildContext context, OrmawaAccount account) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _AccountReviewSheet(account: account),
  );
}

class _AccountReviewSheet extends StatefulWidget {
  const _AccountReviewSheet({required this.account});

  final OrmawaAccount account;

  @override
  State<_AccountReviewSheet> createState() => _AccountReviewSheetState();
}

class _AccountReviewSheetState extends State<_AccountReviewSheet> {
  final TextEditingController _note = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _decide(AccountStatus status) {
    final OrmawaAccount a = widget.account;
    if (status != AccountStatus.terverifikasi &&
        _note.text.trim().length < 10) {
      setState(() => _error = 'Isi alasan minimal 10 karakter');
      return;
    }
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    context.read<ProposalViewModel>().reviewAccount(
      a,
      status,
      note: _note.text,
    );
    Navigator.of(context).pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(switch (status) {
            AccountStatus.terverifikasi => 'Akun ${a.shortName} terverifikasi.',
            AccountStatus.perluRevisi =>
              'Permintaan revisi dikirim ke ${a.shortName}.',
            _ => 'Pengajuan akun ${a.shortName} ditolak.',
          }),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final OrmawaAccount a = widget.account;
    final bool pending = a.status == AccountStatus.menunggu;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (BuildContext context, ScrollController controller) {
        return ListView(
          controller: controller,
          padding: EdgeInsets.fromLTRB(
            24,
            0,
            24,
            24 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          children: [
            Row(
              children: [
                OrmawaAvatar(label: a.initials, size: 48),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.fullName,
                        style: const TextStyle(
                          fontFamily: AppFonts.heading,
                          fontSize: 17,
                          letterSpacing: -0.2,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${a.type} • ${a.faculty}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: AccountStatusBadge(status: a.status),
            ),
            const SizedBox(height: 12),
            Text(
              a.description,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            InfoLine(
              icon: Icons.person_outline_rounded,
              text: 'PIC: ${a.picName} • NIM ${a.picNim}',
            ),
            const SizedBox(height: 8),
            InfoLine(icon: Icons.mail_outline_rounded, text: a.email),
            const SizedBox(height: 8),
            InfoLine(icon: Icons.phone_outlined, text: a.phone),
            const SizedBox(height: 8),
            InfoLine(
              icon: Icons.school_outlined,
              text: 'Pembina: ${a.advisor}',
            ),
            const SizedBox(height: 16),
            FileTile(
              fileName:
                  'SK_Kepengurusan_${a.shortName.replaceAll(' ', '')}.pdf',
              caption: 'SK Kepengurusan • PDF',
            ),
            const SizedBox(height: 8),
            FileTile(
              fileName:
                  'Rekomendasi_Pembina_${a.shortName.replaceAll(' ', '')}.pdf',
              caption: 'Surat Rekomendasi • PDF',
            ),
            if (a.reviewNote != null) ...[
              const SizedBox(height: 12),
              NoteBox.danger(title: 'Catatan BKA', text: a.reviewNote!),
            ],
            if (pending) ...[
              const SizedBox(height: 20),
              const FieldLabel('Catatan (wajib untuk revisi / tolak)'),
              TextField(
                controller: _note,
                minLines: 2,
                maxLines: 4,
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
                decoration: appInputDecoration(
                  hint: 'mis. SK kepengurusan sudah kedaluwarsa',
                ).copyWith(errorText: _error),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _decide(AccountStatus.ditolak),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.danger),
                      ),
                      child: const Text('Tolak'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _decide(AccountStatus.perluRevisi),
                      child: const Text('Revisi'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: () => _decide(AccountStatus.terverifikasi),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.success,
                  ),
                  icon: const Icon(Icons.verified_rounded),
                  label: const Text('Verifikasi Akun'),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
