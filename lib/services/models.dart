import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'dart:async';

import 'authentication.dart';

final uidProvider = Provider<String?>((ref) {
  final user = ref.watch(authUserProvider).asData?.value;
  return user?.uid;
});

final serviceProvider = StreamProvider<QuerySnapshot<Map<String, dynamic>>?>((
  ref,
) {
  final uid = ref.watch(uidProvider);
  return (uid == null)
      ? Stream.value(null)
      : FirebaseFirestore.instance.collection('service').snapshots();
});

final confProvider = Provider<DocumentSnapshot<Map<String, dynamic>>?>((ref) {
  final docs = ref.watch(serviceProvider).asData?.value?.docs;
  return docs == null || docs.any((doc) => doc.id == 'conf') == false
      ? null
      : docs.firstWhere((doc) => doc.id == 'conf');
});

final holidaysProvider =
    Provider<List<DocumentSnapshot<Map<String, dynamic>>>?>((ref) {
      final docs = ref.watch(serviceProvider).asData?.value?.docs;
      return docs == null || docs.any((doc) => doc.id == 'holydays') == false
          ? null
          : docs.where((doc) => RegExp(r'h\s\s\s\s').hasMatch(doc.id)).toList();
    });

final profileProvider = StreamProvider<DocumentSnapshot<Map<String, dynamic>>?>(
  (ref) {
    final uid = ref.watch(uidProvider);
    return (uid == null)
        ? Stream.value(null)
        : FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  },
);

final recordsProvider = StreamProvider<QuerySnapshot<Map<String, dynamic>>?>((
  ref,
) {
  final uid = ref.watch(uidProvider);
  final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
  return (uid == null)
      ? Stream.value(null)
      : userRef.collection('records').snapshots();
});

Future<Either<String, Unit>> deleteUserData(String uid) async {
  try {
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(uid);
    await userDocRef.collection('records').get().then((snapshot) {
      for (final doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
    await userDocRef.delete();
    return right(unit);
  } catch (error, stackTrace) {
    debugPrintStack(
      label: 'Error deleting user data: $error',
      stackTrace: stackTrace,
    );
    return left('Failed to delete user data: $error');
  }
}
