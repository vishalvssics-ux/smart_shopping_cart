import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductProvider with ChangeNotifier {
  List<dynamic> _sections = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get sections => _sections;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('https://smart-cart-delta-rose.vercel.app/api/products/all'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _sections = data['sections'] as List<dynamic>;
      } else {
        _error = 'Failed to load products. Status: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error fetching products: $e';
    }

    _isLoading = false;
    notifyListeners();
  }
}
