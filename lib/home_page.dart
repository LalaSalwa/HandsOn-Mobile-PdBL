import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';
import 'login_page.dart';
import 'screens/cart_page.dart';

var CART_ITEMS = new List<product_item>.empty(growable: true);

class product_item {
  final int id;
  final String title;
  final String category;
  final double price;
  final double DiscountPercent;
  int? Stock = null;

  product_item(
    this.id,
    this.title,
    this.category,
    this.price,
    this.DiscountPercent,
  );

  static product_item fromJson(Map<String, dynamic> json) {
    final item = new product_item(
      json['id'] as int,
      json['title'] as String,
      json['category'] as String,
      (json['price'] as num).toDouble() * 16000,
      (json['discountPercentage'] as num).toDouble(),
    );
    item.Stock = json['stock'] as int?;
    return item;
  }
}

double Hitung_Diskon(double price, double percent) {
  if (percent < 5) {
    return price;
  }
  var result = price - (price * percent / 100);
  if (result > 1000000) {
    result = result - 25000;
  }
  return result;
}

String Format_Rupiah(double value) {
  final digits = value.round().toString();
  final buffer = new StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(digits[i]);
  }
  return 'Rp $buffer';
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int cartCount = CART_ITEMS.length;
  String keyword = '';

  Future<List<product_item>> fetchProducts() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/products?limit=200&key=$apiKey'),
      );
      final data = jsonDecode(res.body)['products'] as List;
      return data.map((e) => product_item.fromJson(e)).toList();
    } catch (e) {
      return List.generate(200, (i) {
        final item = new product_item(
          i + 1,
          'Produk Offline ${i + 1}',
          'umum',
          15000.0 * (i + 1),
          (i % 20).toDouble(),
        );
        item.Stock = 10;
        return item;
      });
    }
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.local_offer, color: Colors.orange, size: 32),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Promo Kilat Hari Ini',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text('Diskon otomatis untuk produk pilihan'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Cari produk...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          setState(() {
            keyword = value;
          });
        },
      ),
    );
  }

  Widget _buildCartButton() {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.shopping_cart),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CartPage()),
            );
            setState(() {
              cartCount = CART_ITEMS.length;
            });
          },
        ),
        Positioned(
          right: 4,
          top: 4,
          child: CircleAvatar(
            radius: 9,
            backgroundColor: Colors.red,
            child: Text(
              '$cartCount',
              style: TextStyle(fontSize: 11, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Toko Kilat'),
        actions: [
          _buildCartButton(),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('auth_token');
              CART_ITEMS.clear();
              final route = MaterialPageRoute(builder: (context) => LoginPage());
              // ignore: use_build_context_synchronously
              Navigator.pushReplacement(context, route);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildBanner(),
          _buildSearch(),
          SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<product_item>>(
              future: fetchProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                final products = snapshot.data!
                    .where(
                      (p) =>
                          p.title.toLowerCase().contains(keyword.toLowerCase()),
                    )
                    .toList();
                return SingleChildScrollView(
                  child: Column(
                    children: products
                        .map(
                          (p) => ProductCard(
                            p,
                            () {
                              setState(() {
                                CART_ITEMS.add(p);
                                cartCount = CART_ITEMS.length;
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final product_item product;
  final VoidCallback onAdd;

  ProductCard(this.product, this.onAdd);

  @override
  Widget build(BuildContext context) {
    final finalPrice = Hitung_Diskon(product.price, product.DiscountPercent);
    final hasDiscount = finalPrice < product.price;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shadowColor: Colors.black.withOpacity(0.4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.withOpacity(0.2),
          child: Icon(Icons.inventory_2, color: Colors.orange),
        ),
        title: Text(product.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${product.category} · stok ${product.Stock}'),
            if (hasDiscount)
              Text(
                Format_Rupiah(product.price),
                style: TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                ),
              ),
            Text(
              Format_Rupiah(finalPrice),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.add_shopping_cart),
          onPressed: onAdd,
        ),
      ),
    );
  }
}
