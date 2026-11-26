import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_theme.dart';

// ===========================================================================
// UI KIT — komponen visual bersama
//
// Komponen visual yang dipakai bersama oleh semua modul (Peserta, Ormawa,
// Admin). Halaman cukup menyusun komponen ini; warna, radius, dan jarak
// diatur di sini dan di app_theme.dart.
// ===========================================================================

/// Jarak standar halaman.
class Gap {
  Gap._();

  static const double page = 20;
  static const double section = 40;
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

/// Header terang bergradasi biru lembut di bagian atas tab utama.
///
/// Susunan: [leading] + [actions] di baris atas, lalu [eyebrow], [title]
/// besar, [subtitle], dan [bottom] (mis. kolom pencarian).
class HeroHeader extends StatelessWidget {
  const HeroHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.leading,
    this.actions = const [],
    this.bottom,
  });

  final String title;
  final String? eyebrow;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return SoftBackdrop(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Gap.page, 12, Gap.page, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leading != null || actions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: Row(
                    children: [
                      Expanded(child: leading ?? const SizedBox.shrink()),
                      for (final Widget a in actions) ...[
                        const SizedBox(width: 8),
                        a,
                      ],
                    ],
                  ),
                )
              else
                const SizedBox(height: 20),
              if (eyebrow != null) ...[
                Reveal(index: 0, child: EyebrowText(text: eyebrow!)),
                const SizedBox(height: 10),
              ],
              Reveal(
                index: 1,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: AppFonts.heading,
                    fontSize: 26,
                    height: 1.15,
                    letterSpacing: -0.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Reveal(
                  index: 2,
                  child: Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
              if (bottom != null) ...[
                const SizedBox(height: 24),
                Reveal(index: 3, child: bottom!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Tombol ikon bulat putih bergaris tipis (aksi di header).
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.badge,
    this.dark = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  /// Angka kecil di pojok (mis. jumlah notifikasi).
  final int? badge;

  /// Versi untuk latar gelap.
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final Widget button = Material(
      color: dark ? const Color(0x1AFFFFFF) : AppColors.surface,
      shape: CircleBorder(
        side: BorderSide(
          color: dark ? const Color(0x33FFFFFF) : AppColors.border,
        ),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            size: 21,
            color: dark ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );

    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: badge == null || badge == 0
            ? button
            : Stack(
                clipBehavior: Clip.none,
                children: [
                  _Wiggle(child: button),
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 18),
                      height: 18,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: AppColors.background,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        '$badge',
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Avatar inisial bulat.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.initials,
    this.size = 44,
    this.onDark = false,
  });

  final String initials;
  final double size;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: onDark ? Colors.white : AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Text(
        initials,
        style: TextStyle(
          fontFamily: AppFonts.heading,
          fontSize: size * 0.36,
          fontWeight: FontWeight.w700,
          color: onDark ? AppColors.primary : Colors.white,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tanggal & tiket
// ---------------------------------------------------------------------------

/// Hasil uraian label tanggal ("Sabtu, 24 Mei 2025") untuk [DateBadge].
class DateParts {
  const DateParts(this.day, this.month);

  final String day;
  final String month;

  static const Map<String, String> _months = {
    'januari': 'JAN',
    'februari': 'FEB',
    'maret': 'MAR',
    'april': 'APR',
    'mei': 'MEI',
    'juni': 'JUN',
    'juli': 'JUL',
    'agustus': 'AGU',
    'september': 'SEP',
    'oktober': 'OKT',
    'november': 'NOV',
    'desember': 'DES',
  };

  static DateParts parse(String label) {
    final RegExpMatch? m = RegExp(r'(\d{1,2})\s+([A-Za-z]+)').firstMatch(label);
    if (m == null) return const DateParts('--', '');
    final String month = m.group(2)!.toLowerCase();
    return DateParts(
      m.group(1)!,
      _months[month] ??
          month.substring(0, month.length.clamp(0, 3)).toUpperCase(),
    );
  }
}

/// Blok tanggal bergaya kalender sobek (bulan di atas, tanggal besar).
class DateBadge extends StatelessWidget {
  const DateBadge({
    super.key,
    required this.dateLabel,
    this.size = 56,
    this.onColor = false,
  });

  final String dateLabel;
  final double size;

  /// true = di atas latar berwarna (kotak putih transparan).
  final bool onColor;

  @override
  Widget build(BuildContext context) {
    final DateParts parts = DateParts.parse(dateLabel);
    return Container(
      width: size,
      padding: EdgeInsets.symmetric(vertical: size * 0.12),
      decoration: BoxDecoration(
        color: onColor ? const Color(0x29FFFFFF) : AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(size * 0.22),
        border: Border.all(
          color: onColor ? const Color(0x40FFFFFF) : AppColors.border,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            parts.month,
            style: TextStyle(
              fontSize: size * 0.18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: onColor ? Colors.white : AppColors.glow,
            ),
          ),
          Text(
            parts.day,
            style: TextStyle(
              fontFamily: AppFonts.heading,
              fontSize: size * 0.42,
              height: 1.05,
              fontWeight: FontWeight.w700,
              color: onColor ? Colors.white : AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bentuk kartu tiket: sudut membulat + dua lekukan setengah lingkaran
/// (perforasi). [vertical] = lekukan di sisi atas & bawah pada jarak
/// [notchAt] dari kiri; selain itu di sisi kiri & kanan pada jarak
/// [notchAt] dari atas.
class TicketBorder extends ShapeBorder {
  const TicketBorder({
    this.radius = AppRadius.lg,
    this.notchRadius = 9,
    this.notchAt = 80,
    this.vertical = true,
    this.side = const BorderSide(color: AppColors.border),
  });

  final double radius;
  final double notchRadius;
  final double notchAt;
  final bool vertical;
  final BorderSide side;

  Path _path(Rect r) {
    final Path base = Path()
      ..addRRect(RRect.fromRectAndRadius(r, Radius.circular(radius)));
    final Path notches = Path();
    if (vertical) {
      final double x = r.left + notchAt;
      notches
        ..addOval(
          Rect.fromCircle(center: Offset(x, r.top), radius: notchRadius),
        )
        ..addOval(
          Rect.fromCircle(center: Offset(x, r.bottom), radius: notchRadius),
        );
    } else {
      final double y = r.top + notchAt;
      notches
        ..addOval(
          Rect.fromCircle(center: Offset(r.left, y), radius: notchRadius),
        )
        ..addOval(
          Rect.fromCircle(center: Offset(r.right, y), radius: notchRadius),
        );
    }
    return Path.combine(PathOperation.difference, base, notches);
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      _path(rect.deflate(side.width));

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) => _path(rect);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none || side.width == 0) return;
    canvas.drawPath(_path(rect.deflate(side.width / 2)), side.toPaint());
  }

  @override
  ShapeBorder scale(double t) => TicketBorder(
    radius: radius * t,
    notchRadius: notchRadius * t,
    notchAt: notchAt * t,
    vertical: vertical,
    side: side.scale(t),
  );
}

/// Garis putus-putus (perforasi tiket).
class DashedLine extends StatelessWidget {
  const DashedLine({
    super.key,
    this.vertical = false,
    this.color = AppColors.border,
  });

  final bool vertical;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final double length = vertical ? c.maxHeight : c.maxWidth;
        final int count = (length / 9).floor().clamp(1, 400);
        final List<Widget> dashes = List<Widget>.generate(
          count,
          (_) => SizedBox(
            width: vertical ? 1.5 : 5,
            height: vertical ? 5 : 1.5,
            child: DecoratedBox(decoration: BoxDecoration(color: color)),
          ),
        );
        return Flex(
          direction: vertical ? Axis.vertical : Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: dashes,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Kartu & panel
// ---------------------------------------------------------------------------

/// Chip kecil berikon (meta event: jam, lokasi, kuota).
class MetaChip extends StatelessWidget {
  const MetaChip({
    super.key,
    required this.icon,
    required this.text,
    this.color = AppColors.textSecondary,
    this.background = AppColors.surfaceLow,
  });

  final IconData icon;
  final String text;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kotak ikon persegi membulat berlatar biru muda.
class IconSquare extends StatelessWidget {
  const IconSquare({
    super.key,
    required this.icon,
    this.size = 44,
    this.color = AppColors.primary,
    this.background = AppColors.primarySoft,
  });

  final IconData icon;
  final double size;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(icon, size: size * 0.48, color: color),
    );
  }
}

/// Panel gelap untuk SATU ajakan utama per layar, dengan lingkaran
/// dekoratif datar di latar.
class CtaBand extends StatelessWidget {
  const CtaBand({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(22),
    this.color = AppColors.primary,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: color == AppColors.primary
          ? AppDecorations.brandPanel()
          : BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
      child: child,
    );
  }
}

/// Panel biru muda bergaris (info penting yang bukan peringatan).
class SoftPanel extends StatelessWidget {
  const SoftPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.primaryTint),
      ),
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// Daftar menu (pengaturan, profil)
// ---------------------------------------------------------------------------

/// Kartu putih berisi beberapa [ListRow] dengan pemisah tipis.
class ListGroup extends StatelessWidget {
  const ListGroup({super.key, required this.children, this.title});

  final List<Widget> children;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              title!.toUpperCase(),
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: AppColors.textMuted,
              ),
            ),
          ),
        Container(
          decoration: AppDecorations.card(),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                if (i > 0) const Divider(indent: 72),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Satu baris menu: ikon, judul, keterangan, dan [trailing].
class ListRow extends StatelessWidget {
  const ListRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor = AppColors.primary,
    this.iconBackground = AppColors.primarySoft,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color iconColor;
  final Color iconBackground;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            IconSquare(
              icon: icon,
              size: 40,
              color: iconColor,
              background: iconBackground,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.4,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 12),
              trailing!,
            ] else if (onTap != null) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// TabBar bergaya segmen: kotak putih bergaris, tab aktif terisi biru. Dipakai bersama [DefaultTabController].
class SegmentTabBar extends StatelessWidget {
  const SegmentTabBar({super.key, required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: AppDecorations.card(radius: AppRadius.md),
      child: TabBar(
        tabs: [for (final String l in labels) Tab(text: l)],
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textMuted,
        labelPadding: EdgeInsets.zero,
        labelStyle: const TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
        ),
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Navigasi bawah mengambang
// ---------------------------------------------------------------------------

class FloatingNavItem {
  const FloatingNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.badge,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int? badge;
}

/// Bilah navigasi berbentuk kapsul putih yang mengambang di atas latar.
/// Label selalu tampil agar mudah dipahami pengguna baru.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<FloatingNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
          child: Container(
            height: 68,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
              boxShadow: AppShadows.raised,
            ),
            child: Row(
              children: [
                for (int i = 0; i < items.length; i++)
                  Expanded(
                    child: _NavButton(
                      item: items[i],
                      selected: i == selectedIndex,
                      onTap: () => onSelected(i),
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

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final FloatingNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = selected ? AppColors.glow : AppColors.textMuted;
    Widget icon = AnimatedScale(
      scale: selected ? 1.08 : 1,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutBack,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 28,
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          selected ? item.selectedIcon : item.icon,
          size: 22,
          color: color,
        ),
      ),
    );
    if ((item.badge ?? 0) > 0) {
      icon = Badge(
        label: Text('${item.badge}'),
        backgroundColor: AppColors.danger,
        child: icon,
      );
    }

    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(height: 4),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Latar & label
// ---------------------------------------------------------------------------

/// Latar header: gradasi biru sangat muda yang memudar ke warna halaman.
/// [onColor] = di atas kartu berwarna (tanpa gradasi).
class SoftBackdrop extends StatelessWidget {
  const SoftBackdrop({super.key, required this.child, this.onColor = false});

  final Widget child;
  final bool onColor;

  @override
  Widget build(BuildContext context) {
    if (onColor) return SizedBox(width: double.infinity, child: child);
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFEAF1FD), AppColors.background],
        ),
      ),
      child: child,
    );
  }
}

/// Label kecil berhuruf kapital di atas judul (eyebrow).
class EyebrowText extends StatelessWidget {
  const EyebrowText({
    super.key,
    required this.text,
    this.color = AppColors.primary,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
        color: color,
      ),
    );
  }
}

/// Teks keterangan kecil (kode/ID, jumlah) dengan angka sejajar.
class CaptionText extends StatelessWidget {
  const CaptionText(
    this.text, {
    super.key,
    this.size = 12,
    this.color = AppColors.textMuted,
    this.weight = FontWeight.w500,
  });

  final String text;
  final double size;
  final Color color;
  final FontWeight weight;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size,
        fontWeight: weight,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Gambar
// ---------------------------------------------------------------------------

/// Foto event dari asset. Jika [path] kosong atau gagal dimuat, tampil
/// blok warna [color] dengan ikon [icon] sebagai pengganti.
class EventImage extends StatelessWidget {
  const EventImage({
    super.key,
    required this.path,
    required this.color,
    required this.icon,
    this.semanticLabel,
  });

  final String? path;
  final Color color;
  final IconData icon;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final Widget fallback = ColoredBox(
      color: color,
      child: Center(
        child: Icon(icon, size: 56, color: Colors.white.withAlpha(90)),
      ),
    );
    if (path == null) return fallback;
    return Image.asset(
      path!,
      fit: BoxFit.cover,
      semanticLabel: semanticLabel,
      errorBuilder: (BuildContext _, Object _, StackTrace? _) => fallback,
    );
  }
}

/// Gradasi gelap di atas foto agar teks putih tetap terbaca.
class PhotoScrim extends StatelessWidget {
  const PhotoScrim({super.key, this.strength = 0xB3});

  /// Kepekatan di bagian bawah (0-255).
  final int strength;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.ink.withAlpha(20),
            AppColors.ink.withAlpha(strength),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Interaksi & animasi
//
// Semua animasi otomatis dilewati bila pengguna mengaktifkan "kurangi
// animasi" di perangkat (MediaQuery.disableAnimations).
// ---------------------------------------------------------------------------

bool _reduceMotion(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// Efek tekan: anak sedikit mengecil saat disentuh dan kembali saat dilepas,
/// disertai getaran halus. Tidak mengganggu onTap milik anaknya.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, this.scale = 0.97});

  final Widget child;
  final double scale;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (_down == v) return;
    setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        _set(true);
        HapticFeedback.selectionClick();
      },
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _down && !_reduceMotion(context) ? widget.scale : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Animasi muncul: memudar sambil naik sedikit. [index] memberi jeda
/// bertahap untuk item daftar (tanpa Timer, aman untuk test).
class Reveal extends StatefulWidget {
  const Reveal({super.key, required this.child, this.index = 0});

  final Widget child;
  final int index;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  static const int _base = 420;
  static const int _step = 70;
  late final AnimationController _c;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();
    final int delay = (widget.index.clamp(0, 6)) * _step;
    _c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _base + delay),
    );
    _t = CurvedAnimation(
      parent: _c,
      curve: Interval(delay / (_base + delay), 1, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_reduceMotion(context)) {
      _c.value = 1;
    } else if (!_c.isAnimating && _c.value == 0) {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (BuildContext context, Widget? child) {
        return Opacity(
          opacity: _t.value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - _t.value)),
            child: child,
          ),
        );
      },
    );
  }
}

/// Angka yang menghitung naik dari 0 ke [value] saat pertama tampil.
class CountUp extends StatelessWidget {
  const CountUp({
    super.key,
    required this.value,
    required this.style,
    this.suffix = '',
  });

  final int value;
  final String suffix;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    if (_reduceMotion(context)) return Text('$value$suffix', style: style);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double v, Widget? _) =>
          Text('${v.round()}$suffix', style: style),
    );
  }
}

/// Tombol hati untuk menyimpan event. Ikon memantul saat berganti status.
class SaveButton extends StatelessWidget {
  const SaveButton({
    super.key,
    required this.saved,
    required this.onPressed,
    this.size = 38,
  });

  final bool saved;
  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: saved,
      label: saved ? 'Hapus dari favorit' : 'Simpan ke favorit',
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 0,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
          child: SizedBox(
            width: size,
            height: size,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              transitionBuilder: (Widget child, Animation<double> a) =>
                  ScaleTransition(
                    scale: CurvedAnimation(parent: a, curve: Curves.elasticOut),
                    child: child,
                  ),
              child: Icon(
                saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                key: ValueKey<bool>(saved),
                size: size * 0.5,
                color: saved ? AppColors.danger : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Goyangan singkat sekali jalan (mis. lonceng saat ada notifikasi baru).
class _Wiggle extends StatelessWidget {
  const _Wiggle({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (_reduceMotion(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1100),
      curve: const Interval(0.35, 1),
      child: child,
      builder: (BuildContext context, double t, Widget? child) {
        final double angle = math.sin(t * math.pi * 6) * 0.22 * (1 - t);
        return Transform.rotate(angle: angle, child: child);
      },
    );
  }
}

/// Isi tab memudar & bergeser sedikit setiap kali [index] berubah.
/// State tiap tab tetap terjaga (dipakai di sekitar IndexedStack).
class TabFade extends StatefulWidget {
  const TabFade({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<TabFade> createState() => _TabFadeState();
}

class _TabFadeState extends State<TabFade> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
    value: 1,
  );
  late final Animation<double> _t = CurvedAnimation(
    parent: _c,
    curve: Curves.easeOutCubic,
  );

  @override
  void didUpdateWidget(covariant TabFade old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index && !_reduceMotion(context)) {
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _t,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.015),
          end: Offset.zero,
        ).animate(_t),
        child: widget.child,
      ),
    );
  }
}

/// Bilah progres yang terisi pelan dan beranimasi saat nilainya berubah.
class AnimatedProgress extends StatelessWidget {
  const AnimatedProgress({
    super.key,
    required this.value,
    this.minHeight = 6,
    this.backgroundColor = AppColors.surfaceHigh,
    this.color = AppColors.primary,
  });

  final double value;
  final double minHeight;
  final Color backgroundColor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.clamp(0, 1).toDouble()),
      duration: _reduceMotion(context)
          ? Duration.zero
          : const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double v, Widget? _) =>
          LinearProgressIndicator(
            value: v,
            minHeight: minHeight,
            backgroundColor: backgroundColor,
            color: color,
          ),
    );
  }
}

/// Ikon sukses: lingkaran hijau yang membesar memantul lalu centang muncul.
class SuccessBurst extends StatelessWidget {
  const SuccessBurst({
    super.key,
    this.icon = Icons.check_rounded,
    this.size = 64,
  });

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final Widget badge = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.successSoft,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.success.withAlpha(60), width: 6),
      ),
      child: Icon(icon, size: size * 0.5, color: AppColors.success),
    );
    if (_reduceMotion(context)) return badge;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.elasticOut,
      child: badge,
      builder: (BuildContext context, double t, Widget? child) =>
          Transform.scale(scale: 0.4 + 0.6 * t, child: child),
    );
  }
}

/// Ikon di tampilan kosong yang muncul memantul sekali.
class PopIn extends StatelessWidget {
  const PopIn({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (_reduceMotion(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      child: child,
      builder: (BuildContext context, double t, Widget? child) => Opacity(
        opacity: t.clamp(0, 1).toDouble(),
        child: Transform.scale(scale: 0.6 + 0.4 * t, child: child),
      ),
    );
  }
}
