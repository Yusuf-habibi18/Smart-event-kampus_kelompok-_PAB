import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

/// Memuat font Roboto (bawaan SDK Flutter) sebelum test dijalankan.
///
/// Font "Inter" & "Plus Jakarta Sans" belum dibundel di pubspec, sehingga di
/// Android aplikasi tampil dengan Roboto. Tanpa langkah ini, `flutter test`
/// memakai font kotak-kotak yang jauh lebih lebar dan pengecekan overflow
/// menjadi tidak realistis.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final Directory? fontsDir = _findMaterialFonts();
  if (fontsDir != null) {
    const List<String> weights = [
      'roboto-regular.ttf',
      'roboto-medium.ttf',
      'roboto-bold.ttf',
      'roboto-black.ttf',
      'roboto-italic.ttf',
    ];
    for (final String family in ['Inter', 'Plus Jakarta Sans', 'Roboto']) {
      final FontLoader loader = FontLoader(family);
      for (final String file in weights) {
        final File font = File('${fontsDir.path}/$file');
        if (font.existsSync()) {
          final Uint8List bytes = font.readAsBytesSync();
          loader.addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
        }
      }
      await loader.load();
    }
  }
  await testMain();
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
