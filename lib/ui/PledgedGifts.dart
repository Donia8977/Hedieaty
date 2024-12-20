import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/models/PledgedGift.dart';
import 'package:lottie/lottie.dart';
import 'package:hedieaty/controllers/FireStoreHelper.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../models/AppUser.dart';
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

      if (pledgedGiftsSnapshot.docs.isEmpty) {
        setState(() {
          gifts = [];
          isLoading = false;
        });
        return;
      }

      final friendIds = pledgedGiftsSnapshot.docs
          .map((doc) => doc['friendId'] as String)
          .toSet()
          .toList();

      final friendDocs = await firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: friendIds)
          .get();
      // List<AppUser>giftOwners =[];
      //
      // for (var doc in friendDocs.docs){
      //   giftOwners.add(AppUser.fromMap(doc.data()));
      //
      // }

      final Map<String, String> friendIdToName = {
        for (var doc in friendDocs.docs)
          doc.id: (doc.data()['name'] ?? 'Unknown Friend') as String
      };

      final List<Gift> fetchedGifts = [];
      for (var pledgedGiftDoc in pledgedGiftsSnapshot.docs) {
        final pledgedGift = pledgedGiftDoc.data() as Map<String, dynamic>;


        final giftDoc = await firestore.collection('giftLists').doc(pledgedGift['giftId']).get();

        if (giftDoc.exists) {
          final giftData = giftDoc.data() as Map<String, dynamic>;

          final friendId = pledgedGift['friendId'];
          final friendName = friendIdToName[friendId] ?? 'Unknown Friend';

          fetchedGifts.add(Gift(
            id: pledgedGift['giftId'],
            name: giftData['name'],
            category: giftData['category'],
            price: giftData['price'].toDouble(),
            status: giftData['status'],
            eventId: giftData['eventId'],
            friendName: friendName,
            imageBase64: giftData['imageBase64'],
          ));
        }
      }

      //linkGiftToGiftOwner(gifts: gifts, pledgedGifts: pledgedGifts, users: giftOwners);

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
                // _buildMenuItem('Gift List', '/giftList'),
                // _buildMenuItem('Gift Details', '/giftDetails'),
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
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: gift.imageBase64 != null && gift.imageBase64!.isNotEmpty
                    ? MemoryImage(base64Decode(gift.imageBase64!))
                    : AssetImage('images/gift.png') as ImageProvider,
              ),
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

class PledgedItemEntity{
  final Gift gift;
  final AppUser giftOwner;

  PledgedItemEntity({required this.gift, required this.giftOwner});

}


// List<PledgedItemEntity>linkGiftToGiftOwner({required List<Gift> gifts, required List<PledgedGift>pledgedGifts,required List<AppUser> users}){
//   List<PledgedItemEntity> result = [];
//   for (var pledgedGift in pledgedGifts){
//     var giftOwner = users.firstWhere((user)=>user.id == pledgedGift.friendId);
//     var gift = gifts.firstWhere((gift)=>gift.id == pledgedGift.giftId);
//
//     result.add(PledgedItemEntity(gift: gift, giftOwner: giftOwner));
//
//   }
//   return result;
//
// }