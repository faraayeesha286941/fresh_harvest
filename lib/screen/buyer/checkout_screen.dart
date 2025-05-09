import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class CheckoutScreen extends StatelessWidget {
  final VoidCallback onCheckoutComplete;

  CheckoutScreen({required this.onCheckoutComplete});

  Future<void> _clearCartAndAddToOrders(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId') ?? '';

    print('Starting checkout for user: $userId'); // Debug log

    DatabaseReference cartRef = FirebaseDatabase.instance.ref().child('db_cart');
    Query query = cartRef.orderByChild('user_id').equalTo(userId);
    DatabaseEvent cartEvent = await query.once();

    print('Cart event snapshot: ${cartEvent.snapshot.value}'); // Debug log

    if (cartEvent.snapshot.value != null) {
      var cartItems = cartEvent.snapshot.value;

      DatabaseReference ordersRef = FirebaseDatabase.instance.ref().child('orders');
      String datePurchased = DateFormat("yyyy-MM-ddTHH:mm:ss").format(DateTime.now());

      try {
        if (cartItems is List) {
          for (var i = 0; i < cartItems.length; i++) {
            if (cartItems[i] != null) {
              var item = cartItems[i] as Map<dynamic, dynamic>;
              print('Processing cart item: $item'); // Debug log
              await ordersRef.push().set({
                'user_id': userId,
                'product_id': item['product_id'],
                'quantity': item['quantity'],
                'approval_status': 'PENDING',
                'date_purchased': datePurchased,
              });
            }
          }
        } else if (cartItems is Map) {
          for (var key in cartItems.keys) {
            var item = cartItems[key];
            print('Processing cart item: $item'); // Debug log
            await ordersRef.push().set({
              'user_id': userId,
              'product_id': item['product_id'],
              'quantity': item['quantity'],
              'approval_status': 'PENDING',
              'date_purchased': datePurchased,
            });
          }
        }

        await cartRef.orderByChild('user_id').equalTo(userId).ref.remove();

        print('Order placed successfully for user: $userId'); // Debug log
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment successful and order placed')),
        );

        // Call the callback to refresh the cart
        onCheckoutComplete();

        // Navigate back to the previous screen
        Navigator.pop(context);
      } catch (error) {
        print('Error placing order: $error'); // Debug log
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order')),
        );
      }
    } else {
      print('No items in the cart for user: $userId'); // Debug log
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No items in the cart')),
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
              onPressed: () => _clearCartAndAddToOrders(context),
              child: const Text('Paid'),
            ),
          ],
        ),
      ),
    );
  }
}
