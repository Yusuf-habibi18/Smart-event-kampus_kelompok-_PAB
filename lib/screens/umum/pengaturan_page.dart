import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_routes.dart';
import '../../core/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';

class PengaturanUmumSmartCampusEvent extends StatefulWidget {
  const PengaturanUmumSmartCampusEvent({super.key});

  @override
  State<PengaturanUmumSmartCampusEvent> createState() =>
      _PengaturanUmumSmartCampusEventState();
}

class _PengaturanUmumSmartCampusEventState
    extends State<PengaturanUmumSmartCampusEvent> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  // Keamanan
  bool _biometric = true;

  // Notifikasi
  bool _pushAlert = true;
  bool _reminderH1 = true;
  bool _whatsapp = true;
  bool _skpiNotif = true;
  bool _weeklyDigest = false;

  // Preferensi
  String _language = 'Bahasa Indonesia (ID)';
  String _theme = 'Ikuti Sistem';
  bool _dataSaver = false;
  bool _offlineTickets = true;

  // Penyimpanan
  double _cacheMb = 28.4;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- Aksi ----------------------------------------------------------------

  void _showInfo(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _comingSoon(String title) {
    _showInfo('"$title" akan tersedia setelah modul ini terhubung.');
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
    bool destructive = false,
  }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: destructive
                  ? FilledButton.styleFrom(backgroundColor: AppColors.danger)
                  : null,
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  void _pickOption({
    required String title,
    required List<String> options,
    required String current,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: AppFonts.heading,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
              ),
              for (final String option in options)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  title: Text(option),
                  trailing: option == current
                      ? const Icon(Icons.check_rounded, color: AppColors.navy)
                      : null,
                  onTap: () {
                    Navigator.of(ctx).pop();
                    onSelected(option);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _gantiPeran() {
    final NavigatorState navigator = Navigator.of(context);
    const List<UserRole> roles = [UserRole.mahasiswa, UserRole.ormawa];

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Text(
                  'Ganti Peran',
                  style: TextStyle(
                    fontFamily: AppFonts.heading,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
              ),
              for (final UserRole role in roles)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.surfaceLow,
                    child: Icon(role.icon, color: AppColors.navy),
                  ),
                  title: Text(
                    role.label,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(role.description),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    navigator.pushNamedAndRemoveUntil(
                      role.homeRoute,
                      (Route<dynamic> route) => false,
                    );
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _clearCache() async {
    final bool ok = await _confirm(
      title: 'Bersihkan cache?',
      message: 'Poster event dan riwayat pencarian yang tersimpan akan '
          'dihapus. Tiket dan sertifikat Anda tidak terpengaruh.',
      confirmLabel: 'Bersihkan',
    );
    if (!ok || !mounted) return;
    setState(() => _cacheMb = 0);
    _showInfo('Cache berhasil dibersihkan.');
  }

  Future<void> _logout() async {
    final bool ok = await _confirm(
      title: 'Keluar dari akun?',
      message: 'Anda perlu masuk kembali untuk mengakses tiket dan '
          'sertifikat.',
      confirmLabel: 'Keluar',
      destructive: true,
    );
    if (!ok || !mounted) return;
    context.read<AuthViewModel>().logout();
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (Route<dynamic> route) => false,
    );
  }

  // --- Data pengaturan -----------------------------------------------------

  _Entry _toggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
    String? tag,
  }) {
    return _Entry(
      icon: icon,
      title: title,
      subtitle: subtitle,
      tag: tag,
      enabled: enabled,
      onTap: enabled ? () => onChanged(!value) : null,
      trailing: Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
      ),
    );
  }

  List<_Section> _buildSections() {
    return [
      _Section('Akun & Keamanan', [
        _Entry(
          icon: Icons.verified_user_rounded,
          title: 'SSO SIAKAD & Kemahasiswaan',
          subtitle: 'Akun resmi institusi universitas',
          tag: 'Prioritas',
          trailing: const _Badge(text: 'Terhubung', tone: _Tone.success),
        ),
        _Entry(
          icon: Icons.password_rounded,
          title: 'Ganti Kata Sandi & PIN Presensi',
          subtitle: 'PIN 6-digit untuk otentikasi tiket',
          trailing: const _Chevron(),
          onTap: () => _comingSoon('Ganti Kata Sandi & PIN Presensi'),
        ),
        _toggle(
          icon: Icons.fingerprint_rounded,
          title: 'Autentikasi Biometrik',
          subtitle: 'Face ID & Sidik Jari untuk tiket cepat',
          value: _biometric,
          onChanged: (bool v) => setState(() => _biometric = v),
        ),
        _Entry(
          icon: Icons.devices_rounded,
          title: 'Kelola Sesi Perangkat Aktif',
          subtitle: '2 perangkat terdaftar login',
          trailing: const _Badge(text: '2 Aktif', tone: _Tone.accent),
          onTap: () => _comingSoon('Kelola Sesi Perangkat Aktif'),
        ),
      ]),
      _Section('Notifikasi & Pengingat', [
        _toggle(
          icon: Icons.notifications_active_rounded,
          title: 'Push Alert',
          subtitle: 'Aktifkan semua notifikasi aplikasi',
          value: _pushAlert,
          onChanged: (bool v) => setState(() => _pushAlert = v),
        ),
        _toggle(
          icon: Icons.alarm_rounded,
          title: 'Pengingat Event H-1',
          subtitle: 'Alarm jadwal kuliah & aula sebelum hari H',
          value: _reminderH1,
          enabled: _pushAlert,
          onChanged: (bool v) => setState(() => _reminderH1 = v),
        ),
        _toggle(
          icon: Icons.chat_rounded,
          title: 'Notifikasi WhatsApp Resmi',
          subtitle: 'Kirim QR Tiket & update darurat panitia',
          value: _whatsapp,
          enabled: _pushAlert,
          onChanged: (bool v) => setState(() => _whatsapp = v),
        ),
        _toggle(
          icon: Icons.workspace_premium_rounded,
          title: 'E-Sertifikat & Poin SKPI',
          subtitle: 'Kabar validasi poin kemahasiswaan',
          value: _skpiNotif,
          enabled: _pushAlert,
          onChanged: (bool v) => setState(() => _skpiNotif = v),
        ),
        _toggle(
          icon: Icons.auto_awesome_rounded,
          title: 'Rekomendasi Event Mingguan',
          subtitle: 'Kompilasi seminar & workshop pilihan',
          value: _weeklyDigest,
          enabled: _pushAlert,
          onChanged: (bool v) => setState(() => _weeklyDigest = v),
        ),
      ]),
      _Section('Preferensi & Tampilan', [
        _Entry(
          icon: Icons.language_rounded,
          title: 'Bahasa Aplikasi',
          subtitle: 'Bahasa antarmuka sistem',
          trailing: _ValueTrailing(text: _language),
          onTap: () => _pickOption(
            title: 'Bahasa Aplikasi',
            options: const ['Bahasa Indonesia (ID)', 'English (EN)'],
            current: _language,
            onSelected: (String v) => setState(() => _language = v),
          ),
        ),
        _Entry(
          icon: Icons.contrast_rounded,
          title: 'Tema Tampilan',
          subtitle: 'Penyesuaian kontras layar',
          trailing: _ValueTrailing(text: _theme),
          onTap: () => _pickOption(
            title: 'Tema Tampilan',
            options: const ['Ikuti Sistem', 'Terang', 'Gelap'],
            current: _theme,
            onSelected: (String v) => setState(() => _theme = v),
          ),
        ),
        _toggle(
          icon: Icons.data_saver_on_rounded,
          title: 'Mode Hemat Kuota & Gambar',
          subtitle: 'Turunkan resolusi poster kegiatan',
          value: _dataSaver,
          onChanged: (bool v) => setState(() => _dataSaver = v),
        ),
        _toggle(
          icon: Icons.qr_code_2_rounded,
          title: 'Sinkronisasi Tiket QR Offline',
          subtitle: 'Simpan enkripsi tiket saat aula minim sinyal',
          tag: 'Fast-Pass',
          value: _offlineTickets,
          onChanged: (bool v) => setState(() => _offlineTickets = v),
        ),
      ]),
      _Section('Bantuan & Tata Kelola', [
        _Entry(
          icon: Icons.help_outline_rounded,
          title: 'Pusat Bantuan & FAQ Mahasiswa',
          subtitle: 'Panduan pendaftaran & sertifikat',
          trailing: const _Chevron(),
          onTap: () => _comingSoon('Pusat Bantuan & FAQ Mahasiswa'),
        ),
        _Entry(
          icon: Icons.support_agent_rounded,
          title: 'Kontak Helpdesk BKA',
          subtitle: 'Biro Kemahasiswaan & Alumni Lt. 2',
          trailing: const _Chevron(),
          onTap: () => _comingSoon('Kontak Helpdesk BKA'),
        ),
        _Entry(
          icon: Icons.menu_book_rounded,
          title: 'Panduan Poin SKPI Kampus',
          subtitle: 'Kriteria bobot kredit kepanitiaan',
          trailing: const _Chevron(),
          onTap: () => _comingSoon('Panduan Poin SKPI Kampus'),
        ),
        _Entry(
          icon: Icons.cleaning_services_rounded,
          title: 'Bersihkan Cache & Riwayat',
          subtitle:
              'Ukuran tersimpan saat ini: ${_cacheMb.toStringAsFixed(1)} MB',
          trailing: TextButton(
            onPressed: _cacheMb > 0 ? _clearCache : null,
            child: const Text('Bersihkan'),
          ),
        ),
      ]),
    ];
  }

  // --- UI ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final bool searching = _query.isNotEmpty;

    final List<_Section> sections = [];
    for (final _Section section in _buildSections()) {
      final List<_Entry> matches =
          section.entries.where((e) => e.matches(_query)).toList();
      if (matches.isNotEmpty) sections.add(_Section(section.title, matches));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                _Header(canPop: Navigator.of(context).canPop()),
                Expanded(
                  child: ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                    children: [
                      TextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        decoration: appInputDecoration(
                          hint: 'Cari pengaturan, keamanan, SKPI...',
                          prefixIcon: Icons.search_rounded,
                          suffixIcon: searching
                              ? IconButton(
                                  tooltip: 'Hapus pencarian',
                                  icon: const Icon(Icons.close_rounded),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _query = '');
                                  },
                                )
                              : null,
                        ),
                        onChanged: (String v) =>
                            setState(() => _query = v.trim().toLowerCase()),
                      ),
                      const SizedBox(height: 20),
                      if (!searching) ...[
                        _ProfileCard(onChangeRole: _gantiPeran),
                        const SizedBox(height: 24),
                      ],
                      if (sections.isEmpty)
                        const _EmptyResult()
                      else
                        for (final _Section section in sections) ...[
                          _SectionBlock(section: section),
                          const SizedBox(height: 24),
                        ],
                      if (!searching) ...[
                        OutlinedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout_rounded, size: 20),
                          label: const Text('Keluar dari Akun Kampus'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            foregroundColor: AppColors.danger,
                            side: const BorderSide(color: AppColors.danger),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontFamily: AppFonts.body,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Smart Campus Event v3.2.0 • Build 2024.11\n'
                          'Server Terpadu Biro Kemahasiswaan & Alumni (BKA)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.6,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Model data
// ---------------------------------------------------------------------------

class _Section {
  const _Section(this.title, this.entries);

  final String title;
  final List<_Entry> entries;
}

class _Entry {
  const _Entry({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.tag,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? tag;
  final bool enabled;

  bool matches(String query) {
    if (query.isEmpty) return true;
    return title.toLowerCase().contains(query) ||
        subtitle.toLowerCase().contains(query);
  }
}

// ---------------------------------------------------------------------------
// Widget pendukung
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({required this.canPop});

  final bool canPop;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(canPop ? 8 : 20, 12, 20, 12),
      child: Row(
        children: [
          if (canPop)
            IconButton(
              tooltip: 'Kembali',
              icon: const Icon(Icons.arrow_back_rounded),
              color: AppColors.navy,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          const Expanded(
            child: Text(
              'Pengaturan Aplikasi',
              style: TextStyle(
                fontFamily: AppFonts.heading,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: AppColors.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.onChangeRole});

  final VoidCallback onChangeRole;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navyLight, AppColors.navy],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  'AP',
                  style: TextStyle(
                    fontFamily: AppFonts.heading,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accentDark,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Arya Pratama',
                          style: TextStyle(
                            fontFamily: AppFonts.heading,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        _Badge(text: 'SSO Aktif', tone: _Tone.success),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      'NIM: 2108561042 • Teknik Informatika',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: AppColors.periwinkle,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Peran: Mahasiswa & Panitia',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: AppColors.periwinkle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onChangeRole,
            icon: const Icon(Icons.swap_horiz_rounded, size: 20),
            label: const Text('Ganti Peran'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(46),
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withAlpha(90)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({required this.section});

  final _Section section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            section.title,
            style: const TextStyle(
              fontFamily: AppFonts.heading,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.surfaceHigh),
          ),
          child: Material(
            color: Colors.transparent,
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                for (int i = 0; i < section.entries.length; i++) ...[
                  if (i > 0)
                    const Divider(
                      height: 1,
                      indent: 72,
                      color: AppColors.surfaceHigh,
                    ),
                  _SettingTile(entry: section.entries[i]),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({required this.entry});

  final _Entry entry;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: entry.onTap,
      child: Opacity(
        opacity: entry.enabled ? 1 : 0.45,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(entry.icon, size: 20, color: AppColors.navy),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            entry.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (entry.tag != null) ...[
                          const SizedBox(width: 6),
                          _Badge(text: entry.tag!, tone: _Tone.accent),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (entry.trailing != null) ...[
                const SizedBox(width: 8),
                entry.trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

enum _Tone { success, accent }

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.tone});

  final String text;
  final _Tone tone;

  @override
  Widget build(BuildContext context) {
    final bool success = tone == _Tone.success;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: success ? AppColors.successSoft : AppColors.accentSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: success ? AppColors.success : AppColors.accentDark,
        ),
      ),
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.chevron_right_rounded,
      color: AppColors.textMuted,
    );
  }
}

class _ValueTrailing extends StatelessWidget {
  const _ValueTrailing({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 110),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.navy,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}

class _EmptyResult extends StatelessWidget {
  const _EmptyResult();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 44, color: AppColors.textMuted),
          SizedBox(height: 12),
          Text(
            'Pengaturan tidak ditemukan',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Coba kata kunci lain, misalnya "notifikasi" atau "SKPI".',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}