import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('presentation layer does not import Firebase packages', () {
    final presentationFiles = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where(
          (file) =>
              file.path.endsWith('.dart') &&
              file.path.split(Platform.pathSeparator).contains('presentation'),
        );

    const forbiddenImports = [
      "import 'package:firebase_core/",
      "import 'package:firebase_auth/",
      "import 'package:cloud_firestore/",
      'import "package:firebase_core/',
      'import "package:firebase_auth/',
      'import "package:cloud_firestore/',
    ];

    final violations = <String>[];

    for (final file in presentationFiles) {
      final contents = file.readAsStringSync();

      for (final forbiddenImport in forbiddenImports) {
        if (contents.contains(forbiddenImport)) {
          violations.add('${file.path}: $forbiddenImport');
        }
      }
    }

    expect(violations, isEmpty);
  });
}
