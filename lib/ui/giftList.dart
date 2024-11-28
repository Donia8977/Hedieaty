import 'package:flutter/material.dart';

import '../models/DatabaseHelper.dart';
import '../models/Gift.dart';
import 'package:uuid/uuid.dart';

class GiftListPage extends StatefulWidget {
  const GiftListPage({super.key});

  @override
  State<GiftListPage> createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  // Mock Data




  List<Map<String, dynamic>> gifts = [];
    // {
    //   'name': 'Toy Car',
    //   'category': 'Toys',
    //   'status': 'Available',
    //   'pledged': false
    // },
    // {
    //   'name': 'Board Game',
    //   'category': 'Games',
    //   'status': 'Pledged',
    //   'pledged': true
    // },
    // {
    //   'name': 'Gift Card',
    //   'category': 'Cards',
    //   'status': 'Pledged',
    //   'pledged': true
    // },
    // {
    //   'name': 'Book',
    //   'category': 'Books',
    //   'status': 'Available',
    //   'pledged': false
    // },

  final DatabaseHelper _dbHelper = DatabaseHelper();

  String sortBy = 'name'; // Default sort option


  @override
  void initState() {
    super.initState();
    fetchGifts();
  }

  Future<void> fetchGifts() async {
    final dbGifts = await _dbHelper.getGifts('someEventId'); // Replace 'someEventId' with actual eventId
    setState(() {
      gifts = dbGifts.map((gift) => gift.toMap()).toList();
    });
  }

  Future<void> addGift(String name, String category) async {

    final uuid = Uuid();
    final eventId = uuid.v4();

    final newGift = Gift(
      name: name,
      category: category,
      status: 'Available',
      price : 20,
      eventId: eventId, // Replace 'someEventId' with actual eventId
    );
    await _dbHelper.insertGift(newGift);
    fetchGifts(); // Refresh the list
  }

  Future<void> updateGiftStatus(int index, String status) async {
    final updatedGift = Gift.fromMap(gifts[index]);
    updatedGift.status = status;
    await _dbHelper.updateGift(updatedGift);
    fetchGifts(); // Refresh the list
  }

  Future<void> deleteGift(int index) async {
    final giftToDelete = Gift.fromMap(gifts[index]);
    await _dbHelper.deleteGift(giftToDelete);
    fetchGifts(); // Refresh the list
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



  //Sort function
  void sortGifts(String criteria) {
    setState(() {
      sortBy = criteria;
      gifts.sort((a, b) => a[criteria].compareTo(b[criteria]));
    });
  }
  //
  // // Add a new gift
  // void addGift(String name, String category) {
  //   setState(() {
  //     gifts.add({
  //       'name': name,
  //       'category': category,
  //       'status': 'Available',
  //       'pledged': false
  //     });
  //   });
  // }
  //
  // // Delete a gift
  // void deleteGift(int index) {
  //   setState(() {
  //     gifts.removeAt(index);
  //   });
  // }
  //
  // // Edit a gift
  // void editGift(int index, String name, String category) {
  //   setState(() {
  //     gifts[index]['name'] = name;
  //     gifts[index]['category'] = category;
  //   });
  // }
  //
  // // Visual indicator for pledged gifts
  // Color getGiftColor(bool pledged) {
  //   return pledged ? Colors.green.shade200 : Colors.white;
  // }


  void showEditDialog(BuildContext context, int index) {
    final TextEditingController nameController = TextEditingController(text: gifts[index]['name']);
    final TextEditingController categoryController = TextEditingController(text: gifts[index]['category']);

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
                final gift = Gift.fromMap(gifts[index]);
                gift.name = nameController.text;
                gift.category = categoryController.text;

                await _dbHelper.updateGift(gift);
                fetchGifts(); // Refresh the list
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
                if (nameController.text.isNotEmpty && categoryController.text.isNotEmpty) {
                  addGift(nameController.text, categoryController.text);
                  Navigator.pop(context);
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
              _buildMenuItem('Gift List', '/giftList'),
              _buildMenuItem('Gift Details', '/giftDetails'),
              _buildMenuItem('Profile', '/profile'),
              _buildMenuItem('My Pledged Gifts', '/pledgedGifts'),
            ],
          ),
        ],
      ),

      body: Column(
        children: [
          // Sorting Options
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sort by:'),
                DropdownButton<String>(
                  value: sortBy,
                  items: ['name', 'category', 'status'].map((String value) {
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
          // Gift List
          Expanded(
            child: ListView.builder(
              itemCount: gifts.length,
              itemBuilder: (context, index) {
                final gift = gifts[index];
                return Card(
                  color: getGiftColor(gift['pledged']),
                  child: ListTile(
                    title: Text(gift['name']),
                    subtitle: Text('${gift['category']} - ${gift['status']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButton<String>(
                          value: gift['status'],
                          items: ['Available', 'Pledged', 'Purchased'].map((status) {
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
                          onPressed: gift['pledged']
                              ? null
                              : () {
                                  deleteGift(index);
                                },
                        ),
                      ],
                    ),
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
