import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fresh_harvest/appconfig/myconfig.dart';

class DeleteProduct extends StatefulWidget {
  @override
  _DeleteProductState createState() => _DeleteProductState();
}

class _DeleteProductState extends State<DeleteProduct> {
  TextEditingController productIdController = TextEditingController();

  Future<void> deleteProduct() async {
    final response = await http.post(
      Uri.parse('${MyConfig().SERVER}/fresh_harvest/php/deleteproduct.php'),
      body: {
        'product_id': productIdController.text,
      },
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['message'] == 'success') {
        Fluttertoast.showToast(msg: 'Product deleted successfully');
      } else {
        Fluttertoast.showToast(msg: jsonResponse['message']);
      }
    } else {
      Fluttertoast.showToast(msg: 'Failed to connect to the server');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete Product'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: productIdController,
                decoration: InputDecoration(
                  labelText: 'Product ID',
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.all(8.0),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: deleteProduct,
                child: Text('Delete Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
