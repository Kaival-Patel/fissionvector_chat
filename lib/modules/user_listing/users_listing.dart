import 'dart:math';

import 'package:fissionvector_chat/firebase/user_query.dart';
import 'package:fissionvector_chat/models/chat.dart';
import 'package:fissionvector_chat/models/user.dart';
import 'package:fissionvector_chat/modules/chats/chat.dart';
import 'package:fissionvector_chat/modules/user_listing/users_listing_controller.dart';
import 'package:fissionvector_chat/repository/repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

class UsersList extends StatefulWidget {
  UsersList({Key? key}) : super(key: key);

  @override
  State<UsersList> createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  final c = Get.put(UsersListingController());

  @override
  Widget build(BuildContext context) {
    timeago.setLocaleMessages('en', MyCustomMessages());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutors'),
        actions: [
          Obx(
            () => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(c.isOnline() ? 'Online' : 'Offline'),
                CupertinoSwitch(
                  value: c.isOnline(),
                  onChanged: (v) {
                    c.updateAvailability();
                  },
                )
              ],
            ),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Container(
            color: Colors.grey[100],
            height: 40,
            child: Obx(() => Center(
                  child: Text(
                      'You are ${authRepo.userDm().name} and Agora ID : ${authRepo.userDm().uid}'),
                )),
          ),
        ),
      ),
      body: Obx(
        () => Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.separated(
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                if (c.chats[index].isDeletedByMe) {
                  return const SizedBox.shrink();
                }
                return ChatListCard(chatModel: c.chats[index]);
              },
              separatorBuilder: (context, index) {
                return const SizedBox(
                  height: 10,
                );
              },
              itemCount: c.chats.length),
        ),
      ),
    );
  }
}

class ChatListCard extends StatelessWidget {
  ChatListCard({Key? key, required this.chatModel}) : super(key: key);
  final ChatModel chatModel;
  final c = Get.find<UsersListingController>();

  @override
  Widget build(BuildContext context) {
    if (chatModel.senderUid != null) {
      debugPrint(chatModel.senderUid!.toString());
      return StreamBuilder(
        builder: (context, snapshot) {
          if (snapshot.hasData && !snapshot.hasError && snapshot.data != null) {
            final user = UserDm.fromJson(snapshot.data!.data()!);
            return ListTile(
              onTap: () {
                Get.to(
                  () => ChatScreen(userDm: user, chatDocId: chatModel.docId),
                );
              },
              leading: CircleAvatar(
                  key: ValueKey(user.uid),
                  backgroundImage: NetworkImage(
                      user.profile),
                  radius: 50),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(user.name),
                  const SizedBox(
                    width: 5,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                    decoration: BoxDecoration(
                        color: user.isOnline
                            ? Colors.green[700]
                            : Colors.grey[600],
                        borderRadius: BorderRadius.circular(5)),
                    child: Text(
                      user.isOnline ? "ONLINE" : "OFFLINE",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              trailing: Text(
                timeago.format(DateTime.now().subtract(
                  DateTime.now().difference(user.lastOnline!.toDate()),
                )),
                style: const TextStyle(
                  fontSize: 11,
                ),
              ),
              subtitle: Row(
                children: [
                  Expanded(child: Text(chatModel.lastMsg)),
                  if (chatModel.unreadCount > 0) ...[
                    const SizedBox(
                      width: 10,
                    ),
                    CircleAvatar(
                      radius: 10,
                      child: Text(
                        chatModel.unreadCount.toString(),
                        style: TextStyle(fontSize: 11),
                      ),
                    )
                  ]
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
        stream: UserQuery().streamUserInfo(uid: chatModel.senderUid!),
      );
    }
    return const SizedBox.shrink();
  }
}

// my_custom_messages.dart
class MyCustomMessages implements timeago.LookupMessages {
  @override
  String prefixAgo() => '';

  @override
  String prefixFromNow() => '';

  @override
  String suffixAgo() => '';

  @override
  String suffixFromNow() => '';

  @override
  String lessThanOneMinute(int seconds) => 'now';

  @override
  String aboutAMinute(int minutes) => '${minutes}m';

  @override
  String minutes(int minutes) => '${minutes}m';

  @override
  String aboutAnHour(int minutes) => '${minutes}m';

  @override
  String hours(int hours) => '${hours}h';

  @override
  String aDay(int hours) => '${hours}h';

  @override
  String days(int days) => '${days}d';

  @override
  String aboutAMonth(int days) => '${days}d';

  @override
  String months(int months) => '${months}mo';

  @override
  String aboutAYear(int year) => '${year}y';

  @override
  String years(int years) => '${years}y';

  @override
  String wordSeparator() => ' ';
}
