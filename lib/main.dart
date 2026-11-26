import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_routes.dart';
import 'core/app_theme.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/presensi_viewmodel.dart';
import 'viewmodels/proposal_viewmodel.dart';
import 'viewmodels/ticket_viewmodel.dart';

void main() {
  runApp(const SmartCampusEventApp());
}

class SmartCampusEventApp extends StatelessWidget {
  const SmartCampusEventApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ViewModel yang dipakai bersama oleh banyak halaman disediakan di sini
    // agar setiap View dapat membacanya lewat context.watch / context.read.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>(create: (_) => AuthViewModel()),
        ChangeNotifierProvider<TicketViewModel>(
          create: (_) => TicketViewModel(),
        ),
        // Modul Ormawa & Admin: proposal dibagikan agar keputusan BKA
        // langsung terlihat di sisi Ormawa, dan presensi dibagikan antara
        // halaman Kelola Peserta dan Scan QR.
        ChangeNotifierProvider<ProposalViewModel>(
          create: (_) => ProposalViewModel(),
        ),
        ChangeNotifierProvider<PresensiViewModel>(
          create: (_) => PresensiViewModel(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Campus Event',
        theme: buildAppTheme(),
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
