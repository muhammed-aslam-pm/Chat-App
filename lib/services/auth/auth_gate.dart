import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/services/auth/login_or_register.dart';

import '../../view/home_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  //listening to the changes whether the user is signed in or not
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          //check if the user is logged in
          if (snapshot.hasData) {
            return const HomeScreen();
          }

          //user is not logged in
          else {
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}
