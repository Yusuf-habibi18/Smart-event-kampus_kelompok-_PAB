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
  final PageController _pageController = PageController(
    viewportFraction: 0.92,
    keepPage: false,
  );

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

  /// Tarik ke bawah untuk memuat ulang (simulasi; nanti dari API).
  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    showSnack(context, 'Daftar event sudah diperbarui.');
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
                    letterSpacing: -0.2,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                SizedBox(height: 8),
                _NotificationTile(
                  icon: Icons.qr_code_2_rounded,
                  title: 'Tiket Workshop UI/UX siap digunakan',
                  subtitle: 'Buka QR presensi di tab Event Saya.',
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
    final double textFactor = MediaQuery.textScalerOf(context)
        .scale(1)
        .clamp(1.0, 1.5)
        .toDouble();
    final String firstName = student.name.split(' ').first;

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            HeroHeader(
              leading: const _Brand(),
              actions: [
                CircleIconButton(
                  icon: Icons.notifications_none_rounded,
                  tooltip: 'Notifikasi, 2 belum dibaca',
                  badge: 2,
                  onPressed: _showNotifications,
                ),
              ],
              eyebrow: 'Halo, $firstName',
              title: 'Mau ikut event apa hari ini?',
              subtitle: student.identityLine,
              bottom: TextField(
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
            const SizedBox(height: 20),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: Gap.page),
                itemCount: vm.categories.length,
                separatorBuilder: (BuildContext _, int index) =>
                    const SizedBox(width: 8),
                itemBuilder: (BuildContext context, int i) {
                  final String label = vm.categories[i];
                  final bool selected = vm.category == label;
                  return ChoiceChip(
                    label: Text(label),
                    selected: selected,
                    labelStyle: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : AppColors.textSecondary,
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
              const SizedBox(height: Gap.section),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Gap.page),
                child: SectionHeader(
                  eyebrow: 'Rekomendasi',
                  title: 'Event Unggulan Kampus',
                  trailingText:
                      '${vm.featuredIndex + 1} / ${featured.length} Rekomendasi',
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 300 * textFactor,
                child: PageView.builder(
                  key: ValueKey<String>(
                    featured.map((CampusEvent e) => e.id).join(','),
                  ),
                  controller: _pageController,
                  itemCount: featured.length,
                  onPageChanged: vm.setFeaturedIndex,
                  itemBuilder: (BuildContext context, int i) {
                    final String tag = 'unggulan-${featured[i].id}';
                    // Kartu di samping sedikit mengecil (efek karusel).
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (BuildContext context, Widget? child) {
                        double page = vm.featuredIndex.toDouble();
                        if (_pageController.hasClients &&
                            _pageController.position.haveDimensions) {
                          page = _pageController.page ?? page;
                        }
                        final double delta = (page - i).abs().clamp(0.0, 1.0);
                        return Transform.scale(
                          scale: 1 - delta * 0.06,
                          child: child,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: EventCard(
                          event: featured[i],
                          heroTag: tag,
                          height: double.infinity,
                          onTap: () => openEventDetail(
                            context,
                            featured[i],
                            heroTag: tag,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              _PageDots(count: featured.length, index: vm.featuredIndex),
            ],
            if (upcoming.isNotEmpty) ...[
              const SizedBox(height: Gap.section),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Gap.page),
                child: SectionHeader(
                  eyebrow: 'Segera Dimulai',
                  title: 'Event Terdekat Minggu Ini',
                  trailingText: 'Lihat Semua',
                  onTrailingTap: _openExplore,
                ),
              ),
              const SizedBox(height: 18),
              for (int i = 0; i < upcoming.length; i++)
                Padding(
                  padding: const EdgeInsets.fromLTRB(Gap.page, 0, Gap.page, 18),
                  child: Reveal(
                    index: i,
                    child: EventCard(
                      event: upcoming[i],
                      heroTag: 'beranda-${upcoming[i].id}',
                      onTap: () => openEventDetail(
                        context,
                        upcoming[i],
                        heroTag: 'beranda-${upcoming[i].id}',
                      ),
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 22),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: Gap.page),
              child: SectionHeader(
                eyebrow: 'Ormawa',
                title: 'Jelajahi Berdasarkan Kategori',
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Gap.page),
              child: _OrmawaGrid(
                ormawas: vm.ormawaOptions,
                countOf: vm.countByOrmawa,
                onTap: (String ormawa) => _openExplore(ormawa: ormawa),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bagian-bagian halaman
// ---------------------------------------------------------------------------

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primaryTint),
          ),
          child: const AppLogo(size: 26),
        ),
        const SizedBox(width: 10),
        const Text(
          'CampusEvent',
          style: TextStyle(
            fontFamily: AppFonts.heading,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}

/// Titik penanda posisi kartu unggulan.
class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == index ? 22 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == index ? AppColors.glow : AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(3),
              boxShadow: i == index
                  ? const [BoxShadow(color: Color(0x668FB0FF), blurRadius: 8)]
                  : null,
            ),
          ),
      ],
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
            padding: EdgeInsets.only(top: i == 0 ? 0 : 14),
            child: Row(
              children: [
                Expanded(child: _tile(ormawas[i])),
                const SizedBox(width: 14),
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

    return Pressable(
      child: Material(
        color: AppColors.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.border),
        ),
        child: InkWell(
          onTap: () => onTap(name),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconSquare(
                      icon: _icons[name] ?? Icons.groups_rounded,
                      size: 40,
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.north_east_rounded,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                CaptionText(
                  '$count EVENT',
                  size: 11,
                  color: AppColors.textMuted,
                ),
              ],
            ),
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
        backgroundColor: AppColors.primarySoft,
        child: Icon(icon, color: AppColors.glow),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      subtitle: Text(subtitle),
    );
  }
}
