
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/custom_button.dart';
import 'package:flutter_chat_app/components/custom_textfield.dart';
import 'package:flutter_chat_app/controller/login_controller.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  //tap for register page
  final void Function()? onTap;
  LoginScreen({super.key, required this.onTap});
  //controllers for both email and password
  // final TextEditingController emailController = TextEditingController();
  // final TextEditingController passController = TextEditingController();

  //login method
  // void login(BuildContext context) async {
  //   //auth service
  //   final authService = AuthService();

  //   //try login
  //   try {
  //     await authService.signInWithEmailPassword(
  //         emailController.text, passController.text);
  //   }

  //   //catch any errors
  //   catch (e) {
  //     showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: Text(e.toString()),
  //       ),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final controller=Provider.of<LoginController>(context,listen: false);
    return Scaffold(
     
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //logo
            const Icon(
              Icons.message_rounded,
              size: 60,
              
            ),
            const SizedBox(
              height: 50,
            ),

            //welcome back message
            const Text(
              "Welcome Back!",
              style: TextStyle(
             
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 25,
            ),

            //email textfield
            CustomTextField(
              controller:controller. emailController,
              obscure: false,
              hintText: "Enter your email",
            ),
            const SizedBox(
              height: 10,
            ),

            //pass textfield
            CustomTextField(
              controller:controller. passController,
              obscure: true,
              hintText: "Enter your Password",
            ),
            const SizedBox(
              height: 25,
            ),

            //login button
            CustomButton(
              onTap: ()=>controller.login(context),
              text: "Login",
            ),
            const SizedBox(
              height: 45,
            ),

            //reg now
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Not a member? ",
                  style:
                      TextStyle(color:Colors.black),
                ),
                InkWell(
                  onTap: onTap,
                  child: const Text("Register now",
                      style: TextStyle(fontWeight: FontWeight.bold,
                          color: Colors.black)),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}