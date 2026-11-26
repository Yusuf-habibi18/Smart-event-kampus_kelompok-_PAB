import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../models/campus_event.dart';
import '../../models/event_ticket.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/ticket_viewmodel.dart';
import '../umum/ui_kit.dart';
import 'detail_event_page.dart';
import 'tiket_event_page.dart';

export '../umum/ui_kit.dart';

// ---------------------------------------------------------------------------
// Helper umum
// ---------------------------------------------------------------------------

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

void showComingSoon(BuildContext context, String feature) {
  showSnack(context, '"$feature" akan aktif setelah modul ini terhubung.');
}

Future<bool> confirmDialog(
  BuildContext context, {
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

/// Navigasi: kartu event (Beranda / Eksplorasi) → DetailEventPage.
/// Objek [event] dikirim ke halaman tujuan lewat constructor.
///
/// [heroTag] menghubungkan foto di kartu dengan foto di halaman detail
/// (animasi Hero). Tag harus unik per layar, mis. 'beranda-3'.
void openEventDetail(
  BuildContext context,
  CampusEvent event, {
  String? heroTag,
}) {
  Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (BuildContext context) =>
          DetailEventPage(event: event, heroTag: heroTag),
    ),
  );
}

/// Navigasi: tombol tiket (Event Saya / Detail Event) → TiketEventPage.
void openTicket(BuildContext context, EventTicket ticket) {
  Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (BuildContext context) => TiketEventPage(ticket: ticket),
    ),
  );
}

/// Logo aplikasi dari Asset Image (assets/images/logo.png).
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppImages.logo,
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticLabel: 'Logo CampusEvent',
    );
  }
}

// ---------------------------------------------------------------------------
// Gaya kategori (warna poster pengganti gambar)
// ---------------------------------------------------------------------------

class CategoryStyle {
  const CategoryStyle(this.colors, this.icon);

  final List<Color> colors;
  final IconData icon;

  /// Warna dasar poster (polos, tanpa gradasi).
  Color get color => colors.first;
}

CategoryStyle categoryStyle(String category) {
  switch (category) {
    case 'Kompetisi':
      return const CategoryStyle([
        Color(0xFF1F7A5A),
        Color(0xFF2E9A74),
      ], Icons.emoji_events_rounded);
    case 'Seni & Musik':
      return const CategoryStyle([
        Color(0xFF3550B5),
        Color(0xFF4A66C9),
      ], Icons.palette_rounded);
    case 'Workshop':
      return const CategoryStyle([
        AppColors.primaryHover,
        Color(0xFF1D5FD0),
      ], Icons.design_services_rounded);
    default:
      return const CategoryStyle([
        AppColors.primary,
        AppColors.primaryHover,
      ], Icons.school_rounded);
  }
}

// ---------------------------------------------------------------------------
// Header & section
// ---------------------------------------------------------------------------

/// AppBar standar halaman: tombol kembali bulat, judul + subjudul.
class ScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ScreenAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = true,
    this.actions = const [],
    this.bottom,
  });

  final String title;
  final String? subtitle;
  final bool showBack;
  final List<Widget> actions;
  final PreferredSizeWidget? bottom;

  static const double _toolbarHeight = 68;

  @override
  Size get preferredSize =>
      Size.fromHeight(_toolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: _toolbarHeight,
      automaticallyImplyLeading: false,
      titleSpacing: showBack ? 4 : 20,
      leadingWidth: showBack ? 64 : null,
      leading: showBack
          ? Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Center(
                child: CircleIconButton(
                  icon: Icons.arrow_back_rounded,
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            )
          : null,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          if (subtitle != null)
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.4,
                color: AppColors.textMuted,
              ),
            ),
        ],
      ),
      actions: [...actions, const SizedBox(width: 12)],
      bottom: bottom,
    );
  }
}

/// Label kecil di atas judul (pola "eyebrow").
class Eyebrow extends StatelessWidget {
  const Eyebrow({
    super.key,
    required this.text,
    this.color = AppColors.glow,
    this.background = AppColors.primarySoft,
  });

  /// Versi untuk di atas panel biru.
  const Eyebrow.onDark({super.key, required this.text})
    : color = Colors.white,
      background = const Color(0x1FFFFFFF);

  final String text;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) => EyebrowText(text: text, color: color);
}

/// Judul section + tautan opsional di kanan ("Lihat Semua →").
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.trailingText,
    this.onTrailingTap,
    this.eyebrow,
  });

  final String title;
  final String? trailingText;
  final VoidCallback? onTrailingTap;

  /// Label kecil di atas judul (opsional).
  final String? eyebrow;

  @override
  Widget build(BuildContext context) {
    final Widget titleText = Text(
      title,
      style: const TextStyle(
        fontFamily: AppFonts.heading,
        fontSize: 18,
        letterSpacing: -0.3,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
    );

    final Widget row = Row(
      children: [
        Expanded(child: titleText),
        if (trailingText != null)
          onTrailingTap == null
              ? Text(
                  trailingText!,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                )
              : TextButton(
                  onPressed: onTrailingTap,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.only(left: 10, right: 4),
                    minimumSize: const Size(0, 32),
                    textStyle: const TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(trailingText!),
                      const SizedBox(width: 2),
                      const Icon(Icons.arrow_forward_rounded, size: 16),
                    ],
                  ),
                ),
      ],
    );

    if (eyebrow == null) return row;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EyebrowText(text: eyebrow!),
        const SizedBox(height: 10),
        row,
      ],
    );
  }
}

class PillBadge extends StatelessWidget {
  const PillBadge({
    super.key,
    required this.text,
    this.background = AppColors.primarySoft,
    this.foreground = AppColors.glow,
    this.icon,
  });

  final String text;
  final Color background;
  final Color foreground;
  final IconData? icon;

  /// Status yang masih menunggu (kuning).
  const PillBadge.warning({super.key, required this.text, this.icon})
    : background = AppColors.warningSoft,
      foreground = AppColors.warning;

  const PillBadge.success({super.key, required this.text, this.icon})
    : background = AppColors.successSoft,
      foreground = AppColors.success;

  /// Di atas foto: latar gelap transparan, teks putih.
  const PillBadge.overlay({super.key, required this.text, this.icon})
    : background = const Color(0xA60A1A2F),
      foreground = Colors.white;

  const PillBadge.glass({super.key, required this.text, this.icon})
    : background = const Color(0x2EFFFFFF),
      foreground = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: foreground),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InfoLine extends StatelessWidget {
  const InfoLine({
    super.key,
    required this.icon,
    required this.text,
    this.color = AppColors.textSecondary,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12.5, height: 1.4, color: color),
          ),
        ),
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      child: Column(
        children: [
          PopIn(
            child: Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: AppColors.glow),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu putih standar ([Card]) dengan border tipis (lihat cardTheme).
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Kartu event
// ---------------------------------------------------------------------------

/// Kartu event bergaya poster: foto penuh dengan teks di atasnya.
///
/// Dipakai di daftar event (Beranda, Cari Event) dan karusel event unggulan.
/// [height] null = tinggi standar daftar; double.infinity = ikuti induk.
class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.heroTag,
    this.height,
  });

  final CampusEvent event;
  final VoidCallback onTap;

  /// Tag animasi Hero untuk foto (lihat [openEventDetail]).
  final String? heroTag;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final CategoryStyle style = categoryStyle(event.category);
    final bool mahasiswa = context.select<AuthViewModel, bool>(
      (AuthViewModel a) => a.isMahasiswa,
    );
    final bool saved = context.select<TicketViewModel, bool>(
      (TicketViewModel t) => t.isSaved(event.id),
    );
    final double textFactor = MediaQuery.textScalerOf(context)
        .scale(1)
        .clamp(1.0, 1.4)
        .toDouble();
    final Widget image = EventImage(
      path: event.image,
      color: style.color,
      icon: style.icon,
      semanticLabel: 'Foto ${event.title}',
    );

    return Pressable(
      child: Material(
        color: style.color,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: height ?? 268 * textFactor,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (heroTag == null)
                  image
                else
                  Hero(tag: heroTag!, child: image),
                const PhotoScrim(strength: 0xE6),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DateBadge(dateLabel: event.dateLabel, size: 54),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Wrap(
                              alignment: WrapAlignment.end,
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                if (event.internal)
                                  const PillBadge.overlay(
                                    text: 'Internal ITPLN',
                                    icon: Icons.lock_outline_rounded,
                                  ),
                                if (mahasiswa)
                                  PillBadge.overlay(text: event.pointsLabel),
                                PillBadge.overlay(text: event.quotaLabel),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          SaveButton(
                            saved: saved,
                            size: 36,
                            onPressed: () {
                              final bool now = context
                                  .read<TicketViewModel>()
                                  .toggleSaved(event.id);
                              showSnack(
                                context,
                                now
                                    ? 'Disimpan ke favorit.'
                                    : 'Dihapus dari favorit.',
                              );
                            },
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        '${event.category} • ${event.organizer}'.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                          color: Color(0xD9FFFFFF),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppFonts.heading,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          height: 1.22,
                          letterSpacing: -0.4,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _PosterLine(
                                  icon: Icons.schedule_rounded,
                                  text: event.timeRange,
                                ),
                                const SizedBox(height: 4),
                                _PosterLine(
                                  icon: Icons.place_outlined,
                                  text: event.location,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton(
                            onPressed: onTap,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.onLight,
                              minimumSize: const Size(84, 42),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
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
      ),
    );
  }
}

/// Satu baris ikon + teks putih di atas foto (maks. 1 baris).
class _PosterLine extends StatelessWidget {
  const _PosterLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.white),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12.5, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tampilan QR (placeholder)
// ---------------------------------------------------------------------------

/// Menggambar pola mirip QR yang selalu sama untuk [data] yang sama.
///
/// CATATAN: ini hanya placeholder visual dan BUKAN kode QR yang bisa dipindai.
/// Untuk produksi, ganti dengan paket `qr_flutter`:
///   QrImageView(data: data, size: size)
class QrCodeView extends StatelessWidget {
  const QrCodeView({super.key, required this.data, this.size = 200});

  final String data;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Kode QR $data',
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _QrPainter(data)),
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  _QrPainter(this.data);

  final String data;

  static const int _modules = 25;

  bool _inFinderZone(int x, int y) {
    return (x < 8 && y < 8) ||
        (x >= _modules - 8 && y < 8) ||
        (x < 8 && y >= _modules - 8);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double cell = size.width / _modules;
    final Paint dark = Paint()..color = AppColors.onLight;
    final Paint light = Paint()..color = Colors.white;

    canvas.drawRect(Offset.zero & size, light);

    int seed = 17;
    for (final int unit in data.codeUnits) {
      seed = (seed * 31 + unit) & 0x7fffffff;
    }

    for (int y = 0; y < _modules; y++) {
      for (int x = 0; x < _modules; x++) {
        seed = (seed * 1103515245 + 12345) & 0x7fffffff;
        if (_inFinderZone(x, y)) continue;
        if (((seed >> 16) & 1) == 0) {
          canvas.drawRect(
            Rect.fromLTWH(x * cell, y * cell, cell + 0.4, cell + 0.4),
            dark,
          );
        }
      }
    }

    void finder(int ox, int oy) {
      canvas.drawRect(
        Rect.fromLTWH(ox * cell, oy * cell, 7 * cell, 7 * cell),
        dark,
      );
      canvas.drawRect(
        Rect.fromLTWH((ox + 1) * cell, (oy + 1) * cell, 5 * cell, 5 * cell),
        light,
      );
      canvas.drawRect(
        Rect.fromLTWH((ox + 2) * cell, (oy + 2) * cell, 3 * cell, 3 * cell),
        dark,
      );
    }

    finder(0, 0);
    finder(_modules - 7, 0);
    finder(0, _modules - 7);
  }

  @override
  bool shouldRepaint(covariant _QrPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}
