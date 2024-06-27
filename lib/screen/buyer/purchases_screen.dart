import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fresh_harvest/appconfig/myconfig.dart';

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
    String serverUrl = MyConfig().SERVER;

    final response = await http.get(Uri.parse('$serverUrl/fresh_harvest/php/getpurchases.php?user_id=$userId&server_url=$serverUrl'));

    if (response.statusCode == 200) {
      List<dynamic> purchasesJson = jsonDecode(response.body);
      return purchasesJson.map((json) => Purchase.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load purchases');
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
                          Text('Price: \$${item.price.toStringAsFixed(2)}'),
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
      productName: json['product_name'],
      price: double.parse(json['price']),
      quantity: int.parse(json['quantity']),
      datePurchased: json['date_purchased'],
      imageUrl: json['image_url'] ?? '', // Assuming the JSON contains an image URL
    );
  }
}
