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

    final response = await http.get(Uri.parse('${MyConfig().SERVER}/fresh_harvest/php/getpurchases.php?user_id=$userId'));

    // Print the response body for debugging
    print('Response body: ${response.body}');

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
        backgroundColor: Colors.blue,
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
              itemCount: purchases.length,
              itemBuilder: (context, index) {
                var item = purchases[index];
                return Card(
                  child: ListTile(
                    title: Text(item.productName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quantity: ${item.quantity}'),
                        Text('Price: \$${item.price.toStringAsFixed(2)}'),
                        Text('Date: ${item.datePurchased}'),
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

class Purchase {
  final String productName;
  final double price;
  final int quantity;
  final String datePurchased;

  Purchase({
    required this.productName,
    required this.price,
    required this.quantity,
    required this.datePurchased,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      productName: json['product_name'],
      price: double.parse(json['price']),
      quantity: int.parse(json['quantity']),
      datePurchased: json['date_purchased'],
    );
  }
}
