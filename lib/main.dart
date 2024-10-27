import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'ui/eventlistpage.dart';
import 'ui/profile.dart';
import 'ui/pledgedgifts.dart';
import 'ui/giftList.dart';
import 'ui/giftDetails.dart';

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
          // PopupMenuButton<String>(
          //
          //   color: Color(0XFF996CF3),
          //   onSelected: (String route) {
          //     Navigator.pushNamed(context, '/eventList');
          //   },
          //   itemBuilder: (BuildContext context) => [
          //     const PopupMenuItem(
          //       value: '/',
          //       child: Text('Home' ,
          //         style: TextStyle(color: Colors.white),),
          //
          //     ),
          //     const PopupMenuItem(
          //       value: '/eventList',
          //       child: Text('Event List' ,
          //         style: TextStyle(color: Colors.white , fontSize: 15),),
          //     ),
          //     const PopupMenuItem(
          //       value: '/giftList',
          //       child: Text('Gift List' ,
          //         style: TextStyle(color: Colors.white , fontSize: 15),),
          //     ),
          //     const PopupMenuItem(
          //       value: '/giftDetails',
          //       child: Text('Gift Details' ,
          //         style: TextStyle(color: Colors.white , fontSize: 15),),
          //     ),
          //     const PopupMenuItem(
          //       value: '/profile',
          //       child: Text('Profile' ,
          //         style: TextStyle(color: Colors.white , fontSize: 15),),
          //     ),
          //     const PopupMenuItem(
          //       value: '/pledgedGifts',
          //       child: Text('My Pledged Gifts' ,
          //         style: TextStyle(color: Colors.white , fontSize: 15),),
          //     ),
          //   ],
          // ),

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
                  // Navigate to friend's gift lists page
                },
              ),
            );
          }
        },
      ),

      // body: ListView(
      //   scrollDirection : Axis.vertical,
      //    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      //   children: [
      //
      //     Padding(
      //       padding: const EdgeInsets.only(bottom: 16.0),
      //       child: ElevatedButton(
      //         onPressed: () {
      //           // Navigate to create new event or list page
      //         },
      //         child: Text("Create Your Own Event/List"),
      //       ),
      //     ),
      //
      //     ...friends.map((friend) {
      //       return Padding(
      //         padding: const EdgeInsets.symmetric(vertical: 4.0),
      //         child: ListTile(
      //           leading: CircleAvatar(
      //             backgroundImage: AssetImage(friend.profilePic),
      //           ),
      //           title: Text(friend.name),
      //           subtitle: Text(friend.upcomingEvents > 0
      //               ? "Upcoming Events: ${friend.upcomingEvents}"
      //               : "No Upcoming Events"),
      //           trailing: Icon(Icons.arrow_forward),
      //           onTap: () {
      //             // Navigate to friend's gift lists page
      //           },
      //         ),
      //       );
      //     }).toList(),
      //   ],
      //
      //
      // ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {

        },
        child: Icon(Icons.person_add),
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
