import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../models/student_profile.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'mahasiswa_widgets.dart';

const String _certNumber = 'SKPI/2025/HMIF-WS/0482';
const String _verifyHost = 'verify.kampus.ac.id/cert/0482-HMIF';

class SertifikatPage extends StatelessWidget {
  const SertifikatPage({super.key, this.showBackButton = false});

  /// true jika halaman dibuka lewat Navigator.push (bukan sebagai tab).
  final bool showBackButton;

  void _openFullscreen(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return Dialog.fullscreen(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 5,
                  child: const AspectRatio(
                    aspectRatio: _CertificateCanvas.width /
                        _CertificateCanvas.height,
                    child: FittedBox(child: _CertificateCanvas()),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: SafeArea(
                  child: IconButton(
                    tooltip: 'Tutup',
                    color: Colors.white,
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ScreenAppBar(
        title: 'Detail & Unduh Sertifikat',
        subtitle: 'SKPI Terverifikasi SIAKAD',
        showBack: showBackButton,
      ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                    children: [
                      const _VerifiedBanner(),
                      const SizedBox(height: 24),
                      const SectionHeader(
                        title: 'Pratinjau E-Sertifikat',
                        trailingText: 'Ukuran A4 Landscape',
                      ),
                      const SizedBox(height: 12),
                      Semantics(
                        button: true,
                        label: 'Buka pratinjau sertifikat layar penuh',
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => _openFullscreen(context),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x1F000000),
                                  blurRadius: 24,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const AspectRatio(
                              aspectRatio: _CertificateCanvas.width /
                                  _CertificateCanvas.height,
                              child: FittedBox(child: _CertificateCanvas()),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.zoom_out_map_rounded,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Ketuk untuk mode layar penuh & pembesaran',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const SectionHeader(
                        title: 'Integrasi Kredit Akademik (SKPI)',
                      ),
                      const SizedBox(height: 12),
                      const SurfaceCard(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: Column(
                          children: [
                            _CreditRow(
                              icon: Icons.stars_rounded,
                              label: 'Kredit Poin',
                              value: '+10 Poin',
                              note: 'Kategori: Pengembangan Keilmuan & '
                                  'Teknologi',
                            ),
                            Divider(height: 1, color: AppColors.surfaceHigh),
                            _CreditRow(
                              icon: Icons.sync_rounded,
                              label: 'Status Transkrip',
                              value: 'Tersinkronisasi',
                              note: 'Tercatat otomatis di Transkrip SKPI '
                                  'Kelulusan Wisuda',
                            ),
                            Divider(height: 1, color: AppColors.surfaceHigh),
                            _CreditRow(
                              icon: Icons.schedule_rounded,
                              label: 'Waktu Penerbitan Resmi',
                              value: '15 Mei 2025 • Pukul 13:00 WIB',
                              badge: 'Permanen',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const SectionHeader(title: 'Opsi Unduh & Ekspor'),
                      const SizedBox(height: 12),
                      _DownloadTile(
                        icon: Icons.picture_as_pdf_rounded,
                        title: 'Unduh PDF Resolusi Tinggi (Cetak)',
                        subtitle: 'Format Cetak Standar Industri (~1.4 MB)',
                        primary: true,
                        onTap: () => showComingSoon(context, 'Unduh PDF'),
                      ),
                      const SizedBox(height: 10),
                      _DownloadTile(
                        icon: Icons.image_rounded,
                        title: 'Simpan Gambar PNG',
                        subtitle: 'Format Media Sosial / LinkedIn (1080p)',
                        onTap: () => showComingSoon(context, 'Simpan PNG'),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _SmallAction(
                              icon: Icons.work_outline_rounded,
                              label: 'Add to LinkedIn',
                              onTap: () =>
                                  showComingSoon(context, 'Add to LinkedIn'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _SmallAction(
                              icon: Icons.mail_outline_rounded,
                              label: 'Kirim ke Email',
                              onTap: () =>
                                  showComingSoon(context, 'Kirim ke Email'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const SectionHeader(title: 'Verifikasi Dokumen Resmi'),
                      const SizedBox(height: 12),
                      const _VerifyCard(),
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
// Banner verifikasi
// ---------------------------------------------------------------------------

class _VerifiedBanner extends StatelessWidget {
  const _VerifiedBanner();

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.successSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sertifikat Sah & Terverifikasi Digital',
                      style: TextStyle(
                        fontFamily: AppFonts.heading,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                        color: AppColors.navy,
                      ),
                    ),
                    SizedBox(height: 6),
                    PillBadge.success(text: 'Resmi SIAKAD'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Terdaftar di Pangkalan Data SKPI Universitas & Siakad '
            'Kemahasiswaan secara kriptografis.',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    'NO: $_certNumber',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                PillBadge(text: 'Hash 256-Bit', icon: Icons.lock_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Gambar sertifikat (kanvas tetap 560x396, diskalakan dengan FittedBox)
// ---------------------------------------------------------------------------

class _CertificateCanvas extends StatelessWidget {
  const _CertificateCanvas();

  static const double width = 560;
  static const double height = 396;

  static const Color _paper = Color(0xFFFFFDF8);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _paper,
        border: Border.all(color: AppColors.navy, width: 6),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.accent, width: 1.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: const Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(width: 490, child: _CertificateBody()),
          ),
        ),
      ),
    );
  }
}

class _CertificateBody extends StatelessWidget {
  const _CertificateBody();

  @override
  Widget build(BuildContext context) {
    final StudentProfile student = context.watch<AuthViewModel>().student;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'UNIVERSITAS TERPADU',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppFonts.heading,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            color: AppColors.navy,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Biro Kemahasiswaan & Himpunan Mahasiswa Informatika (HMIF)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Container(width: 80, height: 2, color: AppColors.accent),
        const SizedBox(height: 10),
        const Text(
          'SERTIFIKAT PENGHARGAAN',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppFonts.heading,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: AppColors.accentDark,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Diberikan secara terhormat kepada:',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          student.name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: AppFonts.heading,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.navy,
          ),
        ),
        Text(
          'NIM: ${student.nim} • ${student.program}',
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        const Text(
          'Atas partisipasinya aktif dalam kegiatan:',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        const Text(
          'Workshop UI/UX Design System 2025:\n'
          'Membangun Portofolio Standar Industri',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            height: 1.3,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Sebagai Peserta Aktif (Kehadiran 100% Presensi Terverifikasi)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _Signature(
                top: '15 Mei 2025',
                name: 'Dr. Ir. Hendra, M.T.',
                role: 'Dosen Pembina Ormawa',
              ),
            ),
            _Seal(),
            Expanded(
              child: _Signature(
                top: 'Ketua Panitia',
                name: 'Rian Kusuma',
                role: 'Ketua Pelaksana Workshop',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Signature extends StatelessWidget {
  const _Signature({required this.top, required this.name, required this.role});

  final String top;
  final String name;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          top,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          color: AppColors.textMuted,
        ),
        const SizedBox(height: 3),
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          role,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _Seal extends StatelessWidget {
  const _Seal();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.accentSoft,
        border: Border.all(color: AppColors.accent, width: 3),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, size: 20, color: AppColors.accentDark),
          Text(
            'SEAL SAH',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w800,
              color: AppColors.accentDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bagian lain
// ---------------------------------------------------------------------------

class _CreditRow extends StatelessWidget {
  const _CreditRow({
    required this.icon,
    required this.label,
    required this.value,
    this.note,
    this.badge,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? note;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (note != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    note!,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (badge != null) ...[
            const SizedBox(width: 8),
            PillBadge.success(text: badge!),
          ],
        ],
      ),
    );
  }
}

class _DownloadTile extends StatelessWidget {
  const _DownloadTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.primary = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final Color fg = primary ? Colors.white : AppColors.textPrimary;
    final Color sub = primary ? AppColors.periwinkle : AppColors.textMuted;

    return Material(
      color: primary ? AppColors.navy : Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: primary ? AppColors.navy : AppColors.surfaceHigh,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: primary
                      ? Colors.white.withAlpha(30)
                      : AppColors.surfaceLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: primary ? AppColors.accent : AppColors.navy,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: fg,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: sub),
                    ),
                  ],
                ),
              ),
              Icon(Icons.download_rounded, color: fg),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallAction extends StatelessWidget {
  const _SmallAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(46),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        foregroundColor: AppColors.navy,
        side: const BorderSide(color: AppColors.outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(fontFamily: AppFonts.body, fontSize: 12.5, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _VerifyCard extends StatelessWidget {
  const _VerifyCard();

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.outline),
                ),
                child: const QrCodeView(data: _verifyHost, size: 96),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pindai kode QR untuk memverifikasi keaslian dokumen di '
                      'laman resmi verifikasi ijazah/sertifikat universitas:',
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 8),
                    PillBadge.success(
                      text: 'Enkripsi SHA-256 Valid',
                      icon: Icons.verified_rounded,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              _verifyHost,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.navy,
              ),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: 'https://$_verifyHost'));
              showSnack(context, 'Tautan verifikasi disalin.');
            },
            icon: const Icon(Icons.link_rounded, size: 18),
            label: const Text('Salin Tautan'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(46),
              foregroundColor: AppColors.navy,
              side: const BorderSide(color: AppColors.outline),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(fontFamily: AppFonts.body, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}