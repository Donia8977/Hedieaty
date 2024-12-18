import 'package:flutter/material.dart';
import 'package:flutter_contacts/properties/event.dart';
import 'package:hedieaty/models/Event.dart';
import 'package:provider/provider.dart';
import '../controllers/DatabaseHelper.dart';
import '../models/Gift.dart';
import 'EventListPage.dart';
import 'PledgedGifts.dart';
import '../models/AppUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ProfilePage extends StatefulWidget {

  final AppUser user;

  const ProfilePage({super.key , required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

 // late final User? user;

 // DatabaseHelper _dbHelper = DatabaseHelper();

late AppUser currentUser;
late Future<List<Gift>> pledgedGifts;
late Future<List<AppEvent>> createdEvents;
bool isLoading = true;

@override
void initState() {
  super.initState();
  currentUser = widget.user;
  _fetchUserData();

  // pledgedGifts = DatabaseHelper.getPledgedGiftsByUserId(currentUser.id!);
  // createdEvents = DatabaseHelper.getEventsByUserId(currentUser.id!) ;
}

  Future<void> _fetchUserData() async {

  setState(() {
    isLoading = true ;
  });


    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.id).get();

      if (userDoc.exists) {
        setState(() {
          currentUser = AppUser.fromFirestore(userDoc);
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }

    finally{
      setState(() {
        isLoading = false;
      });
    }

  }




  @override
  Widget build(BuildContext context) {

    return Scaffold(

        appBar: AppBar(
        backgroundColor: Color(0XFF996CF3),
    title: Text('Profile', style: TextStyle(color: Colors.white)),

          actions: [
            PopupMenuButton<String>(
              color: Color(0XFF996CF3),
              onSelected: (String route) => Navigator.pushNamed(context, route),
              itemBuilder: (context) => [
                _buildMenuItem('Home', '/home'),
                _buildMenuItem('Event List', '/eventList'),
                _buildMenuItem('Gift Details', '/giftDetails'),
                _buildMenuItem('Profile', '/profile'),
                _buildMenuItem('My Pledged Gifts', '/pledgedGifts'),
              ],
            ),
          ],


        ),



      body: isLoading
          ? Center(
        child: LoadingAnimationWidget.inkDrop(
          color: Color(0XFF996CF3),
          size: 60,
        ),
      )

       : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileInfo(currentUser, context),
            const SizedBox(height: 20),
            _buildCreatedEventsSection(context),
            const SizedBox(height: 20),
            _buildPledgedGiftsLink(context),
            const SizedBox(height: 20),
            _buildNotificationSettings(currentUser),
          ],
        ),
      ),


    );
  }


  Widget _buildProfileInfo(AppUser user, BuildContext context) {
    return Card(
      child: ListTile(
       // leading: CircleAvatar(child: Icon(Icons.person)),
        leading: CircleAvatar(
          backgroundImage: AssetImage(
            user.profilePic != null && user.profilePic!.isNotEmpty
                ? user.profilePic!
                : 'images/bro sora .png',
          ),
          // child: user.profilePic == null || user.profilePic!.isEmpty
          //     ? Icon(Icons.person, size: 40)
          //     : null,
        ),
        title: Text(user.name ?? " No name "),
        subtitle: Text(user.email ?? " No email"),
        trailing: IconButton(
          icon: Icon(Icons.edit),
          onPressed: () => _showEditProfileDialog(context),
        ),
      ),
    );
  }


  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(text: currentUser.name);
    final emailController = TextEditingController(text: currentUser.email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
          ],
        ),
        actions: [

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),

          TextButton(onPressed: () async {

            setState(() {
              currentUser.name = nameController.text;
              currentUser.email = emailController.text;
            });
          //  await _dbHelper.updateUesrs(currentUser);
            await FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser.id)
                .update({
              'name': currentUser.name,
              'email': currentUser.email,
            });
            Navigator.pop(context);

          },

              child: Text("Save"))


        ],
      ),
    );
  }


  Widget _buildCreatedEventsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Created Events", style: Theme.of(context).textTheme.titleLarge),
        ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EventListPage()),
          ),
          child: Text("View Created Events"),
        ),
      ],
    );
  }

  Widget _buildPledgedGiftsLink(BuildContext context) {
    return ListTile(
      title: Text("My Pledged Gifts"),
      trailing: Icon(Icons.arrow_forward),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyPledgedGiftsPage(friendId: null,
        eventId: null,)),
      ),
    );
  }

  Widget _buildNotificationSettings(AppUser user) {
    return SwitchListTile(
      title: Text("Notifications"),
      value:  user.notificationsEnabled,
      onChanged: (newValue) async {

        setState(() {
          user.notificationsEnabled = newValue;
        });

       // await _dbHelper.updateUesrs(user);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.id)
            .update({
          'name': currentUser.name,
          'email': currentUser.email,
        });
      },
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




}

//
// void _showEditProfileDialog(BuildContext context) {
//   //final userProvider = Provider.of<UserProvider>(context, listen: false);
//   final nameController = TextEditingController(text: currentUser.name);
//   final emailController = TextEditingController(text: currentUser.email);
//
//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: Text("Edit Profile"),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           TextField(
//             controller: nameController,
//             decoration: InputDecoration(labelText: "Name"),
//           ),
//           TextField(
//             controller: emailController,
//             decoration: InputDecoration(labelText: "Email"),
//           ),
//         ],
//       ),
//       actions: [
//         // TextButton(
//         //   onPressed: () {
//         //     // userProvider.updateUser(
//         //     //   nameController.text,
//         //     //   emailController.text,
//         //     //   userProvider.user.notificationsEnabled,
//         //     // );
//         //
//         //     Navigator.pop(context);
//         //
//         //   },
//         //   child: Text("Save"),
//         // ),
//
//
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: Text("Cancel"),
//         ),
//
//         TextButton(onPressed: () async {
//
//           setState(() {
//             currentUser.name = nameController.text;
//             currentUser.email = emailController.text;
//           });
//           await _dbHelper.updateUesrs(currentUser);
//           Navigator.pop(context);
//
//
//
//         },
//
//
//
//
//
//
//
//             child: Text("Save"))
//
//
//       ],
//     ),
//   );
// }





