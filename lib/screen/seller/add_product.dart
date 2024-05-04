import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  File? _image;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  setState(() {
    if (pickedFile != null) {
      _image = File(pickedFile.path);
    } else {
      print('No image selected.');
    }
  });
}

  Future<void> _uploadProduct() async {
    var uri = Uri.parse('http://your-server-ip/addproduct.php');
    var request = http.MultipartRequest('POST', uri);
    request.fields['product_name'] = _nameController.text;
    request.fields['description'] = _descriptionController.text;
    request.fields['amount'] = _amountController.text;
    request.fields['location'] = _locationController.text;
    if (_image != null) {
      var stream = http.ByteStream(Stream.castFrom(_image!.openRead()));
      var length = await _image!.length();
      var multipartFile = http.MultipartFile('image', stream, length,
          filename: basename(_image!.path));
      request.files.add(multipartFile);
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      print('Product added successfully');
    } else {
      print('Failed to add product');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadProduct,
              child: const Text('Upload Product'),
            ),
          ],
        ),
      ),
    );
  }
}