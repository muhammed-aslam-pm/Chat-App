import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ViedoPlayScreen extends StatefulWidget {
  const ViedoPlayScreen({super.key, required this.videoUrl});
  final String videoUrl;
  @override
  State<ViedoPlayScreen> createState() => _ViedoPlayScreenState();
}

class _ViedoPlayScreenState extends State<ViedoPlayScreen> {
  late final VideoPlayerController _controller;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _controller.initialize().then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("widget.video.title"),
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_controller.value.isPlaying) {
              _controller.pause();
              setState(() {});
            } else {
              _controller.play();
              setState(() {});
            }
          },
          child: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow)),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
