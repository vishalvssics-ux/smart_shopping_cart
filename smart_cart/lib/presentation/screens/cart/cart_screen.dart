import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../../core/theme/app_theme.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final DatabaseReference _cartRef = FirebaseDatabase.instance.ref('cart');
  String _selectedPaymentMethod = 'Cash on Delivery';

  final List<Map<String, dynamic>> _paymentMethods = [
   
    {'name': 'UPI', 'icon': Icons.account_balance_wallet},
    {'name': 'Credit/Debit Card', 'icon': Icons.credit_card},
  ];

  void _handlePaymentSuccess() {
    _cartRef.remove();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Completed'),
        content: Text('Your payment was successfully completed via $_selectedPaymentMethod.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPaymentSelection(double totalBill) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select Payment Method',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ..._paymentMethods.map((method) => ListTile(
                    leading: Icon(method['icon'], color: AppColors.primary),
                    title: Text(method['name']),
                    trailing: Radio<String>(
                      value: method['name'],
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        setModalState(() {
                          _selectedPaymentMethod = value!;
                        });
                        setState(() {
                          _selectedPaymentMethod = value!;
                        });
                      },
                    ),
                  )),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _handlePaymentSuccess();
                  },
                  child: Text('Confirm \$$totalBill',
                      style: const TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: StreamBuilder(
        stream: _cartRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_cart, color: AppColors.primary, size: 60),
                const SizedBox(height: 10),
                const Center(child: Text('Your cart is empty. Scan items to add.')),
              ],
            );
          }

          final cartMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          final cartItems = cartMap.entries.toList();

          double totalBill = 0;
          for (var item in cartItems) {
            final value = item.value as Map<dynamic, dynamic>;
            final price = double.tryParse(value['price'].toString()) ?? 0.0;
            final quantity = int.tryParse(value['qty'].toString()) ?? 1;
            totalBill += price * quantity;
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index].value as Map<dynamic, dynamic>;
                    final key = cartItems[index].key;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(item['link'] ?? ''),
                                fit: BoxFit.cover),
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        title: Text(item['name'] ?? 'Unknown Item',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Qty: ${item['qty'] ?? 1} | \$${item['price']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _cartRef.child(key.toString()).remove();
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withAlpha(50),
                        blurRadius: 10,
                        offset: const Offset(0, -5))
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Bill:',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('\$${totalBill.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _showPaymentSelection(totalBill),
                        child: const Text('Checkout',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}