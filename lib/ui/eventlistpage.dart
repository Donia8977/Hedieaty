import 'package:flutter/material.dart';



// void main() {
//   runApp(MaterialApp(
//     initialRoute: '/',
//
//     routes: {
//       '/': (context) => HomePage(),         // Home Page route
//       '/eventList': (context) => EventListPage(),  // Event List route
//     },
//     debugShowCheckedModeBanner: false,
//   ));
// }

// Event Model
class Event {
  final String name;
  final String category;
  final String status; // Upcoming, Current, Past
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
    // Navigate to an event creation screen or open a dialog
  }

  void _editEvent(int index) {
    // Edit event details by index
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
        title: Text('Event List'),
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
