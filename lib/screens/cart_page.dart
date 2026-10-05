import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home_page.dart';

class CartPage extends StatefulWidget {
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool isLoading = false;

  Future<bool> Proses_Bayar(double total) async {
    final secret = dotenv.env['PAYMENT_SECRET'];
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final headers = {
      'Authorization': 'Bearer $token',
      'X-Payment-Secret': '$secret',
    };
    debugPrint('POST /checkout total=$total headers=$headers');
    await Future.delayed(Duration(seconds: 3));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    double subtotal = 0;
    for (var item in CART_ITEMS) {
      subtotal = subtotal + Hitung_Diskon(item.price, item.DiscountPercent);
    }
    double ongkir = 15000;
    if (subtotal > 500000 || CART_ITEMS.isEmpty) {
      ongkir = 0;
    }
    final total = subtotal + ongkir;

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Keranjang')),
        body: Column(
          children: [
            Expanded(
              child: CART_ITEMS.isEmpty
                  ? Center(child: Text('Keranjang masih kosong'))
                  : SingleChildScrollView(
                      child: Column(
                        children: CART_ITEMS
                            .map(
                              (item) => ListTile(
                                leading: Icon(Icons.inventory_2),
                                title: Text(item.title),
                                subtitle: Text(
                                  Format_Rupiah(
                                    Hitung_Diskon(
                                      item.price,
                                      item.DiscountPercent,
                                    ),
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete_outline),
                                  onPressed: () {
                                    setState(() {
                                      CART_ITEMS.remove(item);
                                    });
                                  },
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.grey.withOpacity(0.1),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal'),
                      Text(Format_Rupiah(subtotal)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ongkir'),
                      Text(Format_Rupiah(ongkir)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        Format_Rupiah(total),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          Colors.green,
                        ),
                        foregroundColor: MaterialStateProperty.all(
                          Colors.white,
                        ),
                      ),
                      onPressed: CART_ITEMS.isEmpty || isLoading
                          ? null
                          : () async {
                              setState(() {
                                isLoading = true;
                              });
                              await Proses_Bayar(total);
                              CART_ITEMS.clear();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Pembayaran berhasil')),
                              );
                            },
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Bayar Sekarang'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
