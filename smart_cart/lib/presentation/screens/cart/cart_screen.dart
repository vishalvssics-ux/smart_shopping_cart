import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../core/theme/app_theme.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final DatabaseReference _cartRef = FirebaseDatabase.instance.ref('cart');
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Clear cart on success
    _cartRef.remove();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment Successful! Cart Cleared.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Failed: ${response.message}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External Wallet: ${response.walletName}'),
      ),
    );
  }

  void _openCheckout(double amount) {
    var options = {
      'key': 'rzp_test_5rVqLzFvJxFx8f', // Standard Razorpay Test Key
      'amount': (amount * 100).toInt(), // amount in the smallest currency unit (paise)
      'name': 'Smart Shopping Cart',
      'description': 'Dummy Payment for Cart Items',
      'timeout': 300, // in seconds
      'prefill': {
        'contact': '9876543210',
        'email': 'test@example.com'
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
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
            return const Center(child: Text('Your cart is empty. Scan items to add.'));
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
                            image: DecorationImage(image: NetworkImage(item['link'],),fit: BoxFit.cover),
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                         
                        ),
                        title: Text(item['name'] ?? 'Unknown Item', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                    BoxShadow(color: Colors.grey.withAlpha(50), blurRadius: 10, offset: const Offset(0, -5))
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Bill:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('\$${totalBill.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _openCheckout(totalBill),
                        child: const Text('Pay Now', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
