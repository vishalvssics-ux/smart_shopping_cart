import 'package:flutter/material.dart';
import 'package:smart_cart/core/theme/app_theme.dart';
import 'package:smart_cart/presentation/screens/profile/profile_screen.dart';
import 'package:smart_cart/presentation/screens/shop/shop_screen.dart';
import 'package:smart_cart/presentation/screens/cart/cart_screen.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _currentIndex = 0;

  // Replace these with your actual screen widgets
  final List<Widget> _pages = [
    const ShopScreen(),
    const CartScreen(),
    const ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        height: 70,
        color: Colors.grey[100],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icontextfield(icon: Icons.shopping_bag, title: 'Shop', index: 0),
            Icontextfield(icon: Icons.shopping_cart, title: 'Cart', index: 1),
            Icontextfield(icon: Icons.person, title: 'Profile', index: 2),
          ],
        ),
      ),
    );
  }

  Widget Icontextfield({IconData? icon, String? title, required int index}) {
    final bool isSelected = _currentIndex == index;
    final Color itemColor = isSelected ? AppColors.primary : Colors.grey;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: isSelected ? 24 : 18, color: itemColor),
          const SizedBox(height: 4),
          Text(
            title!,
            style: TextStyle(
              color: itemColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          )
        ],
      ),
    );
  }
}