import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../umum/ui_kit.dart';
import '../../viewmodels/proposal_viewmodel.dart';
import '../umum/pengaturan_page.dart';
import 'dashboard_admin_page.dart';
import 'review_event_page.dart';

/// Shell utama modul Admin (BKA): Dashboard, Pengajuan, Akun.
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 0;

  void _selectTab(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final ProposalViewModel vm = context.watch<ProposalViewModel>();
    final int pending = vm.pendingAccounts.length + vm.pendingProposals.length;

    return Scaffold(
      body: TabFade(
        index: _currentIndex,
        child: IndexedStack(
          index: _currentIndex,
          children: [
            DashboardAdminPage(onOpenQueue: () => _selectTab(1)),
            const ReviewEventPage(),
            const PengaturanUmumSmartCampusEvent(),
          ],
        ),
      ),
      bottomNavigationBar: FloatingNavBar(
        selectedIndex: _currentIndex,
        onSelected: _selectTab,
        items: [
          const FloatingNavItem(
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard_rounded,
            label: 'Beranda',
          ),
          FloatingNavItem(
            icon: Icons.inbox_outlined,
            selectedIcon: Icons.inbox_rounded,
            label: 'Pengajuan',
            badge: pending,
          ),
          const FloatingNavItem(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings_rounded,
            label: 'Akun',
          ),
        ],
      ),
    );
  }
}
