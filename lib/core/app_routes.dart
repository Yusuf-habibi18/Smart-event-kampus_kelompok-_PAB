import 'package:flutter/material.dart';

import '../models/user_role.dart';
import '../screens/auth/login_page.dart';
import '../screens/mahasiswa/mahasiswa_shell.dart';
import '../screens/mahasiswa/sertifikat_page.dart';
import '../screens/umum/pengaturan_page.dart';
import '../screens/umum/splash_screen.dart';
import 'app_theme.dart';

export '../models/user_role.dart';

/// Route beranda untuk tiap peran.
extension UserRoleRoute on UserRole {
  String get homeRoute {
    switch (this) {
      case UserRole.mahasiswa:
        return AppRoutes.berandaMahasiswa;
      case UserRole.ormawa:
        return AppRoutes.dashboardPanitia;
      case UserRole.admin:
        return AppRoutes.dashboardAdmin;
    }
  }
}

/// Daftar route bernama (named route).
///
/// Halaman yang membutuhkan data (Detail Event & E-Tiket) dibuka langsung
/// dengan `Navigator.push()` + `MaterialPageRoute` dan menerima datanya
/// lewat constructor. Lihat `openEventDetail()` di mahasiswa_widgets.dart.
class AppRoutes {
  AppRoutes._();

  // Umum & auth
  static const String splash = '/';
  static const String login = '/login';
  static const String pengaturan = '/pengaturan';

  // Mahasiswa / Visitor
  static const String berandaMahasiswa = '/mahasiswa/beranda';
  static const String sertifikat = '/mahasiswa/sertifikat';

  // Panitia (Ormawa)
  static const String dashboardPanitia = '/panitia/dashboard';
  static const String pengajuanAkun = '/panitia/pengajuan-akun';

  // Admin
  static const String dashboardAdmin = '/admin/dashboard';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Widget page;

    switch (settings.name) {
      case splash:
        page = const SplashScreenSmartCampusEventUmum();
        break;
      case login:
        page = const MasukSmartCampusEvent();
        break;
      case pengaturan:
        page = const PengaturanUmumSmartCampusEvent();
        break;
      case berandaMahasiswa:
        page = const MahasiswaShell();
        break;
      case sertifikat:
        page = const SertifikatPage(showBackButton: true);
        break;

      // TODO: ganti PlaceholderPage dengan halaman asli modul Panitia & Admin.
      case dashboardPanitia:
        page = const PlaceholderPage(title: 'Dashboard Panitia Event');
        break;
      case pengajuanAkun:
        page = const PlaceholderPage(title: 'Pengajuan Akun Penyelenggara');
        break;
      case dashboardAdmin:
        page = const PlaceholderPage(title: 'Dashboard Admin');
        break;

      default:
        page = PlaceholderPage(title: settings.name ?? 'Halaman');
    }

    return MaterialPageRoute<void>(
      builder: (BuildContext context) => page,
      settings: settings,
    );
  }
}

/// Halaman sementara untuk route yang file halamannya belum dipasang.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.construction_rounded,
                size: 48,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppFonts.heading,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Modul ini masih dalam pengembangan (target sprint '
                'berikutnya).',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.tonal(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.pengaturan),
                child: const Text('Buka Pengaturan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
