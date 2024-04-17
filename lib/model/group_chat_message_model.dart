import 'package:cloud_firestore/cloud_firestore.dart';

class GroupChatMessage {
  final String senderId;
  final String senderName;

  final String? message;
  final String? url;
  final String type;
  final Timestamp timestamp;

  GroupChatMessage({
    required this.senderId,
    required this.senderName,
    this.message,
    this.url,
    required this.timestamp,
    required this.type,
  });

  //convert to a map
  Map<String, dynamic> toMap() {
    return {
      "senderId": senderId,
      "senderName": senderName,
      "type": type,
      "url": url ?? "",
      "message": message ?? "",
      "timestamp": timestamp,
    };
  }
}
