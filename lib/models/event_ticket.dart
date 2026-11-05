import 'campus_event.dart';

/// Model: tiket yang dimiliki mahasiswa setelah mendaftar event.
class EventTicket {
  const EventTicket({
    required this.ticketId,
    required this.title,
    required this.organizer,
    required this.dateLabel,
    required this.timeLabel,
    required this.location,
    required this.seat,
    required this.refId,
    this.eventId,
    this.facilities = 'E-Sertifikat & Snack Box Panitia',
    this.verified = false,
    this.phone,
    this.participation,
    this.track,
  });

  /// Tiket baru dari data formulir pendaftaran.
  factory EventTicket.fromRegistration(
    CampusEvent event, {
    required String phone,
    required String participation,
    required String track,
  }) {
    return EventTicket(
      eventId: event.id,
      ticketId: 'SCE-2025-${98000 + event.id * 37}',
      title: event.title,
      organizer: event.organizer,
      dateLabel: event.dateLabel,
      timeLabel: 'Sesi ${event.startTime} WIB',
      location: event.location,
      seat: participation == 'Daring (Zoom)' ? 'Online' : 'A-${20 + event.id}',
      refId: 'CS-ACD-${2100 + event.id}',
      verified: true,
      phone: phone,
      participation: participation,
      track: track,
    );
  }

  /// Id [CampusEvent] asal tiket (null untuk tiket contoh).
  final int? eventId;
  final String ticketId;
  final String title;
  final String organizer;
  final String dateLabel;
  final String timeLabel;
  final String location;
  final String seat;
  final String refId;
  final String facilities;
  final bool verified;

  /// Data yang diisi mahasiswa pada formulir pendaftaran.
  final String? phone;
  final String? participation;
  final String? track;
}
