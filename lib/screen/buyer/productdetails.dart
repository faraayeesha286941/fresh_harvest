import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fresh_harvest/appconfig/myconfig.dart';

class ProductDetails extends StatefulWidget {
  const ProductDetails({Key? key}) : super(key: key);

  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  late Future<Product> futureProduct;

  @override
  void initState() {
    super.initState();
    futureProduct = fetchProductDetails();
  }

  Future<Product> fetchProductDetails() async {
    String serverUrl = MyConfig().SERVER;  // Use your config class to get the server URL
    print("Using server URL: $serverUrl");
    final response = await http.get(Uri.parse('$serverUrl/getlatestproducts.php'));

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load product');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: FutureBuilder<Product>(
        future: futureProduct,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          }
          // assuming Product has a proper constructor and fromJson method
          return Text('Product Name: ${snapshot.data?.name}');
        },
      ),
    );
  }
}

class Product {
  final String name;

  Product({required this.name});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
    );
  }
}