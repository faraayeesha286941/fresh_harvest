import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    DatabaseReference productRef = FirebaseDatabase.instance.ref().child('db_product').child(productId);
    DatabaseEvent event = await productRef.once();

    if (event.snapshot.exists) {
      Map<String, dynamic> productJson = Map<String, dynamic>.from(event.snapshot.value as Map);
      return Product.fromJson(productJson);
    } else {
      throw Exception('Product not found');
    }
  }

  Future<void> addToCart(String productId, int quantity) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId') ?? '';

    DatabaseReference counterRef = FirebaseDatabase.instance.ref().child('cart_counter');
    DatabaseReference cartRef = FirebaseDatabase.instance.ref().child('db_cart');

    // Get the current counter value
    DatabaseEvent counterEvent = await counterRef.once();
    int currentCounter = (counterEvent.snapshot.value as int?) ?? 0;
    int newCartId = currentCounter + 1;

    // Update the counter
    await counterRef.set(newCartId);

    // Add to cart with the new cart ID
    await cartRef.child(newCartId.toString()).set({
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added to cart')),
    );
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
      id: json['product_id'].toString(),
      name: json['product_name'] ?? '',
      sellerName: json['seller_name'] ?? '',
      price: double.parse(json['price'].toString()),
      description: json['product_description'] ?? '',
      imageUrl: 'https://firebasestorage.googleapis.com/v0/b/freshharvest-96950.appspot.com/o/products%2F${json['product_id']}_1.jpg?alt=media', // Parse image URL from JSON
    );
  }
}
