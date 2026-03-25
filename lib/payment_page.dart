import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentPage extends StatefulWidget {
  final String token;
  final double total;

  PaymentPage({required this.token, required this.total});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  bool isLoading = false;
  String cardType = "";

  void detectCardType(String number) {
    String cleaned = number.replaceAll(' ', '');
    if (cleaned.startsWith('4')) {
      setState(() => cardType = "Visa");
    } else if (cleaned.startsWith('5')) {
      setState(() => cardType = "Mastercard");
    } else if (cleaned.startsWith('3')) {
      setState(() => cardType = "American Express");
    } else {
      setState(() => cardType = "");
    }
  }

  void formatCardNumber(String text) {
    String formatted = text.replaceAll(RegExp(r'\D'), '');
    if (formatted.length > 16) formatted = formatted.substring(0, 16);
    String result = '';
    for (int i = 0; i < formatted.length; i++) {
      if (i > 0 && i % 4 == 0) result += ' ';
      result += formatted[i];
    }
    cardNumberController.value = TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
    detectCardType(formatted);
  }

  void formatExpiry(String text) {
    String cleaned = text.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length > 4) cleaned = cleaned.substring(0, 4);
    if (cleaned.length >= 3) {
      cleaned = '${cleaned.substring(0, 2)}/${cleaned.substring(2)}';
    }
    expiryController.value = TextEditingValue(
      text: cleaned,
      selection: TextSelection.collapsed(offset: cleaned.length),
    );
  }

  Future<void> procesarPago() async {
    if (cardNumberController.text.replaceAll(' ', '').length < 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Número de tarjeta inválido'), backgroundColor: Colors.red),
      );
      return;
    }
    if (expiryController.text.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fecha de expiración inválida'), backgroundColor: Colors.red),
      );
      return;
    }
    if (cvvController.text.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CVV inválido'), backgroundColor: Colors.red),
      );
      return;
    }
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nombre del titular requerido'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => isLoading = true);

    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/create-payment'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'amount': (widget.total * 100).toInt(),
        'currency': 'PEN',
        'email': 'cliente@test.com',
        'description': 'Compra en AméricaFitness',
        'card_last4': cardNumberController.text.replaceAll(' ', '').substring(
          cardNumberController.text.replaceAll(' ', '').length - 4),
        'card_type': cardType,
      }),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Column(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              SizedBox(height: 10),
              Text('¡Pago Exitoso!', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text('ID de transacción: ${data['charge_id']}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context); // Vuelve al home
              },
              child: Text('Aceptar'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error en el pago'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pago Seguro', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        color: Colors.black,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resumen de compra
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red.shade900, Colors.red.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Total a pagar',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'S/ ${widget.total.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),

                // Tarjeta de crédito simulada con logo
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1A1A1A), Color(0xFF2A2A2A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Logo de la tarjeta (Visa/Mastercard)
                      Positioned(
                        top: 20,
                        right: 20,
                        child: cardType.isNotEmpty
                            ? Image.asset(
                                cardType == 'Visa'
                                    ? 'assets/images/visa.png'
                                    : cardType == 'Mastercard'
                                        ? 'assets/images/mastercard.png'
                                        : 'assets/images/credit_card.png',
                                height: 40,
                                errorBuilder: (context, error, stackTrace) => Text(
                                  cardType,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : Icon(Icons.credit_card, color: Colors.white70, size: 40),
                      ),
                      // Número de tarjeta
                      Positioned(
                        bottom: 50,
                        left: 20,
                        child: Text(
                          cardNumberController.text.isEmpty
                              ? "**** **** **** ****"
                              : cardNumberController.text,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Nombre del titular
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: Text(
                          nameController.text.isEmpty ? "NOMBRE DEL TITULAR" : nameController.text.toUpperCase(),
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                      // Fecha de expiración
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: Text(
                          expiryController.text.isEmpty ? "MM/AA" : expiryController.text,
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),

                // Formulario
                Text(
                  'Datos de la tarjeta',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),

                TextField(
                  controller: nameController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person, color: Colors.red.shade800),
                    labelText: 'Nombre del titular',
                    labelStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Color(0xFF1A1A1A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 15),

                TextField(
                  controller: cardNumberController,
                  onChanged: (text) => formatCardNumber(text),
                  style: TextStyle(color: Colors.white, letterSpacing: 1),
                  keyboardType: TextInputType.number,
                  maxLength: 19,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.credit_card, color: Colors.red.shade800),
                    labelText: 'Número de tarjeta',
                    labelStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Color(0xFF1A1A1A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    counterText: '',
                  ),
                ),
                SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: expiryController,
                        onChanged: formatExpiry,
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        maxLength: 5,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.date_range, color: Colors.red.shade800),
                          labelText: 'MM/AA',
                          labelStyle: TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Color(0xFF1A1A1A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          counterText: '',
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: TextField(
                        controller: cvvController,
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        maxLength: 4,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock, color: Colors.red.shade800),
                          labelText: 'CVV',
                          labelStyle: TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Color(0xFF1A1A1A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          counterText: '',
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : procesarPago,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade800,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Pagar S/ ${widget.total.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}