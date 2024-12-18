import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../controllers/DatabaseHelper.dart';
import '../controllers/FireStoreHelper.dart';
import '../models/Gift.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty/models/AppNotification.dart';

import 'GiftDetails.dart';
import 'PledgedGifts.dart';


class Friendgiftlist extends StatefulWidget {

  final String userId;
  final String friendId;
  final String eventId;

  const Friendgiftlist({super.key,  required this.userId,
    required this.friendId,
    required this.eventId,});

  @override
  State<Friendgiftlist> createState() => _FriendgiftlistState();
}


class _FriendgiftlistState extends State<Friendgiftlist> {
 // final DatabaseHelper _dbHelper = DatabaseHelper();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<Gift> gifts = [];
  bool isLoading = true;

  String sortBy = 'name';

  @override
  void initState() {
    super.initState();
    _loadGifts();
  }

  // Future<void> _loadGifts() async {
  //   final currentUser = FirebaseAuth.instance.currentUser;
  //
  //   if (currentUser == null) {
  //     print("Error: User not logged in.");
  //     return;
  //   }
  //
  //   try {
  //     final snapshot = await FirebaseFirestore.instance.collection('giftLists').get();
  //
  //     setState(() {
  //       gifts = snapshot.docs
  //           .map((doc) {
  //         final data = doc.data() as Map<String, dynamic>;
  //
  //         if (data['name'] == null || data['name'].toString().trim().isEmpty) {
  //           print("Skipping gift with empty name: ${doc.id}");
  //           return null;
  //         }
  //
  //         if (data['price'] == null || data['price'].toString().trim().isEmpty) {
  //           print("Skipping gift with invalid price: ${doc.id}");
  //           return null;
  //         }
  //
  //         String userStatus = (data['userStatuses'] as Map<String, dynamic>?)
  //         ?[currentUser.uid] ??
  //             'Available';
  //
  //         data['status'] = userStatus;
  //
  //         return Gift.fromMap({
  //           ...data,
  //           'id': doc.id,
  //         });
  //       })
  //           .where((gift) => gift != null)
  //           .cast<Gift>()
  //           .toList();
  //     });
  //
  //     print("Gifts loaded successfully for user ${currentUser.uid}.");
  //   } catch (e) {
  //     print("Error loading gifts: $e");
  //   }
  // }

  Future<void> _loadGifts() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      print("Error: User not logged in.");
      return;
    }

    try {
      // Filter the query by friendId and eventId
      final snapshot = await FirebaseFirestore.instance
          .collection('giftLists')
          .where('eventId', isEqualTo: widget.eventId)
          .get();

      setState(() {
        gifts = snapshot.docs
            .map((doc) {
          final data = doc.data() as Map<String, dynamic>;

          if (data['name'] == null || data['name'].toString().trim().isEmpty) {
            print("Skipping gift with empty name: ${doc.id}");
            return null;
          }

          if (data['price'] == null || data['price'].toString().trim().isEmpty) {
            print("Skipping gift with invalid price: ${doc.id}");
            return null;
          }

          String userStatus = (data['userStatuses'] as Map<String, dynamic>?)
          ?[currentUser.uid] ??
              'Available';

          data['status'] = userStatus;

          return Gift.fromMap({
            ...data,
            'id': doc.id,
          });
        })
            .where((gift) => gift != null)
            .cast<Gift>()
            .toList();
      });

      print("Gifts loaded successfully for user ${currentUser.uid}.");
    } catch (e) {
      print("Error loading gifts: $e");
    }
  }



  Future<void> addGift(String name, String category, double price) async {
    final uuid = Uuid();

    try {

      final querySnapshot = await firestore
          .collection('friends')
          .where('friendId', isEqualTo: widget.friendId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception("Friend with ID ${widget.friendId} does not exist.");
      }

      final friendData = querySnapshot.docs.first.data();
      final friendName = friendData['name'] ?? 'Unknown';


      final newGift = Gift(
        id: uuid.v4(),
        name: name,
        category: category,
        status: 'Available',
        price: price,
        eventId: widget.eventId,
        friendName: friendName,
      );

      print('Adding Gift: ${newGift.toMap()}');

      await FireStoreHelper().addGift(newGift.toMap());
      _loadGifts();
    } catch (e) {
      print('Error adding gift: $e');
    }
  }




  Color getGiftColor(String status) {
    switch (status) {
      case 'Pledged':
        return Colors.green.shade200;
      case 'Purchased':
        return Colors.red.shade200;
      default:
        return Colors.white;
    }
  }



  Future<void> updateGiftStatus(int index, String newStatus, String friendId) async {
    final Gift giftToUpdate = gifts[index];
    final String? giftId = giftToUpdate.id;

    if (giftId == null) {
      print("Error: Gift ID is null. Cannot update gift status.");
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("Error: User not logged in.");
      return;
    }

    try {

      final giftRef = FirebaseFirestore.instance.collection('giftLists').doc(giftId);

      await giftRef.update({
        'userStatuses.${currentUser.uid}': newStatus,
      });

      print("Gift status updated to '$newStatus' for user ${currentUser.uid}.");

      if (newStatus == 'Available' || newStatus == 'Purchased') {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('pledgedGift')
            .where('giftId', isEqualTo: giftId)
            .where('userId', isEqualTo: currentUser.uid)
            .get();

        for (var doc in querySnapshot.docs) {
          await FirebaseFirestore.instance.collection('pledgedGift').doc(doc.id).delete();
        }
        print("Pledge removed as gift is now '$newStatus'.");
      }

      if (newStatus == 'Pledged') {
        String senderName = await fetchUserName(currentUser.uid);

        final querySnapshot = await FirebaseFirestore.instance
            .collection('pledgedGift')
            .where('giftId', isEqualTo: giftId)
            .where('userId', isEqualTo: currentUser.uid)
            .get();

        if (querySnapshot.docs.isEmpty) {
          await FirebaseFirestore.instance.collection('pledgedGift').add({
            'giftId': giftId,
            'userId': currentUser.uid,
            'friendId': friendId,
            'eventId': giftToUpdate.eventId,
          });

          print("Gift pledged successfully.");

          final notification = AppNotification(
            id: FirebaseFirestore.instance.collection('notifications').doc().id,
            title: "Gift Pledged!",
            body: "Your friend $senderName pledged your gift '${giftToUpdate.name}'.",
            receiverId: friendId,
            senderId: currentUser.uid,
            senderName: senderName,
            giftName: giftToUpdate.name,
            eventId: giftToUpdate.eventId,
            isRead: false,
          );

          await FirebaseFirestore.instance
              .collection('notifications')
              .doc(notification.id)
              .set(notification.toMap());

          print("Notification added to Firestore.");
        } else {
          print("Gift already pledged by this user.");
        }
      }
    } catch (e) {
      print("Error updating gift status: $e");
    }

    await _loadGifts();
  }



  Future<String> fetchUserName(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        return data['name'] ?? 'Unknown User';
      } else {
        return 'Unknown User';
      }
    } catch (e) {
      print("Error fetching user name: $e");
      return 'Unknown User';
    }
  }



  void sortGifts(String criteria) {
    setState(() {
      sortBy = criteria;
      gifts.sort((a, b) {
        if (criteria == 'name') {
          return a.name.compareTo(b.name);
        } else if (criteria == 'category') {
          return a.category.compareTo(b.category);
        } else {
          return a.status.compareTo(b.status);
        }
      });
    });
  }




  // void deleteGifts(int index) {
  //   setState(() {
  //     gifts.removeAt(index);
  //   });
  // }


  // Future<void> _openGiftDetails([Map<String, dynamic>? gift]) async {
  //   final result = await Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => GiftDetailsPage(gift: gift),
  //     ),
  //   );
  //
  //   // if (result != null) {
  //   //   setState(() {
  //   //     gifts.add(result);
  //   //   });
  //   // }
  //
  //   if (result != null) {
  //     _loadGifts();
  //   }
  // }

  void showEditDialog(BuildContext context, int index) {
    final TextEditingController nameController =
        TextEditingController(text: gifts[index].name);
    final TextEditingController categoryController =
        TextEditingController(text: gifts[index].category);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Gift'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: categoryController,
                decoration: InputDecoration(labelText: 'Category'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(

              onPressed: () async {
              //   final gift = gifts[index];
              //   gift.name = nameController.text;
              //   gift.category = categoryController.text;
              //
              //   await _dbHelper.updateGift(gift);
              //   _loadGifts();
              //   Navigator.pop(context);
              // },

                final gift = gifts[index];
                final updatedData = {
                  'name': nameController.text,
                  'category': categoryController.text,
                };

                try {
                  await FireStoreHelper().updateGift(gift.id!, updatedData);
                  await _loadGifts();

                  print("Gift updated successfully.");
                  Navigator.pop(context);
                } catch (e) {
                  print("Error updating gift: $e");
                }
              },

              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }


  void showGiftDetailsBottomSheet(BuildContext context, Gift gift) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0XFF996CF3),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.4,
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  gift.name,
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                SizedBox(height: 10),
                Text(
                  'Category: ${gift.category}',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                SizedBox(height: 10),
                Text(
                  'Price: \$${gift.price.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                SizedBox(height: 10),
                Text(
                  'Status: ${gift.status}',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Color(0XFF996CF3),
                  ),
                  child: Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Gifts List in Build: $gifts');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0XFF996CF3),
        title: Text('Friend Gifts ', style: TextStyle(color: Colors.white)),
        actions: [
          PopupMenuButton<String>(
            color: Color(0XFF996CF3),
            onSelected: (String route) => Navigator.pushNamed(context, route),
            itemBuilder: (context) => [
              _buildMenuItem('Home', '/home'),
              _buildMenuItem('Event List', '/eventList'),
              // _buildMenuItem('Gift List', '/giftList'),
              // _buildMenuItem('Gift Details', '/giftDetails'),
              _buildMenuItem('Profile', '/profile'),
              _buildMenuItem('My Pledged Gifts', '/pledgedGifts'),
            ],
          ),
        ],
      ),
      body: gifts.isEmpty
          ? Center(
              child: Lottie.asset(
                'animation/purplish.json',
                width: 350,
                height: 350,
                fit: BoxFit.contain,
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Sort by:'),
                      DropdownButton<String>(
                        value: sortBy,
                        items:
                            ['name', 'category', 'status'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) sortGifts(value);
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: gifts.length,
                    itemBuilder: (context, index) {
                      final gift = gifts[index];
                      return Card(
                        color: getGiftColor(gift.status),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundImage: gift.imageBase64 != null && gift.imageBase64!.isNotEmpty
                                ? MemoryImage(base64Decode(gift.imageBase64!))
                                : AssetImage('images/gift.png') as ImageProvider,
                          ),
                          title: Text(gift.name),
                          subtitle: Text('${gift.category} - ${gift.price}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DropdownButton<String>(
                                value: gift.status,
                                items: ['Available', 'Pledged', 'Purchased']
                                    .map((status) {
                                  return DropdownMenuItem(
                                    value: status,
                                    child: Text(status),
                                  );
                                }).toList(),
                                onChanged: (newStatus) async {
                                  if (newStatus != null && newStatus !=gift.status) {
                                    if (newStatus == 'Pledged' && gift.status != 'Available') {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Only available gifts can be pledged.')),
                                      );
                                      return;
                                    }
                                    await updateGiftStatus(index, newStatus , widget.friendId);
                                  }
                                },
                              ),
                              // IconButton(
                              //   icon: Icon(Icons.delete),
                              //   onPressed: () {
                              //     deleteGifts(index);
                              //   },
                              // ),
                            ],
                          ),
                          onTap: () {
                            showGiftDetailsBottomSheet(context, gift);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

    );
  }
}

PopupMenuItem<String> _buildMenuItem(String text, String route) {
  return PopupMenuItem(
    value: route,
    child: Text(
      text,
      style: TextStyle(color: Colors.white, fontSize: 15),
    ),
  );
}
