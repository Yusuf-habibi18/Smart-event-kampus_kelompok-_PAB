/// Model: event kampus yang dapat diikuti mahasiswa.
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

  String get dateTimeShort => '$dateLabel • $startTime WIB';
  String get timeRange => '$startTime - $endTime WIB';
  String get pointsLabel => '+$points Poin SKPI';

  bool matches(String query) {
    if (query.isEmpty) return true;
    final String q = query.toLowerCase();
    return title.toLowerCase().contains(q) ||
        organizer.toLowerCase().contains(q) ||
        category.toLowerCase().contains(q) ||
        location.toLowerCase().contains(q);
  }
}
