import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../core/formatters.dart';
import '../../data/dummy_ormawa_data.dart';
import '../../models/event_proposal.dart';
import '../../viewmodels/proposal_viewmodel.dart';
import '../mahasiswa/mahasiswa_widgets.dart';
import '../umum/form_widgets.dart';

/// Batas subsidi anggaran BKA per kegiatan.
const int _budgetLimit = 25000000;

/// View: Form Pengajuan Proposal (3 langkah).
///
/// 1. Info Event → 2. Berkas & RAB → 3. Konfirmasi. Setelah dikirim,
/// proposal disimpan lewat [ProposalViewModel.submitProposal] dan langsung
/// masuk antrean review Admin.
class FormProposalPage extends StatefulWidget {
  const FormProposalPage({super.key});

  @override
  State<FormProposalPage> createState() => _FormProposalPageState();
}

class _FormProposalPageState extends State<FormProposalPage> {
  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _location = TextEditingController();
  final TextEditingController _quota = TextEditingController(text: '100');
  final TextEditingController _budget = TextEditingController();
  final TextEditingController _advisor = TextEditingController(
    text: dummyMyOrmawa.advisor,
  );

  int _step = 0;
  String _category = proposalCategories.first;
  String _format = eventFormats.first;

  /// Siapa yang boleh ikut: false = umum, true = khusus mahasiswa ITPLN.
  bool _internal = false;
  int _skpi = 10;
  DateTime? _date;
  TimeOfDay _start = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 12, minute: 0);
  String? _fileName;
  bool _agreed = false;
  bool _showStepErrors = false;

  static const List<String> _stepLabels = [
    'Info Event',
    'Berkas & RAB',
    'Konfirmasi',
  ];

  @override
  void initState() {
    super.initState();
    _budget.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _location.dispose();
    _quota.dispose();
    _budget.dispose();
    _advisor.dispose();
    super.dispose();
  }

  int get _budgetValue => int.tryParse(_budget.text) ?? 0;

  // --- Aksi ----------------------------------------------------------------

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now.add(const Duration(days: 14)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime({required bool start}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: start ? _start : _end,
    );
    if (picked == null) return;
    setState(() => start ? _start = picked : _end = picked);
  }

  bool _validateStep() {
    setState(() => _showStepErrors = true);
    if (_step == 0) {
      final bool ok = _formKeys[0].currentState!.validate();
      return ok && _date != null;
    }
    if (_step == 1) {
      final bool ok = _formKeys[1].currentState!.validate();
      return ok && _fileName != null && _agreed;
    }
    return true;
  }

  void _next() {
    FocusScope.of(context).unfocus();
    if (!_validateStep()) {
      showSnack(context, 'Lengkapi data yang wajib diisi terlebih dulu.');
      return;
    }
    setState(() {
      _step++;
      _showStepErrors = false;
    });
  }

  void _back() {
    if (_step == 0) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() => _step--);
  }

  Future<void> _submit() async {
    final ProposalViewModel vm = context.read<ProposalViewModel>();
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final EventProposal proposal = await vm.submitProposal(
      title: _title.text,
      category: _category,
      description: _description.text,
      dateLabel: formatTanggal(_date!),
      timeLabel: '${formatJam(_start)} - ${formatJam(_end)} WIB',
      location: _location.text,
      format: _format,
      quota: int.parse(_quota.text),
      budget: _budgetValue,
      skpiPoints: _skpi,
      advisor: _advisor.text,
      fileName: _fileName!,
      internal: _internal,
    );
    if (!mounted) return;
    navigator.pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Proposal ${proposal.code} terkirim. Menunggu review BKA.',
          ),
        ),
      );
  }

  // --- Build ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final bool submitting = context.watch<ProposalViewModel>().isSubmitting;

    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (bool didPop, Object? _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: ScreenAppBar(
          title: 'Pengajuan Proposal',
          subtitle: 'Langkah ${_step + 1} dari 3 • ${_stepLabels[_step]}',
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(34),
            child: _StepHeader(step: _step, labels: _stepLabels),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              children: switch (_step) {
                0 => _stepInfo(),
                1 => _stepFiles(),
                _ => _stepConfirm(),
              },
            ),
          ),
        ),
        bottomNavigationBar: BottomActionBar(
          footnote: _step == 2
              ? 'Proposal akan ditinjau BKA maksimal 3 hari kerja.'
              : null,
          children: [
            OutlinedButton.icon(
              onPressed: submitting ? null : _back,
              icon: Icon(
                _step == 0 ? Icons.close_rounded : Icons.arrow_back_rounded,
                size: 18,
              ),
              label: Text(_step == 0 ? 'Batal' : 'Kembali'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: submitting ? null : (_step < 2 ? _next : _submit),
                iconAlignment: IconAlignment.end,
                icon: submitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.surface,
                        ),
                      )
                    : Icon(
                        _step < 2
                            ? Icons.arrow_forward_rounded
                            : Icons.send_rounded,
                        size: 18,
                      ),
                label: Text(
                  _step == 0
                      ? 'Lanjut ke Berkas & RAB'
                      : _step == 1
                      ? 'Lanjut ke Konfirmasi'
                      : 'Kirim Proposal',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Langkah 1 -----------------------------------------------------------

  List<Widget> _stepInfo() {
    return [
      Form(
        key: _formKeys[0],
        child: Column(
          children: [
            FormSectionCard(
              title: 'Informasi Event',
              icon: Icons.event_note_rounded,
              children: [
                const FieldLabel('Judul Kegiatan', required: true),
                TextFormField(
                  controller: _title,
                  textInputAction: TextInputAction.next,
                  decoration: appInputDecoration(
                    hint: 'mis. National Hackathon & UI/UX Bootcamp',
                  ),
                  validator: (String? v) => (v ?? '').trim().length < 5
                      ? 'Judul minimal 5 karakter'
                      : null,
                ),
                const SizedBox(height: 16),
                const FieldLabel('Kategori Event', required: true),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  isExpanded: true,
                  decoration: appInputDecoration(),
                  items: [
                    for (final String c in proposalCategories)
                      DropdownMenuItem(value: c, child: Text(c)),
                  ],
                  onChanged: (String? v) => setState(() => _category = v!),
                ),
                const SizedBox(height: 16),
                const FieldLabel('Deskripsi Singkat', required: true),
                TextFormField(
                  controller: _description,
                  minLines: 3,
                  maxLines: 5,
                  decoration: appInputDecoration(
                    hint: 'Tujuan, sasaran peserta, dan rangkaian acara',
                  ),
                  validator: (String? v) => (v ?? '').trim().length < 20
                      ? 'Deskripsi minimal 20 karakter'
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            FormSectionCard(
              title: 'Jadwal & Lokasi',
              icon: Icons.calendar_month_rounded,
              children: [
                const FieldLabel('Tanggal Pelaksanaan', required: true),
                _PickerField(
                  icon: Icons.event_rounded,
                  text: _date == null ? 'Pilih tanggal' : formatTanggal(_date!),
                  placeholder: _date == null,
                  error: _showStepErrors && _date == null
                      ? 'Tanggal wajib dipilih'
                      : null,
                  onTap: _pickDate,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const FieldLabel('Jam Mulai', required: true),
                          _PickerField(
                            icon: Icons.schedule_rounded,
                            text: formatJam(_start),
                            onTap: () => _pickTime(start: true),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const FieldLabel('Jam Selesai', required: true),
                          _PickerField(
                            icon: Icons.schedule_rounded,
                            text: formatJam(_end),
                            onTap: () => _pickTime(start: false),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const FieldLabel('Format Penyelenggaraan'),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<String>(
                    showSelectedIcon: false,
                    segments: [
                      for (final String f in eventFormats)
                        ButtonSegment(value: f, label: Text(f)),
                    ],
                    selected: {_format},
                    onSelectionChanged: (Set<String> s) =>
                        setState(() => _format = s.first),
                  ),
                ),
                const SizedBox(height: 16),
                const FieldLabel('Siapa yang boleh ikut?'),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<bool>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: false,
                        icon: Icon(Icons.public_rounded, size: 18),
                        label: Text('Umum'),
                      ),
                      ButtonSegment(
                        value: true,
                        icon: Icon(Icons.lock_outline_rounded, size: 18),
                        label: Text('Internal ITPLN'),
                      ),
                    ],
                    selected: {_internal},
                    onSelectionChanged: (Set<bool> s) =>
                        setState(() => _internal = s.first),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _internal
                      ? 'Hanya mahasiswa ITPLN (email @itpln.ac.id) yang bisa '
                            'melihat dan mendaftar.'
                      : 'Mahasiswa ITPLN dan masyarakat umum bisa melihat dan '
                            'mendaftar.',
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 16),
                const FieldLabel('Lokasi / Ruangan', required: true),
                TextFormField(
                  controller: _location,
                  decoration: appInputDecoration(
                    hint: 'mis. Gedung D.402 Lt. 4',
                    prefixIcon: Icons.place_outlined,
                  ),
                  validator: (String? v) =>
                      (v ?? '').trim().isEmpty ? 'Lokasi wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const FieldLabel('Kuota Peserta', required: true),
                          TextFormField(
                            controller: _quota,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: appInputDecoration(hint: '100'),
                            validator: (String? v) =>
                                (int.tryParse(v ?? '') ?? 0) < 1
                                ? 'Minimal 1'
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const FieldLabel('Poin SKPI'),
                          DropdownButtonFormField<int>(
                            initialValue: _skpi,
                            decoration: appInputDecoration(),
                            items: [
                              for (final int p in const [5, 8, 10, 15, 20])
                                DropdownMenuItem(
                                  value: p,
                                  child: Text('+$p Poin'),
                                ),
                            ],
                            onChanged: (int? v) => setState(() => _skpi = v!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  // --- Langkah 2 -----------------------------------------------------------

  List<Widget> _stepFiles() {
    final double ratio = (_budgetValue / _budgetLimit).clamp(0, 1).toDouble();
    final bool overLimit = _budgetValue > _budgetLimit;

    return [
      _SummaryStrip(
        title: _title.text,
        category: _category,
        date: _date == null ? '-' : formatTanggalPendek(_date!),
      ),
      const SizedBox(height: 16),
      const NoteBox(
        text:
            'Pastikan proposal sudah ditandatangani Ketua Ormawa dan Dosen '
            'Pembina. Berkas tanpa tanda tangan akan dikembalikan BKA.',
        icon: Icons.verified_user_outlined,
        background: AppColors.primaryTint,
        foreground: AppColors.glow,
      ),
      const SizedBox(height: 16),
      FormSectionCard(
        title: 'Dokumen Proposal Resmi',
        icon: Icons.description_outlined,
        trailing: const PillBadge(
          text: 'Wajib',
          background: AppColors.dangerSoft,
          foreground: AppColors.danger,
        ),
        children: [
          if (_fileName == null) ...[
            UploadBox(
              label: 'Ketuk untuk unggah proposal (PDF)',
              onTap: () => setState(() {
                final String slug = _title.text.trim().isEmpty
                    ? 'Kegiatan'
                    : _title.text.trim().split(' ').first;
                _fileName = 'Proposal_${slug}_2025.pdf';
              }),
            ),
            if (_showStepErrors) ...[
              const SizedBox(height: 6),
              const Text(
                'Dokumen proposal wajib diunggah',
                style: TextStyle(fontSize: 12, color: AppColors.danger),
              ),
            ],
          ] else ...[
            FileTile(
              fileName: _fileName!,
              trailing: IconButton(
                tooltip: 'Hapus berkas',
                onPressed: () => setState(() => _fileName = null),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ),
            const SizedBox(height: 8),
            const NoteBox.success(
              text: 'Berkas valid dan siap diverifikasi BKA.',
            ),
          ],
        ],
      ),
      const SizedBox(height: 16),
      Form(
        key: _formKeys[1],
        child: Column(
          children: [
            FormSectionCard(
              title: 'Rincian Anggaran (RAB)',
              icon: Icons.payments_outlined,
              children: [
                const FieldLabel(
                  'Total Estimasi Anggaran Diajukan',
                  required: true,
                ),
                TextFormField(
                  controller: _budget,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: appInputDecoration(
                    hint: '12500000',
                    prefixIcon: Icons.account_balance_wallet_outlined,
                  ).copyWith(prefixText: 'Rp '),
                  validator: (String? v) {
                    final int value = int.tryParse(v ?? '') ?? 0;
                    if (value <= 0) return 'Anggaran wajib diisi';
                    if (value > _budgetLimit) {
                      return 'Melebihi batas subsidi BKA';
                    }
                    return null;
                  },
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
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Batas subsidi BKA per event',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          Text(
                            formatRupiah(_budgetLimit),
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
                          value: ratio,
                          minHeight: 6,
                          backgroundColor: AppColors.surfaceHigh,
                          color: overLimit
                              ? AppColors.danger
                              : AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Terpakai ${(ratio * 100).round()}% • '
                          '${formatRupiah(_budgetValue)}',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: overLimit
                                ? AppColors.danger
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FormSectionCard(
              title: 'Dosen Pembimbing & Verifikator',
              icon: Icons.supervisor_account_outlined,
              children: [
                const FieldLabel(
                  'Dosen Pembina Penanggung Jawab',
                  required: true,
                ),
                TextFormField(
                  controller: _advisor,
                  decoration: appInputDecoration(
                    prefixIcon: Icons.person_outline_rounded,
                  ),
                  validator: (String? v) => (v ?? '').trim().isEmpty
                      ? 'Nama dosen pembina wajib diisi'
                      : null,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Dosen pembina akan menerima notifikasi untuk menyetujui '
                  'proposal.',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                ),
                const Divider(height: 24),
                CheckboxListTile(
                  value: _agreed,
                  onChanged: (bool? v) => setState(() => _agreed = v ?? false),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text(
                    'Saya menyatakan data proposal ini benar dan bersedia '
                    'menyerahkan LPJ maksimal 14 hari setelah kegiatan.',
                    style: TextStyle(fontSize: 12.5, height: 1.45),
                  ),
                  subtitle: _showStepErrors && !_agreed
                      ? const Text(
                          'Persetujuan wajib dicentang',
                          style: TextStyle(color: AppColors.danger),
                        )
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  // --- Langkah 3 -----------------------------------------------------------

  List<Widget> _stepConfirm() {
    return [
      SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PillBadge(
              text: _category,
              background: AppColors.primaryTint,
              foreground: AppColors.glow,
            ),
            const SizedBox(height: 10),
            Text(
              _title.text.trim(),
              style: const TextStyle(
                fontFamily: AppFonts.heading,
                fontSize: 18,
                letterSpacing: -0.2,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _description.text.trim(),
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.1,
              children: [
                LabeledValue(
                  label: 'Tanggal',
                  value: formatTanggalPendek(_date!),
                ),
                LabeledValue(
                  label: 'Waktu',
                  value: '${formatJam(_start)} - ${formatJam(_end)}',
                ),
                LabeledValue(label: 'Lokasi', value: _location.text.trim()),
                LabeledValue(label: 'Format', value: _format),
                LabeledValue(
                  label: 'Peserta',
                  value: _internal ? 'Internal ITPLN' : 'Umum',
                ),
                LabeledValue(label: 'Kuota', value: '${_quota.text} Peserta'),
                LabeledValue(label: 'Poin SKPI', value: '+$_skpi Poin'),
              ],
            ),
            const SizedBox(height: 10),
            LabeledValue(
              label: 'Anggaran Diajukan',
              value: formatRupiah(_budgetValue),
              valueColor: AppColors.primary,
            ),
            const SizedBox(height: 10),
            FileTile(fileName: _fileName!),
            const SizedBox(height: 10),
            InfoLine(
              icon: Icons.school_outlined,
              text: 'Dosen Pembina: ${_advisor.text.trim()}',
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      const NoteBox.warning(
        title: 'Periksa kembali sebelum mengirim',
        text:
            'Setelah dikirim, data proposal tidak dapat diubah sampai BKA '
            'memberikan keputusan atau meminta revisi.',
      ),
    ];
  }
}

// ---------------------------------------------------------------------------
// Widget pendukung
// ---------------------------------------------------------------------------

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.step, required this.labels});

  final int step;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Row(
        children: [
          for (int i = 0; i < labels.length; i++) ...[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: i < step
                          ? AppColors.primary
                          : i == step
                          ? AppColors.primary
                          : AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${i + 1}. ${labels[i]}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: i <= step
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (i < labels.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({
    required this.title,
    required this.category,
    required this.date,
  });

  final String title;
  final String category;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(color: AppColors.primary, width: 4),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.primarySoft,
            child: Icon(Icons.event_note_rounded, color: AppColors.glow),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${category.toUpperCase()} • DRAF',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
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

/// Field yang membuka picker (tanggal / jam) saat diketuk.
class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.icon,
    required this.text,
    required this.onTap,
    this.placeholder = false,
    this.error,
  });

  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final bool placeholder;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: appInputDecoration(prefixIcon: icon)
            .copyWith(errorText: error),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            color: placeholder ? AppColors.textMuted : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
