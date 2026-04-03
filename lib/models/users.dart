import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'dart:async';

import '../services/authentication.dart';
import '../services/authorization.dart';

class User {
  final String name;

  User({required this.name});

  factory User.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return User(name: data['name'] as String);
  }
}

final usersRef = FirebaseFirestore.instance.collection('users');

final uidProvider = Provider<String?>((ref) {
  final user = ref.watch(authUserProvider).asData?.value;
  return user?.uid;
});

final userProvider = StreamProvider<List<User>>((ref) {
  final uid = ref.watch(uidProvider);
  return switch (ref.watch(privilegeProvider)) {
    Privilege.loading => Stream.value([]),
    Privilege.guest => Stream.value([]),
    Privilege.user =>
      usersRef.doc(uid).snapshots().map((doc) => [User.fromDocument(doc)]),
    Privilege.admin => usersRef.snapshots().map(
      (snapshot) => snapshot.docs.map(User.fromDocument).toList(),
    ),
  };
});

final recordsProvider = StreamProvider<QuerySnapshot<Map<String, dynamic>>?>((
  ref,
) {
  final uid = ref.watch(uidProvider);
  final userRef = usersRef.doc(uid);
  return (uid == null)
      ? Stream.value(null)
      : userRef.collection('records').snapshots();
});

Future<Either<String, Unit>> deleteUserData(String uid) async {
  try {
    final userRef = usersRef.doc(uid);
    await userRef.collection('records').get().then((snapshot) {
      for (final doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
    await userRef.delete();
    return right(unit);
  } catch (error, stackTrace) {
    debugPrintStack(
      label: 'Error deleting user data: $error',
      stackTrace: stackTrace,
    );
    return left('$error');
  }
}
