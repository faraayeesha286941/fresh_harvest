import 'package:flutter/material.dart';

class ProductDetails extends StatelessWidget {
  const ProductDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: Column(
        children: <Widget>[
          Image.network('https://via.placeholder.com/150'),
          const SizedBox(height: 8),
          const Text('Product Name', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Product Description', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
