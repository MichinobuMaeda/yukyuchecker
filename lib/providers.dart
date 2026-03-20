import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final authUserProvider = StreamProvider<User?>(
  (_) => FirebaseAuth.instance.authStateChanges(),
);

final confProvider = StreamProvider<DocumentSnapshot<Map<String, dynamic>>?>((
  ref,
) {
  final user = ref.watch(authUserProvider).asData?.value;
  return (user == null)
      ? Stream.value(null)
      : FirebaseFirestore.instance
            .collection('service')
            .doc('conf')
            .snapshots();
});

final profileProvider = StreamProvider<DocumentSnapshot<Map<String, dynamic>>?>(
  (ref) {
    final user = ref.watch(authUserProvider).asData?.value;
    return (user == null)
        ? Stream.value(null)
        : FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots();
  },
);

final recordsProvider = StreamProvider<QuerySnapshot<Map<String, dynamic>>?>((
  ref,
) {
  final user = ref.watch(authUserProvider).asData?.value;
  return (user == null)
      ? Stream.value(null)
      : FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('records')
            .snapshots();
});
