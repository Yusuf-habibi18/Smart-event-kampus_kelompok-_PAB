import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/core/app_routes.dart';
import 'package:flutter_application_1/core/app_theme.dart';
import 'package:flutter_application_1/data/dummy_ormawa_data.dart';
import 'package:flutter_application_1/models/event_proposal.dart';
import 'package:flutter_application_1/models/ormawa_account.dart';
import 'package:flutter_application_1/screens/admin/admin_shell.dart';
import 'package:flutter_application_1/screens/admin/admin_widgets.dart';
import 'package:flutter_application_1/screens/admin/review_event_page.dart';
import 'package:flutter_application_1/screens/panitia/daftar_peserta_page.dart';
import 'package:flutter_application_1/screens/panitia/form_proposal_page.dart';
import 'package:flutter_application_1/screens/panitia/kelola_event_page.dart';
import 'package:flutter_application_1/screens/panitia/ormawa_shell.dart';
import 'package:flutter_application_1/screens/panitia/pengajuan_akun_page.dart';
import 'package:flutter_application_1/screens/panitia/scan_qr_page.dart';
import 'package:flutter_application_1/screens/panitia/status_pengajuan_akun_page.dart';
import 'package:flutter_application_1/viewmodels/auth_viewmodel.dart';
import 'package:flutter_application_1/viewmodels/presensi_viewmodel.dart';
import 'package:flutter_application_1/viewmodels/proposal_viewmodel.dart';
import 'package:flutter_application_1/viewmodels/ticket_viewmodel.dart';

Widget buildApp(
  Widget home, {
  ProposalViewModel? proposals,
  PresensiViewModel? presensi,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthViewModel>(create: (_) => AuthViewModel()),
      ChangeNotifierProvider<TicketViewModel>(create: (_) => TicketViewModel()),
      ChangeNotifierProvider<ProposalViewModel>(
        create: (_) => proposals ?? ProposalViewModel(),
      ),
      ChangeNotifierProvider<PresensiViewModel>(
        create: (_) => presensi ?? PresensiViewModel(),
      ),
    ],
    child: MaterialApp(
      theme: buildAppTheme(),
      home: home,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    ),
  );
}

void setScreenSize(WidgetTester tester, Size logicalSize) {
  tester.view.devicePixelRatio = 3;
  tester.view.physicalSize = logicalSize * 3;
  addTearDown(tester.view.reset);
}

void main() {
  group('ProposalViewModel', () {
    test('submitProposal masuk ke myProposals dan antrean Admin', () async {
      final ProposalViewModel vm = ProposalViewModel();
      final int before = vm.pendingProposals.length;

      final EventProposal p = await vm.submitProposal(
        title: 'Seminar Keamanan Siber',
        category: 'Akademik & Seminar',
        description: 'Seminar keamanan siber untuk mahasiswa umum.',
        dateLabel: 'Senin, 2 Juni 2025',
        timeLabel: '09.00 - 12.00 WIB',
        location: 'Aula Fakultas',
        format: 'Luring',
        quota: 80,
        budget: 5000000,
        skpiPoints: 10,
        advisor: 'Dr. Hendra',
        fileName: 'Proposal_Seminar_2025.pdf',
        internal: true,
      );

      expect(p.internal, isTrue);
      expect(p.audienceLabel, 'Internal ITPLN');

      expect(p.status, ProposalStatus.menungguReview);
      expect(p.ormawa, dummyMyOrmawa.shortName);
      expect(vm.myProposals.first.id, p.id);
      expect(vm.pendingProposals.length, before + 1);
    });

    test('reviewProposal & resubmit mengubah status', () {
      final ProposalViewModel vm = ProposalViewModel();
      final EventProposal hackathon = vm.proposalById(1)!;

      vm.reviewProposal(
        hackathon,
        ProposalStatus.perluRevisi,
        note: 'Lengkapi rincian RAB konsumsi',
      );
      expect(vm.proposalById(1)!.status, ProposalStatus.perluRevisi);
      expect(vm.proposalById(1)!.reviewNote, 'Lengkapi rincian RAB konsumsi');

      vm.resubmitProposal(vm.proposalById(1)!, fileName: 'v3.pdf');
      expect(vm.proposalById(1)!.status, ProposalStatus.menungguReview);
      expect(vm.proposalById(1)!.fileName, 'v3.pdf');

      vm.reviewProposal(vm.proposalById(1)!, ProposalStatus.disetujui);
      expect(vm.myActiveEvents.map((EventProposal p) => p.id), contains(1));
    });

    test('reviewAccount menerbitkan nomor SK', () {
      final ProposalViewModel vm = ProposalViewModel();
      final OrmawaAccount hmsi = vm.pendingAccounts.first;
      vm.reviewAccount(hmsi, AccountStatus.terverifikasi);

      final OrmawaAccount updated = vm.accountApplications
          .firstWhere((OrmawaAccount a) => a.id == hmsi.id);
      expect(updated.status, AccountStatus.terverifikasi);
      expect(updated.skNumber, isNotNull);
      expect(vm.pendingAccounts.any((OrmawaAccount a) => a.id == hmsi.id),
          isFalse);
    });

    test('formatRupiah memakai pemisah titik', () {
      expect(formatRupiah(12500000), 'Rp 12.500.000');
      expect(formatRupiah(500), 'Rp 500');
    });
  });

  group('PresensiViewModel', () {
    PresensiViewModel build() =>
        PresensiViewModel(clock: () => DateTime(2025, 5, 28, 13, 5));

    test('checkIn mencatat jam dan menolak NIM tidak terdaftar', () {
      final PresensiViewModel vm = build();
      final int present = vm.presentCount;

      expect(vm.checkIn('2210512008'), CheckInResult.berhasil);
      expect(vm.presentCount, present + 1);
      expect(vm.lastScanned!.checkInTime, '13.05');

      expect(vm.checkIn('2210512008'), CheckInResult.sudahHadir);
      expect(vm.checkIn('0000000000'), CheckInResult.tidakTerdaftar);
    });

    test('filter dan pencarian peserta', () {
      final PresensiViewModel vm = build();
      vm.selectFilter(AttendanceFilter.belum);
      expect(vm.filteredParticipants.every((p) => !p.isPresent), isTrue);

      vm.selectFilter(AttendanceFilter.semua);
      vm.search('budi');
      expect(vm.filteredParticipants.single.name, 'Budi Santoso');
    });

    test('simulateScan berhenti saat semua sudah hadir', () {
      final PresensiViewModel vm = build();
      while (vm.absentCount > 0) {
        expect(vm.simulateScan(), CheckInResult.berhasil);
      }
      expect(vm.simulateScan(), isNull);
      expect(vm.attendancePercent, 100);
    });
  });

  testWidgets('Login Ormawa membuka OrmawaShell, Admin membuka AdminShell',
      (tester) async {
    setScreenSize(tester, const Size(360, 800));
    await tester.pumpWidget(buildApp(const SizedBox()));
    final NavigatorState nav = tester.state(find.byType(Navigator));

    nav.pushNamed(AppRoutes.dashboardPanitia);
    await tester.pumpAndSettle();
    expect(find.byType(OrmawaShell), findsOneWidget);

    nav.pushNamed(AppRoutes.dashboardAdmin);
    await tester.pumpAndSettle();
    expect(find.byType(AdminShell), findsOneWidget);
  });

  testWidgets('Proposal dari Ormawa bisa disetujui Admin', (tester) async {
    setScreenSize(tester, const Size(400, 2600));
    final ProposalViewModel vm = ProposalViewModel();
    await tester.pumpWidget(buildApp(const SizedBox(), proposals: vm));
    final NavigatorState nav = tester.state(find.byType(Navigator));
    nav.pushNamed(AppRoutes.formProposal);
    await tester.pumpAndSettle();

    // Langkah 1: Info Event.
    final Finder fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Seminar Keamanan Siber 2025');
    await tester.enterText(
      fields.at(1),
      'Seminar keamanan siber untuk seluruh mahasiswa kampus.',
    );
    await tester.enterText(fields.at(2), 'Aula Fakultas Lt. 2');

    // Tanggal belum dipilih → tetap di langkah 1.
    await tester.tap(find.text('Lanjut ke Berkas & RAB'));
    await tester.pumpAndSettle();
    expect(find.text('Tanggal wajib dipilih'), findsOneWidget);

    await tester.tap(find.text('Pilih tanggal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lanjut ke Berkas & RAB'));
    await tester.pumpAndSettle();

    // Langkah 2: Berkas & RAB.
    await tester.tap(find.text('Ketuk untuk unggah proposal (PDF)'));
    await tester.pump();
    await tester.enterText(find.byType(TextFormField).first, '8000000');
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tester.tap(find.text('Lanjut ke Konfirmasi'));
    await tester.pumpAndSettle();

    // Langkah 3: Konfirmasi & kirim.
    expect(find.text('Rp 8.000.000'), findsOneWidget);
    await tester.tap(find.text('Kirim Proposal'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.byType(FormProposalPage), findsNothing);

    final EventProposal submitted = vm.myProposals.first;
    expect(submitted.title, 'Seminar Keamanan Siber 2025');
    expect(submitted.budget, 8000000);
    expect(vm.pendingProposals.map((p) => p.id), contains(submitted.id));

    // Admin menyetujui dari halaman review.
    nav.push(MaterialPageRoute<void>(
      builder: (_) => ReviewProposalPage(proposalId: submitted.id),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Setujui'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Setujui').last);
    await tester.pumpAndSettle();

    expect(vm.proposalById(submitted.id)!.status, ProposalStatus.disetujui);
  });

  testWidgets('Scan QR menandai peserta hadir di daftar peserta',
      (tester) async {
    setScreenSize(tester, const Size(360, 1600));
    final PresensiViewModel presensi = PresensiViewModel();
    final int before = presensi.presentCount;
    await tester.pumpWidget(buildApp(const ScanQrPage(), presensi: presensi));
    await tester.pump();

    await tester.tap(find.bySemanticsLabel(RegExp('Area pemindai QR')));
    await tester.pump();
    expect(find.text('Presensi Berhasil Tercatat'), findsOneWidget);
    expect(presensi.presentCount, before + 1);

    await tester.tap(find.text('Verifikasi & Lanjut Scan'));
    await tester.pump();
    expect(find.text('Presensi Berhasil Tercatat'), findsNothing);
  });

  testWidgets('Pengajuan akun baru masuk antrean Admin', (tester) async {
    setScreenSize(tester, const Size(400, 3200));
    final ProposalViewModel vm = ProposalViewModel();
    await tester.pumpWidget(buildApp(const SizedBox(), proposals: vm));
    final NavigatorState nav = tester.state(find.byType(Navigator));
    nav.pushNamed(AppRoutes.pengajuanAkun);
    await tester.pumpAndSettle();
    expect(find.byType(PengajuanAkunPage), findsOneWidget);

    final Finder fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Himpunan Mahasiswa Elektro');
    await tester.enterText(fields.at(1), 'hme');
    await tester.enterText(
      fields.at(2),
      'Wadah pengembangan keilmuan mahasiswa Teknik Elektro.',
    );
    await tester.enterText(fields.at(3), 'Raka Aditya');
    await tester.enterText(fields.at(4), '2210411055');
    await tester.enterText(fields.at(5), 'hme@kampus.ac.id');
    await tester.enterText(fields.at(6), '081234567890');
    await tester.enterText(fields.at(7), 'Ir. Sutrisno, M.T.');

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fakultas Teknik').last);
    await tester.pumpAndSettle();
    for (int i = 0; i < 2; i++) {
      await tester.tap(find.text('Ketuk untuk unggah berkas').first);
      await tester.pump();
    }
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();

    await tester.tap(find.text('Kirim Pengajuan Akun'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Pengajuan Terkirim'), findsOneWidget);

    expect(vm.pendingAccounts.first.shortName, 'HME');
    expect(vm.pendingAccounts.first.faculty, 'Fakultas Teknik');
  });

  testWidgets('Halaman Ormawa & Admin tidak overflow di layar 360dp',
      (tester) async {
    setScreenSize(tester, const Size(360, 3000));
    final ProposalViewModel vm = ProposalViewModel();
    final EventProposal approved = vm.myActiveEvents.first;

    final Map<String, Widget> pages = {
      'Ormawa shell': const OrmawaShell(),
      'Status pengajuan': const StatusPengajuanPage(),
      'Form proposal': const FormProposalPage(),
      'Edit event': KelolaEventPage(proposal: approved),
      'Daftar peserta': const DaftarPesertaPage(),
      'Pengajuan akun': const PengajuanAkunPage(),
      'Admin shell': const AdminShell(),
      'Daftar pengajuan': const ReviewEventPage(),
      'Review proposal': const ReviewProposalPage(proposalId: 4),
    };

    for (final MapEntry<String, Widget> e in pages.entries) {
      await tester.pumpWidget(buildApp(e.value, proposals: vm));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: e.key);
    }

    // Segmen Akun di Status Pengajuan dan tab di shell.
    await tester.pumpWidget(buildApp(const StatusPengajuanPage(), proposals: vm));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Akun Ormawa'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'Segmen akun');

    await tester.pumpWidget(buildApp(const AdminShell(), proposals: vm));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Akun Ormawa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Akun Ormawa'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'Antrean akun');
    await tester.tap(find.text('Pengajuan').last);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Proposal (').first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'Tab proposal');

    // Pemindai (animasi berulang → pump, bukan pumpAndSettle).
    await tester.pumpWidget(buildApp(const ScanQrPage(), proposals: vm));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull, reason: 'Scan QR');
  });
}
