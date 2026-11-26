import 'package:flutter/material.dart';

import '../umum/ui_kit.dart';
import '../umum/pengaturan_page.dart';
import 'daftar_peserta_page.dart';
import 'dashboard_panitia_page.dart';
import 'scan_qr_page.dart';
import 'status_pengajuan_akun_page.dart';

/// Shell utama modul Ormawa (Panitia).
///
/// Tab: Dashboard, Proposal (Status Pengajuan), Scan QR, Peserta, Akun.
/// Tombol Scan QR tidak berpindah tab, melainkan membuka halaman pemindai
/// layar penuh.
class OrmawaShell extends StatefulWidget {
  const OrmawaShell({super.key});

  @override
  State<OrmawaShell> createState() => _OrmawaShellState();
}

class _OrmawaShellState extends State<OrmawaShell> {
  static const int _scanIndex = 2;

  int _currentIndex = 0;

  void _selectTab(int index) {
    if (index == _scanIndex) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => const ScanQrPage()),
      );
      return;
    }
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabFade(
        index: _currentIndex,
        child: IndexedStack(
          index: _currentIndex,
          children: [
            DashboardPanitiaPage(onOpenStatus: () => _selectTab(1)),
            const StatusPengajuanPage(),
            const SizedBox.shrink(),
            const DaftarPesertaPage(asTab: true),
            const PengaturanUmumSmartCampusEvent(),
          ],
        ),
      ),
      bottomNavigationBar: FloatingNavBar(
        selectedIndex: _currentIndex,
        onSelected: _selectTab,
        items: const [
          FloatingNavItem(
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard_rounded,
            label: 'Beranda',
          ),
          FloatingNavItem(
            icon: Icons.description_outlined,
            selectedIcon: Icons.description_rounded,
            label: 'Proposal',
          ),
          FloatingNavItem(
            icon: Icons.qr_code_scanner_rounded,
            selectedIcon: Icons.qr_code_scanner_rounded,
            label: 'Scan QR',
          ),
          FloatingNavItem(
            icon: Icons.groups_outlined,
            selectedIcon: Icons.groups_rounded,
            label: 'Peserta',
          ),
          FloatingNavItem(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings_rounded,
            label: 'Akun',
          ),
        ],
      ),
    );
  }
}
