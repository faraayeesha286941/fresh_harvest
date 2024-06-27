import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fresh_harvest/appconfig/myconfig.dart';

class ProductDetails extends StatefulWidget {
  final String productId;

  const ProductDetails({Key? key, required this.productId}) : super(key: key);

  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  late Future<Product> futureProduct;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    futureProduct = fetchProductDetails(widget.productId);
  }

  Future<Product> fetchProductDetails(String productId) async {
    final response = await http.get(Uri.parse('${MyConfig().SERVER}/fresh_harvest/php/getproductdetails.php?product_id=$productId&server_url=${MyConfig().SERVER}'));

    if (response.statusCode == 200) {
      try {
        return Product.fromJson(jsonDecode(response.body));
      } catch (e) {
        throw Exception('Failed to parse product details');
      }
    } else {
      throw Exception('Failed to load product details');
    }
  }

  void addToCart(String productId, int quantity) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId') ?? '';

    final response = await http.post(
      Uri.parse('${MyConfig().SERVER}/fresh_harvest/php/addtocart.php'),
      body: {
        'user_id': userId,
        'product_id': productId,
        'quantity': quantity.toString(),
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added to cart')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add to cart')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: Colors.blue[800],
      ),
      body: Center(
        child: FutureBuilder<Product>(
          future: futureProduct,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            final product = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Display product image
                            Container(
                              width: double.infinity,
                              height: 300,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                                image: DecorationImage(
                                  image: NetworkImage(product.imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Text(
                                    product.name,
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[800],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Seller: ${product.sellerName}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    '\RM${product.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      product.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 20),
                    // Quantity selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (quantity > 1) quantity--;
                            });
                          },
                        ),
                        Text(
                          '$quantity',
                          style: TextStyle(fontSize: 20),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              quantity++;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () => addToCart(widget.productId, quantity),
                        icon: Icon(Icons.add_shopping_cart),
                        label: Text('Add To Cart'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.blue[800], // Text color
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
  final String sellerName;
  final double price;
  final String description;
  final String imageUrl; // Add image URL field

  Product({
    required this.id,
    required this.name,
    required this.sellerName,
    required this.price,
    required this.description,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['product_id'] ?? '',
      name: json['product_name'] ?? '',
      sellerName: json['seller_name'] ?? '',
      price: double.parse(json['price'] ?? '0'),
      description: json['product_description'] ?? '',
      imageUrl: json['image_url'] ?? '', // Parse image URL from JSON
    );
  }
}
