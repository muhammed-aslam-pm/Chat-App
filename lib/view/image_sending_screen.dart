import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/services/chat/chat_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ImageSendingScreen extends StatelessWidget {
  const ImageSendingScreen(
      {super.key, required this.image, required this.receiver});
  final XFile image;
  final String receiver;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SizedBox(
            width: double.infinity, child: Image.file(File(image.path))),
      ),
      floatingActionButton: Consumer<ChatService>(
        builder: (context, value, child) => FloatingActionButton(
          onPressed: () {
            Provider.of<ChatService>(context, listen: false)
                .sendImage(context, receiver, image);
          },
          child: value.isUploading
              ? const CircularProgressIndicator()
              : const Icon(Icons.send),
        ),
      ),
    );
  }
}
