import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreHelper{

  FirebaseFirestore firestore = FirebaseFirestore.instance;


  Future<void> addFriend(String userId, Map<String, dynamic> friendData) async {
    try {

      final existingFriendQuery = await firestore
          .collection('friends')
          .where('userId', isEqualTo: userId)
          .where('friendId', isEqualTo: friendData['friendId'])
          .get();

      if (existingFriendQuery.docs.isNotEmpty) {
        print("Friend already exists in the list.");
        return;
      }


      final eventsQuery = await firestore
          .collection('events')
          .where('userId', isEqualTo: friendData['friendId'])
          .get();

      final upcomingEventsCount = eventsQuery.docs.length;

      friendData['upcomingEvents'] = upcomingEventsCount;

      await firestore.collection('friends').add(friendData);

      print("Friend added successfully with $upcomingEventsCount upcoming events!");
    } catch (e) {
      print("Error adding friend: $e");
    }
  }


  Future<List<Map<String, dynamic>>> fetchFriends(String userId) async {
    try {
      QuerySnapshot snapshot = await firestore
          .collection('friends')
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print("Error fetching friends: $e");
      return [];
    }
  }


////////////////////////////////////////////////////////////////////

  Future<void> deleteFriend(String friendId) async {
    try {

      QuerySnapshot friendSnapshot = await firestore
          .collection('friends')
          .where('friendId', isEqualTo: friendId)
          .get();

      for (var doc in friendSnapshot.docs) {
        await doc.reference.delete();
      }

      QuerySnapshot giftSnapshot = await firestore
          .collection('giftLists')
          .where('userStatuses.$friendId', isNotEqualTo: null)
          .get();

      for (var doc in giftSnapshot.docs) {
        await doc.reference.update({
          'userStatuses.$friendId': FieldValue.delete(),
          'status': 'Available',
        });
      }

      QuerySnapshot pledgedGiftSnapshot = await firestore
          .collection('pledgedGift')
          .where('friendId', isEqualTo: friendId)
          .get();

      for (var doc in pledgedGiftSnapshot.docs) {
        await doc.reference.delete();
      }

      print("Friend and associated pledged gifts deleted successfully!");
    } catch (e) {
      print("Error deleting friend and resetting gifts: $e");
    }
  }



  Future<void> addEvents(String userId, Map<String, dynamic> eventData) async {
    try {

      final eventDocRef = firestore.collection('events').doc();
      eventData['id'] = eventDocRef.id;
      eventData['userId'] = userId;
      await eventDocRef.set(eventData);

      print("Event added successfully!");


      final friendQuery = await firestore
          .collection('friends')
          .where('friendId', isEqualTo: userId)
          .get();

      for (var friendDoc in friendQuery.docs) {
        final friendRef = friendDoc.reference;
        await firestore.runTransaction((transaction) async {
          final friendSnapshot = await transaction.get(friendRef);
          if (friendSnapshot.exists) {
            final currentUpcomingEvents = friendSnapshot['upcomingEvents'] ?? 0;
            transaction.update(friendRef, {
              'upcomingEvents': currentUpcomingEvents + 1,
            });
            print("Incremented upcomingEvents for a friend.");
          }
        });
      }
    } catch (e) {
      print("Error adding event: $e");
    }
  }


  Future<List<Map<String, dynamic>>> fetchEventsUsers(String userId) async {
    try {
      QuerySnapshot snapshot = await firestore
          .collection('events')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

    } catch (e) {
      print("Error fetching events: $e");
      return [];
    }
  }

  Future<void> updateEvent(String id, Map<String, dynamic> updatedData) async {
    try {
      print(id);

      if (id.isEmpty) {
        throw Exception("Document ID is empty; cannot update event.");
      }


      await firestore.collection('events').doc(id).update(updatedData);
      print("Event updated successfully!");
    } catch (e) {
      print("Error updating event: $e");
    }
  }


  Future<void> deleteEvent(String eventId) async {
    try {
      final eventDoc = await firestore.collection('events').doc(eventId).get();

      if (eventDoc.exists) {
        final eventData = eventDoc.data();
        final userId = eventData?['userId'];

        if (userId != null) {
          await firestore.collection('events').doc(eventId).delete();
          print("Event deleted successfully!");

          final friendQuery = await firestore
              .collection('friends')
              .where('friendId', isEqualTo: userId)
              .get();

          for (var friendDoc in friendQuery.docs) {
            final friendRef = friendDoc.reference;

            await firestore.runTransaction((transaction) async {
              final friendSnapshot = await transaction.get(friendRef);

              if (friendSnapshot.exists) {
                final currentUpcomingEvents = friendSnapshot['upcomingEvents'] ?? 0;
                if (currentUpcomingEvents > 0) {
                  transaction.update(friendRef, {
                    'upcomingEvents': currentUpcomingEvents - 1,
                  });
                  print("Decremented upcomingEvents for a friend.");
                }
              }
            });
          }
        } else {
          print("Error: userId is null in the event data.");
        }
      } else {
        print("Error: Event with ID $eventId does not exist.");
      }
    } catch (e) {
      print("Error deleting event: $e");
    }
  }



/////////////////////////////////////////////////////////////////////////////


  Future<String> addGift(Map<String, dynamic> giftData) async {
    try {
      final docRef = firestore.collection('giftLists').doc();
      giftData['id'] = docRef.id;
      await docRef.set(giftData);
      print("Gift added successfully with ID: ${docRef.id}");
      return docRef.id;
    } catch (e) {
      print("Error adding gift: $e");
      throw Exception("Failed to add gift");
    }
  }

  Future<void> updateGift(String id, Map<String, dynamic> updatedData) async {
    try {
      await firestore.collection('giftLists').doc(id).update(updatedData);
      print("Gift updated successfully!");
    } catch (e) {
      print("Error updating gift: $e");
    }
  }

  Future<void> addPledgedGift(Map<String, dynamic> pledgedGiftData) async {
    try {
      await firestore.collection('pledgedGift').doc(pledgedGiftData['id']).set(pledgedGiftData);
      print("Pledged gift added successfully to Firestore");
    } catch (e) {
      print("Error adding pledged gift: $e");
    }
  }




  Future<List<Map<String, dynamic>>> fetchGift(String eventId) async {
    try {
      QuerySnapshot snapshot = await firestore
          .collection('giftLists')
          .where('eventId', isEqualTo: eventId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print("Error fetching gifts: $e");
      return [];
    }
  }




  Future<void> deleteGift(String id)async {

     try{

       await firestore.collection('giftLists').doc(id).delete();
       print("Gift deleted successfully!");

     }
     catch(e){
       print("Error deleting gift: $e");
     }
  }

  ////////////////////////////////////////////////////

  Future<void> addEventForFriend({
    required String userId,
    required String friendId,
    required Map<String, dynamic> eventData,
  }) async {
    try {
      final docRef = firestore.collection('events').doc();
      eventData['id'] = docRef.id;
      eventData['userId'] = friendId;
     // eventData['friendId'] = friendId;
      await docRef.set(eventData);
      print("Friend event added successfully with ID: ${docRef.id}");

      final querySnapshot = await firestore
          .collection('friends')
          .where('friendId', isEqualTo: friendId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {

        final friendDocument = querySnapshot.docs.first;
        final DocumentReference docRef = friendDocument.reference;

        await firestore.runTransaction((transaction) async {
          DocumentSnapshot friendSnapshot = await transaction.get(docRef);

          if (friendSnapshot.exists) {
            int currentUpcomingEvents = friendSnapshot['upcomingEvents'] ?? 0;
            transaction.update(docRef, {
              'upcomingEvents': currentUpcomingEvents + 1,
            });
            print("Friend's upcoming events incremented successfully.");
          } else {
            print("Friend document does not exist.");
          }
        });
      } else {
        print("Friend document not found for friendId: $friendId");
      }
    } catch (e) {
      print("Error adding friend event: $e");
    }
  }


  Future<List<Map<String, dynamic>>> fetchEventsByFriend({
    required String userId,
    required String friendId,
  }) async {
    try {
      QuerySnapshot snapshot = await firestore
          .collection('events')
          .where('userId', isEqualTo: friendId)
         // .where('friendId', isEqualTo: friendId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print("Error fetching events by friend: $e");
      return [];
    }
  }

  Future<void> deleteEventForFriend(String eventId, String friendId) async {
    try {
      await firestore.collection('events').doc(eventId).delete();
      print("Event deleted successfully!");

      final querySnapshot = await firestore
          .collection('friends')
          .where('friendId', isEqualTo: friendId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final friendDocRef = querySnapshot.docs.first.reference;

        await firestore.runTransaction((transaction) async {
          final friendSnapshot = await transaction.get(friendDocRef);

          if (friendSnapshot.exists) {
            int currentUpcomingEvents = friendSnapshot['upcomingEvents'] ?? 0;
            if (currentUpcomingEvents > 0) {
              transaction.update(friendDocRef, {
                'upcomingEvents': currentUpcomingEvents - 1,
              });
              print("Friend's upcoming events decremented successfully.");
            } else {
              print("Friend's upcoming events count is already zero.");
            }
          } else {
            print("Friend document does not exist.");
          }
        });
      } else {
        print("Friend document not found for friendId: $friendId");
      }
    } catch (e) {
      print("Error deleting event: $e");
    }
  }




}