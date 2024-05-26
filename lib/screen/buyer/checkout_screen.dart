import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fresh_harvest/appconfig/myconfig.dart';

class CheckoutScreen extends StatelessWidget {
  final VoidCallback onCheckoutComplete;

  CheckoutScreen({required this.onCheckoutComplete});

  Future<void> _clearCart(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId') ?? '';

    final response = await http.post(
      Uri.parse('${MyConfig().SERVER}/fresh_harvest/php/clearcart.php'),
      body: {'user_id': userId},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment successful and cart cleared')),
      );

      // Call the callback to refresh the cart
      onCheckoutComplete();

      // Navigate back to the previous screen
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to clear cart')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/QR.jpg'), // Ensure QR.jpg is in the assets folder and listed in pubspec.yaml
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _clearCart(context),
              child: const Text('Paid'),
            ),
          ],
        ),
      ),
    );
  }
}
