import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../viewmodels/event_viewmodel.dart';
import 'beranda_event_page.dart';
import 'eksplorasi_event_page.dart';
import 'event_saya_page.dart';
import 'profil_mahasiswa_page.dart';
import 'sertifikat_page.dart';

/// Shell utama modul Mahasiswa.
///
/// Membungkus lima tab (Beranda, Eksplorasi, Event Saya, Sertifikat, Profil)
/// dengan [NavigationBar]. Beranda dan Eksplorasi masing-masing memakai
/// [EventViewModel] sendiri agar filter keduanya tidak saling memengaruhi.
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
      body: IndexedStack(
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _selectTab,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.periwinkle,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppColors.navy),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded, color: AppColors.navy),
            label: 'Eksplorasi',
          ),
          NavigationDestination(
            icon: Icon(Icons.confirmation_number_outlined),
            selectedIcon: Icon(Icons.confirmation_number_rounded, color: AppColors.navy),
            label: 'Event Saya',
          ),
          NavigationDestination(
            icon: Icon(Icons.workspace_premium_outlined),
            selectedIcon: Icon(Icons.workspace_premium_rounded, color: AppColors.navy),
            label: 'Sertifikat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppColors.navy),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
