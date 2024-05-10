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
    final response = await http.get(Uri.parse('${MyConfig().SERVER}/fresh_harvest/php/getproduct.php'));

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load product');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: FutureBuilder<Product>(
        future: futureProduct,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return Column(
            children: <Widget>[
              Image.network('https://via.placeholder.com/150'),
              const SizedBox(height: 8),
              Text(snapshot.data!.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(snapshot.data!.description, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('Seller: ${snapshot.data!.seller}', style: const TextStyle(fontSize: 14)),
            ],
          );
        },
      ),
    );
  }
}

class Product {
  final String name;
  final String description;
  final String seller;

  Product({required this.name, required this.description, required this.seller});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      description: json['description'],
      seller: json['seller'],
    );
  }
}