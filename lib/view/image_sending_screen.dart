import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/services/chat/chat_service.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ImageSendingScreen extends StatelessWidget {
  const ImageSendingScreen({
    Key? key,
    required this.images,
    required this.receiver,
  }) : super(key: key);

  final List<XFile> images;
  final String receiver;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: CarouselSlider(
          options: CarouselOptions(
            height: MediaQuery.of(context).size.height * 0.7,
            aspectRatio: 16 / 9,
            viewportFraction: 0.8,
            initialPage: 0,
            enableInfiniteScroll: false,
            reverse: false,
            autoPlay: false,
            autoPlayInterval: Duration(seconds: 3),
            autoPlayAnimationDuration: Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            scrollDirection: Axis.horizontal,
          ),
          items: images.map((XFile image) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  child: Image.file(File(image.path)),
                );
              },
            );
          }).toList(),
        ),
      ),
      floatingActionButton: Consumer<ChatService>(
        builder: (context, value, child) => FloatingActionButton(
          onPressed: () {
            Provider.of<ChatService>(context, listen: false)
                .sendImages(context, receiver, images);
          },
          child: value.isUploading
              ? const CircularProgressIndicator()
              : const Icon(Icons.send),
        ),
      ),
    );
  }
}
