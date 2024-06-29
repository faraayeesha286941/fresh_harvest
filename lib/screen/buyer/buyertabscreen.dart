import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
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
    futureProducts = fetchProducts(query: widget.searchQuery ?? '');
  }

  Future<List<Product>> fetchProducts({String category = '', String query = ''}) async {
    print('Fetching products from Firebase');
    DatabaseReference productsRef = FirebaseDatabase.instance.ref().child('db_product');

    try {
      DataSnapshot snapshot = await productsRef.get();
      print('DataSnapshot received: ${snapshot.value}');

      if (snapshot.exists) {
        List<dynamic> productsList = snapshot.value as List<dynamic>;
        List<Product> products = productsList.map((value) {
          Map<String, dynamic> productJson = Map<String, dynamic>.from(value as Map);
          return Product.fromJson(productJson);
        }).toList();

        // Filter by category
        if (category.isNotEmpty) {
          products = products.where((product) => product.category == category).toList();
        }

        // Filter by search query
        if (query.isNotEmpty) {
          products = products.where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase())).toList();
        }

        print('Products loaded: ${products.length}');
        return products;
      } else {
        print('No products found');
        throw Exception('No products found');
      }
    } catch (error) {
      print('Error fetching products: $error');
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
                childAspectRatio: 4 / 5,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
                              image: DecorationImage(
                                image: NetworkImage(product.imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '\RM${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
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
  final double price;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
  }) : imageUrl = 'https://firebasestorage.googleapis.com/v0/b/freshharvest-96950.appspot.com/o/products%2F${id}_1.jpg?alt=media';

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['product_id'].toString(),
      name: json['product_name'] ?? '',
      price: double.parse(json['price'].toString()),
      category: json['category'] ?? '',
    );
  }
}
