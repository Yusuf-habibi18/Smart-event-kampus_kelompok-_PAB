/// Model: riwayat kegiatan yang sudah selesai diikuti.
class CompletedEvent {
  const CompletedEvent({
    required this.title,
    required this.heldOn,
    required this.points,
    required this.skpiNumber,
  });

  final String title;
  final String heldOn;
  final int points;
  final String skpiNumber;
}

/// Model: ulasan mahasiswa untuk kegiatan yang sudah selesai.
class EventReview {
  const EventReview({required this.rating, required this.comment});

  /// Nilai 1 - 5 bintang.
  final int rating;
  final String comment;
}
