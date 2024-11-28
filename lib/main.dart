import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/ui/sign_in.dart';
import 'package:hedieaty/ui/sign_up.dart';
// import 'package:provider/provider.dart';
// import 'providers/user_provider.dart';
import 'ui/eventlistpage.dart';
import 'ui/profile.dart';
import 'ui/pledgedgifts.dart';
import 'ui/giftList.dart';
import 'ui/giftDetails.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'models/DatabaseHelper.dart';
import 'models/Friend.dart';
import 'models/User.dart' as app;
import 'package:uuid/uuid.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {

  final uuid = Uuid();

  final userId = uuid.v4();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final currentUser = app.User(
    id: userId,
    name: 'John Doe',
    email: 'john.doe@example.com',
    // Add other user fields as required.
  );

  runApp(

    //   MultiProvider(
    // providers: [
    //   ChangeNotifierProvider(create: (_) => UserProvider()),
    // ],
     MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Hedieaty',
      initialRoute: '/home',
      routes: {
        '/home': (context) => HomePage(),
        '/sign_in': (context) => Sign_in(),
        '/sign_up': (context) => Sign_up(),
        '/eventList': (context) => EventListPage(),
        '/giftList': (context) => GiftListPage(),
        '/giftDetails': (context) => GiftDetailsPage(),
        '/profile': (context) => ProfilePage(user: currentUser),

        // FutureBuilder<app.User>(
        //   future: fetchCurrentUser(),
        //   builder: (context, snapshot) {
        //     if (snapshot.connectionState == ConnectionState.waiting) {
        //       return Center(child: CircularProgressIndicator());
        //     } else if (snapshot.hasError || !snapshot.hasData) {
        //       return Center(child: Text("Error fetching user data"));
        //     }
        //     final currentUser = snapshot.data!;
        //     return ProfilePage(user: currentUser);
        //   },
        // ),
        '/pledgedGifts': (context) => MyPledgedGiftsPage(),
      },
    ),
  );


}


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final uuid = Uuid();

  @override
  void initstate() {
    super.initState();
    FirebaseAuth.instance
        .authStateChanges()
        .listen((firebase.User? user) {
      if (user == null) {
        print('=========================User is currently signed out!');
      } else {
        print('============================User is signed in!');
      }
    });
  }

  List<Friend> friends = [];

   DatabaseHelper _dbHelper = DatabaseHelper();

  //String searchQuery = "";
  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    final loadedFriends = await DatabaseHelper.getFriends();
    setState(() {
      friends = loadedFriends;

    });
  }

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
            onPressed: () async {
              if (name.isNotEmpty && phone.isNotEmpty) {
                final userId = uuid.v4();
                final friendId = uuid.v4();


                final newFriend = Friend(
                  userId: userId,
                  friendId: friendId,
                  name: name,
                  profilePic: "images/3430601_avatar_female_normal_woman_icon.png",
                  upcomingEvents: 0,
                );


                await _dbHelper.insertFriend(newFriend);
                _loadFriends();

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
    bool permissionGranted = await FlutterContacts.requestPermission();

    if (permissionGranted) {
      List<Contact> contacts = await FlutterContacts.getContacts(withProperties: true);

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
                  onTap: () async {
                    if (contact.phones.isNotEmpty) {

                      final userId = uuid.v4();
                      final friendId = uuid.v4();

                      final newFriend = Friend(
                        userId: userId,
                        friendId: friendId,
                        name: contact.displayName,
                        profilePic: "images/3430601_avatar_female_normal_woman_icon.png", // Default image
                        upcomingEvents: 0,
                      );
                      final dbHelper = DatabaseHelper();
                      await dbHelper.insertFriend(newFriend);
                      _loadFriends();

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


    if (filteredFriends.isEmpty) {
      return Center(child: Text("No friends found."));
    }

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
