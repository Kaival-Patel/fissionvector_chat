import 'package:fissionvector_chat/firebase/chat_query.dart';
import 'package:fissionvector_chat/modules/user_listing/users_listing.dart';
import 'package:fissionvector_chat/repository/repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectionScreen extends StatelessWidget {
  const SelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select your user type'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton(
                onPressed: () {
                  authRepo.userDm(authRepo.users.first);
                  Get.to(() => UsersList());
                },
                child: const Text('Continue as student')),
            OutlinedButton(
                onPressed: () async {
                  final res = await Get.bottomSheet(UserChangeDialog()) ??
                      authRepo.users.last;
                  authRepo.userDm(res);
                  Get.to(() => UsersList());
                },
                child: const Text('Continue as tutor')),
          ],
        ),
      ),
    );
  }
}

class UserChangeDialog extends StatelessWidget {
  UserChangeDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final users =
        authRepo.users.where((p0) => p0.subject != 'Student').toList();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.amber[200],
      ),
      padding: const EdgeInsets.all(10),
      child: ListView.builder(
        itemBuilder: (context, index) => ListTile(
          onTap: () {
            Get.back(result: users[index]);
          },
          title: Text(users[index].name),
          subtitle: Text(
              users[index].subject.capitalizeFirst ?? '' ' (Tap to change)'),
        ),
        itemCount: users.length,
      ),
    );
  }
}
