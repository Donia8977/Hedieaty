import 'package:flutter/material.dart';


class Event {
  final String name;
  final String category;
  final String status;
  Event({required this.name, required this.category, required this.status});
}

// EventListPage
class EventListPage extends StatefulWidget {
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  List<Event> events = [
    Event(name: 'Event A', category: 'Music', status: 'Upcoming'),
    Event(name: 'Event B', category: 'Sports', status: 'Current'),
    Event(name: 'Event C', category: 'Workshop', status: 'Past'),
  ];

  String _sortOption = 'Name'; // Default sorting by Name

  void _addEvent() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String name = '';
        String category = '';
        String status = '';

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
              onPressed: () {
                if (name.isNotEmpty &&
                    category.isNotEmpty &&
                    status.isNotEmpty) {
                  setState(() {
                    events.add(
                        Event(name: name, category: category, status: status));
                  });
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
          final Event event = events[index];
          String name = event.name;
          String category = event.category;
          String status = event.status;

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
                onPressed: () {
                  if (name.isNotEmpty &&
                      category.isNotEmpty &&
                      status.isNotEmpty) {
                    setState(() {
                      events[index] = Event(name: name, category: category, status: status);
                    });
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Okay'),
              ),
            ],


          );
        });
  }

  void _deleteEvent(int index) {
    setState(() {
      events.removeAt(index);
    });
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
            items: <String>['Name', 'Category', 'Status']
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
              _buildMenuItem('Home', '/'),
              _buildMenuItem('Event List', '/eventList'),
              _buildMenuItem('Gift List', '/giftList'),
              _buildMenuItem('Gift Details', '/giftDetails'),
              _buildMenuItem('Profile', '/profile'),
              _buildMenuItem('My Pledged Gifts', '/pledgedGifts'),
            ],
          ),




        ],




      ),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Card(
            child: ListTile(
              title: Text(event.name),
              subtitle: Text('${event.category} - ${event.status}'),
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
            ),
          );
        },
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
