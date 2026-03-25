import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrdersPage extends StatefulWidget {
  final String token;

  OrdersPage({required this.token});

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/my-orders'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      setState(() {
        orders = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag, size: 80, color: Colors.grey),
                      SizedBox(height: 20),
                      Text(
                        'No tienes pedidos aún',
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Card(
                      color: Color(0xFF1A1A1A),
                      margin: EdgeInsets.all(10),
                      child: ExpansionTile(
                        title: Text(
                          'Pedido #${order['id']}',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total: S/ ${order['total_amount'].toStringAsFixed(2)}',
                              style: TextStyle(color: Colors.red.shade800),
                            ),
                            Text(
                              'Fecha: ${order['created_at'].substring(0, 10)}',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: Chip(
                          label: Text(
                            order['status'].toUpperCase(),
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          backgroundColor: order['status'] == 'paid' ? Colors.green : Colors.orange,
                        ),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: (order['items'] as List).map((item) {
                                return ListTile(
                                  title: Text(
                                    item['product_name'],
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  subtitle: Text('Cantidad: ${item['quantity']}'),
                                  trailing: Text(
                                    'S/ ${item['price'].toStringAsFixed(2)}',
                                    style: TextStyle(color: Colors.red.shade800),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
