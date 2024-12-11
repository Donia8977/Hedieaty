import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:hedieaty/controllers/FireStoreHelper.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../models/Gift.dart';


class MyPledgedGiftsPage extends StatefulWidget {
  const MyPledgedGiftsPage({super.key});

  @override
  State<MyPledgedGiftsPage> createState() => _MyPledgedGiftsPageState();
}

class _MyPledgedGiftsPageState extends State<MyPledgedGiftsPage> {

  List<Gift> gifts = [];
  final FireStoreHelper fireStoreHelper = FireStoreHelper();
  bool isLoading = true;

  // @override
  // void initState() {
  //   super.initState();
  //   fetchGifts(widget.eventId);
  // }

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
