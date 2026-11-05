import 'package:flutter/foundation.dart';

import '../data/dummy_data.dart';
import '../models/campus_event.dart';
import '../models/completed_event.dart';
import '../models/event_ticket.dart';

/// ViewModel: pendaftaran event, tiket milik mahasiswa, dan ulasan.
///
/// Dibagikan ke seluruh aplikasi sehingga tiket yang dibuat di
/// DetailEventPage langsung muncul di EventSayaPage.
class TicketViewModel extends ChangeNotifier {
  TicketViewModel()
      : _active = List<EventTicket>.of(dummyActiveTickets),
        _completed = List<CompletedEvent>.of(dummyCompletedEvents);

  final List<EventTicket> _active;
  final List<EventTicket> _cancelled = [];
  final List<CompletedEvent> _completed;
  final Map<String, EventReview> _reviews = {};
  bool _isSubmitting = false;

  // --- State yang dibaca View ---------------------------------------------

  List<EventTicket> get activeTickets => List.unmodifiable(_active);
  List<EventTicket> get cancelledTickets => List.unmodifiable(_cancelled);
  List<CompletedEvent> get completedEvents => List.unmodifiable(_completed);

  int get totalActive => _active.length;
  int get totalCancelled => _cancelled.length;
  int get totalCompleted => _completed.length;

  /// Total poin SKPI dari kegiatan yang sudah selesai.
  int get totalSkpiPoints =>
      _completed.fold(0, (int sum, CompletedEvent e) => sum + e.points);

  bool get isSubmitting => _isSubmitting;

  bool isRegistered(CampusEvent event) => ticketFor(event) != null;

  EventTicket? ticketFor(CampusEvent event) {
    for (final EventTicket t in _active) {
      if (t.eventId == event.id) return t;
    }
    return null;
  }

  EventReview? reviewFor(CompletedEvent event) => _reviews[event.skpiNumber];

  // --- Aksi dari View ------------------------------------------------------

  /// Mendaftarkan mahasiswa ke [event] dan mengembalikan tiket barunya.
  Future<EventTicket> registerEvent(
    CampusEvent event, {
    required String phone,
    required String participation,
    required String track,
  }) async {
    final EventTicket? existing = ticketFor(event);
    if (existing != null) return existing;

    _isSubmitting = true;
    notifyListeners();

    // TODO: kirim pendaftaran ke API.
    await Future<void>.delayed(const Duration(milliseconds: 900));

    final EventTicket ticket = EventTicket.fromRegistration(
      event,
      phone: phone.trim(),
      participation: participation,
      track: track,
    );
    _active.insert(0, ticket);
    _isSubmitting = false;
    notifyListeners();
    return ticket;
  }

  void cancelTicket(EventTicket ticket) {
    if (!_active.remove(ticket)) return;
    _cancelled.insert(0, ticket);
    notifyListeners();
  }

  void submitReview(CompletedEvent event, {required int rating, String comment = ''}) {
    _reviews[event.skpiNumber] = EventReview(
      rating: rating.clamp(1, 5),
      comment: comment.trim(),
    );
    notifyListeners();
  }
}
