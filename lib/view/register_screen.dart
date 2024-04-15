import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/custom_button.dart';
import 'package:flutter_chat_app/components/custom_textfield.dart';
import 'package:flutter_chat_app/controller/register_controller.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatelessWidget {
  final void Function()? onTap;
  const RegisterScreen({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<RegisterController>(context, listen: false);
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
              "Let's Create an Account",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 25,
            ),

            //Name
            CustomTextField(
              controller: controller.nameController,
              obscure: false,
              hintText: "Enter your Name",
            ),
            const SizedBox(
              height: 10,
            ),

            //email textfield
            CustomTextField(
              controller: controller.emailController,
              obscure: false,
              hintText: "Enter your email",
            ),
            const SizedBox(
              height: 10,
            ),

            //pass textfield
            CustomTextField(
              controller: controller.passController,
              obscure: true,
              hintText: "Enter your Password",
            ),
            const SizedBox(
              height: 10,
            ),
            //confirm pass textfield
            CustomTextField(
              controller: controller.confirmpassController,
              obscure: true,
              hintText: "Confirm Password",
            ),
            const SizedBox(
              height: 25,
            ),

            //login button
            CustomButton(
              onTap: () {
                controller.register(context);
              },
              text: "Register",
            ),
            const SizedBox(
              height: 45,
            ),

            //reg now
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Already have an account? ",
                  style: TextStyle(color: Colors.black),
                ),
                InkWell(
                  onTap: onTap,
                  child: const Text("Login now",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
