import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/data/dummy_data.dart';
import 'package:flutter_application_1/models/campus_event.dart';
import 'package:flutter_application_1/models/event_ticket.dart';
import 'package:flutter_application_1/models/user_role.dart';
import 'package:flutter_application_1/viewmodels/auth_viewmodel.dart';
import 'package:flutter_application_1/viewmodels/event_viewmodel.dart';
import 'package:flutter_application_1/viewmodels/ticket_viewmodel.dart';

void main() {
  group('EventViewModel', () {
    test('pencarian dan filter kategori/ormawa mengubah hasil', () {
      final EventViewModel vm = EventViewModel();
      int notified = 0;
      vm.addListener(() => notified++);

      expect(vm.totalResults, dummyEvents.length);

      vm.search('hackathon');
      expect(vm.filteredEvents.map((CampusEvent e) => e.id), [5]);

      vm.clearSearch();
      vm.selectCategory('Kompetisi');
      expect(
        vm.filteredEvents.every((CampusEvent e) => e.category == 'Kompetisi'),
        isTrue,
      );

      vm.selectOrmawa('Olahraga');
      expect(vm.filteredEvents.map((CampusEvent e) => e.id), [7]);

      expect(notified, 4);
    });

    test('featuredIndex kembali ke 0 saat filter berubah', () {
      final EventViewModel vm = EventViewModel();
      vm.setFeaturedIndex(2);
      vm.search('a');
      expect(vm.featuredIndex, 0);
    });
  });

  group('TicketViewModel', () {
    test('registerEvent menambah tiket berisi data formulir', () async {
      final TicketViewModel vm = TicketViewModel();
      final CampusEvent event = dummyEvents.first;
      final int before = vm.totalActive;

      final EventTicket ticket = await vm.registerEvent(
        event,
        phone: ' 081234567890 ',
        participation: 'Luring',
        track: 'Track A',
      );

      expect(vm.totalActive, before + 1);
      expect(vm.isRegistered(event), isTrue);
      expect(ticket.phone, '081234567890');
      expect(ticket.participation, 'Luring');
      expect(vm.isSubmitting, isFalse);
    });

    test('cancelTicket memindahkan tiket ke daftar dibatalkan', () async {
      final TicketViewModel vm = TicketViewModel();
      final CampusEvent event = dummyEvents.first;
      final EventTicket ticket = await vm.registerEvent(
        event,
        phone: '081234567890',
        participation: 'Luring',
        track: 'Track A',
      );

      vm.cancelTicket(ticket);

      expect(vm.isRegistered(event), isFalse);
      expect(vm.cancelledTickets, contains(ticket));
    });

    test('toggleSaved menyimpan & membatalkan event favorit', () {
      final TicketViewModel vm = TicketViewModel();
      expect(vm.isSaved(1), isFalse);

      expect(vm.toggleSaved(1), isTrue);
      expect(vm.isSaved(1), isTrue);
      expect(vm.totalSaved, 1);

      expect(vm.toggleSaved(1), isFalse);
      expect(vm.isSaved(1), isFalse);
    });

    test('submitReview menyimpan rating dan komentar', () {
      final TicketViewModel vm = TicketViewModel();
      final event = vm.completedEvents.first;

      vm.submitReview(event, rating: 4, comment: '  Materinya bagus  ');

      expect(vm.reviewFor(event)?.rating, 4);
      expect(vm.reviewFor(event)?.comment, 'Materinya bagus');
    });
  });

  group('AuthViewModel', () {
    test('email kampus → mahasiswa ITPLN, NIM diambil dari email', () async {
      final AuthViewModel vm = AuthViewModel();

      await vm.login(id: '2211223344@itpln.ac.id', password: 'rahasia');

      expect(vm.isLoggedIn, isTrue);
      expect(vm.isMahasiswa, isTrue);
      expect(vm.student.nim, '2211223344');
      expect(vm.student.identityLine, startsWith('NIM 2211223344'));
    });

    test('email lain → peserta umum tanpa NIM', () async {
      final AuthViewModel vm = AuthViewModel();
      vm.choosePeserta(PesertaType.umum);

      await vm.login(id: 'budi@gmail.com', password: 'rahasia');

      expect(vm.isMahasiswa, isFalse);
      expect(vm.student.type, PesertaType.umum);
      expect(vm.student.identityLine, 'Peserta Umum');
    });

    test('daftar akun umum menyimpan nama & instansi untuk login', () async {
      final AuthViewModel vm = AuthViewModel();

      await vm.register(
        name: 'Budi Santoso',
        email: 'budi@gmail.com',
        password: 'rahasia',
        institution: 'Universitas Indonesia',
      );
      expect(vm.pesertaChoice, PesertaType.umum);

      await vm.login(id: 'budi@gmail.com', password: 'rahasia');
      expect(vm.student.name, 'Budi Santoso');
      expect(vm.student.identityLine, 'Peserta Umum • Universitas Indonesia');
    });

    test('validasi ID mengikuti peran & jenis peserta', () {
      final AuthViewModel vm = AuthViewModel();
      expect(vm.validateId('abc'), isNotNull);
      expect(vm.validateId('2211223344@itpln.ac.id'), isNull);
      // Pilihan "mahasiswa ITPLN" wajib memakai email kampus.
      expect(vm.validateId('budi@gmail.com'), isNotNull);

      vm.choosePeserta(PesertaType.umum);
      expect(vm.validateId('budi@gmail.com'), isNull);

      vm.selectRole(UserRole.ormawa);
      expect(vm.validateId('hima@kampus.ac.id'), isNull);

      vm.selectRole(UserRole.admin);
      expect(vm.validateId('abc'), isNotNull);
      expect(vm.validateId('198503122010011002'), isNull);
    });
  });

  group('Visibilitas event', () {
    test('peserta umum tidak melihat event Internal ITPLN', () {
      final EventViewModel vm = EventViewModel();
      final int internal =
          dummyEvents.where((CampusEvent e) => e.internal).length;
      expect(internal, greaterThan(0));

      vm.setShowInternal(false);
      expect(vm.totalResults, dummyEvents.length - internal);
      expect(vm.filteredEvents.any((CampusEvent e) => e.internal), isFalse);

      vm.setShowInternal(true);
      expect(vm.totalResults, dummyEvents.length);
    });

    test('jenis akun ditentukan dari domain email', () {
      expect(PesertaType.fromEmail('a@itpln.ac.id'), PesertaType.mahasiswaItpln);
      expect(PesertaType.fromEmail('A@ITPLN.AC.ID'), PesertaType.mahasiswaItpln);
      expect(PesertaType.fromEmail('a@gmail.com'), PesertaType.umum);
      expect(PesertaType.fromEmail('a@itpln.ac.id.palsu.com'), PesertaType.umum);
    });
  });
}
