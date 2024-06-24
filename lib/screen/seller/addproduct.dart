import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fresh_harvest/appconfig/myconfig.dart';

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

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${MyConfig().SERVER}/fresh_harvest/php/addproduct.php'),
    );
    request.fields['product_name'] = productNameController.text;
    request.fields['product_description'] = descriptionController.text;
    request.fields['price'] = priceController.text;
    request.fields['category'] = _selectedCategory;
    request.fields['location'] = locationController.text;
    request.fields['amount'] = amountController.text;
    request.fields['seller_id'] = '1'; // Replace with actual seller ID
    request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

    print('Sending request with fields: ${request.fields}'); // Debugging print

    var response = await request.send();

    if (response.statusCode == 200) {
      response.stream.transform(utf8.decoder).listen((value) {
        print("Response: $value");  // Log the response
        if (value.contains('success')) {
          Fluttertoast.showToast(msg: 'Product added successfully');
          Navigator.pop(context);
        } else {
          Fluttertoast.showToast(msg: value);
        }
      });
    } else {
      Fluttertoast.showToast(msg: 'Failed to add product');
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
