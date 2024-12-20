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
              // _buildMenuItem('Gift List', '/giftList'),
              // _buildMenuItem('Gift Details', '/giftDetails'),
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
