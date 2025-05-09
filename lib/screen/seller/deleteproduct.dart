import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DeleteProduct extends StatefulWidget {
  @override
  _DeleteProductState createState() => _DeleteProductState();
}

class _DeleteProductState extends State<DeleteProduct> {
  bool _isLoading = false;
  Map<String, dynamic> products = {};

  @override
  void initState() {
    super.initState();
    fetchAllProducts();
  }

  Future<void> fetchAllProducts() async {
    setState(() {
      _isLoading = true;
    });

    DatabaseReference productRef = FirebaseDatabase.instance.ref().child('db_product');
    DatabaseEvent event = await productRef.once();

    print("Database event snapshot: ${event.snapshot.value}");

    if (event.snapshot.value != null) {
      Map<String, dynamic> products;
      if (event.snapshot.value is List) {
        products = (event.snapshot.value as List).asMap().map((key, value) => MapEntry(key.toString(), value));
      } else {
        products = Map<String, dynamic>.from(event.snapshot.value as Map);
      }
      setState(() {
        this.products = products;
      });
    } else {
      Fluttertoast.showToast(msg: 'No products found');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> deleteProduct(String productId) async {
    setState(() {
      _isLoading = true;
    });

    DatabaseReference productRef = FirebaseDatabase.instance.ref().child('db_product').child(productId);

    try {
      await productRef.remove();
      Fluttertoast.showToast(msg: 'Product deleted successfully');
      fetchAllProducts(); // Refresh the product list
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to delete product');
      print('Error: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete Product'),
        backgroundColor: Colors.blue[800],
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    DataTable(
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Delete')),
                      ],
                      rows: products.values.map((product) {
                        Map<String, dynamic> productMap = Map<String, dynamic>.from(product);
                        return DataRow(
                          cells: [
                            DataCell(Text(productMap['product_id'].toString())),
                            DataCell(Text(productMap['product_name'] ?? '')),
                            DataCell(
                              ElevatedButton(
                                onPressed: () => deleteProduct(productMap['product_id'].toString()),
                                child: Text('Delete'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red, // Button color
                                  foregroundColor: Colors.white, // Text color
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
