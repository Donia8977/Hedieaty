import 'dart:convert';

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

  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  bool isPledged = false;
  bool isEditingAllowed = true;
  File? imageFile;
  final picker = ImagePicker();

  String? imageBase64;


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

      imageBase64 = widget.gift?['imageBase64'];
    }
    else {
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
        imageBase64 = null;
      });
    }
  }

  final uuid = Uuid();


  Future<void> _saveGift() async {
    // if (nameController.text.isNotEmpty &&
    //     descriptionController.text.isNotEmpty &&
    //     categoryController.text.isNotEmpty &&
    //     priceController.text.isNotEmpty) {
    if (_formKey.currentState?.validate() ?? false) {

      String? base64Image;

      if (imageFile != null) {
        base64Image = await convertFileToBase64(imageFile!);
      }


      final newGift = {
        'id': widget.gift?['id'] ?? uuid.v4(),
        'name': nameController.text,
        'description': descriptionController.text,
        'category': categoryController.text,
        'price': double.tryParse(priceController.text) ?? 0.0,
        'pledged': isPledged,
        'status': isPledged ? 'Pledged' : 'Available',
        'eventId': widget.gift?['eventId'] ?? '',
        'imageBase64': base64Image ?? imageBase64,
      };

      if (widget.gift == null) {
        try {
          final generatedId = await FireStoreHelper().addGift(newGift);
          newGift['id'] = generatedId;
          print('Gift added successfully with ID: $generatedId');
        } catch (e) {
          print("Error adding gift: $e");
        }
      } else {
        final giftId = widget.gift?['id'];
        if (giftId != null) {
          try {
            await FireStoreHelper().updateGift(giftId, newGift);
            print('Gift updated successfully in Firestore.');
          } catch (e) {
            print("Error updating gift in Firestore: $e");
          }
        } else {
          print("Error: Gift ID is null. Cannot update gift.");
        }
      }

      Navigator.pop(context, newGift);
    } else {
      print("Error: All fields must be filled.");
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
            itemBuilder: (context) =>
            [
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

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Gift Name'),
                validator: (value) =>
                value == null || value.trim().isEmpty ? 'Name is required' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Description is required'
                    : null,
                maxLines: 3,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: categoryController,
                decoration: InputDecoration(labelText: 'Category'),
                validator: (value) =>
                value == null || value.trim().isEmpty ? 'Category is required' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  final price = double.tryParse(value ?? '');
                  if (value == null || value.trim().isEmpty) {
                    return 'Price is required';
                  } else if (price == null || price <= 0) {
                    return 'Enter a valid positive price';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text('Upload Image:'),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: _pickImage,
                    child: imageFile != null
                        ? Image.file(imageFile!, width: 100, height: 100)
                        : (imageBase64 != null && imageBase64!.isNotEmpty)
                        ? Image.memory(base64Decode(imageBase64!),
                        width: 100, height: 100)
                        : Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(Icons.image,
                            size: 40, color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveGift,
                child: Text(widget.gift == null ? 'Add Gift' : 'Update Gift'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


  Future<String> convertFileToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
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

