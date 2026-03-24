import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/product_provider.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  Widget _buildBase64Image(String base64String) {
    try {
      final split = base64String.split(',');
      final cleanBase64 = split.length > 1 ? split[1] : split[0];
      final pureBase64 = cleanBase64.replaceAll(RegExp(r'\s+'), '');
      return Image.memory(
        base64Decode(pureBase64),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
      );
    } catch (e) {
      return const Icon(Icons.image, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Store Products')),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }
          if (provider.sections.isEmpty) {
            return const Center(child: Text('No products available right now.'));
          }

          final sections = provider.sections;
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 20),
            itemCount: sections.length,
            itemBuilder: (context, index) {
              final section = sections[index];
              final categoryName = section['category'] ?? 'Category';
              final sectionName = section['section'] ?? '';
              final products = section['products'] as List<dynamic>? ?? [];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                    child: Text(
                      '$categoryName - $sectionName',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: products.length,
                      itemBuilder: (context, pIndex) {
                        final product = products[pIndex];
                        return Container(
                          width: 150,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: _buildBase64Image(product['image'] ?? ''),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['product_name'] ?? 'Unknown',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${product['quantity']} | \$${product['price']}',
                                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                                      ),
                                      if (product['discount'] != null && product['discount'] > 0)
                                        Card(
                                          color: Colors.amber,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'Discount: ${product['discount']}%',
                                              style: const TextStyle(color: Colors.white, fontSize: 12),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              );
            },
          );
        },
      ),
    );
  }
}
