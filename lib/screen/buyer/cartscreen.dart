import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

    print('Fetching cart items for user: $userId'); // Debug log

    DatabaseReference cartRef = FirebaseDatabase.instance.ref().child('db_cart');
    Query query = cartRef.orderByChild('user_id').equalTo(userId);
    DatabaseEvent event = await query.once();

    print('Database event snapshot: ${event.snapshot.value}'); // Debug log

    List<CartItem> cartItems = [];
    if (event.snapshot.value != null) {
      var cartData = event.snapshot.value;

      if (cartData is List) {
        for (var i = 0; i < cartData.length; i++) {
          if (cartData[i] != null) {
            var value = cartData[i] as Map<dynamic, dynamic>;
            print('Cart item raw data: $value'); // Debug log

            var productId = value['product_id'].toString();

            // Fetch product details
            DatabaseReference productRef = FirebaseDatabase.instance.ref().child('db_product').child(productId);
            DatabaseEvent productEvent = await productRef.once();
            var productSnapshot = productEvent.snapshot;

            print('Product event snapshot: ${productSnapshot.value}'); // Debug log

            if (productSnapshot.exists) {
              var productJson = Map<String, dynamic>.from(productSnapshot.value as Map);
              productJson['quantity'] = value['quantity']; // Add quantity to the product data
              productJson['cart_id'] = i.toString(); // Add cart_id to the product data
              cartItems.add(CartItem.fromJson(productJson));
            } else {
              print('Product not found for id: $productId'); // Debug log
            }
          }
        }
      } else if (cartData is Map) {
        for (var key in cartData.keys) {
          var value = cartData[key];
          print('Cart item raw data: $value'); // Debug log

          var productId = value['product_id'].toString();

          // Fetch product details
          DatabaseReference productRef = FirebaseDatabase.instance.ref().child('db_product').child(productId);
          DatabaseEvent productEvent = await productRef.once();
          var productSnapshot = productEvent.snapshot;

          print('Product event snapshot: ${productSnapshot.value}'); // Debug log

          if (productSnapshot.exists) {
            var productJson = Map<String, dynamic>.from(productSnapshot.value as Map);
            productJson['quantity'] = value['quantity']; // Add quantity to the product data
            productJson['cart_id'] = key; // Add cart_id to the product data
            cartItems.add(CartItem.fromJson(productJson));
          } else {
            print('Product not found for id: $productId'); // Debug log
          }
        }
      }
    } else {
      print('No cart items found'); // Debug log
    }

    print('Loaded cart items: $cartItems'); // Debug log
    return cartItems;
  }

  Future<void> updateCartQuantity(String cartId, int quantity) async {
    print('Updating quantity for cart item $cartId to $quantity'); // Debug log
    DatabaseReference cartRef = FirebaseDatabase.instance.ref().child('db_cart/$cartId');
    await cartRef.update({
      'quantity': quantity,
    });

    setState(() {
      futureCartItems = fetchCartItems();
    });
  }

  Future<void> deleteCartItem(String cartId) async {
    print('Deleting cart item $cartId'); // Debug log
    DatabaseReference cartRef = FirebaseDatabase.instance.ref().child('db_cart/$cartId');
    await cartRef.remove();

    setState(() {
      futureCartItems = fetchCartItems();
    });
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
              print('Error loading cart items: ${snapshot.error}'); // Debug log
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
  final String productId;
  final String productName;
  final double price;
  final String imageUrl;
  final int quantity;

  CartItem({
    required this.cartId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    double price;
    try {
      price = (json['price'] is int) ? (json['price'] as int).toDouble() : double.parse(json['price']?.toString() ?? '0.0');
      print('Parsed price: $price'); // Debug log
    } catch (e) {
      price = 0.0;
      print('Error parsing price: $e');
    }

    return CartItem(
      cartId: json['cart_id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      productName: json['product_name'] ?? '',
      price: price,
      imageUrl: 'https://firebasestorage.googleapis.com/v0/b/freshharvest-96950.appspot.com/o/products%2F${json['product_id'] ?? ''}_1.jpg?alt=media',
      quantity: json['quantity'] ?? 0,
    );
  }
}
