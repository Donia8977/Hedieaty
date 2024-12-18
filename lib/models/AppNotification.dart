import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {

  late final String id;
  late final String title;
  late final String body;
  late final String receiverId;
  late final String senderId;
  late final String senderName;
  late final String giftName;
  late final String? eventId;
  final bool isRead;


  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.receiverId,
    required this.senderId,
    required this.giftName,
    required this.senderName,
    this.eventId,
    this.isRead = false,

  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'receiverId': receiverId,
      'senderId': senderId,
      'senderName': senderName,
      'giftName': giftName,
      'eventId': eventId,
      'isRead': isRead,

    };
  }


  factory AppNotification.fromFirestore(Map<String, dynamic> data) {
    return AppNotification(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      receiverId: data['receiverId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? 'Unknown User',
      giftName: data['giftName'] ?? '',
      eventId: data['eventId'],
      isRead: data['isRead'] ?? false,

    );
  }









}