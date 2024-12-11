
class PledgedGift {
  final String id;
  final String giftId;
  final String userId;
  final String? friendId;
  final String? eventId;

  PledgedGift({
    required this.id,
    required this.giftId,
    required this.userId,
    this.friendId,
    this.eventId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'giftId': giftId,
      'userId': userId,
      'friendId': friendId,
      'eventId': eventId,
    };
  }

  static PledgedGift fromMap(Map<String, dynamic> map) {
    return PledgedGift(
      id: map['id'],
      giftId: map['giftId'],
      userId: map['userId'],
      friendId: map['friendId'],
      eventId: map['eventId'],
    );
  }
}
