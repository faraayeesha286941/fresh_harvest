import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fresh_harvest/appconfig/myconfig.dart';
import 'productdetails.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final Key? key;
  CartScreen({this.key}) : super(key: key); // Accept key parameter

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

  Future<void> deleteCartItem(String cartId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId') ?? '';

    final response = await http.post(
      Uri.parse('${MyConfig().SERVER}/fresh_harvest/php/deletecartitem.php'),
      body: {
        'user_id': userId,
        'cart_id': cartId,
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        futureCartItems = fetchCartItems();
      });
    } else {
      throw Exception('Failed to delete cart item');
    }
  }

  void _checkout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CheckoutScreen(onCheckoutComplete: _refreshCart)),
    );
  }

  void _refreshCart() {
    setState(() {
      futureCartItems = fetchCartItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        backgroundColor: Colors.blue[800],
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
                      double totalPrice = item.price * item.quantity; // Calculate total price based on quantity

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              item.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.error, color: Colors.red); // Handle image error
                              },
                            ),
                          ),
                          title: Text(
                            item.productName,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[800]),
                          ),
                          subtitle: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove, color: Colors.blue[800], size: 20.0), // Adjusted icon size
                                onPressed: () {
                                  if (item.quantity > 1) {
                                    updateCartQuantity(item.cartId, item.quantity - 1);
                                  }
                                },
                              ),
                              Text(
                                '${item.quantity}',
                                style: TextStyle(fontSize: 16, color: Colors.blue[800]),
                              ),
                              IconButton(
                                icon: Icon(Icons.add, color: Colors.blue[800], size: 20.0), // Adjusted icon size
                                onPressed: () {
                                  updateCartQuantity(item.cartId, item.quantity + 1);
                                },
                              ),
                            ],
                          ),
                          trailing: Container(
                            height: double.infinity,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '\RM${totalPrice.toStringAsFixed(2)}', // Display total price
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[800]),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red, size: 20.0), // Adjusted icon size
                                  onPressed: () {
                                    deleteCartItem(item.cartId);
                                  },
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetails(productId: item.productId), // Pass product_id
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: _checkout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: const Text('Checkout', style: TextStyle(fontSize: 18)),
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
  final String productId; // Add productId field
  final String productName;
  final double price;
  final String imageUrl;
  final int quantity;

  CartItem({
    required this.cartId,
    required this.productId, // Initialize productId
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      cartId: json['cart_id'],
      productId: json['product_id'], // Parse productId from JSON
      productName: json['product_name'],
      price: double.parse(json['price']),
      imageUrl: json['image_url'],
      quantity: int.parse(json['quantity']),
    );
  }
}
