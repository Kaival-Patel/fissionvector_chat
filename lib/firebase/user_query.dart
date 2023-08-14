import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fissionvector_chat/models/user.dart';
import 'package:fissionvector_chat/repository/repository.dart';

class UserQuery {
  final CollectionReference<Map<String, dynamic>> userColRef =
      FirebaseFirestore.instance.collection('users');

  Future<void> generateDummyUsers() async {
    ;
    for (var i = 0; i < authRepo.users.length; ++i) {
      await userColRef
          .doc(authRepo.users[i].uid.toString())
          .set(authRepo.users[i].toJson());
    }
  }

  Future<UserDm> getUserInfoFromUid({required int uid}) async {
    final user = await userColRef.doc(uid.toString()).get();
    if (user.data() != null) {
      return UserDm.fromJson(user.data()!);
    }
    // By default dummy model;
    return UserDm();
  }

  Future<void> updateUserInfo({required UserDm userDm}) async {
    return await userColRef.doc(userDm.uid.toString()).set(userDm.toJson());
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamUserInfo(
      {required int uid}) {
    return userColRef.doc(uid.toString()).snapshots();
  }
}
