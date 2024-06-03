import 'package:flutter/material.dart';
import 'package:fresh_harvest/screen/seller/productview.dart'; // Import the ProductView screen

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton.icon(
              icon: Icon(Icons.shopping_cart),
              label: Text('Products'),
              onPressed: () {
                // Navigate to ProductView screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductView()),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.receipt),
              label: Text('Orders'),
              onPressed: () {
                // Navigate to Orders screen or perform appropriate action
                // Navigator.pushNamed(context, '/adminOrders');
              },
            ),
          ],
        ),
      ),
    );
  }
}
