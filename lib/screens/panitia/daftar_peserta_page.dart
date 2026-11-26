import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../models/participant.dart';
import '../../viewmodels/presensi_viewmodel.dart';
import '../mahasiswa/mahasiswa_widgets.dart';
import 'scan_qr_page.dart';

/// Menampilkan dialog input NIM dan mencatat presensi manual.
/// Dipakai halaman Kelola Peserta dan Pemindai QR.
Future<void> showManualCheckIn(BuildContext context) async {
  final PresensiViewModel vm = context.read<PresensiViewModel>();
  final String? nim = await showDialog<String>(
    context: context,
    builder: (_) => const _ManualNimDialog(),
  );
  if (nim == null || !context.mounted) return;
  final CheckInResult result = vm.checkIn(nim, manual: true);
  showSnack(context, switch (result) {
    CheckInResult.berhasil =>
      'Presensi ${vm.lastScanned!.name} tercatat (manual).',
    CheckInResult.sudahHadir => '${vm.lastScanned!.name} sudah tercatat hadir.',
    CheckInResult.tidakTerdaftar => 'NIM $nim tidak terdaftar di event ini.',
  });
}

/// View: Kelola Peserta & Presensi.
///
/// Statistik kehadiran, pencarian, filter, dan tombol tandai hadir manual.
/// Data dari [PresensiViewModel] yang sama dengan halaman Scan QR.
class DaftarPesertaPage extends StatefulWidget {
  const DaftarPesertaPage({super.key, this.asTab = false});

  /// true jika ditampilkan sebagai tab di OrmawaShell (tanpa tombol back).
  final bool asTab;

  @override
  State<DaftarPesertaPage> createState() => _DaftarPesertaPageState();
}

class _DaftarPesertaPageState extends State<DaftarPesertaPage> {
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(
      text: context.read<PresensiViewModel>().query,
    );
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openScanner() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const ScanQrPage()),
    );
  }

  Future<void> _markPresent(Participant p) async {
    final PresensiViewModel vm = context.read<PresensiViewModel>();
    final bool ok = await confirmDialog(
      context,
      title: 'Tandai hadir manual?',
      message: '${p.name} (${p.nim}) akan dicatat hadir tanpa scan QR.',
      confirmLabel: 'Tandai Hadir',
    );
    if (!ok || !mounted) return;
    vm.checkIn(p.nim, manual: true);
    showSnack(context, '${p.name} ditandai hadir.');
  }

  @override
  Widget build(BuildContext context) {
    final PresensiViewModel vm = context.watch<PresensiViewModel>();
    final List<Participant> list = vm.filteredParticipants;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ScreenAppBar(
        title: 'Kelola Peserta & Presensi',
        subtitle: 'Daftar hadir diperbarui otomatis',
        showBack: !widget.asTab,
        actions: [
          IconButton(
            tooltip: 'Ekspor data peserta',
            onPressed: () => showComingSoon(context, 'Ekspor Excel'),
            icon: const Icon(Icons.file_download_outlined),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            children: [
              _EventBanner(vm: vm),
              const SizedBox(height: 16),
              _AttendanceCard(vm: vm),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ActionTile(
                      icon: Icons.qr_code_scanner_rounded,
                      title: 'Buka Scanner',
                      caption: 'Presensi via QR',
                      filled: true,
                      onTap: _openScanner,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionTile(
                      icon: Icons.keyboard_alt_outlined,
                      title: 'Input NIM',
                      caption: 'Presensi manual',
                      onTap: () => showManualCheckIn(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _search,
                onChanged: vm.search,
                textInputAction: TextInputAction.search,
                decoration: appInputDecoration(
                  hint: 'Cari nama, NIM, atau program studi...',
                  prefixIcon: Icons.search_rounded,
                  suffixIcon: vm.query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Hapus pencarian',
                          onPressed: () {
                            _search.clear();
                            vm.search('');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final AttendanceFilter f
                        in AttendanceFilter.values) ...[
                      ChoiceChip(
                        label: Text('${f.label} (${vm.countBy(f)})'),
                        selected: vm.filter == f,
                        onSelected: (_) => vm.selectFilter(f),
                        showCheckmark: false,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: vm.filter == f
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
              const SizedBox(height: 12),
              Text(
                'Menampilkan ${list.length} dari ${vm.total} peserta',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 10),
              if (list.isEmpty)
                const EmptyState(
                  icon: Icons.person_search_outlined,
                  title: 'Peserta tidak ditemukan',
                  message: 'Coba kata kunci atau filter lain.',
                ),
              for (final Participant p in list) ...[
                _ParticipantCard(
                  participant: p,
                  onMarkPresent: () => _markPresent(p),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: widget.asTab
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: _openScanner,
                    icon: const Icon(Icons.qr_code_scanner_rounded),
                    label: const Text('Scan Tiket QR Peserta'),
                  ),
                ),
              ),
            ),
    );
  }
}

class _EventBanner extends StatelessWidget {
  const _EventBanner({required this.vm});

  final PresensiViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.brandPanel(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PillBadge(
            text: 'Acara Berlangsung',
            icon: Icons.circle,
            background: Colors.white,
            foreground: AppColors.glow,
          ),
          const SizedBox(height: 10),
          Text(
            vm.eventTitle,
            style: const TextStyle(
              fontFamily: AppFonts.heading,
              fontSize: 17,
              letterSpacing: -0.2,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 14,
            runSpacing: 4,
            children: [
              _WhiteMeta(Icons.place_outlined, vm.eventLocation),
              _WhiteMeta(Icons.schedule_rounded, vm.eventTime),
            ],
          ),
        ],
      ),
    );
  }
}

class _WhiteMeta extends StatelessWidget {
  const _WhiteMeta(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xCCFFFFFF)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: Color(0xCCFFFFFF)),
        ),
      ],
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({required this.vm});

  final PresensiViewModel vm;

  @override
  Widget build(BuildContext context) {
    Widget box(String label, int value, Color bg, Color fg) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$value',
                style: TextStyle(
                  fontFamily: AppFonts.heading,
                  fontSize: 20,
                  letterSpacing: -0.2,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SurfaceCard(
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.insights_rounded, size: 18, color: AppColors.glow),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Statistik Kehadiran',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              PillBadge(
                text: 'Live',
                icon: Icons.circle,
                background: AppColors.successSoft,
                foreground: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${vm.presentCount}',
                style: const TextStyle(
                  fontFamily: AppFonts.heading,
                  fontSize: 30,
                  letterSpacing: -0.3,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5, left: 4),
                child: Text(
                  '/ ${vm.total} Peserta',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${vm.attendancePercent}%',
                style: const TextStyle(
                  fontFamily: AppFonts.heading,
                  fontSize: 18,
                  letterSpacing: -0.2,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: AnimatedProgress(
              value: vm.attendanceRatio,
              minHeight: 8,
              backgroundColor: AppColors.surfaceHigh,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              box(
                'Hadir',
                vm.presentCount,
                AppColors.successSoft,
                AppColors.success,
              ),
              const SizedBox(width: 8),
              box(
                'Belum Hadir',
                vm.absentCount,
                AppColors.warningSoft,
                AppColors.warning,
              ),
              const SizedBox(width: 8),
              box(
                'Manual',
                vm.manualCount,
                AppColors.surfaceLow,
                AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.caption,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final String title;
  final String caption;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final Color fg = filled ? Colors.white : AppColors.glow;
    return Material(
      color: filled ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary, width: 1.2),
          ),
          child: Row(
            children: [
              Icon(icon, color: fg),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: fg,
                      ),
                    ),
                    Text(
                      caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: fg.withAlpha(190)),
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

class _ParticipantCard extends StatelessWidget {
  const _ParticipantCard({
    required this.participant,
    required this.onMarkPresent,
  });

  final Participant participant;
  final VoidCallback onMarkPresent;

  @override
  Widget build(BuildContext context) {
    final Participant p = participant;
    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: p.isPresent
                    ? AppColors.primaryTint
                    : AppColors.surfaceLow,
                child: Text(
                  p.initials,
                  style: const TextStyle(
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
                      p.name,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'NIM ${p.nim}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      p.program,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Kursi',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      p.seat,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.glow,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 22),
          Row(
            children: [
              if (p.isPresent) ...[
                PillBadge.success(
                  text: 'Hadir • ${p.checkInTime} WIB',
                  icon: Icons.check_circle_rounded,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    p.manual ? 'Ditandai manual' : 'Scan QR',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ] else ...[
                const PillBadge.warning(
                  text: 'Belum Hadir',
                  icon: Icons.schedule_rounded,
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: onMarkPresent,
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.touch_app_outlined, size: 16),
                  label: const Text('Tandai Hadir'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ManualNimDialog extends StatefulWidget {
  const _ManualNimDialog();

  @override
  State<_ManualNimDialog> createState() => _ManualNimDialogState();
}

class _ManualNimDialogState extends State<_ManualNimDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nim = TextEditingController();

  @override
  void dispose() {
    _nim.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_nim.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Input NIM Manual'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gunakan jika QR peserta rusak atau tidak terbaca.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nim,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onFieldSubmitted: (_) => _submit(),
              decoration: appInputDecoration(
                label: 'NIM Peserta',
                prefixIcon: Icons.badge_outlined,
              ),
              validator: (String? v) =>
                  (v ?? '').trim().length < 8 ? 'NIM minimal 8 digit' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Catat Hadir')),
      ],
    );
  }
}
