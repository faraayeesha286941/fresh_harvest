import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PurchasesScreen extends StatefulWidget {
  @override
  _PurchasesScreenState createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  late Future<List<Purchase>> futurePurchases;

  @override
  void initState() {
    super.initState();
    futurePurchases = fetchPurchases();
  }

  Future<List<Purchase>> fetchPurchases() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId') ?? '';

    print('Fetching purchases for user: $userId'); // Debug log

    DatabaseReference ordersRef = FirebaseDatabase.instance.ref().child('orders');
    Query query = ordersRef.orderByChild('user_id').equalTo(userId);
    DatabaseEvent event = await query.once();

    print('Database event snapshot: ${event.snapshot.value}'); // Debug log

    if (event.snapshot.value != null) {
      Map<dynamic, dynamic> purchasesJson = event.snapshot.value as Map<dynamic, dynamic>;
      List<Purchase> purchases = [];

      for (var key in purchasesJson.keys) {
        var value = purchasesJson[key];
        print('Purchase raw data: $value'); // Debug log

        // Fetch product details
        var productId = value['product_id'].toString();
        DatabaseReference productRef = FirebaseDatabase.instance.ref().child('db_product').child(productId);
        DataSnapshot productSnapshot = await productRef.get();
        if (productSnapshot.exists) {
          Map<String, dynamic> productJson = Map<String, dynamic>.from(productSnapshot.value as Map);
          productJson['quantity'] = value['quantity'] ?? 0; // Add quantity to the product data
          productJson['date_purchased'] = value['date_purchased'] ?? ''; // Add date_purchased to the product data
          purchases.add(Purchase.fromJson(productJson));
        } else {
          print('Product not found for id: $productId'); // Debug log
        }
      }
      print('Loaded purchases: $purchases'); // Debug log
      return purchases;
    } else {
      print('No purchases found'); // Debug log
      return []; // Return an empty list if no purchases are found
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Purchases'),
        backgroundColor: Colors.blue[800],
      ),
      body: Center(
        child: FutureBuilder<List<Purchase>>(
          future: futurePurchases,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('You have no purchases');
            }

            final purchases = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: purchases.length,
              itemBuilder: (context, index) {
                var item = purchases[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: item.imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              item.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.error, color: Colors.red);
                              },
                            ),
                          )
                        : null,
                    title: Text(
                      item.productName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Quantity: ${item.quantity}'),
                          Text('Price: \RM${item.price.toStringAsFixed(2)}'),
                          Text('Date: ${item.datePurchased}'),
                        ],
                      ),
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

class Purchase {
  final String productName;
  final double price;
  final int quantity;
  final String datePurchased;
  final String imageUrl;

  Purchase({
    required this.productName,
    required this.price,
    required this.quantity,
    required this.datePurchased,
    required this.imageUrl,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      productName: json['product_name'] ?? 'Unknown',
      price: (json['price'] is int) ? (json['price'] as int).toDouble() : double.parse(json['price'].toString()),
      quantity: json['quantity'] ?? 0,
      datePurchased: json['date_purchased'] ?? 'Unknown',
      imageUrl: 'https://firebasestorage.googleapis.com/v0/b/freshharvest-96950.appspot.com/o/products%2F${json['product_id']}_1.jpg?alt=media',
    );
  }
}
