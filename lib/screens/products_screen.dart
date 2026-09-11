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

enum _StatusFilter { ativos, inativos }

class _ProductsScreenState extends State<ProductsScreen> {
  final _productService = ProductService();

  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = '';
  String _sortField = 'createdAt';
  bool _sortDescending = true;
  _StatusFilter _statusFilter = _StatusFilter.ativos;

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
            child: IconButton(
              icon: const Icon(Icons.add, size: 28),
              onPressed: () => _navigateToForm(),
              tooltip: 'Novo Produto',
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                onlyActive: _statusFilter == _StatusFilter.ativos,
                onlyInactive: _statusFilter == _StatusFilter.inativos,
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
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Icons.tune,
              color: _statusFilter == _StatusFilter.ativos
                  ? const Color(0xFFD32F2F)
                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              size: 24,
            ),
            tooltip: 'Filtrar e ordenar',
            onPressed: () => _showFilterBottomSheet(context, isDark, cardColor),
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

  void _showFilterBottomSheet(BuildContext context, bool isDark, Color cardColor) {
    _StatusFilter tempStatusFilter = _statusFilter;
    String tempSortField = _sortField;
    bool tempSortDescending = _sortDescending;

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    // Para tablet/desktop, usar modal centralizado; para mobile, bottom sheet
    if (isTablet) {
      _showFilterDialog(context, isDark, cardColor);
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      enableDrag: true,
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.85,
      ),
      builder: (context) {
        return Theme(
          data: Theme.of(context).copyWith(splashFactory: NoSplash.splashFactory),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  // Handle bar melhorado
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 48,
                      height: 5,
                      margin: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        Text(
                          'FILTRAR E ORDENAR',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.close, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Seção Filtros
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
                    child: Text(
                      'FILTROS',
                      style: TextStyle(
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  // Opção Ativos
                  RadioListTile<_StatusFilter>(
                    value: _StatusFilter.ativos,
                    groupValue: tempStatusFilter,
                    onChanged: (value) => setModalState(() => tempStatusFilter = value!),
                    dense: true,
                    title: Text(
                      'Ativos',
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14),
                    ),
                    secondary: Icon(
                      Icons.check_circle,
                      size: 22,
                      color: tempStatusFilter == _StatusFilter.ativos
                          ? const Color(0xFFD32F2F)
                          : (isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                    ),
                    activeColor: const Color(0xFFD32F2F),
                    tileColor: tempStatusFilter == _StatusFilter.ativos
                        ? const Color(0xFFD32F2F).withValues(alpha: 0.1)
                        : Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    visualDensity: VisualDensity.compact,
                  ),
                  // Opção Inativos
                  RadioListTile<_StatusFilter>(
                    value: _StatusFilter.inativos,
                    groupValue: tempStatusFilter,
                    onChanged: (value) => setModalState(() => tempStatusFilter = value!),
                    dense: true,
                    title: Text(
                      'Inativos',
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14),
                    ),
                    secondary: Icon(
                      Icons.cancel,
                      size: 22,
                      color: tempStatusFilter == _StatusFilter.inativos
                          ? const Color(0xFFD32F2F)
                          : (isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                    ),
                    activeColor: const Color(0xFFD32F2F),
                    tileColor: tempStatusFilter == _StatusFilter.inativos
                        ? const Color(0xFFD32F2F).withValues(alpha: 0.1)
                        : Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    visualDensity: VisualDensity.compact,
                  ),
                  const Divider(height: 16),
                  // Seção Ordenação
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: Text(
                      'ORDENAR',
                      style: TextStyle(
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  // Opções de ordenação
                  ..._sortOptions.entries.map((entry) {
                    final isSelected = tempSortDescending
                        ? entry.key == '${tempSortField}_desc'
                        : entry.key == tempSortField;
                    return RadioListTile<String>(
                      value: entry.key,
                      groupValue: tempSortDescending ? '${tempSortField}_desc' : tempSortField,
                      onChanged: (value) {
                        if (value == null) return;
                        setModalState(() {
                          if (value.endsWith('_desc')) {
                            tempSortField = value.replaceAll('_desc', '');
                            tempSortDescending = true;
                          } else {
                            tempSortField = value;
                            tempSortDescending = false;
                          }
                        });
                      },
                      title: Text(
                        entry.value,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 15),
                      ),
                      secondary: isSelected
                          ? Icon(Icons.check, size: 20, color: const Color(0xFFD32F2F))
                          : null,
                      activeColor: const Color(0xFFD32F2F),
                      tileColor: isSelected
                          ? const Color(0xFFD32F2F).withValues(alpha: 0.1)
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    );
                  }),
const SizedBox(height: 16),
                  // Botões de ação
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isSmallScreen = constraints.maxWidth < 360;
                        return Row(
                          children: [
                            // Botão Limpar (vassoura)
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: Icon(Icons.cleaning_services, size: isSmallScreen ? 18 : 20),
                                label: Text('LIMPAR', style: TextStyle(fontSize: isSmallScreen ? 13 : 14)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                                  side: BorderSide(
                                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                                  ),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 10 : 12),
                                ),
                                onPressed: () {
                                  setModalState(() {
                                    tempStatusFilter = _StatusFilter.ativos;
                                    tempSortField = 'createdAt';
                                    tempSortDescending = true;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Botão Aplicar (lupa)
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: Icon(Icons.search, size: isSmallScreen ? 18 : 20),
                                label: Text('APLICAR', style: TextStyle(fontSize: isSmallScreen ? 13 : 14)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD32F2F),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 10 : 12),
                                  elevation: 1,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _statusFilter = tempStatusFilter;
                                    _sortField = tempSortField;
                                    _sortDescending = tempSortDescending;
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ); // Theme
}, // showModalBottomSheet builder
); // showModalBottomSheet
}

void _showFilterDialog(BuildContext context, bool isDark, Color cardColor) {
  _StatusFilter tempStatusFilter = _statusFilter;
  String tempSortField = _sortField;
  bool tempSortDescending = _sortDescending;

  showDialog(
    context: context,
    builder: (context) {
      return Theme(
        data: Theme.of(context).copyWith(splashFactory: NoSplash.splashFactory),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                'FILTRAR E ORDENAR',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Seção Filtros
                    Text(
                      'FILTROS',
                      style: TextStyle(
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Opção Ativos
                    RadioListTile<_StatusFilter>(
                      value: _StatusFilter.ativos,
                      groupValue: tempStatusFilter,
                      onChanged: (value) => setModalState(() => tempStatusFilter = value!),
                      dense: true,
                      title: Text(
                        'Ativos',
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14),
                      ),
                      secondary: Icon(
                        Icons.check_circle,
                        size: 22,
                        color: tempStatusFilter == _StatusFilter.ativos
                            ? const Color(0xFFD32F2F)
                            : (isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                      ),
                      activeColor: const Color(0xFFD32F2F),
                      tileColor: tempStatusFilter == _StatusFilter.ativos
                          ? const Color(0xFFD32F2F).withValues(alpha: 0.1)
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                      visualDensity: VisualDensity.compact,
                    ),
                    // Opção Inativos
                    RadioListTile<_StatusFilter>(
                      value: _StatusFilter.inativos,
                      groupValue: tempStatusFilter,
                      onChanged: (value) => setModalState(() => tempStatusFilter = value!),
                      dense: true,
                      title: Text(
                        'Inativos',
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14),
                      ),
                      secondary: Icon(
                        Icons.cancel,
                        size: 22,
                        color: tempStatusFilter == _StatusFilter.inativos
                            ? const Color(0xFFD32F2F)
                            : (isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                      ),
                      activeColor: const Color(0xFFD32F2F),
                      tileColor: tempStatusFilter == _StatusFilter.inativos
                          ? const Color(0xFFD32F2F).withValues(alpha: 0.1)
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                      visualDensity: VisualDensity.compact,
                    ),
                    const Divider(height: 16),
                    // Seção Ordenação
                    Text(
                      'ORDENAR',
                      style: TextStyle(
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Opções de ordenação
                    ..._sortOptions.entries.map((entry) {
                      final isSelected = tempSortDescending
                          ? entry.key == '${tempSortField}_desc'
                          : entry.key == tempSortField;
                      return RadioListTile<String>(
                        value: entry.key,
                        groupValue: tempSortDescending ? '${tempSortField}_desc' : tempSortField,
                        onChanged: (value) {
                          if (value == null) return;
                          setModalState(() {
                            if (value.endsWith('_desc')) {
                              tempSortField = value.replaceAll('_desc', '');
                              tempSortDescending = true;
                            } else {
                              tempSortField = value;
                              tempSortDescending = false;
                            }
                          });
                        },
                        dense: true,
                        title: Text(
                          entry.value,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14),
                        ),
                        secondary: isSelected
                            ? Icon(Icons.check, size: 18, color: const Color(0xFFD32F2F))
                            : null,
                        activeColor: const Color(0xFFD32F2F),
                        tileColor: isSelected
                            ? const Color(0xFFD32F2F).withValues(alpha: 0.1)
                            : Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                        visualDensity: VisualDensity.compact,
                      );
                    }),
                    const SizedBox(height: 16),
                    // Botões de ação
                    Row(
                      children: [
                        // Botão Limpar (vassoura)
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.cleaning_services, size: 18),
                            label: const Text('LIMPAR', style: TextStyle(fontSize: 13)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                              side: BorderSide(
                                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onPressed: () {
                              setModalState(() {
                                tempStatusFilter = _StatusFilter.ativos;
                                tempSortField = 'createdAt';
                                tempSortDescending = true;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Botão Aplicar (lupa)
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.search, size: 18),
                            label: const Text('APLICAR', style: TextStyle(fontSize: 13)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD32F2F),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              elevation: 1,
                            ),
                            onPressed: () {
                              setState(() {
                                _statusFilter = tempStatusFilter;
                                _sortField = tempSortField;
                                _sortDescending = tempSortDescending;
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('CANCELAR', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                ),
              ],
            );
          },
        ),
      );
    },
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
                          if (!product.ativo)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'INATIVO',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, size: 24),
                            tooltip: 'Mais opções',
                            color: cardColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            onSelected: (value) {
                              if (value == 'edit') {
                                onEdit();
                              } else if (value == 'delete') {
                                onDelete();
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem<String>(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 20, color: Colors.blue),
                                    const SizedBox(width: 12),
                                    const Text('Editar'),
                                  ],
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 20, color: Colors.red),
                                    const SizedBox(width: 12),
                                    const Text('Excluir'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            product.marca,
                            style: TextStyle(
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 12),
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