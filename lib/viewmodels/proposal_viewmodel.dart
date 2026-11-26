import 'package:flutter/foundation.dart';

import '../data/dummy_ormawa_data.dart';
import '../models/event_proposal.dart';
import '../models/ormawa_account.dart';

/// ViewModel: proposal event dan pengajuan akun Ormawa.
///
/// Dibagikan ke seluruh aplikasi (lihat main.dart) sehingga proposal yang
/// diajukan Ormawa langsung muncul di antrean Admin (BKA), dan keputusan
/// Admin langsung terlihat di halaman Status Pengajuan milik Ormawa.
class ProposalViewModel extends ChangeNotifier {
  ProposalViewModel()
      : _proposals = List<EventProposal>.of(dummyProposals),
        _accounts = List<OrmawaAccount>.of(dummyAccountApplications);

  final List<EventProposal> _proposals;
  final List<OrmawaAccount> _accounts;
  final OrmawaAccount _myOrmawa = dummyMyOrmawa;
  bool _isSubmitting = false;

  // --- State yang dibaca View ---------------------------------------------

  OrmawaAccount get myOrmawa => _myOrmawa;
  bool get isSubmitting => _isSubmitting;

  List<EventProposal> get allProposals => List.unmodifiable(_proposals);

  /// Proposal milik Ormawa yang sedang masuk.
  List<EventProposal> get myProposals => _proposals
      .where((EventProposal p) => p.ormawa == _myOrmawa.shortName)
      .toList();

  List<EventProposal> myProposalsBy(ProposalStatus? status) => status == null
      ? myProposals
      : myProposals.where((EventProposal p) => p.status == status).toList();

  /// Event milik Ormawa yang sudah disetujui (bisa dikelola & presensi).
  List<EventProposal> get myActiveEvents =>
      myProposalsBy(ProposalStatus.disetujui);

  int get myTotalRegistered => myActiveEvents.fold(
        0,
        (int sum, EventProposal p) => sum + p.registered,
      );

  /// Antrean review Admin: urgent dulu, lalu urutan masuk terbaru.
  List<EventProposal> get pendingProposals {
    final List<EventProposal> list = _proposals
        .where((EventProposal p) => p.status == ProposalStatus.menungguReview)
        .toList();
    list.sort((EventProposal a, EventProposal b) {
      if (a.urgent != b.urgent) return a.urgent ? -1 : 1;
      return b.id.compareTo(a.id);
    });
    return list;
  }

  List<OrmawaAccount> get accountApplications => List.unmodifiable(_accounts);

  List<OrmawaAccount> get pendingAccounts => _accounts
      .where((OrmawaAccount a) => a.status == AccountStatus.menunggu)
      .toList();

  int get urgentCount =>
      pendingProposals.where((EventProposal p) => p.urgent).length +
      pendingAccounts.where((OrmawaAccount a) => a.urgent).length;

  int get totalApproved => _proposals
      .where((EventProposal p) => p.status == ProposalStatus.disetujui)
      .length;

  int get totalParticipants => _proposals
      .where((EventProposal p) => p.status == ProposalStatus.disetujui)
      .fold(0, (int sum, EventProposal p) => sum + p.registered);

  EventProposal? proposalById(int id) {
    for (final EventProposal p in _proposals) {
      if (p.id == id) return p;
    }
    return null;
  }

  // --- Aksi Ormawa ---------------------------------------------------------

  /// Mengajukan proposal baru dan mengembalikan proposal yang tersimpan.
  Future<EventProposal> submitProposal({
    required String title,
    required String category,
    required String description,
    required String dateLabel,
    required String timeLabel,
    required String location,
    required String format,
    required int quota,
    required int budget,
    required int skpiPoints,
    required String advisor,
    required String fileName,
    bool internal = false,
  }) async {
    _isSubmitting = true;
    notifyListeners();

    // TODO: kirim proposal ke API.
    await Future<void>.delayed(const Duration(milliseconds: 900));

    final int id = _proposals.fold(
          0,
          (int max, EventProposal p) => p.id > max ? p.id : max,
        ) +
        1;
    final EventProposal proposal = EventProposal(
      id: id,
      code: 'PROP-2025-${_myOrmawa.shortName}-${(id + 12).toString().padLeft(3, '0')}',
      title: title.trim(),
      category: category,
      ormawa: _myOrmawa.shortName,
      description: description.trim(),
      dateLabel: dateLabel,
      timeLabel: timeLabel,
      location: location.trim(),
      format: format,
      quota: quota,
      budget: budget,
      skpiPoints: skpiPoints,
      advisor: advisor.trim(),
      fileName: fileName,
      internal: internal,
      submittedLabel: 'Baru saja',
    );
    _proposals.insert(0, proposal);
    _isSubmitting = false;
    notifyListeners();
    return proposal;
  }

  /// Menyimpan perubahan informasi event (halaman Edit Informasi Event).
  void updateProposal(EventProposal updated) {
    final int index =
        _proposals.indexWhere((EventProposal p) => p.id == updated.id);
    if (index < 0) return;
    _proposals[index] = updated;
    notifyListeners();
  }

  /// Mengunggah ulang berkas proposal yang diminta revisi.
  void resubmitProposal(EventProposal proposal, {required String fileName}) {
    updateProposal(proposal.copyWith(
      status: ProposalStatus.menungguReview,
      fileName: fileName,
      submittedLabel: 'Baru saja',
    ));
  }

  // --- Aksi Admin ----------------------------------------------------------

  /// Keputusan BKA atas proposal. [note] wajib untuk revisi / tolak.
  void reviewProposal(
    EventProposal proposal,
    ProposalStatus decision, {
    String note = '',
  }) {
    assert(decision != ProposalStatus.menungguReview);
    updateProposal(proposal.copyWith(
      status: decision,
      reviewNote: note.trim().isEmpty ? null : note.trim(),
      urgent: false,
    ));
  }

  /// Ormawa mengirim pengajuan akun baru (dari halaman login).
  Future<void> submitAccount(OrmawaAccount account) async {
    _isSubmitting = true;
    notifyListeners();

    // TODO: kirim pengajuan akun ke API.
    await Future<void>.delayed(const Duration(milliseconds: 900));

    _accounts.insert(0, account);
    _isSubmitting = false;
    notifyListeners();
  }

  int get nextAccountId =>
      _accounts.fold(1, (int max, OrmawaAccount a) => a.id > max ? a.id : max) +
      1;

  void reviewAccount(
    OrmawaAccount account,
    AccountStatus decision, {
    String note = '',
  }) {
    final int index =
        _accounts.indexWhere((OrmawaAccount a) => a.id == account.id);
    if (index < 0) return;
    _accounts[index] = account.copyWith(
      status: decision,
      skNumber: decision == AccountStatus.terverifikasi
          ? 'SK/BKA/2025/${(40 + account.id).toString().padLeft(3, '0')}'
          : null,
      reviewNote: note.trim().isEmpty ? null : note.trim(),
    );
    notifyListeners();
  }
}
