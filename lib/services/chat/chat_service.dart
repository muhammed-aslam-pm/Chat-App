// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/view/image_sending_screen.dart';
import 'package:flutter_chat_app/view/video_sending_screen.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chat_app/model/message_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ChatService with ChangeNotifier {
  // get instance of  firestore
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  XFile? pickedImage;
  String? receiverID;
  bool isUploading = false;

  // send messages
  Future<void> sendMessage(String receiverID, message) async {
    //get current user info
    final String currentUserID = auth.currentUser!.uid;
    final String currentUserEmail = auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();
    // create a new message
    Message newMessage = Message(
      type: "text",
      senderId: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    // construct a chat room Id fo the 2 users(sorted to ensure uniqueness)
    List<String> ids = [currentUserID, receiverID];
    ids.sort(); // sort the ids to ensure the chatroomId is the same for any 2 peoples
    String chatRoomID = ids.join("_");

    // add new msg to db
    await firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());
  }

  Future<void> deleteMessage(
      String userID, otherUserID, String messageID) async {
    //construct a chatroom id for the 2 users
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join("_");
    try {
      await firestore
          .collection("chat_rooms")
          .doc(chatRoomID)
          .collection("messages")
          .doc(messageID)
          .delete();
      print("Message deleted successfully");
    } catch (e) {
      print("Error deleting message: $e");
    }
  }

  //get messages
  Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
    //construct a chatroom id for the 2 users
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join("_");
    return firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  // sendImage(BuildContext context, String receiverID, XFile image) async {
  //   isUploading = true;
  //   notifyListeners();
  //   print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<satrted>>>>>>>>>>>>>>>>>>>>>>>>>>");
  //   final String currentUserID = auth.currentUser!.uid;
  //   final String currentUserEmail = auth.currentUser!.email!;
  //   final Timestamp timestamp = Timestamp.now();
  //   List<String> ids = [currentUserID, receiverID];
  //   ids.sort();
  //   String chatRoomID = ids.join("_");
  //   print(
  //       "<<<<<<<<<<<<<<<<<<<<<<<<<<<<Caht room id : $chatRoomID>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
  //   final url = await uploadploadImage(chatroom: chatRoomID, image: image);
  //   print(
  //       "<<<<<<<<<<<<<<<<<<<<<<<<<<<< URL : $url>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
  //   print(
  //       "<<<<<<<<<<<<<<<<<<<<<<<<<<<< Image : $pickedImage>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");

  //   if (url != null) {
  //     Message newMessage = Message(
  //       type: "image",
  //       senderId: currentUserID,
  //       senderEmail: currentUserEmail,
  //       receiverID: receiverID,
  //       url: url,
  //       timestamp: timestamp,
  //     );

  //     await firestore
  //         .collection("chat_rooms")
  //         .doc(chatRoomID)
  //         .collection("messages")
  //         .add(newMessage.toMap());
  //   }
  //   isUploading = false;
  //   notifyListeners();
  //   Navigator.pop(context);
  // }

  //   Future<void> sendMediaFiles(
  //     BuildContext context, List<XFile> mediaFiles) async {
  //   for (XFile mediaFile in mediaFiles) {
  //     // Check if the file is an image or a video based on its extension
  //     String extension = mediaFile.path.split('.').last.toLowerCase();
  //     if (extension == 'jpg' ||
  //         extension == 'jpeg' ||
  //         extension == 'png' ||
  //         extension == 'gif') {
  //       // Upload image to Firebase Storage
  //       await uploadImage(mediaFile);
  //     } else if (extension == 'mp4') {
  //       // Upload video to Firebase Storage
  //       await uploadVideo(mediaFile);
  //     }
  //   }
  // }

  Future<void> sendImages(
      BuildContext context, String receiverID, List<XFile> images) async {
    try {
      isUploading = true;
      notifyListeners();
      final String currentUserID = auth.currentUser!.uid;
      final String currentUserEmail = auth.currentUser!.email!;
      final Timestamp timestamp = Timestamp.now();
      List<String> ids = [currentUserID, receiverID];
      ids.sort();
      String chatRoomID = ids.join("_");

      for (XFile image in images) {
        final String? url =
            await uploadploadImage(chatroom: chatRoomID, image: image);

        if (url != null) {
          Message newMessage = Message(
            type: "image",
            senderId: currentUserID,
            senderEmail: currentUserEmail,
            receiverID: receiverID,
            url: url,
            timestamp: timestamp,
          );

          await firestore
              .collection("chat_rooms")
              .doc(chatRoomID)
              .collection("messages")
              .add(newMessage.toMap());
        }
      }

      isUploading = false;
      notifyListeners();
      Navigator.pop(context);
    } catch (e) {
      // Handle errors
      print("Error sending images: $e");
      isUploading = false;
      notifyListeners();
      // You may want to show a snackbar or dialog to inform the user about the error
    }
  }

  sendVideo(BuildContext context, String receiverID, XFile video) async {
    isUploading = true;
    notifyListeners();
    final String currentUserID = auth.currentUser!.uid;
    final String currentUserEmail = auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join("_");
    final url = await uploadploadVideo(chatroom: chatRoomID, video: video);

    if (url != null) {
      Message newMessage = Message(
        type: "video",
        senderId: currentUserID,
        senderEmail: currentUserEmail,
        receiverID: receiverID,
        url: url,
        timestamp: timestamp,
      );

      await firestore
          .collection("chat_rooms")
          .doc(chatRoomID)
          .collection("messages")
          .add(newMessage.toMap());
    }
    isUploading = false;
    notifyListeners();
    Navigator.pop(context);
  }

  // Future<String?> pickAndUploadImage({required String chatroom}) async {
  //   final imagePicker = ImagePicker();
  //   final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

  //   if (pickedFile == null) return null;
  //   final fileName = basenameWithoutExtension(pickedFile.path);
  //   final storageRef =
  //       FirebaseStorage.instance.ref().child('$chatroom/images/$fileName');
  //   final uploadTask = storageRef.putFile(File(pickedFile.path));

  //   final snapshot = await uploadTask.whenComplete(() => null);
  //   final url = await snapshot.ref.getDownloadURL();

  //   return url;
  // }

  pickImages({required BuildContext context, required String receiver}) async {
    final imagePicker = ImagePicker();
    List<XFile>? pickedImages = await imagePicker.pickMultiImage();
    notifyListeners();
    if (pickedImages.isNotEmpty) {
      receiverID = receiver;
      notifyListeners();
      print("Picked Files: $pickedImages");

      // print("Picked File Path: ${image.path}");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageSendingScreen(
            images: pickedImages,
            receiver: receiver,
          ),
        ),
      );
    } else {
      print("No images picked");
    }
  }

  Future<String?> uploadploadImage(
      {required String chatroom, required XFile image}) async {
    final fileName = basenameWithoutExtension(image.path);
    final storageRef =
        FirebaseStorage.instance.ref().child('$chatroom/images/$fileName');
    final uploadTask = storageRef.putFile(File(image.path));

    final snapshot = await uploadTask.whenComplete(() => null);
    final url = await snapshot.ref.getDownloadURL();

    return url;
  }

  Future<String?> uploadploadVideo(
      {required String chatroom, required XFile video}) async {
    final fileName = basenameWithoutExtension(video.path);
    final storageRef =
        FirebaseStorage.instance.ref().child('$chatroom/videos/$fileName');
    final uploadTask = storageRef.putFile(File(video.path));

    final snapshot = await uploadTask.whenComplete(() => null);
    final url = await snapshot.ref.getDownloadURL();

    return url;
  }

  pickVideo({required BuildContext context, required String receiver}) async {
    final imagePicker = ImagePicker();
    pickedImage = await imagePicker.pickVideo(source: ImageSource.gallery);
    notifyListeners();
    if (pickedImage != null) {
      receiverID = receiver;
      notifyListeners();
      print("Picked File: $pickedImage");
      print("Picked File Path: ${pickedImage!.path}");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoSendingScreen(
            pickedVideo: pickedImage!,
            receiver: receiver,
          ),
        ),
      );
    } else {
      print("No image picked");
    }
  }

  // Future<String?> pickAndUploadVideo(String chatroom) async {
  //   final videoPicker = ImagePicker();
  //   final pickedFile = await videoPicker.pickVideo(source: ImageSource.gallery);

  //   if (pickedFile == null) return null;
  //   final fileName = basenameWithoutExtension(pickedFile.path);

  //   final storageRef =
  //       FirebaseStorage.instance.ref().child('$chatroom/videos/$fileName');
  //   final uploadTask = storageRef.putFile(File(pickedFile.path));

  //   final snapshot = await uploadTask.whenComplete(() => null);
  //   final url = await snapshot.ref.getDownloadURL();

  //   return url;
  // }

  Future<Uint8List> getThumbnailData(String videoUrl) async {
    final thumbnailBytes = await VideoThumbnail.thumbnailData(
      video: videoUrl,
      imageFormat: ImageFormat.JPEG, // Or choose PNG, WEBP, etc.
      maxWidth: 128, // Adjust width as needed
      maxHeight: 72, // Adjust height as needed
      quality: 75, // Adjust quality (0-100)
    );
    return thumbnailBytes!;
  }
}
