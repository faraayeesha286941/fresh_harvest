import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fresh_harvest/appconfig/myconfig.dart';
import 'productdetails.dart';  // Import the ProductDetails screen

class BuyerTabScreen extends StatefulWidget {
  final String? searchQuery;

  const BuyerTabScreen({Key? key, this.searchQuery}) : super(key: key);

  @override
  _BuyerTabScreenState createState() => _BuyerTabScreenState();
}

class _BuyerTabScreenState extends State<BuyerTabScreen> {
  late Future<List<Product>> futureProducts;

  @override
  void initState() {
    super.initState();
    futureProducts = fetchProducts(widget.searchQuery);
  }

  Future<List<Product>> fetchProducts(String? query) async {
    final serverUrl = MyConfig().SERVER;
    final response = await http.get(Uri.parse('$serverUrl/fresh_harvest/php/getlatestproducts.php?server_url=$serverUrl&query=${query ?? ''}'));

    if (response.statusCode == 200) {
      List<dynamic> productsJson = jsonDecode(response.body);
      return productsJson.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Products'),
      ),
      body: Center(
        child: FutureBuilder<List<Product>>(
          future: futureProducts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No products found');
            }

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 4 / 3,
              ),
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                var product = snapshot.data![index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetails(productId: product.id),
                      ),
                    );
                  },
                  child: Card(
                    child: Column(
                      children: <Widget>[
                        Image.network(product.imageUrl),
                        Text(product.name),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class Product {
  final String id;
  final String name;
  final String imageUrl;

  Product({required this.id, required this.name, required this.imageUrl});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['product_id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }
}
