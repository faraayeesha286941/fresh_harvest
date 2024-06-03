import 'package:flutter/material.dart';

class ProductView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Management'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton.icon(
              icon: Icon(Icons.add),
              label: Text('Add New Product'),
              onPressed: () {
                // Navigate to Add New Product screen or perform appropriate action
                // Navigator.pushNamed(context, '/addNewProduct');
              },
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.edit),
              label: Text('Modify Product'),
              onPressed: () {
                // Navigate to Modify Product screen or perform appropriate action
                // Navigator.pushNamed(context, '/modifyProduct');
              },
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.delete),
              label: Text('Delete Product'),
              onPressed: () {
                // Navigate to Delete Product screen or perform appropriate action
                // Navigator.pushNamed(context, '/deleteProduct');
              },
            ),
          ],
        ),
      ),
    );
  }
}
