import 'package:ak_chat_app/pages/chat_page.dart';
import 'package:ak_chat_app/pages/login_page.dart';
import 'package:ak_chat_app/widgets/constans.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage();

  static String id = 'Splash Screen';
  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  @override
  void initState() {
    navigate();
    super.initState();
  }

  void navigate() async {
    await Future.delayed(const Duration(seconds: 3));

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      final userName = userDoc.data()?['userName'] ?? '';
      String color = userDoc.data()?['color'] ?? '0xffFFFFFF';
      String argumentID = user.uid;

      Navigator.pushReplacementNamed(
        context,
        ChatPage.id,
        arguments: {
          'email': user.email,
          'userName': userName,
          'argumentID': argumentID,
          'color': color,
        },
      );
    } else {
      Navigator.pushReplacementNamed(context, LoginPage.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPraimaryColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/scholar.png', scale: 0.4),

            Text(
              'Academic Chat',
              style: TextStyle(
                color: Colors.white,
                fontSize: 43,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
