import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/models/AppNotification.dart';
import 'package:hedieaty/ui/FriendEventList.dart';
import 'package:hedieaty/ui/Sign_in.dart';
import 'package:hedieaty/ui/Sign_up.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'ui/EventListPage.dart';
import 'ui/Profile.dart';
import 'ui/PledgedGifts.dart';
import 'ui/GiftList.dart';
import 'ui/GiftDetails.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'controllers/DatabaseHelper.dart';
import 'models/Friend.dart';
import 'models/AppUser.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'controllers/FireStoreHelper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hedieaty/controllers/Auth.dart';
import 'package:permission_handler/permission_handler.dart';


MyAuth myAuth = MyAuth();


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

AppUser? appUser;
Future<void> updateAppUser() async {
  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        appUser = AppUser.fromFirestore(userDoc);
        print("AppUser updated: ${appUser?.name}");
      } else {
        print("User document does not exist.");
      }
    } catch (e) {
      print("Error updating AppUser: $e");
    }
  } else {
    print("No user is logged in.");
  }
}

void main() async {
  final uuid = Uuid();

  final userId = uuid.v4();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'gift_channel',
    'Gift Notifications',
    description: 'This channel is used for gift notifications.',
    importance: Importance.max,
    playSound: true,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  await FirebaseMessaging.instance.requestPermission();
  await updateAppUser();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hedieaty',
      initialRoute: '/sign_in',
      routes: {
        '/home': (context) => HomePage(),
        '/sign_in': (context) => Sign_in(),
        '/sign_up': (context) => Sign_up(),
        '/eventList': (context) => EventListPage(),
        '/giftList': (context) => GiftListPage(
              eventId: 'id',
            ),
        '/giftDetails': (context) => GiftDetailsPage(),
        '/profile': (context) {
          if (appUser == null) {
            return const Sign_in();
          } else {
            return ProfilePage(user: appUser!);
          }
        },
        '/pledgedGifts': (context) => MyPledgedGiftsPage(
              friendId: null,
              eventId: null,
            ),
      },
    ),
  );


}

Future<void> showLocalNotification(String title, String body) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'gift_channel', // Must match the created channel ID
    'Gift Notifications',
    channelDescription: 'Notifications for pledged gifts',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
  );

  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
  );
}





class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final uuid = Uuid();
  bool isLoading = true;
  List<Map<String, dynamic>> notifications = [];


  @override
  void initState() {
    super.initState();
    _fetchUnreadNotifications();
    checkNotifications();
    requestNotificationPermission();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('=========================User is currently signed out!');
      } else {
        print('============================User is signed in!');
      }
    });


    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print("Foreground notification: ${message.notification?.title}");

        showLocalNotification(
          message.notification!.title ?? "No Title",
          message.notification!.body ?? "No Body",
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLocalNotification("Welcome User", "Enjoy your event !");
    });

    _listenForNotifications();

    _loadFriends();

  }

  Future<void> checkNotifications() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      print("User is not logged in.");
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('receiverId', isEqualTo: currentUser.uid)
          .where('isRead', isEqualTo: false)
          //.orderBy('timestamp', descending: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final senderName = data['senderName'];
          final giftName = data['giftName'];

          await showLocalNotification(
            "Gift Pledged!",
            "Your friend $senderName pledged your gift \"$giftName\".",
          );

          // Mark notification as read
          await doc.reference.update({'isRead': true});
        }
      }
    } catch (e) {
      print("Error checking notifications: $e");
    }
  }




  List<Friend> friends = [];

  DatabaseHelper _dbHelper = DatabaseHelper();
  FireStoreHelper FirestoreHelper = FireStoreHelper();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // @override
  // void initState() {
  //   super.initState();
  //   _loadFriends();
  //
  // }

  Future<void> _loadFriends() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      if(mounted) {
        setState(() {
          isLoading = true;
        });
      }

      firestore
          .collection('friends')
          .where('userId', isEqualTo: currentUser.uid)
          .snapshots()
          .listen((QuerySnapshot snapshot) {
        final List<Friend> updatedFriends = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Friend.fromFirestore(data);
        }).toList();

        if(mounted) {
          setState(() {
            friends = updatedFriends;
            isLoading = false;
          });
        }
      });
    }
  }
  //
  // void _showManualAddDialog() {
  //   String name = "";
  //   String phone = "";
  //   String selectedGender = 'male';
  //
  //   var gender = ['male', 'female '];
  //
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text("Add Friend"),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           TextField(
  //             decoration: InputDecoration(labelText: "Name"),
  //             onChanged: (value) => name = value,
  //           ),
  //           TextField(
  //             decoration: InputDecoration(labelText: "Phone Number"),
  //             keyboardType: TextInputType.phone,
  //             onChanged: (value) => phone = value,
  //           ),
  //           DropdownButton<String>(
  //             value: selectedGender,
  //             items: gender.map((String gender) {
  //               return DropdownMenuItem<String>(
  //                 value: gender,
  //                 child: Text(gender),
  //               );
  //             }).toList(),
  //             onChanged: (String? newValue) {
  //               setState(() {
  //                 selectedGender = newValue!;
  //               });
  //             },
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           child: Text("Cancel"),
  //           onPressed: () => Navigator.pop(context),
  //         ),
  //         ElevatedButton(
  //             child: Text("Add"),
  //             onPressed: () async {
  //               if (name.isNotEmpty && phone.isNotEmpty) {
  //                 final currentUser = FirebaseAuth.instance.currentUser;
  //                 if (currentUser != null) {
  //                   final friendId = uuid.v4();
  //
  //                   String profilePic = selectedGender == 'male' ? 'images/male_iocn.png' : 'images/3430601_avatar_female_normal_woman_icon.png';
  //
  //                   // final newFriend = Friend(
  //                   //   userId: userId,
  //                   //   friendId: friendId,
  //                   //   name: name,
  //                   //   profilePic: "images/3430601_avatar_female_normal_woman_icon.png",
  //                   //   upcomingEvents: 0,
  //                   // );
  //                   //
  //                   //
  //                   // await _dbHelper.insertFriend(newFriend);
  //                   // _loadFriends();
  //                   final friendData = {
  //                     'friendId': friendId,
  //                     'name': name,
  //                     'profilePic': profilePic,
  //                     'upcomingEvents': 0,
  //                   };
  //
  //                   await FirestoreHelper.addFriend(
  //                       currentUser.uid, friendData);
  //                   _loadFriends();
  //
  //                   Navigator.pop(context);
  //                 } else {
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     SnackBar(content: Text("Please fill in all fields.")),
  //                   );
  //                 }
  //               }
  //             }),
  //       ],
  //     ),
  //   );
  // }

  void _showManualAddDialog() {
    TextEditingController emailController = TextEditingController();
    String name = "";
    String phone = "";
    String selectedGender = 'male';
    final genderOptions = ['male', 'female'];

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
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Friend's Email"),
            ),
            SizedBox(height: 16),
            DropdownButton<String>(
              value: selectedGender,
              items: genderOptions.map((String gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender.toUpperCase()),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  selectedGender = newValue;
                }
              },
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
              final email = emailController.text.trim();
              if (email.isNotEmpty) {
                final userQuery = await FirebaseFirestore.instance
                    .collection('users')
                    .where('email', isEqualTo: email)
                    .get();

                if (userQuery.docs.isNotEmpty) {
                  final friendDoc = userQuery.docs.first;
                  final friendData = friendDoc.data();
                  final currentUser = FirebaseAuth.instance.currentUser;

                  if (currentUser != null) {
                    String profilePic = selectedGender == 'male'
                        ? 'images/male_iocn.png'
                        : 'images/3430601_avatar_female_normal_woman_icon.png';

                    final friend = {
                      'friendId': friendDoc.id,
                      'name': friendData['name'],
                      'profilePic': profilePic,
                      'upcomingEvents': '',
                      'userId': currentUser.uid,
                    };
                    await FireStoreHelper().addFriend(currentUser.uid, friend);
                    _loadFriends();
                    Navigator.pop(context);
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text("No registered user found with this email.")),
                  );
                }
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
      List<Contact> contacts =
          await FlutterContacts.getContacts(withProperties: true);

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
                  subtitle: Text(contact.phones.isNotEmpty
                      ? contact.phones.first.number
                      : "No Phone"),
                  onTap: () async {
                    if (contact.phones.isNotEmpty) {
                      final currentUser = FirebaseAuth.instance.currentUser;
                      if (currentUser != null) {
                        final friendId = uuid.v4();

                        final friendData = (
                          friendId: friendId,
                          name: contact.displayName,
                          profilePic:
                              "images/3430601_avatar_female_normal_woman_icon.png",
                          upcomingEvents: 0,
                        );
                        await FirestoreHelper.addFriend(currentUser.uid,
                            friendData as Map<String, dynamic>);
                        _loadFriends();
                      }
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
        content: Text(
            "Contacts permission is required to access your contact list."),
      ));
    }
  }

  Future<void> _fetchUnreadNotifications() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('receiverId', isEqualTo: currentUser.uid)
          .where('isRead', isEqualTo: false)
          .get();

      final fetchedNotifications = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'senderName': doc['senderName'],
          'giftName': doc['giftName'],
          'isRead': doc['isRead'],
        };
      }).toList();

      setState(() {
        notifications = fetchedNotifications;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching notifications: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _markNotificationAsRead(String notificationId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});

    setState(() {
      notifications.removeWhere((notification) => notification['id'] == notificationId);
    });
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
              // _buildMenuItem('Gift Details', '/giftDetails'),
              _buildMenuItem('Profile', '/profile'),
              _buildMenuItem('My Pledged Gifts', '/pledgedGifts'),
            ],
          ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(appUser?.name ?? "User"),
              accountEmail: Text(appUser?.email ?? "example@example.com"),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage(
                    'images/bro sora .png'),
                backgroundColor: Colors.grey[200],
              ),
              decoration: BoxDecoration(
                color: Color(0XFF996CF3),
              ),
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text("Log Out"),
              onTap: () async {
                await myAuth.sign_out(context);
              },
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(
        child: LoadingAnimationWidget.inkDrop(
          color: Color(0XFF996CF3),
          size: 60,
        ),
      )
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventListPage(),
                  ),
                );
              },
              child: Text("Create Your Own Event/List"),
            ),
          ),

          Expanded(
            child: friends.isEmpty
                ? Center(
              child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'animation/purplish.json',
                    width: 350,
                    height: 350,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "No friends found. Add a friend to get started!",
                    style:
                    TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(
                  vertical: 8.0, horizontal: 16.0),
              itemCount: friends.length,
              itemBuilder: (context, index) {
                final friend = friends[index];
                return Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(friend.gender ==
                          'male'
                          ? 'images/male_iocn.png'
                          : 'images/3430601_avatar_female_normal_woman_icon.png'),
                    ),
                    title: Text(friend.name),
                    subtitle: Text(friend.upcomingEvents > 0
                        ? "Upcoming Events: ${friend.upcomingEvents}"
                        : "No Upcoming Events"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_forward),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FriendEventList(
                                      userId: FirebaseAuth
                                          .instance.currentUser!.uid,
                                      friendId: friend.friendId,
                                      friendName: friend.name,
                                    ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon:
                          Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final shouldDelete =
                            await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text("Delete Friend"),
                                content: Text(
                                    "Are you sure you want to delete ${friend.name}?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(
                                        context, false),
                                    child: Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(
                                        context, true),
                                    child: Text("Delete"),
                                  ),
                                ],
                              ),
                            );

                            if (shouldDelete ?? false) {
                              await FirestoreHelper.deleteFriend(
                                  friend.friendId);
                              _loadFriends();
                            }
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


  Future<List<AppNotification>> fetchNotificationsForUser(String userId) async {
    if (userId.isEmpty) {
      print("Error: User ID is empty");
      return [];
    }

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return AppNotification.fromFirestore(data);
        }).toList();
      } else {
        print("No unread notifications found.");
        return [];
      }
    } catch (e) {
      print("Error fetching notifications: $e");
      return [];
    }
  }






  //
  // Future<void> requestNotificationPermission() async {
  //   if (await Permission.notification.isDenied) {
  //     final result = await Permission.notification.request();
  //
  //     if (result.isGranted) {
  //       print("Notification permission granted.");
  //     } else {
  //       print("Notification permission denied.");
  //     }
  //   }
  // }
  Future<void> requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission for notifications
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Notification permission granted.');
    } else {
      print('Notification permission denied.');
    }
  }



}





void _listenForNotifications() {
  final currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    FirebaseFirestore.instance
        .collection('notifications')
        .where('recipientId', isEqualTo: currentUser.uid)
        //.where('read', isEqualTo: false) // Unread notifications only
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      for (var doc in snapshot.docs) {
        final notification = doc.data() as Map<String, dynamic>;
        _showLocalNotification(notification['senderName'], notification['giftName']);

        // Mark notification as read
      //  doc.reference.update({'read': true});
      }
    });
  }
}

// void _showLocalNotification(String senderName, String giftName) async {
//   const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//     'gift_channel', // Unique channel ID
//     'Gift Notifications', // Channel name
//     importance: Importance.high,
//     priority: Priority.high,
//   );
//
//   const NotificationDetails notificationDetails = NotificationDetails(
//     android: androidDetails,
//   );
//
//   await flutterLocalNotificationsPlugin.show(
//     0, // Notification ID
//     'Gift Pledged!',
//     'Your friend $senderName pledged your gift "$giftName".',
//     notificationDetails,
//   );
// }

// void _listenForFriendNotifications() {
//   final currentUser = FirebaseAuth.instance.currentUser;
//
//   if (currentUser != null) {
//     FirebaseFirestore.instance
//         .collection('friends')
//         .where('userId', isEqualTo: currentUser.uid)
//         .snapshots()
//         .listen((QuerySnapshot snapshot) {
//       for (var change in snapshot.docChanges) {
//         if (change.type == DocumentChangeType.added) {
//           final newFriend = change.doc.data() as Map<String, dynamic>;
//           print("New friend added: ${newFriend['name']}");
//           _showNotification(newFriend['name']);
//         }
//       }
//     });
//   }
// }
// void _testNotification() {
//   _showNotification("Test Friend");
// }
//
//
//
// void _showNotification(String friendName) async {
//   const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//     'friend_channel', // Channel ID
//     'Friend Notifications', // Channel Name
//     importance: Importance.high,
//     priority: Priority.high,
//   );
//
//   const NotificationDetails notificationDetails =
//   NotificationDetails(android: androidDetails);
//
//   await flutterLocalNotificationsPlugin.show(
//     0, // Notification ID
//     'New Friend Added', // Notification Title
//     'You added $friendName as a friend!', // Notification Body
//     notificationDetails,
//   );
// }


// class _selectContactFromList {
// }
//
// class _showManualAddDialog {
// }

// void _showLocalNotification(String senderName, String giftName) async {
//   const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//     'gift_channel', // Channel ID (must be unique for each channel)
//     'Gift Notifications', // Channel name
//     channelDescription: 'Notifications for pledged gifts', // Optional channel description
//     importance: Importance.max, // High importance to show heads-up notification
//     priority: Priority.high, // Forces heads-up notification
//     playSound: true, // Ensure sound is played
//    // enableVibration: true, // Vibrate when notification is shown
//     ticker: 'Gift Pledged Notification', // Optional ticker text
//   );
//
//   const NotificationDetails notificationDetails = NotificationDetails(
//     android: androidDetails,
//   );
//
//   await flutterLocalNotificationsPlugin.show(
//     0, // Notification ID
//     'Gift Pledged!', // Notification title
//     'Your friend $senderName pledged your gift "$giftName".', // Notification body
//     notificationDetails,
//   );
// }

void _showLocalNotification(String title, String body) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'gift_channel', // Channel ID (must match the created channel)
    'Gift Notifications', // Channel name
    channelDescription: 'Notifications for pledged gifts', // Channel description
    importance: Importance.max, // High importance ensures heads-up notification
    priority: Priority.high, // Forces heads-up display
    playSound: true, // Plays sound when notification appears
    enableVibration: true, // Enables vibration
    ticker: 'Gift Pledged Notification', // Optional ticker text
    timeoutAfter: 4000, // Auto-dismiss notification after 4 seconds
  );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    0, // Notification ID (unique for each notification)
    title, // Notification title
    body, // Notification body
    notificationDetails,
  );
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FriendEventList(
                  userId: FirebaseAuth.instance.currentUser!.uid,
                  friendId: friend.friendId,
                  friendName: friend.name,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
