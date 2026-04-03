import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:async';

import '../services/authentication.dart';

final confRef = FirebaseFirestore.instance.collection('service').doc('conf');

final uidProvider = Provider<String?>((ref) {
  final user = ref.watch(authUserProvider).asData?.value;
  return user?.uid;
});

final confProvider = StreamProvider<DocumentSnapshot<Map<String, dynamic>>?>((
  ref,
) {
  final uid = ref.watch(uidProvider);
  return (uid == null) ? Stream.value(null) : confRef.snapshots();
});

final adminsProvider = Provider<List<String>>((ref) {
  final conf = ref.watch(confProvider).asData?.value;
  final data = conf?.data();
  return (data != null && data['admins'] is List)
      ? List<String>.from(data['admins'])
      : [];
});

final uiVersionProvider = Provider<String?>((ref) {
  final conf = ref.watch(confProvider).asData?.value;
  final data = conf?.data();
  return (data != null && data['uiVersion'] is String)
      ? data['uiVersion']
      : null;
});
