import 'package:flutter/material.dart';

import '../models/cart_model.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartController _controller = CartController.instance;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();

    _controller.ensureLoaded().catchError((Object error) {
      if (!mounted) return;
      _showError(_cleanError(error));
    });
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_isUpdating) return;

    setState(() => _isUpdating = true);

    try {
      await action();
    } catch (error) {
      _showError(_cleanError(error));
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _clearCart() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: AppBorder.thin,
        ),
        title: Text('Limpar carrinho', style: AppTextStyles.headlineSmall),
        content: Text(
          'Remover todos os itens do carrinho?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'CANCELAR',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.textDim),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.none),
              ),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('LIMPAR'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await _run(() => _controller.clear());
  }

  Future<void> _openCheckout() async {
    await _controller.ensureLoaded();

    if (!mounted) return;

    if (_controller.items.isEmpty) {
      _showError('Seu carrinho está vazio.');
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceDeep,
      appBar: AppBar(
        title: Text('Meu Carrinho', style: AppTextStyles.headlineSmall),
        actions: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              if (_controller.items.isEmpty) return const SizedBox.shrink();

              return IconButton(
                icon: const Icon(Icons.delete_sweep_outlined),
                tooltip: 'Limpar carrinho',
                onPressed: _isUpdating ? null : _clearCart,
              );
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.isLoading && _controller.cart == null) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2.5),
            );
          }

          final items = _controller.items;

          if (items.isEmpty) return _buildEmptyState();

          return RefreshIndicator(
            color: AppColors.accentPrimary,
            onRefresh: () => _controller.ensureLoaded(),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final item = items[index];

                return _CartItemCard(
                  item: item,
                  enabled: !_isUpdating,
                  onIncrement: () => _run(
                    () => _controller.updateQuantity(
                      item.productId,
                      item.quantidade + 1,
                    ),
                  ),
                  onDecrement: () => _run(
                    () => _controller.updateQuantity(
                      item.productId,
                      item.quantidade - 1,
                    ),
                  ),
                  onRemove: () => _run(
                    () => _controller.removeItem(item.productId),
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.items.isEmpty) return const SizedBox.shrink();
          return _buildBottomBar();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.accentPrimary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 64,
                color: AppColors.accentPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Seu carrinho está vazio',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Adicione produtos para continuar a compra.',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.storefront_outlined, size: 20),
              label: const Text('EXPLORAR PRODUTOS'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceElevated,
        border: Border(
          top: BorderSide(color: AppColors.borderSubtle, width: 0.5),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text('Subtotal', style: AppTextStyles.labelLarge),
              const Spacer(),
              Text(
                formatCurrency(_controller.subtotal),
                style: AppTextStyles.monoLarge.copyWith(
                  color: AppColors.accentPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Frete calculado no checkout',
              style: AppTextStyles.bodySmall,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isUpdating ? null : _openCheckout,
              icon: const Icon(Icons.shopping_cart_checkout, size: 20),
              label: const Text('FINALIZAR COMPRA'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final bool enabled;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.enabled,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.card,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProductThumb(item: item),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nome,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${item.precoFormatado} cada',
                      style: AppTextStyles.monoSmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      item.estoque > 0
                          ? 'Estoque: ${item.estoque}'
                          : 'Produto indisponível',
                      style: AppTextStyles.caption.copyWith(
                        color: item.estoque > 0
                            ? AppColors.textDim
                            : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: AppColors.error,
                tooltip: 'Remover item',
                onPressed: enabled ? onRemove : null,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _buildQuantityStepper(),
              const Spacer(),
              Text(
                item.subtotalFormatado,
                style: AppTextStyles.monoMedium.copyWith(
                  color: AppColors.accentPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityStepper() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceOverlay,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            onPressed: enabled && item.quantidade > 1 ? onDecrement : null,
            tooltip: item.quantidade <= 1
                ? 'Use a lixeira para remover'
                : 'Diminuir quantidade',
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            padding: EdgeInsets.zero,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text(
              '${item.quantidade}',
              style: AppTextStyles.monoMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: enabled && item.quantidade < item.estoque
                ? onIncrement
                : null,
            tooltip: item.quantidade >= item.estoque
                ? 'Estoque máximo atingido'
                : 'Aumentar quantidade',
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

class _ProductThumb extends StatelessWidget {
  final CartItem item;

  const _ProductThumb({required this.item});

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.accentPrimary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.accentPrimary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Icon(
        ProductCategory.fromString(item.categoria).icon,
        color: AppColors.accentPrimary,
        size: 26,
      ),
    );

    final url = item.imagemUrl;

    if (url == null || url.isEmpty) return fallback;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Image.network(
        url,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      ),
    );
  }
}
