import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chat_app/services/chat/chat_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class VideoSendingScreen extends StatefulWidget {
  final XFile pickedVideo;
  final String receiver;

  const VideoSendingScreen(
      {super.key, required this.pickedVideo, required this.receiver});

  @override
  _VideoSendingScreenState createState() => _VideoSendingScreenState();
}

class _VideoSendingScreenState extends State<VideoSendingScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.pickedVideo.path))
      ..initialize().then((_) {
        setState(() {});
      })
      ..setLooping(true);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Video'),
      ),
      body: Stack(
        children: [
          Center(
            child: InkWell(
              onTap: () {
                setState(() {
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  } else {
                    _controller.play();
                  }
                });
              },
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<ChatService>(
        builder: (context, value, child) => FloatingActionButton(
          onPressed: () {
            Provider.of<ChatService>(context, listen: false)
                .sendVideo(context, widget.receiver, widget.pickedVideo);
          },
          child: value.isUploading
              ? const CircularProgressIndicator()
              : const Icon(Icons.send),
        ),
      ),
    );
  }
}
