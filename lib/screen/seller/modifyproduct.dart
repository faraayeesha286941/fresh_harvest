import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fresh_harvest/appconfig/myconfig.dart';

class ModifyProduct extends StatefulWidget {
  @override
  _ModifyProductState createState() => _ModifyProductState();
}

class _ModifyProductState extends State<ModifyProduct> {
  TextEditingController productIdController = TextEditingController();
  TextEditingController productNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  bool _isLoading = false;
  bool _isProductFetched = false;

  Future<void> fetchProduct() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(
      Uri.parse('${MyConfig().SERVER}/fresh_harvest/php/getproduct.php?product_id=${productIdController.text}'),
    );

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      try {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['message'] != 'Product not found') {
          setState(() {
            productNameController.text = jsonResponse['product_name'];
            descriptionController.text = jsonResponse['product_description'];
            amountController.text = jsonResponse['amount'].toString();
            locationController.text = jsonResponse['location'];
            _isProductFetched = true;
          });
        } else {
          Fluttertoast.showToast(msg: jsonResponse['message']);
        }
      } catch (e) {
        print("Error decoding JSON: $e");
        Fluttertoast.showToast(msg: 'Error fetching product details');
      }
    } else {
      Fluttertoast.showToast(msg: 'Failed to connect to the server');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> updateProduct() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse('${MyConfig().SERVER}/fresh_harvest/php/updateproduct.php'),
      body: {
        'product_id': productIdController.text,
        'product_name': productNameController.text,
        'product_description': descriptionController.text,
        'amount': amountController.text,
        'location': locationController.text,
      },
    );

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      try {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['message'] == 'success') {
          Fluttertoast.showToast(msg: 'Product updated successfully');
        } else {
          Fluttertoast.showToast(msg: jsonResponse['message']);
        }
      } catch (e) {
        print("Error decoding JSON: $e");
        Fluttertoast.showToast(msg: 'Error updating product details');
      }
    } else {
      Fluttertoast.showToast(msg: 'Failed to connect to the server');
    }

    setState(() {
      _isLoading = false;
      _isProductFetched = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modify Product'),
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
                onPressed: _isLoading ? null : fetchProduct,
                child: _isLoading ? CircularProgressIndicator() : Text('Fetch Product'),
              ),
              if (_isProductFetched) ...[
                SizedBox(height: 20),
                TextField(
                  controller: productNameController,
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.all(8.0),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.all(8.0),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.all(8.0),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.all(8.0),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : updateProduct,
                  child: _isLoading ? CircularProgressIndicator() : Text('Update Product'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
