/// Model: event kampus yang dapat diikuti peserta.
class CampusEvent {
  const CampusEvent({
    required this.id,
    required this.title,
    required this.organizer,
    required this.category,
    required this.ormawa,
    required this.dateLabel,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.points,
    required this.quotaLabel,
    this.featured = false,
    this.internal = false,
    this.image,
  });

  final int id;
  final String title;
  final String organizer;
  final String category;
  final String ormawa;
  final String dateLabel;
  final String startTime;
  final String endTime;
  final String location;
  final int points;
  final String quotaLabel;
  final bool featured;

  /// true = khusus mahasiswa ITPLN (Internal ITPLN); false = terbuka umum.
  final bool internal;

  /// Foto event (path asset). null = pakai warna kategori.
  final String? image;

  String get dateTimeShort => '$dateLabel • $startTime WIB';
  String get timeRange => '$startTime - $endTime WIB';
  String get pointsLabel => '+$points Poin SKPI';
  String get audienceLabel => internal ? 'Internal ITPLN' : 'Terbuka untuk Umum';

  bool matches(String query) {
    if (query.isEmpty) return true;
    final String q = query.toLowerCase();
    return title.toLowerCase().contains(q) ||
        organizer.toLowerCase().contains(q) ||
        category.toLowerCase().contains(q) ||
        location.toLowerCase().contains(q);
  }
}
