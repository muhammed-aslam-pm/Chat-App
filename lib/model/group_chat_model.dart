class GroupChatModel {
  final String groupName;
  final String? groupProfile;
  final String? lastMessage;
  final String? lastMessageSender;
  final String? lastMessageType;
  final DateTime? lastMessageTime;
  final String? groupId;
  final List<String> members;

  GroupChatModel({
    this.lastMessageSender,
    required this.groupName,
    this.groupProfile,
    this.lastMessage,
    this.lastMessageType,
    this.lastMessageTime,
    this.groupId,
    required this.members,
  });

  // Convert to a map
  Map<String, dynamic> toMap() {
    return {
      "groupName": groupName,
      "groupProfile": groupProfile ?? "",
      "lastMessage": lastMessage ?? "",
      "lastMessageType": lastMessageType ?? "",
      "lastMessageSender": lastMessageSender ?? "",
      "lastMessageTime": lastMessageTime ?? null,
      "groupId": groupId ?? "",
      "members": members
    };
  }
}
