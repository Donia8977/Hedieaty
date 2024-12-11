import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../controllers/DatabaseHelper.dart';
import '../models/Gift.dart';
import 'GiftList.dart';
import 'package:hedieaty/controllers/FireStoreHelper.dart';

void main() => runApp(MaterialApp(home: GiftDetailsPage()));

class GiftDetailsPage extends StatefulWidget {


  final Map<String, dynamic>? gift;


  GiftDetailsPage({this.gift});

  @override
  State<GiftDetailsPage> createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  bool isPledged = false;
  bool isEditingAllowed = true;
  File? imageFile;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.gift != null) {
      nameController.text = widget.gift?['name'] ?? '';
      descriptionController.text = widget.gift?['description'] ?? '';
      categoryController.text = widget.gift?['category'] ?? '';
      priceController.text = widget.gift?['price']?.toString() ?? '';
      isPledged = widget.gift?['pledged'] ?? false;
      isEditingAllowed = !isPledged;
    }
    else{

      nameController.text = '';
      descriptionController.text = '';
      categoryController.text = '';
      priceController.text = '';
      isPledged = false;
      isEditingAllowed = true;

    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  final uuid = Uuid();


  Future<void> _saveGift() async {
    if (nameController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        categoryController.text.isNotEmpty &&
        priceController.text.isNotEmpty) {

      final newGift = {
        'id': widget.gift?['id'] ?? uuid.v4(),
        'name': nameController.text,
        'description': descriptionController.text,
        'category': categoryController.text,
        'price': double.tryParse(priceController.text) ?? 0.0,
        'pledged': isPledged,
        'status': isPledged ? 'Pledged' : 'Available',
        'eventId': widget.gift?['eventId'] ?? '',
      };

      final dbHelper = DatabaseHelper();
      if (widget.gift == null)  {
       // newGift['id'] = uuid.v4();
        int generatedId = await dbHelper.insertGift(Gift.fromMap(newGift));
        print('Generated Gift ID: $generatedId');
      } else {

        print('Updating gift with ID: ${widget.gift?['id']}');

        final giftId = widget.gift?['id'];
        final updatedGift = Gift.fromMap({...newGift, 'id': giftId});
        await dbHelper.updateGift(updatedGift);
      }

      Navigator.pop(context, newGift);
    //  print("Gift saved!");

    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
      backgroundColor: Color(0XFF996CF3),
      title: Text('Gift Details', style: TextStyle(color: Colors.white)),
         // title: Text(gift['name']),
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

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Gift Name'),
              enabled: isEditingAllowed,
            ),
            SizedBox(height: 10),

            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              enabled: isEditingAllowed,
              maxLines: 3,
            ),
            SizedBox(height: 10),

            TextField(
              controller: categoryController,
              decoration: InputDecoration(labelText: 'Category'),
              enabled: isEditingAllowed,
            ),
            SizedBox(height: 10),

            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              enabled: isEditingAllowed,
            ),
            SizedBox(height: 10),

            Row(
              children: [
                Text('Upload Image:'),
                SizedBox(width: 10),
                imageFile == null
                    ? IconButton(
                  icon: Icon(Icons.image),
                  onPressed: isEditingAllowed ? _pickImage : null,
                )
                    : Image.file(imageFile!, width: 100, height: 100),
              ],
            ),
            SizedBox(height: 20),

            Row(
              children: [
                Text('Status:'),
                SizedBox(width: 10),
                Switch(
                  value: isPledged,
                  onChanged: isEditingAllowed
                      ? (value) {
                    setState(() {
                      isPledged = value;
                    });
                  }
                      : null,
                ),
                Text(isPledged ? 'Pledged' : 'Available'),
              ],
            ),
            SizedBox(height: 20),

            ElevatedButton(
             // onPressed: _saveGift,

              onPressed: () async {
                await _saveGift();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GiftListPage(eventId: 'id',),
                  ),
                );
              },
              child: Text(widget.gift == null ? 'Add Gift' : 'Update Gift'),



            ),
          ],
        ),
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
