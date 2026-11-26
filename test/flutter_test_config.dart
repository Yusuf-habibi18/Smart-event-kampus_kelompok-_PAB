import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

/// Memuat font aplikasi sebelum test dijalankan.
///
/// `flutter test` tidak memuat font dari pubspec secara otomatis, sehingga
/// tanpa langkah ini teks digambar dengan font kotak-kotak yang jauh lebih
/// lebar dan pengecekan overflow menjadi tidak realistis.
/// - Inter & Plus Jakarta Sans: dari assets/fonts (sama dengan aplikasi).
/// - Roboto: dari cache SDK Flutter (dipakai sebagai cadangan).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await _loadFamily('Inter', _assetFonts('Inter-'));
  await _loadFamily('Plus Jakarta Sans', _assetFonts('PlusJakartaSans-'));

  final Directory? materialFonts = _findMaterialFonts();
  if (materialFonts != null) {
    await _loadFamily('Roboto', [
      for (final String file in [
        'roboto-regular.ttf',
        'roboto-medium.ttf',
        'roboto-bold.ttf',
      ])
        File('${materialFonts.path}/$file'),
    ]);
  }
  await testMain();
}

List<File> _assetFonts(String prefix) {
  final Directory dir = Directory('assets/fonts');
  if (!dir.existsSync()) return const [];
  return dir
      .listSync()
      .whereType<File>()
      .where((File f) {
        final String name = f.uri.pathSegments.last;
        return name.startsWith(prefix) && name.endsWith('.ttf');
      })
      .toList();
}

Future<void> _loadFamily(String family, List<File> files) async {
  final FontLoader loader = FontLoader(family);
  bool any = false;
  for (final File font in files) {
    if (!font.existsSync()) continue;
    final Uint8List bytes = font.readAsBytesSync();
    loader.addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
    any = true;
  }
  if (any) await loader.load();
}

/// Mencari folder `bin/cache/artifacts/material_fonts` di instalasi Flutter.
Directory? _findMaterialFonts() {
  final List<String> roots = [
    if (Platform.environment['FLUTTER_ROOT'] != null)
      Platform.environment['FLUTTER_ROOT']!,
  ];
  // flutter_tester berada di <flutter>/bin/cache/artifacts/engine/<os>/.
  Directory dir = File(Platform.resolvedExecutable).parent;
  for (int i = 0; i < 8; i++) {
    roots.add(dir.path);
    dir = dir.parent;
  }
  for (final String root in roots) {
    for (final String sub in [
      'bin/cache/artifacts/material_fonts',
      'cache/artifacts/material_fonts',
      'artifacts/material_fonts',
    ]) {
      final Directory candidate = Directory('$root/$sub');
      if (candidate.existsSync()) return candidate;
    }
  }
  return null;
}
