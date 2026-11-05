import 'package:flutter/foundation.dart';

import '../data/dummy_data.dart';
import '../models/campus_event.dart';

/// ViewModel: daftar event beserta pencarian dan filter.
///
/// Dipakai oleh BerandaEventPage dan EksplorasiEventPage. Masing-masing
/// halaman memiliki instance sendiri sehingga filternya tidak saling
/// memengaruhi.
class EventViewModel extends ChangeNotifier {
  EventViewModel([this._events = dummyEvents]);

  final List<CampusEvent> _events;

  String _query = '';
  String _category = eventCategories.first;
  String? _ormawa;
  int _featuredIndex = 0;

  // --- State yang dibaca View ---------------------------------------------

  List<String> get categories => eventCategories;
  List<String> get ormawaOptions => ormawaCategories;

  String get query => _query;
  String get category => _category;
  String? get ormawa => _ormawa;

  /// Posisi kartu Event Unggulan yang sedang tampil (Beranda).
  int get featuredIndex => _featuredIndex;

  /// Event yang lolos pencarian, kategori, dan ormawa.
  List<CampusEvent> get filteredEvents {
    return _events.where((CampusEvent e) {
      final bool okCategory =
          _category == eventCategories.first || e.category == _category;
      final bool okOrmawa = _ormawa == null || e.ormawa == _ormawa;
      return okCategory && okOrmawa && e.matches(_query);
    }).toList();
  }

  List<CampusEvent> get featuredEvents =>
      filteredEvents.where((CampusEvent e) => e.featured).toList();

  List<CampusEvent> get upcomingEvents =>
      filteredEvents.where((CampusEvent e) => !e.featured).toList();

  int get totalResults => filteredEvents.length;

  int countByOrmawa(String ormawa) =>
      _events.where((CampusEvent e) => e.ormawa == ormawa).length;

  // --- Aksi dari View ------------------------------------------------------

  void search(String value) {
    _query = value.trim();
    _featuredIndex = 0;
    notifyListeners();
  }

  void clearSearch() => search('');

  void selectCategory(String category) {
    if (category == _category) return;
    _category = category;
    _featuredIndex = 0;
    notifyListeners();
  }

  void selectOrmawa(String? ormawa) {
    _ormawa = ormawa;
    _featuredIndex = 0;
    notifyListeners();
  }

  void setFeaturedIndex(int index) {
    if (index == _featuredIndex) return;
    _featuredIndex = index;
    notifyListeners();
  }
}
