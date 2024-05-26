import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fresh_harvest/appconfig/myconfig.dart';

class UploadDocuments extends StatefulWidget {
  @override
  _UploadDocumentsState createState() => _UploadDocumentsState();
}

class _UploadDocumentsState extends State<UploadDocuments> {
  File? _document;
  bool _isUploaded = false;
  final picker = ImagePicker();

  Future<void> _pickDocument() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _document = File(pickedFile.path);
      } else {
        print('No document selected.');
      }
    });
  }

  Future<void> _uploadDocument() async {
    if (_document == null) {
      Fluttertoast.showToast(msg: 'Please select a document first');
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId') ?? '';

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${MyConfig().SERVER}/fresh_harvest/php/upload_documents.php'),
    );

    request.fields['user_id'] = userId;
    request.files.add(await http.MultipartFile.fromPath('document', _document!.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: 'Document uploaded successfully');
      setState(() {
        _isUploaded = true;
      });
    } else {
      Fluttertoast.showToast(msg: 'Failed to upload document');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Documents'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _pickDocument,
              child: const Text('Select Document'),
            ),
            _document == null
                ? const Text('No document selected.')
                : Text('Document: ${_document!.path}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadDocument,
              child: const Text('Upload'),
            ),
            if (_isUploaded)
              Column(
                children: [
                  const SizedBox(height: 20),
                  const Text('Please wait for 3-5 business days'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _pickDocument,
                    child: const Text('Modify Documents'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
