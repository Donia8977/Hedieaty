import 'package:flutter/material.dart';

import '../controllers/DatabaseHelper.dart';
import '../controllers/FireStoreHelper.dart';
import '../models/Gift.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'GiftDetails.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class GiftListPage extends StatefulWidget {
  final String eventId;

  const GiftListPage({required this.eventId, super.key});

  @override
  State<GiftListPage> createState() => _GiftListPageState();
}


class _GiftListPageState extends State<GiftListPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final FireStoreHelper fireStoreHelper = FireStoreHelper();

  List<Gift> gifts = [];
  bool isLoading = true;

  String sortBy = 'name';

  @override
  void initState() {
    super.initState();
    fetchGifts(widget.eventId);
  }

  Future<void> fetchGifts(String eventId) async {
    // final dbGifts = await _dbHelper.getGifts(eventId);

    setState(() {
      isLoading = true;
    });

    try {
      final dbGifts = await fireStoreHelper.fetchGift(eventId);
      final giftList =
          dbGifts.map((giftData) => Gift.fromMap(giftData)).toList();
      //  final dbGifts = await fireStoreHelper.fetchGifts(eventId)
      print('Fetched Gifts: $dbGifts');
      setState(() {
        gifts = giftList;
      });
    } catch (e) {
      print("Error fetching gifts: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addGift(String name, String category, double price) async {
    final uuid = Uuid();

    final newGift = Gift(
      id: uuid.v4(),
      name: name,
      category: category,
      status: 'Available',
      price: price,
      eventId: widget.eventId,
    );
    print('Adding Gift: ${newGift.toMap()}');
    // await _dbHelper.insertGift(newGift);
    await fireStoreHelper.addGift(newGift.toMap());
    fetchGifts(widget.eventId);
  }

  // Future<void> deleteGift(int index) async {
  //   final giftToDelete = Gift.fromMap(gifts[index]);
  //   await _dbHelper.deleteGift(giftToDelete);
  //   fetchGifts(); // Refresh the list
  // }

  Future<void> deleteGifts(int index) async {
    final giftToDelete = gifts[index];
    // await _dbHelper.deleteGift(giftToDelete);
    await fireStoreHelper.deleteGift(giftToDelete.id!);
    print('Gift deleted from Firestore.');
    fetchGifts(widget.eventId); // Refresh the list
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
  //   await _dbHelper.updateGift(updatedGift);
  //   fetchGifts(widget.eventId); // Refresh the list
  // }

  Future<void> updateGiftStatus(int index, String newStatus) async {
    final Gift giftToUpdate = gifts[index];

    setState(() {
      giftToUpdate.updateStatus(newStatus);
    });

    try {
      await fireStoreHelper.updateGift(giftToUpdate.id!, {'status': newStatus});
      print('Gift status updated in Firestore.');
    } catch (e) {
      print('Failed to update gift status in Firestore: $e');
      setState(() {
        giftToUpdate.updateStatus(giftToUpdate.status);
      });
    }

    await fetchGifts(widget.eventId);
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
      fetchGifts(widget.eventId);
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
                final gift = gifts[index];
                gift.name = nameController.text;
                gift.category = categoryController.text;

                // await _dbHelper.updateGift(gift);

                await fireStoreHelper.updateGift(gift.id!, gift.toMap());
                fetchGifts(widget.eventId);
                Navigator.pop(context);
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
                keyboardType: TextInputType.number, // Ensure numerical input
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
                //   print(
                //       'Name: ${nameController.text}, Category: ${categoryController.text}');
                //   if (nameController.text.isNotEmpty &&
                //       categoryController.text.isNotEmpty) {
                //     addGift(nameController.text, categoryController.text);
                //     Navigator.pop(context);
                //   }
                // },

                final String name = nameController.text;
                final String category = categoryController.text;
                final String priceText = priceController.text;

                if (name.isNotEmpty &&
                    category.isNotEmpty &&
                    priceText.isNotEmpty) {
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

  @override
  Widget build(BuildContext context) {
    print('Gifts List in Build: $gifts');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0XFF996CF3),
        title: Text('Gift List', style: TextStyle(color: Colors.white)),
        actions: [
          PopupMenuButton<String>(
            color: Color(0XFF996CF3),
            onSelected: (String route) => Navigator.pushNamed(context, route),
            itemBuilder: (context) => [
              _buildMenuItem('Home', '/home'),
              _buildMenuItem('Event List', '/eventList'),
              _buildMenuItem('Gift Details', '/giftDetails'),
              _buildMenuItem('Profile', '/profile'),
              _buildMenuItem('My Pledged Gifts', '/pledgedGifts'),
            ],
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: LoadingAnimationWidget.inkDrop(
                color: Color(0XFF996CF3),
                size: 60,
              ),
            )
          : gifts.isEmpty
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
                            items: ['name', 'category', 'status']
                                .map((String value) {
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
                              subtitle:
                                  Text('${gift.category} - ${gift.price}'),
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
                                        await updateGiftStatus(
                                            index, newStatus);
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        GiftDetailsPage(gift: gift.toMap()),
                                  ),
                                );
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
          //  var res =  DatabaseHelper().deleteDatabaseFile();
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