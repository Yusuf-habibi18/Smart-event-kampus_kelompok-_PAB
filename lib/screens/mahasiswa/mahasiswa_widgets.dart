import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/campus_event.dart';
import '../../models/event_ticket.dart';
import 'detail_event_page.dart';
import 'tiket_event_page.dart';

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
void openEventDetail(BuildContext context, CampusEvent event) {
  Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (BuildContext context) => DetailEventPage(event: event),
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
}

CategoryStyle categoryStyle(String category) {
  switch (category) {
    case 'Kompetisi':
      return const CategoryStyle(
        [Color(0xFF0F766E), Color(0xFF14B8A6)],
        Icons.emoji_events_rounded,
      );
    case 'Seni & Musik':
      return const CategoryStyle(
        [Color(0xFF9D174D), Color(0xFFEC4899)],
        Icons.palette_rounded,
      );
    case 'Workshop':
      return const CategoryStyle(
        [Color(0xFF92400E), Color(0xFFD97706)],
        Icons.design_services_rounded,
      );
    default:
      return const CategoryStyle(
        [AppColors.navyLight, AppColors.navy],
        Icons.school_rounded,
      );
  }
}

// ---------------------------------------------------------------------------
// Header & section
// ---------------------------------------------------------------------------

/// AppBar standar halaman: judul + subjudul opsional + tombol kembali.
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

  static const double _toolbarHeight = 64;

  @override
  Size get preferredSize => Size.fromHeight(
        _toolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: _toolbarHeight,
      automaticallyImplyLeading: false,
      titleSpacing: showBack ? 0 : 20,
      leading: showBack ? const BackButton() : null,
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
                fontFamily: AppFonts.body,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
                color: AppColors.textMuted,
              ),
            ),
        ],
      ),
      actions: [...actions, const SizedBox(width: 8)],
      bottom: bottom,
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.trailingText,
    this.onTrailingTap,
  });

  final String title;
  final String? trailingText;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: AppFonts.heading,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
        ),
        if (trailingText != null)
          onTrailingTap == null
              ? Text(
                  trailingText!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                )
              : TextButton(
                  onPressed: onTrailingTap,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 32),
                  ),
                  child: Text(trailingText!),
                ),
      ],
    );
  }
}

class PillBadge extends StatelessWidget {
  const PillBadge({
    super.key,
    required this.text,
    this.background = AppColors.accentSoft,
    this.foreground = AppColors.accentDark,
    this.icon,
  });

  final String text;
  final Color background;
  final Color foreground;
  final IconData? icon;

  const PillBadge.success({super.key, required this.text, this.icon})
      : background = AppColors.successSoft,
        foreground = AppColors.success;

  const PillBadge.glass({super.key, required this.text, this.icon})
      : background = const Color(0x33FFFFFF),
        foreground = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
          Icon(icon, size: 44, color: AppColors.textMuted),
          const SizedBox(height: 12),
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
    this.padding = const EdgeInsets.all(16),
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

class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event, required this.onTap});

  final CampusEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CategoryStyle style = categoryStyle(event.category);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 104,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: style.colors,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -10,
                    bottom: -18,
                    child: Icon(
                      style.icon,
                      size: 110,
                      color: Colors.white.withAlpha(46),
                    ),
                  ),
                  const Positioned(
                    left: 14,
                    top: 14,
                    child: PillBadge.glass(text: 'Pendaftaran Buka'),
                  ),
                  Positioned(
                    right: 14,
                    top: 14,
                    child: PillBadge(text: event.pointsLabel),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.organizer,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppFonts.heading,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InfoLine(
                    icon: Icons.event_rounded,
                    text: event.dateTimeShort,
                  ),
                  const SizedBox(height: 6),
                  InfoLine(
                    icon: Icons.place_rounded,
                    text: event.location,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.quotaLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                      const Text(
                        'Lihat Detail',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: AppColors.navy,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
    final Paint dark = Paint()..color = AppColors.textPrimary;
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