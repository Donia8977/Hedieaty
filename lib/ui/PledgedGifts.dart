import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:hedieaty/controllers/FireStoreHelper.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../models/Gift.dart';


class MyPledgedGiftsPage extends StatefulWidget {

 // final List<Gift>? pledgedGifts;
  final String? friendId;
  final String? eventId;

  const MyPledgedGiftsPage({super.key , required this.friendId, required this.eventId});

  @override
  State<MyPledgedGiftsPage> createState() => _MyPledgedGiftsPageState();
}

class _MyPledgedGiftsPageState extends State<MyPledgedGiftsPage> {

  List<Gift> gifts = [];
  final FireStoreHelper fireStoreHelper = FireStoreHelper();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isLoading = true;
  final currentUser = FirebaseAuth.instance.currentUser;

  // @override
  // void initState() {
  //   super.initState();
  //   fetchGifts(widget.eventId);
  // }

  @override
  void initState() {
    super.initState();
    _loadPledgedGifts();
  }


  Future<void> _loadPledgedGifts() async {
    setState(() {
      isLoading = true;
    });

    try {

      Query query = firestore.collection('pledgedGift').where('userId', isEqualTo: currentUser!.uid);

      if (widget.friendId != null) {
        query = query.where('friendId', isEqualTo: widget.friendId);
      }
      if (widget.eventId != null) {
        query = query.where('eventId', isEqualTo: widget.eventId);
      }

      final pledgedGiftsSnapshot = await query.get();

      final List<Gift> fetchedGifts = [];
      for (var pledgedGiftDoc in pledgedGiftsSnapshot.docs) {
        final pledgedGift = pledgedGiftDoc.data() as Map<String, dynamic>;
        final giftDoc = await firestore.collection('giftLists').doc(pledgedGift['giftId']).get();

        if (giftDoc.exists) {
          final giftData = giftDoc.data() as Map<String, dynamic>;
          fetchedGifts.add(Gift(
            id: pledgedGift['giftId'],
            name: giftData['name'],
            category: giftData['category'],
            price: giftData['price'].toDouble(),
            status: giftData['status'],
            eventId: giftData['eventId'],
            friendName: '',
          ));
        }
      }

      setState(() {
        gifts = fetchedGifts;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading pledged gifts: $e");
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
          title: Text('Pledged Gifts', style: TextStyle(color: Colors.white)),

          actions: [
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

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : gifts.isEmpty
          ? Center(
        child: Lottie.asset(
          'animation/purplish.json',
          width: 350,
          height: 350,
          fit: BoxFit.contain,
        ),
      )
          : ListView.builder(
        itemCount: gifts.length,
        itemBuilder: (context, index) {
          final gift = gifts[index];
          return Card(
            child: ListTile(
              title: Text(gift.name),
              subtitle: Text('${gift.category} - ${gift.price}'),
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
