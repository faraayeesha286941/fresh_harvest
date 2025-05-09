import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  TextEditingController productNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  String _selectedCategory = 'Fruits';
  File? _image;

  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> addProduct() async {
    if (_image == null) {
      Fluttertoast.showToast(msg: 'Please select an image');
      return;
    }

    // Get user ID from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId') ?? '1'; // Default to '1' for testing purposes

    try {
      DatabaseReference counterRef = FirebaseDatabase.instance.ref().child('product_counter');
      DatabaseReference productRef = FirebaseDatabase.instance.ref().child('db_product');

      // Get the current counter value
      DatabaseEvent counterEvent = await counterRef.once();
      int currentCounter = counterEvent.snapshot.value as int;
      int newProductId = currentCounter + 1;

      // Update the counter
      await counterRef.set(newProductId);

      // Upload image to Firebase Storage
      String imageName = 'products/${newProductId}_1.jpg';
      await FirebaseStorage.instance.ref(imageName).putFile(_image!);
      String imageUrl = await FirebaseStorage.instance.ref(imageName).getDownloadURL();

      // Prepare product data
      Map<String, dynamic> productData = {
        'amount': int.parse(amountController.text),
        'category': _selectedCategory,
        'date_reg': DateTime.now().toIso8601String(),
        'place_location': locationController.text,
        'price': double.parse(priceController.text),
        'product_description': descriptionController.text,
        'product_id': newProductId,
        'product_name': productNameController.text,
        'seller_id': userId,
        'seller_name': 'Added by Admin',
        'image_url': imageUrl,
      };

      // Save product data to Firebase Realtime Database
      await productRef.child(newProductId.toString()).set(productData);

      Fluttertoast.showToast(msg: 'Product added successfully');
      Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to add product');
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: productNameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            Row(
              children: [
                Text('Category', style: TextStyle(fontSize: 16)),
                SizedBox(width: 16), // Add some space between the text and dropdown
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                      });
                    },
                    items: <String>['Fruits', 'Vegetables']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            TextField(
              controller: amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: locationController,
              decoration: InputDecoration(labelText: 'Location'),
            ),
            SizedBox(height: 20),
            _image == null
                ? Text('No image selected.')
                : Image.file(_image!),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: getImage,
              child: Text('Select Image'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: addProduct,
              child: Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}
