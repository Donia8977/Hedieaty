import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../controllers/DatabaseHelper.dart';
import '../controllers/FireStoreHelper.dart';
import '../models/Gift.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  //
  // Future<void> fetchGifts(String eventId) async {
  //   final dbGifts = await _dbHelper.getGifts(eventId);
  //   print('Fetched Gifts: $dbGifts');
  //   setState(() {
  //     gifts = dbGifts;
  //   });
  // }

  Future<void> _loadGifts() async {
    setState(() {
       isLoading = true;
    });

    try {
      final fetchedGifts = await FireStoreHelper().fetchGift(widget.eventId);
      print('Fetched gifts from Firestore: $fetchedGifts');
      setState(() {
        gifts = fetchedGifts.map((giftData) => Gift.fromMap(giftData)).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error loading gifts: $e");
      setState(() {
        isLoading = false;
      });
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

      // Create the Gift object
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
      _loadGifts(); // Refresh the gift list
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

  // Future<void> updateGiftStatus(int index, String status) async {
  //   final updatedGift = gifts[index];
  //   // updatedGift.status = status;
  //   updatedGift.updateStatus(status);
  //  // await _dbHelper.updateGift(updatedGift);
  // //  await FireStoreHelper().updateGift(updatedGift);
  //   _loadGifts(); // Refresh the list
  // }



  Future<void> updateGiftStatus(int index, String newStatus) async {
    final Gift giftToUpdate = gifts[index];
    final String? giftId = giftToUpdate.id;

    if (giftId == null) {
      print("Error: Gift ID is null. Cannot update gift status.");
      return;
    }

    setState(() {
      giftToUpdate.updateStatus(newStatus);
    });

    try {
      await FireStoreHelper().updateGift(giftId, {
        'status': newStatus,
      });
      print("Gift status updated successfully in Firestore.");

      if (newStatus == 'Pledged') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyPledgedGiftsPage(
              friendId: widget.friendId,
              eventId: widget.eventId,),
          ),
        );

      }
    } catch (e) {
      print("Error updating gift status in Firestore: $e");
      setState(() {
        giftToUpdate.updateStatus(giftToUpdate.status);
      });
    }

    await _loadGifts();
  }

  // Future<void> _loadPledgedGifts() async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //
  //   try {
  //     // Fetch all gifts with status 'Pledged' and the specified eventId and friendId
  //     Query query = firestore.collection('giftLists').where('status', isEqualTo: 'Pledged');
  //
  //     if (widget.eventId != null) {
  //       query = query.where('eventId', isEqualTo: widget.eventId);
  //     }
  //     if (widget.friendId != null) {
  //       query = query.where('friendId', isEqualTo: widget.friendId);
  //     }
  //
  //     final querySnapshot = await query.get();
  //
  //     final List<Gift> fetchedGifts = querySnapshot.docs.map((doc) {
  //       final data = doc.data() as Map<String, dynamic>;
  //       return Gift(
  //         id: doc.id,
  //         name: data['name'],
  //         category: data['category'],
  //         price: data['price'].toDouble(),
  //         status: data['status'],
  //         eventId: data['eventId'],
  //         friendName: data['friendName'] ?? '',
  //       );
  //     }).toList();
  //
  //     setState(() {
  //       gifts = fetchedGifts;
  //       isLoading = false;
  //     });
  //   } catch (e) {
  //     print("Error loading pledged gifts: $e");
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }
  //

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




  void deleteGifts(int index) {
    setState(() {
      gifts.removeAt(index);
    });
  }


  Future<void> _openGiftDetails([Map<String, dynamic>? gift]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiftDetailsPage(gift: gift),
      ),
    );

    // if (result != null) {
    //   setState(() {
    //     gifts.add(result);
    //   });
    // }

    if (result != null) {
      _loadGifts();
    }
  }

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
              // onPressed: () {
              //   editGift(index, nameController.text, categoryController.text);
              //   Navigator.pop(context);
              // },

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

  void showAddGiftDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController categoryController = TextEditingController();
    final TextEditingController priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Gift'),
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
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Price'),
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
              onPressed: () {

                final String name = nameController.text;
                final String category = categoryController.text;
                final String priceText = priceController.text;

                if (name.isNotEmpty && category.isNotEmpty && priceText.isNotEmpty) {
                  final double price = double.tryParse(priceText) ?? 0.0;

                  if (price > 0) {
                    addGift(name, category, price);
                    Navigator.pop(context);
                  } else {
                    print('Invalid price. Please enter a positive number.');
                  }
                }
              },
              child: Text('Add'),
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
              _buildMenuItem('Gift List', '/giftList'),
              _buildMenuItem('Gift Details', '/giftDetails'),
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
                                  if (newStatus != null) {
                                    await updateGiftStatus(index, newStatus);
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  deleteGifts(index);
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) =>
                            //         GiftDetailsPage(gift: gift.toMap()),
                            //   ),
                            // );
                            showGiftDetailsBottomSheet(context, gift);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // var res =  DatabaseHelper().deleteDatabaseFile();
          showAddGiftDialog(context);
        },
        child: Icon(Icons.add),
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
