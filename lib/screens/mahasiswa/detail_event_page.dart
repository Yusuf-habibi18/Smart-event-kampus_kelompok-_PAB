import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../models/campus_event.dart';
import '../../models/event_ticket.dart';
import '../../models/student_profile.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/ticket_viewmodel.dart';
import 'mahasiswa_widgets.dart';
import 'tiket_event_page.dart';

const List<String> _workshopTracks = [
  'Track A: UI Design Tokens & Atomic System',
  'Track B: Adaptive Layout & Responsive Grid',
  'Track C: Portfolio Review & Career Pathway',
];

const List<String> _jalurLabels = ['Luring', 'Daring (Zoom)'];

/// View: detail event (langkah 1) dan formulir pendaftaran (langkah 2).
///
/// Menerima [event] dari halaman asal lewat constructor (Navigator.push).
/// Proses pendaftaran dijalankan oleh [TicketViewModel.registerEvent].
class DetailEventPage extends StatefulWidget {
  const DetailEventPage({super.key, required this.event});

  final CampusEvent event;

  @override
  State<DetailEventPage> createState() => _DetailEventPageState();
}

class _DetailEventPageState extends State<DetailEventPage> {
  final ScrollController _scroll = ScrollController();
  final TextEditingController _phoneController = TextEditingController();

  int _step = 0; // 0 = Detail, 1 = Pendaftaran
  int? _jalur; // 0 = luring, 1 = daring
  String? _track;
  String? _fileName;
  bool _agree = false;
  bool _submitted = false;

  @override
  void dispose() {
    _scroll.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool get _loading => context.read<TicketViewModel>().isSubmitting;

  static String? _validatePhone(String text) {
    final String digits = text.replaceAll(RegExp(r'[\s-]'), '');
    if (digits.isEmpty) return 'Nomor WhatsApp wajib diisi.';
    if (!RegExp(r'^(08|\+628)\d{7,12}$').hasMatch(digits)) {
      return 'Format nomor tidak valid, contoh 081234567890.';
    }
    return null;
  }

  void _goStep(int step) {
    if (_loading) return;
    // Sudah terdaftar: tombol "Daftar" berubah menjadi "Lihat Tiket Saya".
    final EventTicket? mine =
        context.read<TicketViewModel>().ticketFor(widget.event);
    if (step == 1 && mine != null) {
      openTicket(context, mine);
      return;
    }
    setState(() => _step = step);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _pickTrack() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Text(
                  'Pilih Peminatan Workshop',
                  style: TextStyle(
                    fontFamily: AppFonts.heading,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
              ),
              for (final String track in _workshopTracks)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  title: Text(track),
                  trailing: track == _track
                      ? const Icon(Icons.check_rounded, color: AppColors.navy)
                      : null,
                  onTap: () {
                    Navigator.of(ctx).pop();
                    setState(() => _track = track);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  /// Simulasi unggah berkas.
  /// TODO: ganti dengan paket `file_picker` untuk memilih file sungguhan.
  void _toggleFile() {
    setState(() {
      _fileName = _fileName == null ? 'ktm_arya_pratama.jpg' : null;
    });
  }

  /// Alur data: input (TextField) → _phoneController → registerEvent()
  /// di ViewModel → Navigator.pushReplacement ke TiketEventPage → nomor
  /// WhatsApp, jalur, dan track tampil di E-Tiket.
  Future<void> _submit() async {
    setState(() => _submitted = true);

    final bool phoneValid = _validatePhone(_phoneController.text) == null;
    if (!phoneValid ||
        _jalur == null ||
        _track == null ||
        _fileName == null ||
        !_agree) {
      showSnack(context, 'Lengkapi data yang ditandai terlebih dahulu.');
      return;
    }
    FocusScope.of(context).unfocus();

    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final EventTicket ticket =
        await context.read<TicketViewModel>().registerEvent(
              widget.event,
              phone: _phoneController.text,
              participation: _jalurLabels[_jalur!],
              track: _track!,
            );
    if (!mounted) return;

    navigator.pushReplacement(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => TiketEventPage(ticket: ticket),
      ),
    );
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Pendaftaran berhasil. Tiket QR siap.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final CampusEvent event = widget.event;
    final TicketViewModel tickets = context.watch<TicketViewModel>();
    final EventTicket? myTicket = tickets.ticketFor(event);

    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) _goStep(0);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: ScreenAppBar(
          title: _step == 0 ? 'Detail Event' : 'Pendaftaran Event',
          subtitle: event.organizer,
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
                    child: _StepIndicator(current: _step, onSelect: _goStep),
                  ),
                  Expanded(
                    child: ListView(
                      controller: _scroll,
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      children: _step == 0
                          ? _detailChildren(event, registered: myTicket != null)
                          : _formChildren(event),
                    ),
                  ),
                  _BottomBar(
                    step: _step,
                    loading: tickets.isSubmitting,
                    registered: myTicket != null,
                    onNext: () => _goStep(1),
                    onSubmit: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Langkah 1: detail ---------------------------------------------------

  List<Widget> _detailChildren(CampusEvent event, {required bool registered}) {
    final CategoryStyle style = categoryStyle(event.category);

    return [
      ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 168,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: style.colors,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -12,
                bottom: -24,
                child: Icon(
                  style.icon,
                  size: 170,
                  color: Colors.white.withAlpha(40),
                ),
              ),
              Positioned(
                left: 16,
                bottom: 16,
                child: PillBadge.glass(text: event.category),
              ),
              Positioned(
                right: 16,
                top: 16,
                child: PillBadge(text: event.pointsLabel),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (registered)
            const PillBadge.success(
              text: 'Anda Sudah Terdaftar',
              icon: Icons.check_circle_rounded,
            ),
          const PillBadge(text: 'Gratis Bersertifikat SKPI'),
          PillBadge.success(
            text: 'Kuota: ${event.quotaLabel}',
            icon: Icons.event_seat_rounded,
          ),
          const PillBadge.success(
            text: 'Terverifikasi BEM',
            icon: Icons.verified_rounded,
          ),
        ],
      ),
      const SizedBox(height: 12),
      Text(
        event.title,
        style: const TextStyle(
          fontFamily: AppFonts.heading,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          height: 1.25,
          letterSpacing: -0.4,
          color: AppColors.navy,
        ),
      ),
      const SizedBox(height: 16),
      SurfaceCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                _initials(event.organizer),
                style: const TextStyle(
                  fontFamily: AppFonts.heading,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.organizer,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Text(
                    'Biro Kemahasiswaan & Penalaran',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const PillBadge.success(text: 'Mitra Resmi'),
          ],
        ),
      ),
      const SizedBox(height: 24),
      const SectionHeader(title: 'Jadwal Acara'),
      const SizedBox(height: 12),
      _twoColumns([
        _InfoTile(
          icon: Icons.event_rounded,
          label: 'Tanggal & Waktu',
          value: event.dateLabel,
          sub: event.timeRange,
        ),
        _InfoTile(
          icon: Icons.place_rounded,
          label: 'Lokasi',
          value: event.location,
          sub: 'Hybrid via Zoom tersedia',
        ),
      ]),
      const SizedBox(height: 24),
      SectionHeader(title: 'Benefit Peserta', trailingText: event.pointsLabel),
      const SizedBox(height: 12),
      _twoColumns([
        const _InfoTile(
          icon: Icons.workspace_premium_rounded,
          value: 'E-Sertifikat SIAKAD',
          sub: 'Otomatis sinkron ke transkrip',
        ),
        _InfoTile(
          icon: Icons.stars_rounded,
          value: '+${event.points} Poin Kemahasiswaan',
          sub: 'Syarat kelulusan wisuda',
        ),
        const _InfoTile(
          icon: Icons.lunch_dining_rounded,
          value: 'Snack & Makan Siang',
          sub: 'Khusus peserta luring',
        ),
        const _InfoTile(
          icon: Icons.folder_zip_rounded,
          value: 'Toolkit & Modul',
          sub: 'Materi dan kit digital',
        ),
      ]),
      const SizedBox(height: 24),
      const SectionHeader(title: 'Tentang Acara'),
      const SizedBox(height: 12),
      SurfaceCard(
        child: Text(
          '${event.title} dirancang bersama praktisi dan pembina ormawa '
          'untuk memperkuat portofolio, jejaring, dan sertifikasi '
          'kompetensi mahasiswa. Peserta mendapat materi terstruktur, sesi '
          'praktik, dan kesempatan berdiskusi langsung dengan narasumber.',
          style: const TextStyle(
            fontSize: 14,
            height: 1.6,
            color: AppColors.textSecondary,
          ),
        ),
      ),
      const SizedBox(height: 24),
      const SectionHeader(title: 'Silabus Sesi'),
      const SizedBox(height: 12),
      const SurfaceCard(
        child: Column(
          children: [
            _SyllabusRow(
              number: 1,
              title: 'Pembukaan & Keynote',
              detail: 'Gambaran besar materi dan arahan dari narasumber.',
            ),
            _SyllabusRow(
              number: 2,
              title: 'Sesi Praktik',
              detail: 'Hands-on lab dan latihan terbimbing bersama mentor.',
            ),
            _SyllabusRow(
              number: 3,
              title: 'Review & Peluang',
              detail: 'Review portofolio, tanya jawab, dan info magang.',
              isLast: true,
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      const SectionHeader(
        title: 'Narasumber Tamu',
        trailingText: '2 Pembicara Utama',
      ),
      const SizedBox(height: 12),
      const _SpeakerCard(
        name: 'Nadira Anindya, S.Kom.',
        role: 'Lead Design Architect - GoTo Financial',
      ),
      const SizedBox(height: 10),
      const _SpeakerCard(
        name: 'Dimas Wicaksono, M.T.',
        role: 'Principal Engineer - Tokopedia Campus Tech',
        note: 'Dosen Tamu Pemrograman Mobile',
      ),
    ];
  }

  // --- Langkah 2: formulir -------------------------------------------------

  List<Widget> _formChildren(CampusEvent event) {
    final String? jalurError = _submitted && _jalur == null
        ? 'Pilih salah satu jalur partisipasi.'
        : null;
    final String? trackError =
        _submitted && _track == null ? 'Pilih peminatan workshop.' : null;
    final String? fileError =
        _submitted && _fileName == null ? 'Unggah berkas persyaratan.' : null;
    final String? agreeError =
        _submitted && !_agree ? 'Anda harus menyetujui komitmen kehadiran.' : null;
    final String? phoneError =
        _submitted ? _validatePhone(_phoneController.text) : null;
    final StudentProfile student = context.watch<AuthViewModel>().student;

    return [
      Row(
        children: [
          const Expanded(
            child: Text(
              'Formulir Konfirmasi Pendaftaran',
              style: TextStyle(
                fontFamily: AppFonts.heading,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                height: 1.25,
                color: AppColors.navy,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const PillBadge(text: 'Data SIAKAD', icon: Icons.sync_rounded),
        ],
      ),
      const SizedBox(height: 6),
      Text(
        event.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
      ),
      const SizedBox(height: 20),
      const SectionHeader(title: 'Identitas Mahasiswa Terhubung'),
      const SizedBox(height: 12),
      SurfaceCard(
        child: Column(
          children: [
            _ReadOnlyField(label: 'Nama Lengkap', value: student.name),
            const SizedBox(height: 12),
            _ReadOnlyField(label: 'NIM', value: student.nim),
            const SizedBox(height: 12),
            _ReadOnlyField(
              label: 'Fakultas / Program Studi',
              value: '${student.faculty} / ${student.program} '
                  '(Semester ${student.semester})',
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      const _FieldLabel('Nomor WhatsApp Aktif', required: true),
      const SizedBox(height: 10),
      TextField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.done,
        autofillHints: const [AutofillHints.telephoneNumber],
        decoration: appInputDecoration(
          hint: '081234567890',
          prefixIcon: Icons.phone_rounded,
        ).copyWith(
          errorText: phoneError,
          helperText: 'Dipakai panitia untuk info teknis acara.',
        ),
        // Perbarui pesan error secara langsung setelah tombol Konfirmasi
        // pernah ditekan.
        onChanged: (_) {
          if (_submitted) setState(() {});
        },
      ),
      const SizedBox(height: 24),
      const _FieldLabel('Pilihan Jalur Partisipasi', required: true),
      const SizedBox(height: 10),
      IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _ChoiceCard(
                icon: Icons.meeting_room_rounded,
                title: 'Luring (${_shortPlace(event.location)})',
                subtitle: 'Sisa 24 kursi makan siang',
                selected: _jalur == 0,
                onTap: () => setState(() => _jalur = 0),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ChoiceCard(
                icon: Icons.videocam_rounded,
                title: 'Daring (Zoom)',
                subtitle: 'Kuota tak terbatas',
                selected: _jalur == 1,
                onTap: () => setState(() => _jalur = 1),
              ),
            ),
          ],
        ),
      ),
      if (jalurError != null) _ErrorText(jalurError),
      const SizedBox(height: 24),
      const _FieldLabel('Pilih Peminatan Workshop', required: true),
      const SizedBox(height: 10),
      InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: _pickTrack,
        child: InputDecorator(
          isEmpty: _track == null,
          decoration: appInputDecoration(
            hint: 'Ketuk untuk memilih track',
            suffixIcon: const Icon(Icons.expand_more_rounded),
          ).copyWith(errorText: trackError),
          child: Text(
            _track ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
      const SizedBox(height: 24),
      const SectionHeader(title: 'Syarat Tambahan Panitia'),
      const SizedBox(height: 12),
      SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tangkapan layar follow Instagram @hmif.kampus atau Kartu '
              'Mahasiswa (KTM).',
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            _UploadBox(fileName: _fileName, onTap: _toggleFile),
            if (fileError != null) _ErrorText(fileError),
          ],
        ),
      ),
      const SizedBox(height: 16),
      CheckboxListTile(
        value: _agree,
        onChanged: (bool? v) => setState(() => _agree = v ?? false),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        activeColor: AppColors.navy,
        title: const Text(
          'Saya berkomitmen hadir tepat waktu dan memahami bahwa '
          'pembatalan sepihak dapat mempengaruhi penalti poin SKPI.',
          style: TextStyle(
            fontSize: 13,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
      ),
      if (agreeError != null) _ErrorText(agreeError),
      const SizedBox(height: 16),
      const SectionHeader(title: 'Panduan Alur Pendaftaran & Tiket'),
      const SizedBox(height: 12),
      const SurfaceCard(
        child: Column(
          children: [
            _SyllabusRow(
              number: 1,
              title: 'Pendaftaran Berhasil & Verifikasi Instan',
              detail: 'Data diambil otomatis dari SIAKAD.',
            ),
            _SyllabusRow(
              number: 2,
              title: 'QR Ticket untuk Absensi Hari H',
              detail: 'Dapat dibuka kembali lewat tab Tiket Saya.',
            ),
            _SyllabusRow(
              number: 3,
              title: 'Klaim Sertifikat Digital SIAKAD',
              detail: 'Tersedia setelah presensi terverifikasi.',
              isLast: true,
            ),
          ],
        ),
      ),
    ];
  }

  static String _initials(String text) {
    final List<String> words =
        text.split(RegExp(r'\s+')).where((String w) => w.isNotEmpty).toList();
    return words.take(2).map((String w) => w[0]).join().toUpperCase();
  }

  static String _shortPlace(String location) {
    final String first = location.split('&').first.trim();
    return first.length > 18 ? '${first.substring(0, 17)}…' : first;
  }
}

// ---------------------------------------------------------------------------
// Widget pendukung
// ---------------------------------------------------------------------------

Widget _twoColumns(List<Widget> items) {
  return Column(
    children: [
      for (int i = 0; i < items.length; i += 2)
        Padding(
          padding: EdgeInsets.only(top: i == 0 ? 0 : 12),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: items[i]),
                const SizedBox(width: 12),
                Expanded(
                  child: i + 1 < items.length
                      ? items[i + 1]
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
    ],
  );
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current, required this.onSelect});

  final int current;
  final ValueChanged<int> onSelect;

  static const List<String> _labels = ['Detail', 'Pendaftaran', 'Tiket QR'];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < _labels.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 13),
                child: Container(
                  height: 2,
                  color: i <= current ? AppColors.navy : AppColors.outline,
                ),
              ),
            ),
          _StepDot(
            index: i,
            label: _labels[i],
            done: i < current,
            active: i == current,
            // Langkah "Tiket QR" baru terbuka setelah pendaftaran selesai.
            onTap: i < 2 ? () => onSelect(i) : null,
          ),
        ],
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.index,
    required this.label,
    required this.done,
    required this.active,
    required this.onTap,
  });

  final int index;
  final String label;
  final bool done;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool filled = done || active;

    return Semantics(
      button: onTap != null,
      selected: active,
      label: 'Langkah ${index + 1}: $label',
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: filled ? AppColors.navy : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: filled ? AppColors.navy : AppColors.outline,
                    width: 2,
                  ),
                ),
                child: done
                    ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                    : Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: filled ? Colors.white : AppColors.textMuted,
                        ),
                      ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                  color: active ? AppColors.navy : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.step,
    required this.loading,
    required this.registered,
    required this.onNext,
    required this.onSubmit,
  });

  final int step;
  final bool loading;
  final bool registered;
  final VoidCallback onNext;
  final VoidCallback onSubmit;

  String get _label {
    if (step != 0) return 'Konfirmasi';
    return registered ? 'Lihat Tiket Saya' : 'Daftar Sekarang';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.surfaceHigh)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Biaya Registrasi',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                SizedBox(height: 2),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'GRATIS',
                        style: TextStyle(
                          fontFamily: AppFonts.heading,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.success,
                        ),
                      ),
                      TextSpan(
                        text: ' / Mahasiswa Aktif',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: loading ? null : (step == 0 ? onNext : onSubmit),
            style: FilledButton.styleFrom(
              minimumSize: const Size(150, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontFamily: AppFonts.heading,
                fontWeight: FontWeight.w800,
              ),
            ),
            child: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(_label),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.value,
    this.label,
    this.sub,
  });

  final IconData icon;
  final String? label;
  final String value;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.navy),
          ),
          const SizedBox(height: 10),
          if (label != null)
            Text(
              label!,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              height: 1.3,
              color: AppColors.textPrimary,
            ),
          ),
          if (sub != null) ...[
            const SizedBox(height: 2),
            Text(
              sub!,
              style: const TextStyle(
                fontSize: 12,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SyllabusRow extends StatelessWidget {
  const _SyllabusRow({
    required this.number,
    required this.title,
    required this.detail,
    this.isLast = false,
  });

  final int number;
  final String title;
  final String detail;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.accentSoft,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.accentDark,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: AppColors.textSecondary,
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

class _SpeakerCard extends StatelessWidget {
  const _SpeakerCard({required this.name, required this.role, this.note});

  final String name;
  final String role;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.surfaceLow,
            child: Text(
              name[0],
              style: const TextStyle(
                fontFamily: AppFonts.heading,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  role,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (note != null)
                  Text(
                    note!,
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
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {this.required = false});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
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
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4),
      child: Text(
        message,
        style: const TextStyle(fontSize: 12, color: AppColors.danger),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
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
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppColors.periwinkle : Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected ? AppColors.navy : AppColors.outline,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 22, color: AppColors.navy),
                    const Spacer(),
                    Icon(
                      selected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 20,
                      color: selected ? AppColors.navy : AppColors.outline,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.textSecondary,
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

class _UploadBox extends StatelessWidget {
  const _UploadBox({required this.fileName, required this.onTap});

  final String? fileName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool hasFile = fileName != null;

    return Material(
      color: hasFile ? AppColors.successSoft : AppColors.surfaceLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: hasFile ? AppColors.success : AppColors.outline,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Icon(
                hasFile
                    ? Icons.check_circle_rounded
                    : Icons.cloud_upload_outlined,
                size: 28,
                color: hasFile ? AppColors.success : AppColors.navy,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasFile ? fileName! : 'Ketuk untuk unggah file berkas',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      hasFile
                          ? 'Ketuk lagi untuk menghapus berkas'
                          : 'JPG, PNG, atau PDF (Maks. 2MB)',
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
        ),
      ),
    );
  }
}