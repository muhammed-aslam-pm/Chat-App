import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/model/group_chat_message_model.dart';
import 'package:flutter_chat_app/view/image_sending_screen.dart';
import 'package:flutter_chat_app/view/video_sending_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path/path.dart';

class GroupChatSerice with ChangeNotifier {
  // get instance of  firestore
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  XFile? pickedImage;
  String? receiverID;
  bool isUploading = false;

  // send messages
  Future<void> sendMessage(String chatId, message) async {
    //get current user info
    final String currentUserID = auth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();
    final String userName = await getUserName(currentUserID);
    // create a new message
    GroupChatMessage newMessage = GroupChatMessage(
      type: "text",
      senderId: currentUserID,
      message: message,
      timestamp: timestamp,
      senderName: userName,
    );

    // add new msg to db
    await firestore
        .collection("group_chats")
        .doc(chatId)
        .collection("messages")
        .add(newMessage.toMap());
  }

  Future<void> deleteMessage(String messageID, String chatid) async {
    try {
      await firestore
          .collection("group_chats")
          .doc(chatid)
          .collection("messages")
          .doc(messageID)
          .delete();
    } catch (e) {}
  }

  Stream<QuerySnapshot> getMessages(String chatID) {
    return firestore
        .collection("group_chats")
        .doc(chatID)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  Future<void> sendImages(
      BuildContext context, String chatId, List<XFile> images) async {
    try {
      isUploading = true;
      notifyListeners();
      final String currentUserID = auth.currentUser!.uid;
      final Timestamp timestamp = Timestamp.now();

      final String userName = await getUserName(currentUserID);
      for (XFile image in images) {
        final String? url =
            await uploadploadImage(chatroom: chatId, image: image);

        if (url != null) {
          GroupChatMessage newMessage = GroupChatMessage(
            type: "image",
            senderId: currentUserID,
            url: url,
            timestamp: timestamp,
            senderName: userName,
          );

          await firestore
              .collection("group_chats")
              .doc(chatId)
              .collection("messages")
              .add(newMessage.toMap());
        }
      }

      isUploading = false;
      notifyListeners();
      Navigator.pop(context);
    } catch (e) {
      // Handle errors
      isUploading = false;
      notifyListeners();
      // You may want to show a snackbar or dialog to inform the user about the error
    }
  }

  sendVideo(BuildContext context, String chatId, XFile video) async {
    isUploading = true;
    notifyListeners();
    final String currentUserID = auth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();

    final url = await uploadploadVideo(chatroom: chatId, video: video);
    final String userName = await getUserName(currentUserID);

    if (url != null) {
      GroupChatMessage newMessage = GroupChatMessage(
        type: "video",
        senderId: currentUserID,
        url: url,
        timestamp: timestamp,
        senderName: userName,
      );

      await firestore
          .collection("group_chats")
          .doc(chatId)
          .collection("messages")
          .add(newMessage.toMap());
    }
    isUploading = false;
    notifyListeners();
    Navigator.pop(context);
  }

  pickImages({required BuildContext context, required String chatId}) async {
    final imagePicker = ImagePicker();
    List<XFile>? pickedImages = await imagePicker.pickMultiImage();
    notifyListeners();
    if (pickedImages.isNotEmpty) {
      notifyListeners();

      // print("Picked File Path: ${image.path}");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageSendingScreen(
            isGroup: true,
            images: pickedImages,
            receiver: chatId,
          ),
        ),
      );
    } else {}
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

  pickVideo({required BuildContext context, required String chatId}) async {
    final imagePicker = ImagePicker();
    pickedImage = await imagePicker.pickVideo(source: ImageSource.gallery);
    notifyListeners();
    if (pickedImage != null) {
      notifyListeners();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoSendingScreen(
            pickedVideo: pickedImage!,
            receiver: chatId,
            isGroup: true,
          ),
        ),
      );
    } else {}
  }

  Future<String> getUserName(String userId) async {
    try {
      // Get the user document directly using the user ID as the document ID
      DocumentSnapshot userSnapshot =
          await firestore.collection('Users').doc(userId).get();

      // Check if the document exists
      if (userSnapshot.exists) {
        // Extract and return the user name
        return userSnapshot.get('name');
      } else {
        // If the document doesn't exist, return null
        return 'null';
      }
    } catch (e) {
      // Handle any errors that occur during the process
      return 'null';
    }
  }

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
