import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
      // Prepopulate fields if editing an existing gift
      nameController.text = widget.gift?['name'] ?? '';
      descriptionController.text = widget.gift?['description'] ?? '';
      categoryController.text = widget.gift?['category'] ?? '';
      priceController.text = widget.gift?['price']?.toString() ?? '';
      isPledged = widget.gift?['pledged'] ?? false;
      isEditingAllowed = !isPledged;
    }
  }

  // Pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  // Save or update gift
  void _saveGift() {
    if (nameController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        categoryController.text.isNotEmpty &&
        priceController.text.isNotEmpty) {
      // Add or update the gift based on the gift data (this is just a mock)
      print("Gift saved!");
      // Here you would normally save the data to a database or API
      Navigator.pop(context);
    }
  }










  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
      backgroundColor: Color(0XFF996CF3),
      title: Text('Gift Details', style: TextStyle(color: Colors.white)),
      actions: [
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

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Name Input Field
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Gift Name'),
              enabled: isEditingAllowed,
            ),
            SizedBox(height: 10),

            // Description Input Field
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              enabled: isEditingAllowed,
              maxLines: 3,
            ),
            SizedBox(height: 10),

            // Category Input Field
            TextField(
              controller: categoryController,
              decoration: InputDecoration(labelText: 'Category'),
              enabled: isEditingAllowed,
            ),
            SizedBox(height: 10),

            // Price Input Field
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              enabled: isEditingAllowed,
            ),
            SizedBox(height: 10),

            // Image Upload
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

            // Status Toggle (Available/Pledged)
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

            // Save/Update Button
            ElevatedButton(
              onPressed: _saveGift,
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
