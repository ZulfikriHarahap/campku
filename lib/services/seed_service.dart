import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:campku/data/camp_data.dart';
import 'package:campku/data/destinations_data.dart';
import 'package:campku/data/tent_data.dart';

/// Mengisi Firestore dengan data contoh. Jalankan sekali saja:
/// `flutter run --dart-define=SEED=true`
///
/// Field `order` menjaga urutan tampil sama seperti daftar data contoh.
Future<void> seedFirestore() async {
  final db = FirebaseFirestore.instance;
  final batch = db.batch();

  for (var i = 0; i < kDestinations.length; i++) {
    final d = kDestinations[i];
    batch.set(
      db.collection('destinations').doc(d.slug),
      {...d.toMap(), 'order': i},
    );
  }
  for (var i = 0; i < kCamps.length; i++) {
    final c = kCamps[i];
    batch.set(db.collection('camps').doc(c.id), {...c.toMap(), 'order': i});
  }
  for (var i = 0; i < kTentTypes.length; i++) {
    final t = kTentTypes[i];
    batch.set(
      db.collection('tent_types').doc(t.id),
      {...t.toMap(), 'order': i},
    );
  }

  await batch.commit();
}
