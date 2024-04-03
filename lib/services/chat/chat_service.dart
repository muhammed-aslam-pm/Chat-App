import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chat_app/model/message_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ChatService {
  // get instance of  firestore
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  XFile? pickedImage;

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

  sendImage(String receiverID) async {
    final String currentUserID = auth.currentUser!.uid;
    final String currentUserEmail = auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join("_");
    final url = await pickAndUploadImage(chatroom: chatRoomID);

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

  sendVideo(String receiverID) async {
    final String currentUserID = auth.currentUser!.uid;
    final String currentUserEmail = auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join("_");
    final url = await pickAndUploadVideo(
      chatRoomID,
    );

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
  }

  Future<String?> pickAndUploadImage({required String chatroom}) async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return null;
    final fileName = basenameWithoutExtension(pickedFile.path);
    final storageRef =
        FirebaseStorage.instance.ref().child('$chatroom/images/$fileName');
    final uploadTask = storageRef.putFile(File(pickedFile.path));

    final snapshot = await uploadTask.whenComplete(() => null);
    final url = await snapshot.ref.getDownloadURL();

    return url;
  }

  Future<String?> pickAndUploadVideo(String chatroom) async {
    final videoPicker = ImagePicker();
    final pickedFile = await videoPicker.pickVideo(source: ImageSource.gallery);

    if (pickedFile == null) return null;
    final fileName = basenameWithoutExtension(pickedFile.path);

    final storageRef =
        FirebaseStorage.instance.ref().child('$chatroom/videos/$fileName');
    final uploadTask = storageRef.putFile(File(pickedFile.path));

    final snapshot = await uploadTask.whenComplete(() => null);
    final url = await snapshot.ref.getDownloadURL();

    return url;
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
