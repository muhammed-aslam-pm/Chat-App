import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderEmail;
  final String receiverID;
  final String? message;
  final String? url;
  final String type;
  final Timestamp timestamp;

  Message({
    required this.senderId,
    required this.senderEmail,
    required this.receiverID,
    this.message,
    this.url,
    required this.timestamp,
    required this.type,
  });

  //convert to a map
  Map<String, dynamic> toMap() {
    return {
      "senderId": senderId,
      "senderEmail": senderEmail,
      "receiverID": receiverID,
      "type": type,
      "url": url ?? "",
      "message": message ?? "",
      "timestamp": timestamp,
    };
  }
}
