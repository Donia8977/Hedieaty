import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/controllers/FireStoreHelper.dart';
import 'package:hedieaty/models/Event.dart';
import 'package:uuid/uuid.dart';
import 'package:hedieaty/controllers/DatabaseHelper.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'GiftList.dart';



class EventListPage extends StatefulWidget {
 // final String id;
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {

  FireStoreHelper fireStoreHelper = FireStoreHelper();

  final uuid = Uuid();
  List<AppEvent> events = [];
  bool isLoading = true;



  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  // Future<void> _loadEvents() async {
  //   final fetchedEvents = await DatabaseHelper.getEvents();
  //
  //   setState(() {
  //     events = fetchedEvents;
  //   });
  // }

  Future<void> _loadEvents() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      if(mounted) {
        setState(() {
          isLoading = true;
        });
      }

      try {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('events')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .get();

        if(mounted) {
          setState(() {
            events = snapshot.docs.map((doc) => AppEvent.fromFirestore(doc))
                .toList();
          });
        }
        for (var event in events) {
          print("Event ID: ${event.id}, Name: ${event.name}");
        }
      } catch (e) {
        print("Error fetching events: $e");
      }
      finally {
        if(mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  final _formKey = GlobalKey<FormState>();
  String _sortOption = 'Name';

  void _addEvent() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String name = '';
        String category = '';
        String status = '';
        String date = '';
        String location = '';

        return AlertDialog(
          title: Text('Add Event'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                    onChanged: (value) => name = value,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Category'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Category is required';
                      }
                      return null;
                    },
                    onChanged: (value) => category = value,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Status'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Status is required';
                      }
                      const validStatuses = ['Present', 'Future', 'Past'];
                      if (!validStatuses.contains(value.trim())) {
                        return 'Status must be Present, Future, or Past';
                      }
                      return null;
                    },
                    onChanged: (value) => status = value,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Date is required';
                      }
                      final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                      if (!dateRegex.hasMatch(value.trim())) {
                        return 'Enter date in YYYY-MM-DD format';
                      }
                      try {
                        DateTime.parse(value.trim()); // Validate the date
                      } catch (_) {
                        return 'Enter a valid date';
                      }
                      return null;
                    },
                    onChanged: (value) => date = value,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Location'),
                    onChanged: (value) => location = value,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  // Proceed only if the form is valid
                  final currentUser = FirebaseAuth.instance.currentUser;
                  if (currentUser != null) {
                    final eventData = {
                      'name': name,
                      'category': category,
                      'status': status,
                      'date': date.isNotEmpty ? date : '2024-01-01',
                      'location': location.isNotEmpty ? location : 'No location provided',
                      'userId': currentUser.uid,
                    };

                    await fireStoreHelper.addEvents(currentUser.uid, eventData);
                    _loadEvents(); // Reload events
                  }
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );

    //     return AlertDialog(
    //       title: Text('Add Event'),
    //       content: Column(
    //         mainAxisSize: MainAxisSize.min,
    //         children: [
    //           TextField(
    //             decoration: InputDecoration(labelText: 'Name'),
    //             onChanged: (value) {
    //               name = value;
    //             },
    //           ),
    //           TextField(
    //             decoration: InputDecoration(labelText: 'Category'),
    //             onChanged: (value) {
    //               category = value;
    //             },
    //           ),
    //           TextField(
    //             decoration: InputDecoration(labelText: 'Status'),
    //             onChanged: (value) {
    //               status = value;
    //             },
    //           ),
    //
    //           TextField(
    //             decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
    //             onChanged: (value) {
    //               date = value;
    //             },
    //           ),
    //
    //           TextField(
    //             decoration: InputDecoration(labelText: 'Location'),
    //             onChanged: (value) {
    //               location = value;
    //             },
    //           ),
    //
    //
    //         ],
    //       ),
    //       actions: [
    //         TextButton(
    //           onPressed: () {
    //             Navigator.of(context).pop();
    //           },
    //           child: Text('Cancel'),
    //         ),
    //         TextButton(
    //
    //           onPressed: () async {
    //             if (name.isNotEmpty && category.isNotEmpty && status.isNotEmpty ) {
    //               final currentUser = FirebaseAuth.instance.currentUser;
    //               if (currentUser!= null) {
    //
    //                 final eventData = {
    //                   'name': name,
    //                   'category': category,
    //                   'status': status,
    //                   'date': date.isNotEmpty ? date : '2024-01-01',
    //                   'location': location.isNotEmpty ? location : 'No location provided',
    //                   'userId': currentUser.uid,
    //                 };
    //
    //                 await fireStoreHelper.addEvents(currentUser.uid, eventData);
    //                 _loadEvents();
    //               }
    //               // final newEvent = AppEvent(
    //               //   id: DateTime.now().toString(),
    //               //   date: date,
    //               //   location: location,
    //               //   name: name,
    //               //   category: category,
    //               //   status: status,
    //               //   userId: uuid.v4(),
    //               // );
    //               // await DatabaseHelper().addEvents(newEvent);
    //               // _loadEvents();
    //               // setState(() {
    //               //   events.add(newEvent);
    //               // });
    //               Navigator.of(context).pop();
    //             }
    //           },
    //
    //
    //           child: Text('Add'),
    //         ),
    //       ],
    //     );
    //   },
    // );
  }

  void _editEvent(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          final AppEvent event = events[index];
          print("Editing Event ID: ${event.id}, Name: ${event.name}");

          if (event.id.isEmpty) {
            print("Error: Event ID is empty.");

          }

          final _editFormKey = GlobalKey<FormState>();
          String name = event.name;
          String category = event.category;
          String status = event.status;
          String? location = event.location;
          String date = event.date;

          return AlertDialog(
            title: Text('Edit Event'),
            content: Form(
              key: _editFormKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: name,
                      decoration: InputDecoration(labelText: 'Name'),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Name is required'
                          : null,
                      onChanged: (value) => name = value,
                    ),
                    TextFormField(
                      initialValue: category,
                      decoration: InputDecoration(labelText: 'Category'),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Category is required'
                          : null,
                      onChanged: (value) => category = value,
                    ),
                    TextFormField(
                      initialValue: status,
                      decoration: InputDecoration(labelText: 'Status'),
                      validator: (value) {
                        const validStatuses = ['Present', 'Future', 'Past'];
                        if (value == null || !validStatuses.contains(value.trim())) {
                          return 'Status must be Present, Future, or Past';
                        }
                        return null;
                      },
                      onChanged: (value) => status = value,
                    ),
                    TextFormField(
                      initialValue: date,
                      decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                      validator: (value) {
                        final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                        if (value == null || !dateRegex.hasMatch(value)) {
                          return 'Enter date in YYYY-MM-DD format';
                        }
                        return null;
                      },
                      onChanged: (value) => date = value,
                    ),
                    TextFormField(
                      initialValue: location,
                      decoration: InputDecoration(labelText: 'Location'),
                      onChanged: (value) => location = value,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (_editFormKey.currentState?.validate() ?? false) {
                    final updatedData = {
                      'name': name,
                      'category': category,
                      'status': status,
                      'date': date,
                      'location':  (location?.isNotEmpty ?? false) ? location : 'No location provided',
                    };

                    try {
                      await fireStoreHelper.updateEvent(event.id, updatedData);
                      await _loadEvents();
                      Navigator.of(context).pop();
                    } catch (e) {
                      print("Error updating event: $e");
                    }
                  }
                },
                child: Text('Save'),
              ),
            ],
          );
        },
    );
  }

  //         return AlertDialog(
  //           title: Text('Edit Event'),
  //           content: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               TextFormField(
  //                 decoration: InputDecoration(labelText: 'Name'),
  //                 onChanged: (value) {
  //                   name = value;
  //                 },
  //                 initialValue: event.name,
  //               ),
  //               TextFormField(
  //                 decoration: InputDecoration(labelText: 'Category'),
  //                 onChanged: (value) {
  //                   category = value;
  //                 },
  //                 initialValue: event.category,
  //               ),
  //               TextFormField(
  //                 decoration: InputDecoration(labelText: 'Status'),
  //                 onChanged: (value) {
  //                   status = value;
  //                 },
  //                 initialValue: event.status,
  //               ),
  //
  //               TextFormField(
  //                 decoration: InputDecoration(labelText: 'location'),
  //                 onChanged: (value) {
  //                   location = value;
  //                 },
  //                 initialValue: event.location,
  //               ),
  //
  //               TextFormField(
  //                 decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
  //                 onChanged: (value) {
  //                   date = value;
  //                 },
  //                 initialValue: event.date,
  //               ),
  //
  //             ],
  //           ),
  //
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //
  //                 Navigator.of(context).pop();
  //               },
  //
  //               child: Text('Cancel'),
  //             ),
  //             TextButton(
  //               onPressed: () async {
  //                 if (name.isNotEmpty &&
  //                     category.isNotEmpty &&
  //                     status.isNotEmpty) {
  //
  //                   final updatedData = {
  //                     'name': name,
  //                     'category': category,
  //                     'status': status,
  //                     'date': date.isNotEmpty ? date : '2024-01-01',
  //                     'location':  (location?.isNotEmpty ?? false) ? location : 'No location provided',
  //                   };
  //
  //                   print("Updating Event ID: ${event.id}");
  //
  //                   try {
  //                     await fireStoreHelper.updateEvent(event.id, updatedData);
  //                     await _loadEvents();
  //
  //                     //  final updatedEvent = AppEvent(
  //                     //    id: event.id,
  //                     //    name: name,
  //                     //    category: category,
  //                     //    status: status,
  //                     //    location: location,
  //                     //    date: date,
  //                     //    userId: event.userId,
  //                     //  );
  //                     //
  //                     // await DatabaseHelper().updateEvent(updatedEvent);
  //                     // await  _loadEvents();
  //
  //                     Navigator.of(context).pop();
  //                   }
  //                   catch (e) {
  //                     print("Error updating event: $e");
  //                   }
  //                 }
  //               },
  //               child: Text('Okay'),
  //             ),
  //           ],
  //
  //
  //         );
  //       });
  // }

  // void _deleteEvent(int index) async {
  //   // final String? eventId = events[index].id;
  //   //
  //   // await DatabaseHelper().deleteEvent(eventId!);
  //   // await _loadEvents();
  //   //
  //   // setState(() {
  //   //   events.removeAt(index);
  //   // });
  //
  //   final String eventId = events[index].id;
  //   await fireStoreHelper.deleteEvent(eventId);
  //   _loadEvents();
  // }

  void _deleteEvent(int index) async {
    final String eventId = events[index].id;

    try {
      await fireStoreHelper.deleteEvent(eventId);

      if (mounted) {
        setState(() {
          events.removeAt(index);
        });
      }

      await _loadEvents();
    } catch (e) {
      print("Error deleting event: $e");
    }
  }


  void _sortEvents() {
    setState(() {
      switch (_sortOption) {
        case 'Name':
          events.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'Category':
          events.sort((a, b) => a.category.compareTo(b.category));
          break;
        case 'Status':
          events.sort((a, b) => a.status.compareTo(b.status));
          break;
        case 'Date':
          events.sort((a, b) => a.date.compareTo(b.date));
          break;
        case 'Location':
          events.sort((a, b) => (a.location ?? '').compareTo(b.location ?? ''));
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0XFF996CF3),
        title: Text('Event List', style: TextStyle(color: Colors.white)),
        actions: [
          DropdownButton<String>(
            value: _sortOption,
            onChanged: (String? newValue) {
              setState(() {
                _sortOption = newValue!;
                _sortEvents();
              });
            },
            items: <String>['Name', 'Category', 'Status' , 'Date', 'Location']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),

          PopupMenuButton<String>(
            color: Color(0XFF996CF3),
            onSelected: (String route) => Navigator.pushNamed(context, route),
            itemBuilder: (context) => [
              _buildMenuItem('Home', '/home'),
              _buildMenuItem('Event List', '/eventList'),
              // _buildMenuItem('Gift Details', '/giftDetails'),
              _buildMenuItem('Profile', '/profile'),
              _buildMenuItem('My Pledged Gifts', '/pledgedGifts'),
            ],
          ),




        ],




      ),
      body: Center(
        child:isLoading
            ? LoadingAnimationWidget.inkDrop(
          color: Color(0XFF996CF3),
          size: 60,
        )
            : events.isEmpty
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'animation/purplish.json',
              width: 350,
              height: 350,
              fit: BoxFit.contain,
            ),

          ],
        )
            : ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return Card(
              child: ListTile(
                title: Text(event.name),
                subtitle: Text('${event.category} - ${event.status} - ${event.date} - ${event.location ?? 'No location'}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _editEvent(index),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteEvent(index),
                    ),


                  ],
                ),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GiftListPage(eventId: event.id,)),

                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEvent,
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
