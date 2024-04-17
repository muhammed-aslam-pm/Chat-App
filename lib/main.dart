import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/controller/group_controller.dart';
import 'package:flutter_chat_app/controller/login_controller.dart';
import 'package:flutter_chat_app/controller/register_controller.dart';
import 'package:flutter_chat_app/firebase_options.dart';
import 'package:flutter_chat_app/services/auth/auth_gate.dart';
import 'package:flutter_chat_app/services/auth/auth_service.dart';
import 'package:flutter_chat_app/services/chat/chat_service.dart';
import 'package:flutter_chat_app/services/chat/group_chat_service.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => LoginController()),
        ChangeNotifierProvider(create: (context) => RegisterController()),
        ChangeNotifierProvider(create: (context) => ChatService()),
        ChangeNotifierProvider(create: (context) => GroupChatSerice()),
        ChangeNotifierProvider(create: (context) => GroupChatController()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AuthGate(),
      ),
    );
  }
}
