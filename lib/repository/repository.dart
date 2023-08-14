import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fissionvector_chat/models/user.dart';
import 'package:get/get.dart';

final authRepo = Get.put(AuthRepository());

class AuthRepository {
  Rx<UserDm> userDm = UserDm().obs;
  RxList<UserDm> users = [
    UserDm(
        uid: 1,
        isOnline: false,
        lastOnline: Timestamp.now(),
        name: 'Heeren',
        subject: 'Student'),
    UserDm(
        uid: 2,
        isOnline: false,
        lastOnline: Timestamp.now(),
        name: 'Hemlata jain',
        subject: 'Science'),
    UserDm(
        uid: 3,
        isOnline: false,
        lastOnline: Timestamp.now(),
        name: 'Savita Hirani',
        subject: 'Maths'),
    UserDm(
        uid: 4,
        isOnline: false,
        lastOnline: Timestamp.now(),
        name: 'Ramila vaghani',
        subject: 'Biology'),
    UserDm(
        uid: 5,
        isOnline: false,
        lastOnline: Timestamp.now(),
        name: 'Jyotsna Pandya',
        subject: 'History'),
    UserDm(
        uid: 6,
        isOnline: false,
        lastOnline: Timestamp.now(),
        name: 'Manjula Makadiya',
        subject: 'Geography'),
  ].obs;
}
