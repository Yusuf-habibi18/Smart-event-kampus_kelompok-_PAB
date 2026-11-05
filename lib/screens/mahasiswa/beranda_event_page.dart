import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../models/campus_event.dart';
import '../../models/student_profile.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/event_viewmodel.dart';
import 'mahasiswa_widgets.dart';

/// View: halaman utama mahasiswa.
///
/// State pencarian & filter dibaca dari [EventViewModel], identitas
/// mahasiswa dibaca dari [AuthViewModel].
class BerandaEventPage extends StatefulWidget {
  const BerandaEventPage({super.key, this.onSelectTab, this.onOpenExplore});

  /// Dipanggil untuk pindah tab di [MahasiswaShell].
  final ValueChanged<int>? onSelectTab;

  /// Membuka tab Eksplorasi, opsional dengan filter ormawa.
  final void Function({String? ormawa})? onOpenExplore;

  @override
  State<BerandaEventPage> createState() => _BerandaEventPageState();
}

class _BerandaEventPageState extends State<BerandaEventPage> {
  final TextEditingController _search = TextEditingController();
  final PageController _pageController =
      PageController(viewportFraction: 0.92, keepPage: false);

  @override
  void dispose() {
    _search.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _openExplore({String? ormawa}) {
    final void Function({String? ormawa})? callback = widget.onOpenExplore;
    if (callback != null) {
      callback(ormawa: ormawa);
    } else {
      showComingSoon(context, 'Eksplorasi event');
    }
  }

  void _showNotifications() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Notifikasi',
                  style: TextStyle(
                    fontFamily: AppFonts.heading,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
                SizedBox(height: 8),
                _NotificationTile(
                  icon: Icons.qr_code_2_rounded,
                  title: 'Tiket Workshop UI/UX siap digunakan',
                  subtitle: 'Buka QR presensi di tab Tiket Saya.',
                ),
                _NotificationTile(
                  icon: Icons.workspace_premium_rounded,
                  title: 'E-Sertifikat Seminar Nasional AI terbit',
                  subtitle: '+10 Poin SKPI sudah masuk ke transkrip.',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final EventViewModel vm = context.watch<EventViewModel>();
    final StudentProfile student = context.watch<AuthViewModel>().student;
    final List<CampusEvent> featured = vm.featuredEvents;
    final List<CampusEvent> upcoming = vm.upcomingEvents;
    final bool nothing = featured.isEmpty && upcoming.isEmpty;
    final double textFactor =
        MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.5).toDouble();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 20,
        title: const Row(
          children: [
            AppLogo(size: 34),
            SizedBox(width: 10),
            Text('CampusEvent'),
          ],
        ),
        actions: [
          _NotificationButton(onTap: _showNotifications),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.only(bottom: 28),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: _GreetingRow(student: student),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: TextField(
                    controller: _search,
                    textInputAction: TextInputAction.search,
                    decoration: appInputDecoration(
                      hint: 'Cari seminar, ormawa, atau sertifikasi...',
                      prefixIcon: Icons.search_rounded,
                      suffixIcon: vm.query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Hapus pencarian',
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () {
                                _search.clear();
                                vm.clearSearch();
                              },
                            ),
                    ),
                    onChanged: vm.search,
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: vm.categories.length,
                    separatorBuilder: (BuildContext _, int index) => const SizedBox(width: 8),
                    itemBuilder: (BuildContext context, int i) {
                      final String label = vm.categories[i];
                      final bool selected = vm.category == label;
                      return ChoiceChip(
                        label: Text(label),
                        selected: selected,
                        showCheckmark: false,
                        selectedColor: AppColors.navy,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color:
                              selected ? Colors.white : AppColors.textSecondary,
                        ),
                        onSelected: (_) => vm.selectCategory(label),
                      );
                    },
                  ),
                ),
                if (nothing)
                  const EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'Event tidak ditemukan',
                    message: 'Coba kata kunci lain atau pilih kategori Semua.',
                  ),
                if (featured.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SectionHeader(
                      title: 'Event Unggulan Kampus',
                      trailingText:
                          '${vm.featuredIndex + 1} / ${featured.length} '
                          'Rekomendasi',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 292 * textFactor,
                    child: PageView.builder(
                      key: ValueKey<String>(
                        featured.map((CampusEvent e) => e.id).join(','),
                      ),
                      controller: _pageController,
                      itemCount: featured.length,
                      onPageChanged: vm.setFeaturedIndex,
                      itemBuilder: (BuildContext context, int i) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: _FeaturedCard(
                            event: featured[i],
                            onTap: () => openEventDetail(context, featured[i]),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                if (upcoming.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SectionHeader(
                      title: 'Event Terdekat Minggu Ini',
                      trailingText: 'Lihat Semua',
                      onTrailingTap: _openExplore,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final CampusEvent event in upcoming)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: EventCard(
                        event: event,
                        onTap: () => openEventDetail(context, event),
                      ),
                    ),
                ],
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: SectionHeader(
                    title: 'Jelajahi Berdasarkan Kategori Ormawa',
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _OrmawaGrid(
                    ormawas: vm.ormawaOptions,
                    countOf: vm.countByOrmawa,
                    onTap: (String ormawa) => _openExplore(ormawa: ormawa),
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
// Bagian-bagian halaman
// ---------------------------------------------------------------------------

class _GreetingRow extends StatelessWidget {
  const _GreetingRow({required this.student});

  final StudentProfile student;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.navy,
            shape: BoxShape.circle,
          ),
          child: Text(
            student.initials,
            style: const TextStyle(
              fontFamily: AppFonts.heading,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Halo,',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              Text(
                student.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: AppFonts.heading,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
              Text(
                'NIM ${student.nim} • ${student.program}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: 'Notifikasi, 2 belum dibaca',
          color: AppColors.navy,
          icon: const Icon(Icons.notifications_none_rounded, size: 28),
          onPressed: onTap,
        ),
        Positioned(
          right: 6,
          top: 6,
          child: IgnorePointer(
            child: Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 2),
              ),
              child: const Text(
                '2',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accentDark,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.event, required this.onTap});

  final CampusEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CategoryStyle style = categoryStyle(event.category);

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: style.colors,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Positioned(
                right: -16,
                top: -10,
                child: Icon(
                  style.icon,
                  size: 150,
                  color: Colors.white.withAlpha(36),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            const PillBadge(text: 'Gratis Bersertifikat SKPI'),
                            PillBadge.glass(text: event.quotaLabel),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          event.organizer,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withAlpha(215),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: AppFonts.heading,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                            letterSpacing: -0.4,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InfoLine(
                                icon: Icons.event_rounded,
                                text: event.dateTimeShort,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 6),
                              InfoLine(
                                icon: Icons.place_rounded,
                                text: event.location,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: onTap,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: AppColors.accentDark,
                            minimumSize: const Size(84, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: const TextStyle(
                              fontFamily: AppFonts.body,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          child: const Text('Daftar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrmawaGrid extends StatelessWidget {
  const _OrmawaGrid({
    required this.ormawas,
    required this.countOf,
    required this.onTap,
  });

  final List<String> ormawas;
  final int Function(String ormawa) countOf;
  final ValueChanged<String> onTap;

  static const Map<String, IconData> _icons = {
    'Penalaran': Icons.psychology_rounded,
    'Olahraga': Icons.sports_soccer_rounded,
    'Seni Budaya': Icons.palette_rounded,
    'Sosial': Icons.volunteer_activism_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < ormawas.length; i += 2)
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : 12),
            child: Row(
              children: [
                Expanded(child: _tile(ormawas[i])),
                const SizedBox(width: 12),
                Expanded(
                  child: i + 1 < ormawas.length
                      ? _tile(ormawas[i + 1])
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _tile(String name) {
    final int count = countOf(name);

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.surfaceHigh),
      ),
      child: InkWell(
        onTap: () => onTap(name),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_icons[name], size: 22, color: AppColors.navy),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '$count event',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppColors.surfaceLow,
        child: Icon(icon, color: AppColors.navy),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      subtitle: Text(subtitle),
    );
  }
}