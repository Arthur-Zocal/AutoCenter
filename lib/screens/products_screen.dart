import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import 'product_form_screen.dart';
import '../theme/app_theme.dart';

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
    'Adesivo/Envelopamento',
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
      builder: (context) => _DeleteConfirmDialog(product: product),
    );

    if (confirmed == true) {
      try {
        await _productService.deleteProduct(product.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Produto excluído com sucesso'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir: ${e.toString()}'),
            backgroundColor: AppColors.error,
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
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryFilter = _selectedCategory.isEmpty ? null : _selectedCategory;

    return Scaffold(
      backgroundColor: AppColors.surfaceDeep,
      appBar: AppBar(
        title: Text('Produtos', style: AppTextStyles.headlineSmall),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: IconButton.filled(
              icon: const Icon(Icons.add, size: 24),
              onPressed: () => _navigateToForm(),
              tooltip: 'Novo Produto',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.accentPrimary,
                foregroundColor: AppColors.textOnAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                padding: const EdgeInsets.all(AppSpacing.sm),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndSortBar(),
          _buildFilterChips(),
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
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  );
                }

                if (snapshot.hasError) {
                  final error = snapshot.error.toString();
                  final isIndexError = error.contains('index') || error.contains('Index') || error.contains('FAILED_PRECONDITION');

                  return _buildErrorState(error, isIndexError);
                }

                final products = snapshot.data ?? [];

                if (products.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async => setState(() {}),
                  color: AppColors.accentPrimary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.lg),
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

  Widget _buildSearchAndSortBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: AppTextStyles.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Buscar por nome, SKU ou marca...',
                prefixIcon: const Icon(Icons.search, size: 22),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            icon: Icon(
              Icons.tune,
              color: _statusFilter == _StatusFilter.ativos
                  ? AppColors.accentPrimary
                  : AppColors.textDim,
              size: 24,
            ),
            tooltip: 'Filtrar e ordenar',
            onPressed: () => _showFilterBottomSheet(),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceOverlay,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              padding: const EdgeInsets.all(AppSpacing.sm),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = (_selectedCategory.isEmpty && category == 'Todas') ||
              _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) => _onCategoryChanged(category),
              selectedColor: AppColors.accentPrimary.withValues(alpha: 0.15),
              checkmarkColor: AppColors.accentPrimary,
              labelStyle: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? AppColors.accentPrimary : AppColors.textMuted,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              backgroundColor: AppColors.surfaceOverlay,
              side: BorderSide(
                color: isSelected
                    ? AppColors.accentPrimary
                    : AppColors.borderSubtle,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String error, bool isIndexError) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Erro ao carregar produtos',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            if (isIndexError) ...[
              Text(
                'Índice do Firestore necessário.',
                style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Acesse o link no console do Firebase para criar o índice automaticamente:',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              SelectableText(
                error,
                style: AppTextStyles.monoSmall.copyWith(color: AppColors.accentGlow),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              Text(
                error,
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
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
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: AppColors.textDim,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Nenhum produto encontrado',
              style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (_searchController.text.isNotEmpty || _selectedCategory.isNotEmpty)
              Text(
                'Tente ajustar os filtros ou a busca',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              )
            else
              Text(
                'Cadastre o primeiro produto da loja',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () => _navigateToForm(),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Cadastrar Produto'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.none),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    _StatusFilter tempStatusFilter = _statusFilter;
    String tempSortField = _sortField;
    bool tempSortDescending = _sortDescending;

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    if (isTablet) {
      _showFilterDialog(
        tempStatusFilter: tempStatusFilter,
        tempSortField: tempSortField,
        tempSortDescending: tempSortDescending,
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      isScrollControlled: true,
      enableDrag: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      builder: (context) => Theme(
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
                    _buildBottomSheetHandle(),
                    _buildFilterModalContent(
                      setModalState: setModalState,
                      tempStatusFilter: tempStatusFilter,
                      tempSortField: tempSortField,
                      tempSortDescending: tempSortDescending,
                      onStatusChanged: (v) => setModalState(() => tempStatusFilter = v),
                      onSortChanged: (v) => setModalState(() {
                        if (v.endsWith('_desc')) {
                          tempSortField = v.replaceAll('_desc', '');
                          tempSortDescending = true;
                        } else {
                          tempSortField = v;
                          tempSortDescending = false;
                        }
                      }),
                      onApply: () {
                        setState(() {
                          _statusFilter = tempStatusFilter;
                          _sortField = tempSortField;
                          _sortDescending = tempSortDescending;
                        });
                        Navigator.pop(context);
                      },
                      onClear: () => setModalState(() {
                        tempStatusFilter = _StatusFilter.ativos;
                        tempSortField = 'createdAt';
                        tempSortDescending = true;
                      }),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showFilterDialog({
    required _StatusFilter tempStatusFilter,
    required String tempSortField,
    required bool tempSortDescending,
  }) {
    showDialog(
      context: context,
      builder: (context) => Theme(
        data: Theme.of(context).copyWith(splashFactory: NoSplash.splashFactory),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            _StatusFilter localStatusFilter = tempStatusFilter;
            String localSortField = tempSortField;
            bool localSortDescending = tempSortDescending;

            return AlertDialog(
              backgroundColor: AppColors.surfaceElevated,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                side: AppBorder.thin,
              ),
              title: Text(
                'FILTRAR E ORDENAR',
                style: AppTextStyles.headlineSmall.copyWith(letterSpacing: 0.5),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterSectionTitle('FILTROS'),
                    RadioListTile<_StatusFilter>(
                      value: _StatusFilter.ativos,
                      groupValue: localStatusFilter,
                      onChanged: (v) => setModalState(() => localStatusFilter = v!),
                      dense: true,
                      title: Text('Ativos', style: AppTextStyles.bodyMedium),
                      secondary: Icon(
                        Icons.check_circle,
                        size: 22,
                        color: localStatusFilter == _StatusFilter.ativos
                            ? AppColors.accentPrimary
                            : AppColors.textDim,
                      ),
                      activeColor: AppColors.accentPrimary,
                      tileColor: localStatusFilter == _StatusFilter.ativos
                          ? AppColors.accentPrimary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    ),
                    RadioListTile<_StatusFilter>(
                      value: _StatusFilter.inativos,
                      groupValue: localStatusFilter,
                      onChanged: (v) => setModalState(() => localStatusFilter = v!),
                      dense: true,
                      title: Text('Inativos', style: AppTextStyles.bodyMedium),
                      secondary: Icon(
                        Icons.cancel,
                        size: 22,
                        color: localStatusFilter == _StatusFilter.inativos
                            ? AppColors.accentPrimary
                            : AppColors.textDim,
                      ),
                      activeColor: AppColors.accentPrimary,
                      tileColor: localStatusFilter == _StatusFilter.inativos
                          ? AppColors.accentPrimary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    ),
                    const Divider(height: AppSpacing.xl),
                    _buildFilterSectionTitle('ORDENAR'),
                    ..._sortOptions.entries.map((entry) {
                      final isSelected = localSortDescending
                          ? entry.key == '${localSortField}_desc'
                          : entry.key == localSortField;
                      return RadioListTile<String>(
                        value: entry.key,
                        groupValue: localSortDescending ? '${localSortField}_desc' : localSortField,
                        onChanged: (value) {
                          if (value == null) return;
                          setModalState(() {
                            if (value.endsWith('_desc')) {
                              localSortField = value.replaceAll('_desc', '');
                              localSortDescending = true;
                            } else {
                              localSortField = value;
                              localSortDescending = false;
                            }
                          });
                        },
                        dense: true,
                        title: Text(entry.value, style: AppTextStyles.bodyMedium),
                        secondary: isSelected
                            ? const Icon(Icons.check, size: 18, color: AppColors.accentPrimary)
                            : null,
                        activeColor: AppColors.accentPrimary,
                        tileColor: isSelected
                            ? AppColors.accentPrimary.withValues(alpha: 0.1)
                            : Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                      );
                    }),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.cleaning_services, size: 18),
                            label: Text('LIMPAR', style: AppTextStyles.buttonMedium),
                            onPressed: () => setModalState(() {
                              localStatusFilter = _StatusFilter.ativos;
                              localSortField = 'createdAt';
                              localSortDescending = true;
                            }),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.search, size: 18),
                            label: Text('APLICAR', style: AppTextStyles.buttonMedium),
                            onPressed: () {
                              setState(() {
                                _statusFilter = localStatusFilter;
                                _sortField = localSortField;
                                _sortDescending = localSortDescending;
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
                  child: Text('CANCELAR', style: AppTextStyles.labelLarge.copyWith(color: AppColors.textDim)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomSheetHandle() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.borderSubtle,
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
      ),
    );
  }

  Widget _buildFilterModalContent({
    required StateSetter setModalState,
    required _StatusFilter tempStatusFilter,
    required String tempSortField,
    required bool tempSortDescending,
    required void Function(_StatusFilter) onStatusChanged,
    required void Function(String) onSortChanged,
    required VoidCallback onApply,
    required VoidCallback onClear,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'FILTRAR E ORDENAR',
                style: AppTextStyles.headlineSmall.copyWith(letterSpacing: 0.5),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.close, color: AppColors.textDim),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(height: 1),
          _buildFilterSectionTitle('FILTROS'),
          RadioListTile<_StatusFilter>(
            value: _StatusFilter.ativos,
            groupValue: tempStatusFilter,
            onChanged: (v) => setModalState(() => onStatusChanged(v!)),
            dense: true,
            title: Text('Ativos', style: AppTextStyles.bodyMedium),
            secondary: Icon(
              Icons.check_circle,
              size: 22,
              color: tempStatusFilter == _StatusFilter.ativos
                  ? AppColors.accentPrimary
                  : AppColors.textDim,
            ),
            activeColor: AppColors.accentPrimary,
            tileColor: tempStatusFilter == _StatusFilter.ativos
                ? AppColors.accentPrimary.withValues(alpha: 0.1)
                : Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          ),
          RadioListTile<_StatusFilter>(
            value: _StatusFilter.inativos,
            groupValue: tempStatusFilter,
            onChanged: (v) => setModalState(() => onStatusChanged(v!)),
            dense: true,
            title: Text('Inativos', style: AppTextStyles.bodyMedium),
            secondary: Icon(
              Icons.cancel,
              size: 22,
              color: tempStatusFilter == _StatusFilter.inativos
                  ? AppColors.accentPrimary
                  : AppColors.textDim,
            ),
            activeColor: AppColors.accentPrimary,
            tileColor: tempStatusFilter == _StatusFilter.inativos
                ? AppColors.accentPrimary.withValues(alpha: 0.1)
                : Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          ),
          const Divider(height: AppSpacing.xl),
          _buildFilterSectionTitle('ORDENAR'),
          ..._sortOptions.entries.map((entry) {
            final isSelected = tempSortDescending
                ? entry.key == '${tempSortField}_desc'
                : entry.key == tempSortField;
            return RadioListTile<String>(
              value: entry.key,
              groupValue: tempSortDescending ? '${tempSortField}_desc' : tempSortField,
              onChanged: (value) {
                if (value == null) return;
                setModalState(() => onSortChanged(value));
              },
              dense: true,
              title: Text(entry.value, style: AppTextStyles.bodyMedium),
              secondary: isSelected
                  ? const Icon(Icons.check, size: 18, color: AppColors.accentPrimary)
                  : null,
              activeColor: AppColors.accentPrimary,
              tileColor: isSelected
                  ? AppColors.accentPrimary.withValues(alpha: 0.1)
                  : Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            );
          }),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.cleaning_services, size: 18),
                  label: Text('LIMPAR', style: AppTextStyles.buttonMedium),
                  onPressed: onClear,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.search, size: 18),
                  label: Text('APLICAR', style: AppTextStyles.buttonMedium),
                  onPressed: onApply,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: AppTextStyles.labelSmall,
      ),
    );
  }
}

class _DeleteConfirmDialog extends StatelessWidget {
  final Product product;

  const _DeleteConfirmDialog({required this.product});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceElevated,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: AppBorder.thin,
      ),
      title: Text('Confirmar Exclusão', style: AppTextStyles.headlineSmall),
      content: Text(
        'Excluir "${product.nome}"?\n\nEsta ação não pode ser desfeita.',
        style: AppTextStyles.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancelar', style: AppTextStyles.labelLarge.copyWith(color: AppColors.textDim)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.textOnAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.none)),
          ),
          child: Text('EXCLUIR', style: AppTextStyles.buttonMedium),
        ),
      ],
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
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: AppDecorations.card,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
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
                        color: AppColors.accentPrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppColors.accentPrimary.withValues(alpha: 0.2), width: 1),
                      ),
                      child: Icon(
                        product.categoryEnum.icon,
                        color: AppColors.accentPrimary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  product.nome,
                                  style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (!product.ativo)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                                  decoration: AppDecorations.badgeError,
                                  child: Text(
                                    'INATIVO',
                                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.error, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              PopupMenuButton<String>(
                                icon: Icon(Icons.more_vert, color: AppColors.textDim, size: 24),
                                tooltip: 'Mais opções',
                                color: AppColors.surfaceElevated,
                                surfaceTintColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.lg),
                                  side: AppBorder.thin,
                                ),
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
                                        Icon(Icons.edit, size: 20, color: AppColors.accentGlow),
                                        const SizedBox(width: AppSpacing.md),
                                        Text('Editar', style: AppTextStyles.bodyMedium),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, size: 20, color: AppColors.error),
                                        const SizedBox(width: AppSpacing.md),
                                        Text('Excluir', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              Text(
                                product.marca,
                                style: AppTextStyles.bodySmall,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Text(
                                'SKU: ${product.sku}',
                                style: AppTextStyles.monoSmall.copyWith(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (product.descricao.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    product.descricao,
                    style: AppTextStyles.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (product.imagemUrl != null && product.imagemUrl!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        product.imagemUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: AppColors.surfaceOverlay,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: AppColors.accentPrimary,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.surfaceOverlay,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  size: 32,
                                  color: AppColors.textDim,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'Imagem indisponível',
                                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textDim),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                _buildInfoRow('CATEGORIA', product.categoria, AppColors.accentGlow),
                const SizedBox(height: AppSpacing.sm),
                _buildInfoRow('ESTOQUE', product.stockStatus, product.stockColor == Colors.green ? AppColors.success : (product.stockColor == Colors.orange ? AppColors.warning : AppColors.error)),
                const SizedBox(height: AppSpacing.sm),
                _buildInfoRow('VALOR', product.formattedPrice, AppColors.accentPrimary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: AppTextStyles.labelMedium,
        ),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.monoMedium.copyWith(color: color, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}