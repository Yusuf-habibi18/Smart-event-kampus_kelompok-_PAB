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

    test('submitReview menyimpan rating dan komentar', () {
      final TicketViewModel vm = TicketViewModel();
      final event = vm.completedEvents.first;

      vm.submitReview(event, rating: 4, comment: '  Materinya bagus  ');

      expect(vm.reviewFor(event)?.rating, 4);
      expect(vm.reviewFor(event)?.comment, 'Materinya bagus');
    });
  });

  group('AuthViewModel', () {
    test('login menyimpan NIM yang diketik ke profil mahasiswa', () async {
      final AuthViewModel vm = AuthViewModel();

      await vm.login(id: '2211223344', password: 'rahasia');

      expect(vm.isLoggedIn, isTrue);
      expect(vm.student.nim, '2211223344');
    });

    test('validasi ID mengikuti peran yang dipilih', () {
      final AuthViewModel vm = AuthViewModel();
      expect(vm.validateId('abc'), isNotNull);
      expect(vm.validateId('2211223344'), isNull);

      vm.selectRole(UserRole.ormawa);
      expect(vm.validateId('hima@kampus.ac.id'), isNull);
    });
  });
}
