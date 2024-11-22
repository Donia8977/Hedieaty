import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'ui/eventlistpage.dart';
import 'ui/profile.dart';
import 'ui/pledgedgifts.dart';
import 'ui/giftList.dart';
import 'ui/giftDetails.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';


void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => UserProvider()),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      title: 'Hedieaty',
      routes: {
        '/eventList': (context) => EventListPage(),
        '/giftList': (context) => GiftListPage(),
        '/giftDetails': (context) => GiftDetailsPage(),
        '/profile': (context) => ProfilePage(),
        '/pledgedGifts': (context) => MyPledgedGiftsPage(),
      },
    ),
  ));
}



class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  List<Friend> friends = [
    Friend(
        name: "John Doe",
        profilePic: "images/3430601_avatar_female_normal_woman_icon.png",
        upcomingEvents: 1),
    Friend(
        name: "Jane Smith",
        profilePic: "images/3430601_avatar_female_normal_woman_icon.png",
        upcomingEvents: 0),
    Friend(
        name: "Alex Johnson",
        profilePic: "images/3430601_avatar_female_normal_woman_icon.png",
        upcomingEvents: 2),
    Friend(
        name: "Alex Johnson",
        profilePic: "images/3430601_avatar_female_normal_woman_icon.png",
        upcomingEvents: 2),
    Friend(
        name: "Emily Davis",
        profilePic: "images/3430601_avatar_female_normal_woman_icon.png",
        upcomingEvents: 3),
    Friend(
        name: "Michael Brown",
        profilePic: "images/3430601_avatar_female_normal_woman_icon.png",
        upcomingEvents: 0),
    Friend(
        name: "Sophia Taylor",
        profilePic: "images/3430601_avatar_female_normal_woman_icon.png",
        upcomingEvents: 1),
    Friend(
        name: "David Wilson",
        profilePic: "images/3430601_avatar_female_normal_woman_icon.png",
        upcomingEvents: 0),
    Friend(
        name: "Olivia Martinez",
        profilePic: "images/3430601_avatar_female_normal_woman_icon.png",
        upcomingEvents: 2),
    Friend(
        name: "Liam Garcia",
        profilePic: "images/3430601_avatar_female_normal_woman_icon.png",
        upcomingEvents: 1),
    Friend(
        name: "Isabella Moore",
        profilePic: "images/3430601_avatar_female_normal_woman_icon.png",
        upcomingEvents: 0),
    Friend(
        name: "Lucas Thompson",
        profilePic: "images/3430601_avatar_female_normal_woman_icon.png",
        upcomingEvents: 1),
    Friend(
        name: "Ava White",
        profilePic: "images/3430601_avatar_female_normal_woman_icon.png",
        upcomingEvents: 4),
    // Friend(name: "Mason Harris", profilePic: "assets/images/profile13.jpg", upcomingEvents: 2),
    // Friend(name: "Charlotte Clark", profilePic: "assets/images/profile14.jpg", upcomingEvents: 0),
    // Friend(name: "James Lewis", profilePic: "assets/images/profile15.jpg", upcomingEvents: 3),
    // Friend(name: "Amelia Robinson", profilePic: "assets/images/profile16.jpg", upcomingEvents: 2),
    // Friend(name: "Benjamin Young", profilePic: "assets/images/profile17.jpg", upcomingEvents: 0),
    // Friend(name: "Mia Hernandez", profilePic: "assets/images/profile18.jpg", upcomingEvents: 1),
  ];

  String searchQuery = "";

  void _showManualAddDialog() {
    String name = "";
    String phone = "";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Friend"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: "Name"),
              onChanged: (value) => name = value,
            ),
            TextField(
              decoration: InputDecoration(labelText: "Phone Number"),
              keyboardType: TextInputType.phone,
              onChanged: (value) => phone = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text("Add"),
            onPressed: () {
              if (name.isNotEmpty && phone.isNotEmpty) {
                setState(() {
                  friends.add(Friend(
                    name: name,
                    profilePic: "images/default_avatar.png",
                    upcomingEvents: 0,
                  ));
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please fill in all fields.")),
                );
              }
            },
          ),
        ],
      ),
    );
  }


  void _selectContactFromList() async {
    // Request permission
    bool permissionGranted = await FlutterContacts.requestPermission();

    if (permissionGranted) {
      // Fetch contacts
      List<Contact> contacts = await FlutterContacts.getContacts(withProperties: true);

      // Show contacts in a dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Select Contact"),
          content: Container(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return ListTile(
                  title: Text(contact.displayName),
                  subtitle: Text(contact.phones.isNotEmpty ? contact.phones.first.number : "No Phone"),
                  onTap: () {
                    if (contact.phones.isNotEmpty) {
                      setState(() {
                        friends.add(Friend(
                          name: contact.displayName,
                          profilePic: "images/default_avatar.png", // Default image
                          upcomingEvents: 0,
                        ));
                      });
                    }
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Contacts permission is required to access your contact list."),
      ));
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(


      appBar: AppBar(

        backgroundColor: Color(0XFF996CF3),
        title: Text("Hedieaty", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                  context: context, delegate: FriendSearchDelegate(friends));
            },
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
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        itemCount: friends.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>  EventListPage() ),);
                  // Navigate to create new event or list page
                },
                child: Text("Create Your Own Event/List"),
              ),
            );
          } else {
            final friend =
                friends[index - 1];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage(friend.profilePic),
                ),
                title: Text(friend.name),
                subtitle: Text(friend.upcomingEvents > 0
                    ? "Upcoming Events: ${friend.upcomingEvents}"
                    : "No Upcoming Events"),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const GiftListPage()),);
                  // Navigate to friend's gift lists page
                },
              ),
            );
          }
        },
      ),



      floatingActionButton: FloatingActionButton(
        onPressed: () {

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Add Friend"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.phone),
                    title: Text("Add Manually"),
                    onTap: () {
                      Navigator.pop(context);
                      _showManualAddDialog();
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.contacts),
                    title: Text("Select from Contacts"),
                    onTap: () {
                      Navigator.pop(context);
                      _selectContactFromList();
                    },
                  ),
                ],
              ),
            ),
          );

        },
        child: Icon(Icons.person_add),
      ),



      
      
      
    );



  }


}

class _selectContactFromList {
}

class _showManualAddDialog {
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

class Friend {
  final String name;
  final String profilePic;
  final int upcomingEvents;

  Friend(
      {required this.name,
      required this.profilePic,
      required this.upcomingEvents});
}

class FriendSearchDelegate extends SearchDelegate {
  final List<Friend> friends;

  FriendSearchDelegate(this.friends);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildFriendList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildFriendList();
  }

  Widget _buildFriendList() {
    final filteredFriends = friends.where((friend) {
      return friend.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filteredFriends.length,
      itemBuilder: (context, index) {
        final friend = filteredFriends[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage(friend.profilePic),
          ),
          title: Text(friend.name),
          subtitle: Text(friend.upcomingEvents > 0
              ? "Upcoming Events: ${friend.upcomingEvents}"
              : "No Upcoming Events"),
          onTap: () {
            // Navigate to friend's gift lists page
            close(context, null);
          },
        );
      },
    );
  }
}
