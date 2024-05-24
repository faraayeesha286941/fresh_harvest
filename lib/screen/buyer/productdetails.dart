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
    print("ProductDetails initState called"); // Add this print
    futureProduct = fetchProductDetails();
  }

  Future<Product> fetchProductDetails() async {
  print("fetchProductDetails called"); // Add this print
  String serverUrl = MyConfig().SERVER;
  print("Using server URL: $serverUrl");

  String requestUrl = '$serverUrl/getlatestproducts.php';
  print("Final Request URL: $requestUrl");
  final response = await http.get(Uri.parse(requestUrl));

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
      return Column(
        children: [
          Text('Product Name: ${snapshot.data?.name}'),
          if (snapshot.data?.imageUrl != null)
            Image.network(snapshot.data!.imageUrl),
        ],
      );
    },
  ),
);

  }
}

class Product {
  final String name;
  final String imageUrl;

  Product({required this.name, required this.imageUrl});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      imageUrl: json['image_url'],
    );
  }
}
