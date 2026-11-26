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

/// View: Edit Informasi Event.
///
/// Menerima [proposal] (event yang sudah disetujui BKA) lewat constructor.
/// Perubahan disimpan dengan [ProposalViewModel.updateProposal]. Anggaran
/// dan poin SKPI dikunci karena sudah ditetapkan BKA.
class KelolaEventPage extends StatefulWidget {
  const KelolaEventPage({super.key, required this.proposal});

  final EventProposal proposal;

  @override
  State<KelolaEventPage> createState() => _KelolaEventPageState();
}

class _KelolaEventPageState extends State<KelolaEventPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _title;
  late final TextEditingController _quota;
  late final TextEditingController _location;
  late final TextEditingController _link;
  late final TextEditingController _notes;

  late String _category;
  late String _format;
  late String _dateLabel;
  late String _timeLabel;
  bool _waitingList = true;
  bool _dirty = false;

  EventProposal get _p => widget.proposal;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: _p.title);
    _quota = TextEditingController(text: '${_p.quota}');
    _location = TextEditingController(text: _p.location);
    _link = TextEditingController(
      text: _p.format == 'Luring' ? '' : 'https://zoom.us/j/9284471100',
    );
    _notes = TextEditingController(text: _p.description);
    _category = proposalCategories.contains(_p.category)
        ? _p.category
        : proposalCategories.first;
    _format = _p.format;
    _dateLabel = _p.dateLabel;
    _timeLabel = _p.timeLabel;

    for (final TextEditingController c in [
      _title,
      _quota,
      _location,
      _link,
      _notes,
    ]) {
      c.addListener(_markDirty);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _quota.dispose();
    _location.dispose();
    _link.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  void _set(VoidCallback change) {
    setState(() {
      change();
      _dirty = true;
    });
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) _set(() => _dateLabel = formatTanggal(picked));
  }

  Future<void> _pickTimeRange() async {
    final TimeOfDay? start = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 13, minute: 0),
      helpText: 'Jam mulai',
    );
    if (start == null || !mounted) return;
    final TimeOfDay? end = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: (start.hour + 3) % 24, minute: start.minute),
      helpText: 'Jam selesai',
    );
    if (end == null) return;
    _set(() => _timeLabel = '${formatJam(start)} - ${formatJam(end)} WIB');
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final int quota = int.parse(_quota.text);
    if (quota < _p.registered) {
      showSnack(
        context,
        'Kuota tidak boleh kurang dari ${_p.registered} peserta terdaftar.',
      );
      return;
    }

    context.read<ProposalViewModel>().updateProposal(
      _p.copyWith(
        title: _title.text.trim(),
        category: _category,
        description: _notes.text.trim(),
        dateLabel: _dateLabel,
        timeLabel: _timeLabel,
        location: _location.text.trim(),
        format: _format,
        quota: quota,
      ),
    );
    Navigator.of(context).pop();
    showSnack(context, 'Perubahan "${_title.text.trim()}" tersimpan.');
  }

  Future<void> _cancel() async {
    if (!_dirty) {
      Navigator.of(context).pop();
      return;
    }
    final bool discard = await confirmDialog(
      context,
      title: 'Buang perubahan?',
      message: 'Perubahan yang belum disimpan akan hilang.',
      confirmLabel: 'Buang',
      destructive: true,
    );
    if (discard && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (bool didPop, Object? _) {
        if (!didPop) _cancel();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: ScreenAppBar(
          title: 'Edit Informasi Event',
          subtitle: _p.code,
          actions: [TextButton(onPressed: _save, child: const Text('Simpan'))],
        ),
        body: Form(
          key: _formKey,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                children: [
                  _EventSummary(proposal: _p),
                  const SizedBox(height: 16),
                  _sectionMain(),
                  const SizedBox(height: 16),
                  _sectionLocation(),
                  const SizedBox(height: 16),
                  _sectionSchedule(),
                  const SizedBox(height: 16),
                  _sectionTicket(),
                  const SizedBox(height: 16),
                  FormSectionCard(
                    title: '5. Catatan & Syarat Peserta',
                    icon: Icons.rule_rounded,
                    children: [
                      const FieldLabel('Deskripsi & persyaratan peserta'),
                      TextFormField(
                        controller: _notes,
                        minLines: 3,
                        maxLines: 6,
                        maxLength: 500,
                        decoration: appInputDecoration(
                          hint: 'mis. Membawa laptop dengan Figma terpasang',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomActionBar(
          children: [
            OutlinedButton(onPressed: _cancel, child: const Text('Batal')),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined, size: 18),
                label: const Text('Simpan Perubahan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionMain() {
    return FormSectionCard(
      title: '1. Informasi Utama & Kuota',
      icon: Icons.info_outline_rounded,
      children: [
        const FieldLabel('Judul Kegiatan', required: true),
        TextFormField(
          controller: _title,
          decoration: appInputDecoration(),
          validator: (String? v) =>
              (v ?? '').trim().length < 5 ? 'Judul minimal 5 karakter' : null,
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
          onChanged: (String? v) => _set(() => _category = v!),
        ),
        const SizedBox(height: 16),
        FieldLabel(
          'Kuota Total Peserta',
          required: true,
          trailing: PillBadge(
            text: '${_p.registered} terdaftar',
            background: AppColors.primaryTint,
            foreground: AppColors.glow,
          ),
        ),
        TextFormField(
          controller: _quota,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: appInputDecoration().copyWith(suffixText: 'Peserta'),
          validator: (String? v) =>
              (int.tryParse(v ?? '') ?? 0) < 1 ? 'Kuota minimal 1' : null,
        ),
        const SizedBox(height: 10),
        const NoteBox.warning(
          text:
              'Kuota tidak dapat dikurangi di bawah jumlah peserta yang '
              'sudah terdaftar.',
        ),
        const SizedBox(height: 6),
        SwitchListTile(
          value: _waitingList,
          onChanged: (bool v) => _set(() => _waitingList = v),
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'Aktifkan daftar tunggu',
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
          ),
          subtitle: const Text(
            'Peserta tetap bisa mendaftar saat kuota penuh.',
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _sectionLocation() {
    final bool online = _format != 'Luring';
    return FormSectionCard(
      title: '2. Lokasi & Ruang Acara',
      icon: Icons.place_outlined,
      children: [
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
                _set(() => _format = s.first),
          ),
        ),
        if (_format != 'Daring') ...[
          const SizedBox(height: 16),
          const FieldLabel('Nama Gedung & Ruangan', required: true),
          TextFormField(
            controller: _location,
            decoration: appInputDecoration(prefixIcon: Icons.apartment_rounded),
            validator: (String? v) =>
                (v ?? '').trim().isEmpty ? 'Lokasi wajib diisi' : null,
          ),
        ],
        if (online) ...[
          const SizedBox(height: 16),
          const FieldLabel(
            'Tautan Virtual Meeting (Zoom / Google Meet)',
            required: true,
          ),
          TextFormField(
            controller: _link,
            keyboardType: TextInputType.url,
            decoration: appInputDecoration(
              hint: 'https://zoom.us/j/...',
              prefixIcon: Icons.videocam_outlined,
            ),
            validator: (String? v) {
              final String text = (v ?? '').trim();
              if (text.isEmpty) return 'Tautan wajib diisi';
              if (!text.startsWith('http')) return 'Awali dengan https://';
              return null;
            },
          ),
          const SizedBox(height: 6),
          const Text(
            'Tautan hanya dikirim ke peserta terdaftar melalui E-Tiket.',
            style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
          ),
        ],
      ],
    );
  }

  Widget _sectionSchedule() {
    return FormSectionCard(
      title: '3. Jadwal & Waktu Acara',
      icon: Icons.calendar_month_rounded,
      children: [
        const FieldLabel('Tanggal Pelaksanaan', required: true),
        _TapField(
          icon: Icons.event_rounded,
          text: _dateLabel,
          onTap: _pickDate,
        ),
        const SizedBox(height: 16),
        const FieldLabel('Jam Pelaksanaan', required: true),
        _TapField(
          icon: Icons.schedule_rounded,
          text: _timeLabel,
          onTap: _pickTimeRange,
        ),
      ],
    );
  }

  Widget _sectionTicket() {
    return FormSectionCard(
      title: '4. Tiket & Akreditasi SKPI',
      icon: Icons.confirmation_number_outlined,
      trailing: const PillBadge(
        text: 'Diatur BKA',
        icon: Icons.lock_outline_rounded,
        background: AppColors.surfaceLow,
        foreground: AppColors.textSecondary,
      ),
      children: [
        const LabeledValue(
          label: 'Jenis Tiket Masuk',
          value: 'Gratis Mahasiswa Kampus (subsidi dana BKA)',
          icon: Icons.local_offer_outlined,
        ),
        const SizedBox(height: 10),
        LabeledValue(
          label: 'Poin SKPI yang didapat',
          value: '+${_p.skpiPoints} Poin SKPI',
          icon: Icons.workspace_premium_outlined,
          valueColor: AppColors.primary,
        ),
        const SizedBox(height: 10),
        LabeledValue(
          label: 'Anggaran disetujui',
          value: _p.budgetLabel,
          icon: Icons.payments_outlined,
        ),
        const SizedBox(height: 8),
        const Text(
          'Perubahan poin SKPI atau anggaran harus diajukan ulang ke BKA.',
          style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _EventSummary extends StatelessWidget {
  const _EventSummary({required this.proposal});

  final EventProposal proposal;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Dikelola oleh ${proposal.ormawa}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              ProposalStatusBadge(status: proposal.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            proposal.title,
            style: const TextStyle(
              fontFamily: AppFonts.heading,
              fontSize: 17,
              letterSpacing: -0.2,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          InfoLine(
            icon: Icons.groups_outlined,
            text: '${proposal.registered} peserta sudah mendaftar',
          ),
        ],
      ),
    );
  }
}

class _TapField extends StatelessWidget {
  const _TapField({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  final IconData icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: appInputDecoration(
          prefixIcon: icon,
          suffixIcon: const Icon(Icons.edit_calendar_outlined, size: 20),
        ),
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
