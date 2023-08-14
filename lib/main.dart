import 'package:firebase_core/firebase_core.dart';
import 'package:fissionvector_chat/modules/user_selection/user_selection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey:
              'AAAAIHHtZD8:APA91bF8yf7KGxx0BZI7w0gyu0-lb-fJDuYBwOva9UW2ZX6-y4II0Ho-0FN9Y1jUAJok7cLCU0iVjQ4E4HahYFTv3VY5lFISBibc3MZuc24l97idoVBfa-bEw6e3yviwGvsZ76BUiKUJ',
          appId: '1:139350336575:android:d51039eaa13bb8df36048a',
          messagingSenderId: '139350336575',
          projectId: 'fissionvector-ca585'));
  runApp(const MyApp());
}

void hideKeyBoard(BuildContext context) {
  FocusScope.of(context).requestFocus(FocusNode());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => hideKeyBoard(context),
      child: Builder(builder: (context) {
        return GetMaterialApp(
          enableLog: kDebugMode,
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.light,
          theme: ThemeData(
              colorScheme: const ColorScheme.light(primary: Colors.amber)),
          title: 'Agora FissionVector',
          home: const SelectionScreen(),
        );
      }),
    );
  }
}
