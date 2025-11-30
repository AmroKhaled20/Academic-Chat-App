import 'package:ak_chat_app/pages/chat_page.dart';
import 'package:ak_chat_app/pages/login_page.dart';
import 'package:ak_chat_app/pages/signUp_page.dart';
import 'package:ak_chat_app/pages/splash_screen_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        LoginPage.id: (context) => LoginPage(),
        SignupPage.id: (context) => SignupPage(),
        ChatPage.id: (context) => ChatPage(),
        SplashScreenPage.id: (context) => SplashScreenPage(),
      },
      debugShowCheckedModeBanner: false,
      initialRoute: 'Splash Screen',
      // initialRoute: 'Test Page',
    );
  }
}
