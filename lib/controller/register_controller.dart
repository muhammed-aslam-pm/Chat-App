import 'package:flutter/material.dart';
import 'package:flutter_chat_app/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

class RegisterController with ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController confirmpassController = TextEditingController();

  //register method --1
  void register(BuildContext context) async {
    //get auth service ---2
    final authservice = Provider.of<AuthService>(context, listen: false);

    //passwords match => create user
    if (passController.text == confirmpassController.text) {
      try {
        authservice.signUpWithEmailPassword(
            emailController.text, passController.text, nameController.text);
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(e.toString()),
          ),
        );
      }
    }
    //passwords dont match => tell user to fix
    else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Passwords don't match")));
    }
  }
}
