import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import 'product_form_screen.dart';

class ProductsScreen extends StatefulWidget {
  final String? initialCategory;

  const ProductsScreen({super.key, this.initialCategory});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _productService = ProductService();

  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = '';
  String _sortField = 'createdAt';
  bool _sortDescending = true;

  static const List<String> _categories = [
    'Todas',
    'Mecânica Geral',
    'Estética Automotiva',
    'Suspensão e Freios',
    'Faróis e Lâmpadas',
    'Lubrificantes',
    'Baterias',
  ];

  static const Map<String, String> _sortOptions = {
    'createdAt': 'Mais recentes',
    'createdAt_desc': 'Mais antigos',
    'nome': 'Nome (A-Z)',
    'nome_desc': 'Nome (Z-A)',
    'preco': 'Preço (Menor)',
    'preco_desc': 'Preço (Maior)',
    'estoque': 'Estoque (Menor)',
    'estoque_desc': 'Estoque (Maior)',
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null && widget.initialCategory!.isNotEmpty) {
      _selectedCategory = widget.initialCategory!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {});
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category == 'Todas' ? '' : category;
    });
  }

  void _onSortChanged(String? value) {
    if (value == null) return;
    setState(() {
      if (value.endsWith('_desc')) {
        _sortField = value.replaceAll('_desc', '');
        _sortDescending = true;
      } else {
        _sortField = value;
        _sortDescending = false;
      }
    });
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmar Exclusão', style: TextStyle(color: Colors.white)),
        content: Text(
          'Excluir "${product.nome}"?\n\nEsta ação não pode ser desfeita.',
          style: TextStyle(color: Colors.grey.shade300),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _productService.deleteProduct(product.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produto excluído com sucesso'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _navigateToForm({Product? product}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ProductFormScreen(product: product),
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(product == null ? 'Produto cadastrado!' : 'Produto atualizado!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : Colors.grey.shade50;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    final categoryFilter = _selectedCategory.isEmpty ? null : _selectedCategory;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Produtos', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        foregroundColor: textColor,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () => _navigateToForm(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: const Color(0xFFD32F2F).withValues(alpha: 0.4),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                'Novo Produto',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndSortBar(context),
          _buildFilterChips(context),
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: _productService.getProducts(
                category: categoryFilter,
                searchQuery: _searchController.text.trim(),
                sortField: _sortField,
                sortDescending: _sortDescending,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFD32F2F)),
                  );
                }

                if (snapshot.hasError) {
                  final error = snapshot.error.toString();
                  final isIndexError = error.contains('index') || error.contains('Index') || error.contains('FAILED_PRECONDITION');
                  
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'Erro ao carregar produtos',
                            style: TextStyle(color: textColor, fontSize: 18),
                          ),
                          const SizedBox(height: 12),
                          if (isIndexError) ...[
                            Text(
                              'Índice do Firestore necessário.',
                              style: TextStyle(color: hintColor, fontSize: 14, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Acesse o link no console do Firebase para criar o índice automaticamente:',
                              style: TextStyle(color: hintColor, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            SelectableText(
                              error,
                              style: TextStyle(color: Colors.blue.shade300, fontSize: 11, fontFamily: 'monospace'),
                              textAlign: TextAlign.center,
                            ),
                          ] else ...[
                            Text(
                              error,
                              style: TextStyle(color: hintColor, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => setState(() {}),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Tentar novamente'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD32F2F),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final products = snapshot.data ?? [];

                if (products.isEmpty) {
                  return _buildEmptyState(context);
                }

                return RefreshIndicator(
                  onRefresh: () async => setState(() {}),
                  color: const Color(0xFFD32F2F),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return _ProductListCard(
                        product: products[index],
                        onEdit: () => _navigateToForm(product: products[index]),
                        onDelete: () => _deleteProduct(products[index]),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndSortBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: 'Buscar por nome, SKU ou marca...',
                hintStyle: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                prefixIcon: Icon(Icons.search, color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                filled: true,
                fillColor: cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 2),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          PopupMenuButton<String>(
            icon: Icon(Icons.sort, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, size: 24),
            tooltip: 'Ordenar',
            color: cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: _onSortChanged,
            itemBuilder: (context) => _sortOptions.entries.map((entry) {
              return PopupMenuItem<String>(
                value: entry.key,
                child: Text(
                  entry.value,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = (_selectedCategory.isEmpty && category == 'Todas') ||
              _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) => _onCategoryChanged(category),
              selectedColor: const Color(0xFFD32F2F).withValues(alpha: 0.2),
              checkmarkColor: const Color(0xFFD32F2F),
              labelStyle: TextStyle(
                color: isSelected
                    ? const Color(0xFFD32F2F)
                    : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFFD32F2F)
                    : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum produto encontrado',
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            if (_searchController.text.isNotEmpty || _selectedCategory.isNotEmpty)
              Text(
                'Tente ajustar os filtros ou a busca',
                style: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade500),
                textAlign: TextAlign.center,
              )
            else
              Text(
                'Cadastre o primeiro produto da loja',
                style: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _navigateToForm(),
              icon: const Icon(Icons.add),
              label: const Text('Cadastrar Produto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductListCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductListCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD32F2F).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    product.categoryEnum.icon,
                    color: const Color(0xFFD32F2F),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.nome,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: product.ativo
                                  ? Colors.green.withValues(alpha: 0.15)
                                  : Colors.red.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product.ativo ? 'ATIVO' : 'INATIVO',
                              style: TextStyle(
                                color: product.ativo ? Colors.green : Colors.red,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.marca,
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'SKU: ${product.sku}',
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (product.descricao.isNotEmpty) ...[
              Text(
                product.descricao,
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
            ],
            _buildInfoRow('Categoria', product.categoria, Colors.blue, isDark),
            const SizedBox(height: 6),
            _buildInfoRow('Estoque', product.stockStatus, product.stockColor, isDark),
            const SizedBox(height: 6),
            _buildInfoRow('Valor', product.formattedPrice, const Color(0xFFD32F2F), isDark),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                  onPressed: onEdit,
                  tooltip: 'Editar',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: onDelete,
                  tooltip: 'Excluir',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color, bool isDark) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}