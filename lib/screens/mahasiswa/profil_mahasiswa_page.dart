import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_routes.dart';
import '../../core/app_theme.dart';
import '../../models/student_profile.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'mahasiswa_widgets.dart';

const int _skpiPoints = 85;
const int _skpiTarget = 100;

const List<String> _interestOptions = [
  'Teknologi',
  'Desain',
  'Karir',
  'Olahraga',
  'Seni',
  'Kewirausahaan',
  'Sosial',
  'Akademik',
];

class ProfilMahasiswaPage extends StatefulWidget {
  const ProfilMahasiswaPage({super.key, this.onSelectTab});

  /// Dipanggil untuk pindah tab di [MahasiswaShell].
  final ValueChanged<int>? onSelectTab;

  @override
  State<ProfilMahasiswaPage> createState() => _ProfilMahasiswaPageState();
}

class _ProfilMahasiswaPageState extends State<ProfilMahasiswaPage> {
  Set<String> _interests = {'Teknologi', 'Desain', 'Karir', 'Olahraga'};

  void _openStudentPass() {
    final StudentProfile student = context.read<AuthViewModel>().student;
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Digital Student Pass',
                  style: TextStyle(
                    fontFamily: AppFonts.heading,
                    fontSize: 18,
                    letterSpacing: -0.2,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.outline, width: 2),
                  ),
                  child: QrCodeView(
                    data:
                        'PESERTA-${student.isMahasiswa ? student.nim : student.email}',
                    size: 210,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  student.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  student.isMahasiswa ? 'NIM: ${student.nim}' : student.email,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tunjukkan ke panitia untuk presensi cepat di semua event.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.5,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                    shape: buttonShape,
                  ),
                  child: const Text('Tutup'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _editInterests() async {
    final Set<String>? result = await showDialog<Set<String>>(
      context: context,
      builder: (BuildContext ctx) => _InterestDialog(selected: _interests),
    );
    if (result != null && mounted) {
      setState(() => _interests = result);
      showSnack(context, 'Minat bidang kegiatan diperbarui.');
    }
  }

  Future<void> _logout() async {
    final bool ok = await confirmDialog(
      context,
      title: 'Keluar dari akun?',
      message: 'Anda perlu masuk kembali untuk mengakses tiket dan sertifikat.',
      confirmLabel: 'Keluar',
      destructive: true,
    );
    if (!ok || !mounted) return;
    context.read<AuthViewModel>().logout();
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (Route<dynamic> route) => false);
  }

  void _openTicketsTab() {
    final ValueChanged<int>? select = widget.onSelectTab;
    if (select != null) {
      select(2);
    } else {
      showComingSoon(context, 'Riwayat Transaksi & Tiket Event');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double progress = _skpiPoints / _skpiTarget;
    final int remaining = _skpiTarget - _skpiPoints;

    final StudentProfile student = context.watch<AuthViewModel>().student;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: HeroHeader(
                    eyebrow: 'Akun kamu',
                    title: 'Profil',
                    subtitle: 'Identitas, poin, dan dokumen kegiatan kamu.',
                    actions: [
                      CircleIconButton(
                        icon: Icons.settings_outlined,
                        tooltip: 'Pengaturan',
                        onPressed: () =>
                            Navigator.of(context)
                                .pushNamed(AppRoutes.pengaturan),
                      ),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 12, 20, 40),
                  sliver: SliverList.list(
                    children: [
                      _ProfileCard(
                        student: student,
                        onEdit: () => showComingSoon(context, 'Edit Profil'),
                      ),
                      const SizedBox(height: 20),
                      SurfaceCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.qr_code_2_rounded,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Digital Student Pass',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Tunjukkan saat masuk acara',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            FilledButton(
                              onPressed: _openStudentPass,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(0, 40),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                shape: buttonShape,
                                textStyle: const TextStyle(
                                  fontFamily: AppFonts.body,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              child: const Text('Buka QR'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      if (student.isMahasiswa) ...[
                        const SectionHeader(
                          eyebrow: 'Progres',
                          title: 'Capaian Poin SKPI',
                          trailingText: 'Target Wisuda: $_skpiTarget',
                        ),
                        const SizedBox(height: 12),
                        SurfaceCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Terkumpul',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  CountUp(
                                    value: _skpiPoints,
                                    style: TextStyle(
                                      fontFamily: AppFonts.heading,
                                      fontSize: 40,
                                      letterSpacing: -0.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                  Text(
                                    ' / $_skpiTarget Poin',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween<double>(begin: 0, end: progress),
                                  duration: const Duration(milliseconds: 900),
                                  curve: Curves.easeOutCubic,
                                  builder:
                                      (
                                        BuildContext context,
                                        double v,
                                        Widget? _,
                                      ) => LinearProgressIndicator(
                                        value: v,
                                        minHeight: 10,
                                        backgroundColor: AppColors.surfaceHigh,
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                              AppColors.primary,
                                            ),
                                      ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Sisa $remaining Poin untuk Wisuda',
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                  PillBadge(
                                    text:
                                        '${(progress * 100).round()}% Terpenuhi',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Row(
                          children: [
                            Expanded(
                              child: _MiniStat(
                                value: '10',
                                label: 'Event Diikuti',
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: _MiniStat(
                                value: '10',
                                label: 'E-Sertifikat',
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: _MiniStat(
                                value: '100%',
                                label: 'Presensi Hadir',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SurfaceCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: AppColors.successSoft,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.sync_rounded,
                                  color: AppColors.success,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Integrasi Akun SIAKAD',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      'Sinkronisasi data akademik otomatis',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const PillBadge.success(text: 'Terhubung'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                      const SectionHeader(title: 'Akademik & Kegiatan'),
                      const SizedBox(height: 12),
                      _MenuCard(
                        items: [
                          if (student.isMahasiswa)
                            _MenuItem(
                              icon: Icons.description_rounded,
                              title: 'Transkrip SKPI Saya',
                              subtitle:
                                  'Rincian Ilmiah, Organisasi, Kepanitiaan',
                              trailing: '3 Kategori',
                              onTap: () =>
                                  showComingSoon(context, 'Transkrip SKPI'),
                            ),
                          _MenuItem(
                            icon: Icons.workspace_premium_rounded,
                            title: 'Dokumen E-Sertifikat Tersimpan',
                            subtitle:
                                'Akses berkas digital format PDF & validasi',
                            trailing: '10 File',
                            onTap: () =>
                                Navigator.of(context)
                                    .pushNamed(AppRoutes.sertifikat),
                          ),
                          _MenuItem(
                            icon: Icons.receipt_long_rounded,
                            title: 'Riwayat Transaksi & Tiket Event',
                            subtitle: 'Daftar booking, invoice, & check-in',
                            onTap: _openTicketsTab,
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      SectionHeader(
                        title: 'Minat Bidang Kegiatan',
                        trailingText: 'Ubah',
                        onTrailingTap: _editInterests,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Rekomendasi acara disesuaikan dengan topik yang kamu ikuti:',
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final String interest in _interestOptions)
                            if (_interests.contains(interest))
                              Chip(
                                label: Text(interest),
                                backgroundColor: AppColors.primaryTint,
                                side: BorderSide.none,
                                labelStyle: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.glow,
                                ),
                              ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      const SectionHeader(title: 'Pusat Informasi'),
                      const SizedBox(height: 12),
                      _MenuCard(
                        items: [
                          _MenuItem(
                            icon: Icons.help_outline_rounded,
                            title: 'Bantuan & FAQ Kemahasiswaan',
                            onTap: () =>
                                showComingSoon(context, 'Bantuan & FAQ'),
                          ),
                          _MenuItem(
                            icon: Icons.menu_book_rounded,
                            title: 'Ketentuan SKPI & Panduan Organisasi',
                            onTap: () =>
                                showComingSoon(context, 'Ketentuan SKPI'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      OutlinedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout_rounded, size: 20),
                        label: const Text('Keluar Akun'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          foregroundColor: AppColors.danger,
                          side: const BorderSide(color: AppColors.danger),
                          shape: buttonShape,
                          textStyle: const TextStyle(
                            fontFamily: AppFonts.body,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'CampusEvent v2.4.0 • Universitas Terpadu Indonesia',
                        textAlign: TextAlign.center,
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
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widget pendukung
// ---------------------------------------------------------------------------

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.student, required this.onEdit});

  final StudentProfile student;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.brandPanel(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Text(
              student.initials,
              style: const TextStyle(
                fontFamily: AppFonts.heading,
                fontSize: 22,
                letterSpacing: -0.2,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(
                    fontFamily: AppFonts.heading,
                    fontSize: 20,
                    letterSpacing: -0.2,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                for (final String line
                    in student.isMahasiswa
                        ? [
                            'NIM: ${student.nim}',
                            student.program,
                            student.faculty,
                          ]
                        : [student.email, student.institution ?? 'Umum'])
                  Text(
                    line,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xD9FFFFFF),
                    ),
                  ),
                const SizedBox(height: 10),
                PillBadge.glass(
                  text: student.isMahasiswa
                      ? 'Aktif • Sem ${student.semester}'
                      : 'Peserta Umum',
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_rounded, size: 16),
            label: const Text('Edit'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 36),
              textStyle: const TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: AppFonts.heading,
              fontSize: 22,
              letterSpacing: -0.2,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailing;
  final VoidCallback onTap;
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.items});

  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              if (i > 0) const Divider(height: 1, indent: 72),
              _MenuTile(item: items[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.item});

  final _MenuItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, size: 20, color: AppColors.glow),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (item.subtitle != null)
                    Text(
                      item.subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: AppColors.textMuted,
                      ),
                    ),
                ],
              ),
            ),
            if (item.trailing != null) ...[
              const SizedBox(width: 8),
              PillBadge(text: item.trailing!),
            ],
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _InterestDialog extends StatefulWidget {
  const _InterestDialog({required this.selected});

  final Set<String> selected;

  @override
  State<_InterestDialog> createState() => _InterestDialogState();
}

class _InterestDialogState extends State<_InterestDialog> {
  late final Set<String> _temp = {...widget.selected};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Minat Bidang Kegiatan'),
      content: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final String option in _interestOptions)
            FilterChip(
              label: Text(option),
              selected: _temp.contains(option),
              selectedColor: AppColors.primaryTint,
              checkmarkColor: AppColors.primary,
              onSelected: (bool on) => setState(() {
                if (on) {
                  _temp.add(option);
                } else {
                  _temp.remove(option);
                }
              }),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _temp.isEmpty
              ? null
              : () => Navigator.of(context).pop(_temp),
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
