// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_chat_app/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

class LoginController with ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  //login method
  void login(BuildContext context) async {
    //auth service
    final authService = Provider.of<AuthService>(context, listen: false);

    //try login
    try {
      await authService.signInWithEmailPassword(
          emailController.text, passController.text);
    }

    //catch any errors
    catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}
