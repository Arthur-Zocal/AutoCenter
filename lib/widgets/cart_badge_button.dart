import 'package:flutter/material.dart';

import '../screens/cart_screen.dart';
import '../services/cart_service.dart';
import '../theme/app_theme.dart';

class CartBadgeButton extends StatefulWidget {
  const CartBadgeButton({super.key});

  @override
  State<CartBadgeButton> createState() => _CartBadgeButtonState();
}

class _CartBadgeButtonState extends State<CartBadgeButton> {
  @override
  void initState() {
    super.initState();
    CartController.instance.ensureLoaded().catchError((Object _) {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CartController.instance,
      builder: (context, _) {
        final count = CartController.instance.totalItens;
        final label = count > 99 ? '99+' : '$count';

        return Badge(
          isLabelVisible: count > 0,
          label: Text(label),
          backgroundColor: AppColors.accentPrimary,
          textColor: AppColors.textOnAccent,
          child: IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            tooltip: 'Meu carrinho',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
        );
      },
    );
  }
}
