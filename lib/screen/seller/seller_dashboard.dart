import 'package:flutter/material.dart';
import 'package:fresh_harvest/screen/seller/ongoing_orders_screen.dart';
import 'package:fresh_harvest/screen/seller/past_orders_screen.dart';
import 'package:fresh_harvest/screen/seller/my_products_screen.dart';

class SellerDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Dashboard'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          children: <Widget>[
            _buildDashboardItem(context, Icons.store, 'My Products', MyProductsScreen()),
            _buildDashboardItem(context, Icons.shopping_cart, 'Ongoing Orders', OngoingOrdersScreen()),
            _buildDashboardItem(context, Icons.history, 'Past Orders', PastOrdersScreen()),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardItem(BuildContext context, IconData icon, String label, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.all(10.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 50, color: Colors.blue),
            const SizedBox(height: 10),
            Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
