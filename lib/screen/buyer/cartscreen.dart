import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fresh_harvest/appconfig/myconfig.dart';
import 'package:fresh_harvest/screen/buyer/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Future<List<CartItem>> futureCartItems;

  @override
  void initState() {
    super.initState();
    futureCartItems = fetchCartItems();
  }

  Future<List<CartItem>> fetchCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId') ?? '';

    final response = await http.get(Uri.parse('${MyConfig().SERVER}/fresh_harvest/php/getcartitems.php?user_id=$userId&server_url=${MyConfig().SERVER}'));

    if (response.statusCode == 200) {
      List<dynamic> cartJson = jsonDecode(response.body);
      return cartJson.map((json) => CartItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load cart items');
    }
  }

  Future<void> updateCartQuantity(String cartId, int quantity) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId') ?? '';

    final response = await http.post(
      Uri.parse('${MyConfig().SERVER}/fresh_harvest/php/updatecartquantity.php'),
      body: {
        'user_id': userId,
        'cart_id': cartId,
        'quantity': quantity.toString(),
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        futureCartItems = fetchCartItems();
      });
    } else {
      throw Exception('Failed to update cart quantity');
    }
  }

  void _checkout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CheckoutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: FutureBuilder<List<CartItem>>(
          future: futureCartItems,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('Your cart is empty');
            }

            final cartItems = snapshot.data!;

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      var item = cartItems[index];
                      return Card(
                        child: ListTile(
                          leading: Image.network(
                            item.imageUrl,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.error); // Handle image error
                            },
                          ),
                          title: Text(item.productName),
                          subtitle: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () {
                                  if (item.quantity > 1) {
                                    updateCartQuantity(item.cartId, item.quantity - 1);
                                  }
                                },
                              ),
                              Text('${item.quantity}'),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  updateCartQuantity(item.cartId, item.quantity + 1);
                                },
                              ),
                            ],
                          ),
                          trailing: Text('\$${item.price.toStringAsFixed(2)}'),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: _checkout,
                    child: const Text('Checkout'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class CartItem {
  final String cartId;
  final String productName;
  final double price;
  final String imageUrl;
  final int quantity;

  CartItem({
    required this.cartId,
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      cartId: json['cart_id'],
      productName: json['product_name'],
      price: double.parse(json['price']),
      imageUrl: json['image_url'],
      quantity: int.parse(json['quantity']),
    );
  }
}
