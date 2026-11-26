import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/core/app_routes.dart';
import 'package:flutter_application_1/core/app_theme.dart';
import 'package:flutter_application_1/data/dummy_data.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/screens/auth/login_page.dart';
import 'package:flutter_application_1/screens/mahasiswa/detail_event_page.dart';
import 'package:flutter_application_1/screens/mahasiswa/mahasiswa_shell.dart';
import 'package:flutter_application_1/screens/mahasiswa/mahasiswa_widgets.dart';
import 'package:flutter_application_1/screens/mahasiswa/tiket_event_page.dart';
import 'package:flutter_application_1/viewmodels/auth_viewmodel.dart';
import 'package:flutter_application_1/viewmodels/ticket_viewmodel.dart';

/// Aplikasi lengkap dengan ViewModel, dimulai dari halaman [home].
Widget buildTestApp(Widget home) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthViewModel>(create: (_) => AuthViewModel()),
      ChangeNotifierProvider<TicketViewModel>(create: (_) => TicketViewModel()),
    ],
    child: MaterialApp(
      theme: buildAppTheme(),
      home: home,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    ),
  );
}

/// Mengatur ukuran layar logis (dp) selama satu test.
void setScreenSize(WidgetTester tester, Size logicalSize) {
  tester.view.devicePixelRatio = 3;
  tester.view.physicalSize = logicalSize * 3;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('Splash screen menampilkan nama aplikasi', (tester) async {
    await tester.pumpWidget(const SmartCampusEventApp());
    await tester.pump();

    expect(find.text('CampusEvent'), findsOneWidget);
    expect(find.text('Mulai Eksplorasi'), findsOneWidget);
    expect(find.byType(Image), findsWidgets);
  });

  Future<void> login(WidgetTester tester, String email) async {
    await tester.enterText(find.byType(TextFormField).at(0), email);
    await tester.enterText(find.byType(TextFormField).at(1), 'rahasia123');
    await tester.ensureVisible(find.text('Masuk ke Portal'));
    await tester.tap(find.text('Masuk ke Portal'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  }

  testWidgets('Email kampus dari form login → NIM tampil di Beranda',
      (tester) async {
    setScreenSize(tester, const Size(360, 800));
    await tester.pumpWidget(buildTestApp(const MasukSmartCampusEvent()));

    await login(tester, '2299887766@itpln.ac.id');

    expect(find.byType(MahasiswaShell), findsOneWidget);
    expect(find.textContaining('NIM 2299887766'), findsOneWidget);
  });

  testWidgets('Pilihan mahasiswa ITPLN menolak email non-kampus',
      (tester) async {
    setScreenSize(tester, const Size(360, 800));
    await tester.pumpWidget(buildTestApp(const MasukSmartCampusEvent()));

    await login(tester, 'budi@gmail.com');

    expect(find.byType(MahasiswaShell), findsNothing);
    expect(find.textContaining('Ini bukan email kampus'), findsOneWidget);
  });

  testWidgets('Peserta umum masuk: event Internal ITPLN & SKPI disembunyikan',
      (tester) async {
    setScreenSize(tester, const Size(360, 2400));
    await tester.pumpWidget(buildTestApp(const MasukSmartCampusEvent()));

    await tester.tap(find.text('Saya peserta umum'));
    await tester.pump();
    await login(tester, 'budi@gmail.com');

    expect(find.byType(MahasiswaShell), findsOneWidget);
    expect(find.text('Peserta Umum'), findsOneWidget);
    expect(find.text('Internal ITPLN'), findsNothing);
    expect(find.textContaining('Poin SKPI'), findsNothing);
  });

  testWidgets('Daftar akun: email kampus terdeteksi sebagai mahasiswa',
      (tester) async {
    setScreenSize(tester, const Size(360, 1600));
    await tester.pumpWidget(buildTestApp(const SizedBox()));
    final NavigatorState nav = tester.state(find.byType(Navigator));
    nav.pushNamed(AppRoutes.daftarAkun);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(1), 'a@gmail.com');
    await tester.pump();
    expect(find.text('Akun Peserta Umum'), findsOneWidget);
    expect(find.text('Asal instansi (opsional)'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(1), 'a@itpln.ac.id');
    await tester.pump();
    expect(find.text('Akun Mahasiswa ITPLN'), findsOneWidget);
    expect(find.text('Asal instansi (opsional)'), findsNothing);
  });

  testWidgets(
      'Daftar event: input WhatsApp terkirim ke E-Tiket & muncul di Event Saya',
      (tester) async {
    setScreenSize(tester, const Size(360, 2400));
    await tester.pumpWidget(buildTestApp(const MahasiswaShell()));
    await tester.pumpAndSettle();

    // Beranda → Detail Event (Navigator.push).
    await tester.tap(find.byType(EventCard).first);
    await tester.pumpAndSettle();
    expect(find.byType(DetailEventPage), findsOneWidget);

    // Langkah 2: formulir pendaftaran.
    await tester.tap(find.text('Daftar Sekarang'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '081234567890');
    await tester.tap(find.text('Daring (Zoom)'));
    await tester.tap(find.ancestor(
      of: find.text('Ketuk untuk memilih track'),
      matching: find.byType(InkWell),
    ).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Track B: Adaptive Layout & Responsive Grid'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ketuk untuk unggah file berkas'));
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();

    await tester.tap(find.text('Konfirmasi'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // Output di halaman tujuan.
    expect(find.byType(TiketEventPage), findsOneWidget);
    expect(find.text('081234567890'), findsOneWidget);
    expect(find.text('Daring (Zoom)'), findsOneWidget);

    // Kembali ke shell, tiket baru ada di tab Event Saya.
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Event Saya').last);
    await tester.pumpAndSettle();

    final int expected = dummyActiveTickets.length + 1;
    expect(find.text('Mendatang ($expected)'), findsOneWidget);
    expect(find.byType(TabBar), findsOneWidget);
  });

  testWidgets('Halaman utama tidak overflow di layar 360dp', (tester) async {
    setScreenSize(tester, const Size(360, 3000));
    await tester.pumpWidget(buildTestApp(const MahasiswaShell()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    for (final String tab in ['Cari Event', 'Event Saya', 'Sertifikat', 'Profil']) {
      await tester.tap(find.text(tab).last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Tab $tab');
    }

    // Tab di dalam Event Saya.
    await tester.tap(find.text('Event Saya').last);
    await tester.pumpAndSettle();
    for (final String label in ['Selesai', 'Dibatalkan']) {
      await tester.tap(find.textContaining(label).first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'TabBar $label');
    }

    // Detail Event (detail + formulir) dan E-Tiket.
    final NavigatorState navigator = tester.state(find.byType(Navigator));
    navigator.push(MaterialPageRoute<void>(
      builder: (_) => DetailEventPage(event: dummyEvents[1]),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'Detail Event');

    await tester.tap(find.text('Daftar Sekarang'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'Formulir pendaftaran');

    navigator.push(MaterialPageRoute<void>(
      builder: (_) => TiketEventPage(ticket: dummyActiveTickets.first),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'E-Tiket');
  });

  testWidgets('Animasi muncul dilewati saat "kurangi animasi" aktif',
      (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Reveal(index: 3, child: Text('Halo')),
        ),
      ),
    );
    await tester.pump();

    final Opacity opacity = tester.widget<Opacity>(
      find.ancestor(of: find.text('Halo'), matching: find.byType(Opacity)),
    );
    expect(opacity.opacity, 1);
  });
}
