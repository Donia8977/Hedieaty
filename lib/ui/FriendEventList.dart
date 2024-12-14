import 'package:flutter/material.dart';
import 'package:hedieaty/models/Event.dart';
import 'package:lottie/lottie.dart';
import 'package:uuid/uuid.dart';
import 'package:hedieaty/controllers/DatabaseHelper.dart';

import '../controllers/FireStoreHelper.dart';
import 'FriendGiftList.dart';

class FriendEventList extends StatefulWidget {

  final String userId;
  final String friendId;
  final String friendName;

  const FriendEventList({
    required this.userId,
    required this.friendId,
    required this.friendName,
  });


  // final String id;
  @override
  _FriendEventListState createState() => _FriendEventListState();
}

class _FriendEventListState extends State<FriendEventList> {

  final uuid = Uuid();


  List<AppEvent> events = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }
  //
  // Future<void> _loadEvents() async {//id in loadEvents
  //   final fetchedEvents = await DatabaseHelper.getEvents();
  //
  //   setState(() {
  //     events = fetchedEvents;
  //   });
  // }

  Future<void> _loadEvents() async {
    setState(() {
      isLoading = true;
    });

    try {
      final friendEvents = await FireStoreHelper().fetchEventsByFriend(
        userId: widget.friendId,
        friendId: widget.friendId,
      );

      setState(() {
        events = friendEvents.map((eventData) => AppEvent.fromMap(eventData)).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error loading friend's events: $e");
      setState(() {
        isLoading = false;
      });
    }
  }


  String _sortOption = 'Name';

  void _addFriendEvent() {
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (value) {
                  name = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Category'),
                onChanged: (value) {
                  category = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Status'),
                onChanged: (value) {
                  status = value;
                },
              ),

              TextField(
                decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                onChanged: (value) {
                  date = value;
                },
              ),

              TextField(
                decoration: InputDecoration(labelText: 'Location'),
                onChanged: (value) {
                  location = value;
                },
              ),


            ],
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
                if (name.isNotEmpty && category.isNotEmpty && status.isNotEmpty ) {
                  // final newEvent = AppEvent(
                  //   id: DateTime.now().toString(),
                  //   date: date,
                  //   location: location,
                  //   name: name,
                  //   category: category,
                  //   status: status,
                  //   userId: uuid.v4(),
                  // );
                  // await DatabaseHelper().addEvents(newEvent);
                  final newEvent = {
                    'name': name,
                    'category': category,
                    'status': status,
                    'date': date.isNotEmpty ? date : '2024-01-01',
                    'location': location.isNotEmpty ? location : 'No location provided',
                  };

                  await FireStoreHelper().addEventForFriend(
                    userId: widget.userId,
                    friendId: widget.friendId,
                    eventData: newEvent,
                  );

                  _loadEvents();
                  // setState(() {
                  //   events.add(newEvent);
                  // });
                  Navigator.of(context).pop();
                }
              },


              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _editEvent(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          final AppEvent event = events[index];
          String name = event.name;
          String category = event.category;
          String status = event.status;
          String? location = event.location;
          String date = event.date;

          return AlertDialog(
            title: Text('Edit Event'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Name'),
                  onChanged: (value) {
                    name = value;
                  },
                  initialValue: event.name,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Category'),
                  onChanged: (value) {
                    category = value;
                  },
                  initialValue: event.category,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Status'),
                  onChanged: (value) {
                    status = value;
                  },
                  initialValue: event.status,
                ),

                TextFormField(
                  decoration: InputDecoration(labelText: 'location'),
                  onChanged: (value) {
                    location = value;
                  },
                  initialValue: event.location,
                ),

                TextFormField(
                  decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                  onChanged: (value) {
                    date = value;
                  },
                  initialValue: event.date,
                ),

              ],
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
                  if (name.isNotEmpty &&
                      category.isNotEmpty &&
                      status.isNotEmpty) {

                    final updatedEvent = AppEvent(
                      id: event.id,
                      name: name,
                      category: category,
                      status: status,
                      location: location,
                      date: date,
                      userId: event.userId,
                    );

                    await DatabaseHelper().updateEvent(updatedEvent);
                    await  _loadEvents();

                    Navigator.of(context).pop();
                  }
                },
                child: Text('Okay'),
              ),
            ],


          );
        });
  }

  // void _deleteEvent(int index) async {
  //   final String? eventId = events[index].id;
  //
  //  // await DatabaseHelper().deleteEvent(eventId!);
  //   if(eventId != null) {
  //     await FireStoreHelper().deleteEventForFriend(eventId!, widget.friendId);
  //     await _loadEvents();
  //   }
  //
  //   // setState(() {
  //   //   events.removeAt(index);
  //   // });
  // }

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
        title: Text('Events for ${widget.friendName} ', style: TextStyle(color: Colors.white)),
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
              _buildMenuItem('Gift List', '/giftList'),
              _buildMenuItem('Gift Details', '/giftDetails'),
              _buildMenuItem('Profile', '/profile'),
              _buildMenuItem('My Pledged Gifts', '/pledgedGifts'),
            ],
          ),

        ],

      ),
      body: events.isEmpty
          ? Center(

        child: Lottie.asset('animation/purplish.json' ,
          width: 350,
          height: 350,
          fit: BoxFit.contain,),

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
                  // IconButton(
                  //   icon: Icon(Icons.delete, color: Colors.red),
                  //   onPressed: () => _deleteEvent(index),
                  // ),
                  Icon(Icons.arrow_forward),
                ],
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Friendgiftlist(  userId: widget.userId,
                  friendId: widget.friendId,
                  eventId: event.id,)),);
              },
            ),
          );
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _addFriendEvent,
      //   child: Icon(Icons.add),
      // ),
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
