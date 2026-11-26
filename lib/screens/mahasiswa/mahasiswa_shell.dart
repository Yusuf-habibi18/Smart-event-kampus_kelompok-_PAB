import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/event_viewmodel.dart';
import 'beranda_event_page.dart';
import 'eksplorasi_event_page.dart';
import 'event_saya_page.dart';
import 'mahasiswa_widgets.dart';
import 'profil_mahasiswa_page.dart';
import 'sertifikat_page.dart';

/// Shell utama modul Peserta (mahasiswa ITPLN & umum).
///
/// Membungkus lima tab (Beranda, Cari Event, Event Saya, Sertifikat, Profil)
/// dengan [FloatingNavBar]. Beranda dan Cari Event masing-masing memakai
/// [EventViewModel] sendiri agar filter keduanya tidak saling memengaruhi.
/// Event Internal ITPLN disembunyikan untuk peserta umum.
class MahasiswaShell extends StatefulWidget {
  const MahasiswaShell({super.key});

  @override
  State<MahasiswaShell> createState() => _MahasiswaShellState();
}

class _MahasiswaShellState extends State<MahasiswaShell> {
  final EventViewModel _berandaVm = EventViewModel();
  final EventViewModel _exploreVm = EventViewModel();
  int _currentIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Peserta umum tidak melihat event Internal ITPLN.
    final bool mahasiswa = context.watch<AuthViewModel>().isMahasiswa;
    _berandaVm.setShowInternal(mahasiswa);
    _exploreVm.setShowInternal(mahasiswa);
  }

  @override
  void dispose() {
    _berandaVm.dispose();
    _exploreVm.dispose();
    super.dispose();
  }

  void _selectTab(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  /// Dipanggil dari Beranda: buka tab Eksplorasi dengan filter ormawa.
  void _openExplore({String? ormawa}) {
    _exploreVm.selectOrmawa(ormawa);
    setState(() => _currentIndex = 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabFade(
        index: _currentIndex,
        child: IndexedStack(
          index: _currentIndex,
          children: [
            ChangeNotifierProvider<EventViewModel>.value(
              value: _berandaVm,
              child: BerandaEventPage(
                onSelectTab: _selectTab,
                onOpenExplore: _openExplore,
              ),
            ),
            ChangeNotifierProvider<EventViewModel>.value(
              value: _exploreVm,
              child: const EksplorasiEventPage(),
            ),
            const EventSayaPage(),
            const SertifikatPage(),
            ProfilMahasiswaPage(onSelectTab: _selectTab),
          ],
        ),
      ),
      bottomNavigationBar: FloatingNavBar(
        selectedIndex: _currentIndex,
        onSelected: _selectTab,
        items: const [
          FloatingNavItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
            label: 'Beranda',
          ),
          FloatingNavItem(
            icon: Icons.explore_outlined,
            selectedIcon: Icons.explore_rounded,
            label: 'Cari Event',
          ),
          FloatingNavItem(
            icon: Icons.confirmation_number_outlined,
            selectedIcon: Icons.confirmation_number_rounded,
            label: 'Event Saya',
          ),
          FloatingNavItem(
            icon: Icons.workspace_premium_outlined,
            selectedIcon: Icons.workspace_premium_rounded,
            label: 'Sertifikat',
          ),
          FloatingNavItem(
            icon: Icons.person_outline_rounded,
            selectedIcon: Icons.person_rounded,
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
