import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class SellerRegistration extends StatefulWidget {
  const SellerRegistration({super.key});

  @override
  _SellerRegistrationState createState() => _SellerRegistrationState();
}

class _SellerRegistrationState extends State<SellerRegistration> {
  late File _image;
  final picker = ImagePicker();

  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery, maxHeight: 500, maxWidth: 500, imageQuality: 100);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }


  Future uploadImage() async {
    var request = http.MultipartRequest('POST', Uri.parse('https://example.com/register_seller.php'));
    request.files.add(await http.MultipartFile.fromPath('image', _image.path, contentType: MediaType('image', 'jpeg')));
    var response = await request.send();

    if (response.statusCode == 200) {
      setState(() {
        File? image;
      });
      print('Uploaded successfully');
    } else {
      print('Error uploading');
    }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seller Registration')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: getImage,
              child: _image == null
                  ? Image.asset('assets/upload.jpg')
                  : Image.file(_image),
            ),
            ElevatedButton(
              onPressed: uploadImage,
              child: const Text('Submit'),
            ),
            const Text('Your documents are being reviewed. Please wait 3-5 business days.')
          ],
        ),
      ),
    );
  }
}
