import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ModifyProduct extends StatefulWidget {
  @override
  _ModifyProductState createState() => _ModifyProductState();
}

class _ModifyProductState extends State<ModifyProduct> {
  TextEditingController productNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  bool _isLoading = false;
  bool _isProductFetched = false;
  Map<String, dynamic>? selectedProduct;

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

  Future<void> updateProduct() async {
    if (selectedProduct == null) {
      Fluttertoast.showToast(msg: 'Please select a product first');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String productId = selectedProduct!['product_id'].toString();
    DatabaseReference productRef = FirebaseDatabase.instance.ref().child('db_product').child(productId);

    try {
      await productRef.update({
        'product_name': productNameController.text,
        'product_description': descriptionController.text,
        'amount': int.parse(amountController.text),
        'place_location': locationController.text,
      });

      Fluttertoast.showToast(msg: 'Product updated successfully');
      fetchAllProducts(); // Refresh the product list
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to update product');
      print('Error: $e');
    }

    setState(() {
      _isLoading = false;
      _isProductFetched = false;
      selectedProduct = null; // Clear the selected product after update
    });
  }

  Map<String, dynamic> products = {};

  void selectProduct(Map<String, dynamic> product) {
    setState(() {
      selectedProduct = product;
      productNameController.text = product['product_name'] ?? '';
      descriptionController.text = product['product_description'] ?? '';
      amountController.text = product['amount'].toString();
      locationController.text = product['place_location'] ?? '';
      _isProductFetched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modify Product'),
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
                        DataColumn(label: Text('Edit')),
                      ],
                      rows: products.values.map((product) {
                        return DataRow(
                          cells: [
                            DataCell(Text(product['product_id'].toString())),
                            DataCell(Text(product['product_name'] ?? '')),
                            DataCell(
                              ElevatedButton(
                                onPressed: () => selectProduct(product),
                                child: Text('Edit'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[800], // Button color
                                  foregroundColor: Colors.white, // Text color
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                    if (_isProductFetched) ...[
                      SizedBox(height: 20),
                      TextField(
                        controller: productNameController,
                        decoration: InputDecoration(
                          labelText: 'Product Name',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.all(8.0),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.all(8.0),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: amountController,
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.all(8.0),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: locationController,
                        decoration: InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.all(8.0),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isLoading ? null : updateProduct,
                        child: _isLoading ? CircularProgressIndicator() : Text('Update Product'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800], // Button color
                          foregroundColor: Colors.white, // Text color
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
