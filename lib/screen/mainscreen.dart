import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fresh_harvest/appconfig/myconfig.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late Future<List<Product>> futureProducts;

  @override
  void initState() {
    super.initState();
    futureProducts = fetchProducts();
  }

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('${MyConfig().SERVER}/fresh_harvest/php/getproducts.php'));

    if (response.statusCode == 200) {
      List<dynamic> productsJson = jsonDecode(response.body);
      return productsJson.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  void clearSharedPreferences(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Screen'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => clearSharedPreferences(context),
            tooltip: 'Log out',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(child: TextField(decoration: InputDecoration(hintText: 'Search'))),
                  IconButton(icon: const Icon(Icons.settings), onPressed: null)
                ],
              ),
            ),
            const Text('Categories'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: SizedBox(
                    width: 40,
                    height: 40,
                    child: Image.asset('assets/images/vegetable.png'),
                  ),
                  onPressed: null,
                ),
                IconButton(
                  icon: SizedBox(
                    width: 40,
                    height: 40,
                    child: Image.asset('assets/images/fruit.png'),
                  ),
                  onPressed: null,
                ),
              ],
            ),
            Expanded(
              child: FutureBuilder<List<Product>>(
                future: futureProducts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 4 / 3,
                    ),
                    itemCount: snapshot.data?.length ?? 0,
                    itemBuilder: (context, index) {
                      var product = snapshot.data![index];
                      return Card(
                        child: Column(
                          children: <Widget>[
                            Image.network(product.imageUrl),
                            Text(product.name),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Product {
  final String name;
  final String imageUrl;

  Product({required this.name, required this.imageUrl});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      imageUrl: json['image_url'],
    );
  }
}
