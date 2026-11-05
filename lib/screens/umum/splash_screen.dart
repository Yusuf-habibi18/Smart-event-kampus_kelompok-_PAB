import 'package:flutter/material.dart';

import '../../core/app_routes.dart';
import '../../core/app_theme.dart';

Color _white(int alpha) => Colors.white.withAlpha(alpha);

class SplashScreenSmartCampusEventUmum extends StatefulWidget {
  const SplashScreenSmartCampusEventUmum({super.key});

  @override
  State<SplashScreenSmartCampusEventUmum> createState() =>
      _SplashScreenSmartCampusEventUmumState();
}

class _SplashScreenSmartCampusEventUmumState
    extends State<SplashScreenSmartCampusEventUmum>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    // Hormati pengaturan "kurangi animasi" milik perangkat.
    if (MediaQuery.of(context).disableAnimations) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _mulai() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.navyLight, AppColors.navy, AppColors.navyDark],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.hardEdge,
          children: [
            const Positioned(
              top: -96,
              right: -90,
              child: _Blob(size: 320, color: Color(0x4C4059AA)),
            ),
            const Positioned(
              top: 260,
              left: -128,
              child: _Blob(size: 288, color: Color(0x33FEA619)),
            ),
            const Positioned(
              bottom: -120,
              right: -60,
              child: _Blob(size: 256, color: Color(0x6600389A)),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return SingleChildScrollView(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 480,
                          minHeight: constraints.maxHeight,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const _TopBar(),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 32),
                                child: _Hero(),
                              ),
                              _LoadingFooter(
                                controller: _controller,
                                progress: _progress,
                                onStart: _mulai,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bagian atas: status server & nama universitas
// ---------------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        _GlassPill(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x66FEA619),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Sistem Terhubung • Server BKA Aktif',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _white(230),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.25,
                  ),
                ),
              ),
            ],
          ),
        ),
        const _GlassPill(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.account_balance_rounded,
                size: 12,
                color: AppColors.periwinkle,
              ),
              SizedBox(width: 6),
              Text(
                'Universitas Terpadu',
                style: TextStyle(
                  color: AppColors.periwinkle,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _white(26),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _white(38)),
      ),
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// Bagian tengah: logo, judul, deskripsi, fitur unggulan
// ---------------------------------------------------------------------------

class _Hero extends StatelessWidget {
  const _Hero();

  static const List<_Feature> _features = [
    _Feature(
      Icons.qr_code_scanner_rounded,
      'Fast-Pass QR',
      'Check-in Aula & Lab',
    ),
    _Feature(
      Icons.workspace_premium_rounded,
      'E-Sertifikat',
      'Terakreditasi SKPI',
    ),
    _Feature(
      Icons.verified_user_rounded,
      'Validasi BKA',
      'Izin Legal Ormawa',
    ),
    _Feature(
      Icons.sync_rounded,
      'SIAKAD Sync',
      'Otomatisasi Poin',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, AppColors.periwinkle],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 30,
                offset: Offset(0, 16),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          // Asset Image: logo aplikasi dari assets/images/logo.png.
          child: Image.asset(AppImages.logo, semanticLabel: 'Logo CampusEvent'),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'CampusEvent',
              style: TextStyle(
                color: Colors.white,
                fontFamily: AppFonts.heading,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
                height: 1.2,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'SMART CAMPUS EVENT MANAGEMENT',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.periwinkle,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Portal Terpadu Eksplorasi, Partisipasi & '
          'Sertifikasi Kegiatan Mahasiswa',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _white(230),
            fontSize: 15,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        for (int i = 0; i < _features.length; i += 2)
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : 12),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _FeatureTile(feature: _features[i])),
                  const SizedBox(width: 12),
                  Expanded(child: _FeatureTile(feature: _features[i + 1])),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Feature {
  const _Feature(this.icon, this.title, this.subtitle);

  final IconData icon;
  final String title;
  final String subtitle;
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.feature});

  final _Feature feature;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _white(26),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _white(38)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0x33FEA619),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(feature.icon, size: 20, color: AppColors.accent),
          ),
          const SizedBox(height: 10),
          Text(
            feature.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            feature.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.periwinkle,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bagian bawah: progres, tombol mulai, info versi
// ---------------------------------------------------------------------------

class _LoadingFooter extends StatelessWidget {
  const _LoadingFooter({
    required this.controller,
    required this.progress,
    required this.onStart,
  });

  final AnimationController controller;
  final Animation<double> progress;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedBuilder(
          animation: controller,
          builder: (BuildContext context, Widget? child) {
            final bool done = controller.value >= 1.0;
            final int percent = (progress.value * 100).round();

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        done
                            ? 'Sinkronisasi selesai. Siap dijelajahi.'
                            : 'Memuat profil SSO & sinkronisasi agenda '
                                'kampus...',
                        style: const TextStyle(
                          color: AppColors.periwinkle,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress.value,
                    minHeight: 6,
                    backgroundColor: _white(38),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.accent),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: done ? onStart : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.accentDark,
                    disabledBackgroundColor: _white(30),
                    disabledForegroundColor: _white(120),
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: AppFonts.heading,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  child: const Text('Mulai Eksplorasi'),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        Text(
          'V3.2.0 • ENTERPRISE ACADEMIC EDITION',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _white(140),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Biro Kemahasiswaan & Alumni (BKA) Universitas • '
          'Dilindungi Enkripsi SSL 256-bit',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _white(110),
            fontSize: 10,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}