import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:campku/data/destinations_data.dart';

Destination _sample({Uint8List? image}) => Destination(
      slug: 'bukit_contoh',
      name: 'Bukit Contoh',
      category: 'Gunung',
      description: 'Bukit contoh untuk pengujian foto destinasi.',
      imageBytes: image,
    );

void main() {
  group('Foto destinasi di database', () {
    test('foto disimpan sebagai base64 dan terbaca kembali sama persis', () {
      final bytes = Uint8List.fromList([0, 1, 2, 127, 128, 255]);
      final map = _sample(image: bytes).toMap();

      expect(map['image'], isA<String>());
      final back = Destination.fromMap('bukit_contoh', map);
      expect(back.imageBytes, bytes);
      expect(back.name, 'Bukit Contoh');
    });

    test('tanpa foto, field image tidak ditulis', () {
      final map = _sample().toMap();
      expect(map.containsKey('image'), isFalse);
      expect(Destination.fromMap('bukit_contoh', map).imageBytes, isNull);
    });

    test('data foto rusak dianggap tanpa foto (tidak membuat error)', () {
      final d = Destination.fromMap('bukit_contoh', {
        'name': 'Bukit Contoh',
        'category': 'Gunung',
        'description': 'Bukit contoh untuk pengujian foto destinasi.',
        'image': '%%% bukan base64 %%%',
      });
      expect(d.imageBytes, isNull);
    });
  });
}
