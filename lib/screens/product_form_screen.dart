import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../theme/app_theme.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _CategoryItem {
  final String label;
  final IconData icon;

  const _CategoryItem({required this.label, required this.icon});
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productService = ProductService();

  late final TextEditingController _nomeController;
  late final TextEditingController _marcaController;
  late final TextEditingController _skuController;
  late final TextEditingController _precoController;
  late final TextEditingController _estoqueController;
  late final TextEditingController _descricaoController;
  late final TextEditingController _imagemUrlController;

  String _selectedCategoryLabel = ProductCategory.mecanicaGeral.label;
  bool _ativo = true;
  bool _isLoading = false;
  bool _isEditing = false;

  static const List<_CategoryItem> _allCategories = [
    _CategoryItem(label: 'Mecânica Geral', icon: Icons.build),
    _CategoryItem(label: 'Estética Automotiva', icon: Icons.clean_hands),
    _CategoryItem(label: 'Suspensão e Freios', icon: Icons.directions_car),
    _CategoryItem(label: 'Faróis e Lâmpadas', icon: Icons.light_mode),
    _CategoryItem(label: 'Lubrificantes', icon: Icons.local_gas_station),
    _CategoryItem(label: 'Baterias', icon: Icons.battery_charging_full),
    _CategoryItem(label: 'Adesivo/Envelopamento', icon: Icons.layers),
  ];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.product != null;

    _nomeController = TextEditingController(text: widget.product?.nome ?? '');
    _marcaController = TextEditingController(text: widget.product?.marca ?? '');
    _skuController = TextEditingController(text: widget.product?.sku ?? '');
    _precoController = TextEditingController(
      text: widget.product?.preco.toStringAsFixed(2).replaceAll('.', ',') ?? '',
    );
    _estoqueController = TextEditingController(text: widget.product?.estoque.toString() ?? '');
    _descricaoController = TextEditingController(text: widget.product?.descricao ?? '');
    _imagemUrlController = TextEditingController(text: widget.product?.imagemUrl ?? '');

    if (widget.product != null) {
      _selectedCategoryLabel = widget.product!.categoria;
      _ativo = widget.product!.ativo;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _marcaController.dispose();
    _skuController.dispose();
    _precoController.dispose();
    _estoqueController.dispose();
    _descricaoController.dispose();
    _imagemUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final preco = double.parse(_precoController.text.replaceAll(',', '.'));
      final estoque = int.parse(_estoqueController.text);

      final product = Product(
        id: widget.product?.id ?? '',
        nome: _nomeController.text.trim(),
        marca: _marcaController.text.trim(),
        sku: _skuController.text.trim().toUpperCase(),
        preco: preco,
        estoque: estoque,
        descricao: _descricaoController.text.trim(),
        categoria: _selectedCategoryLabel,
        ativo: _ativo,
        imagemUrl: _imagemUrlController.text.trim().isEmpty
            ? null
            : _imagemUrlController.text.trim(),
      );

      if (_isEditing) {
        await _productService.updateProduct(product);
      } else {
        await _productService.createProduct(product);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'Produto atualizado com sucesso!' : 'Produto cadastrado com sucesso!',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop(true);
    } on FormatException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preço ou estoque inválido. Verifique os valores.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${e.toString()}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _checkSkuAvailability(String sku) async {
    if (sku.length < 3) return;

    try {
      final exists = await _productService.checkSkuExists(
        sku,
        excludeId: _isEditing ? widget.product?.id : null,
      );

      if (exists && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SKU "$sku" já está em uso'),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceDeep,
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Produto' : 'Novo Produto', style: AppTextStyles.headlineSmall),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('Informações Básicas'),
              _buildTextField(
                controller: _nomeController,
                label: 'Nome do Produto *',
                hint: 'Ex: Kit Embreagem',
                icon: Icons.inventory_2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o nome do produto';
                  }
                  if (value.trim().length < 2) {
                    return 'Nome muito curto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              _buildCategoryDropdown(),
              const SizedBox(height: AppSpacing.md),
              _buildTextField(
                controller: _marcaController,
                label: 'Marca *',
                hint: 'Ex: Bosch, NGK, Gates',
                icon: Icons.branding_watermark,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe a marca';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              _buildTextField(
                controller: _skuController,
                label: 'SKU / Código *',
                hint: 'Ex: KIT-EMB-001',
                icon: Icons.qr_code,
                textCapitalization: TextCapitalization.characters,
                onChanged: (value) => _checkSkuAvailability(value),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o SKU';
                  }
                  if (value.trim().length < 3) {
                    return 'SKU deve ter pelo menos 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildSectionTitle('Preço e Estoque'),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _precoController,
                      label: 'Preço (R\$) *',
                      hint: '0,00',
                      icon: Icons.attach_money,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                        _CurrencyInputFormatter(),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe o preço';
                        }
                        final preco = double.tryParse(value.replaceAll(',', '.'));
                        if (preco == null || preco <= 0) {
                          return 'Preço inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildTextField(
                      controller: _estoqueController,
                      label: 'Estoque *',
                      hint: '0',
                      icon: Icons.inventory,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe o estoque';
                        }
                        final estoque = int.tryParse(value);
                        if (estoque == null || estoque < 0) {
                          return 'Estoque inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildSectionTitle('Descrição'),
              _buildTextField(
                controller: _descricaoController,
                label: 'Descrição',
                hint: 'Detalhes do produto, aplicações, especificações...',
                icon: Icons.description,
                maxLines: 3,
                validator: (value) => null,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildTextField(
                controller: _imagemUrlController,
                label: 'URL da Imagem',
                hint: 'https://imagem.com/imagem.jpg',
                icon: Icons.image,
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final uri = Uri.tryParse(value.trim());
                    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
                      return 'URL inválida';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildSectionTitle('Status'),
              Container(
                decoration: AppDecorations.card,
                child: SwitchListTile(
                  secondary: Icon(
                    _ativo ? Icons.check_circle : Icons.cancel,
                    color: _ativo ? AppColors.success : AppColors.error,
                  ),
                  title: Text(
                    _ativo ? 'Produto Ativo' : 'Produto Inativo',
                    style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    _ativo
                        ? 'Visível nas listagens e disponível para venda'
                        : 'Oculto das listagens, não disponível para venda',
                    style: AppTextStyles.bodySmall,
                  ),
                  value: _ativo,
                  activeThumbColor: AppColors.accentPrimary,
                  onChanged: (value) => setState(() => _ativo = value),
                  contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProduct,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppColors.textOnAccent,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          _isEditing ? 'SALVAR ALTERAÇÕES' : 'CADASTRAR PRODUTO',
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategoryLabel,
      items: _allCategories.map((cat) {
        return DropdownMenuItem<String>(
          value: cat.label,
          child: Row(
            children: [
              Icon(cat.icon, size: 20, color: AppColors.accentPrimary),
              const SizedBox(width: AppSpacing.sm),
              Text(cat.label, style: AppTextStyles.bodyMedium),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) setState(() => _selectedCategoryLabel = value);
      },
      validator: (value) => value == null ? 'Selecione uma categoria' : null,
      style: AppTextStyles.bodyLarge,
      dropdownColor: AppColors.surfaceElevated,
      decoration: InputDecoration(
        labelText: 'Categoria *',
        hintText: 'Selecione a categoria',
        prefixIcon: Icon(Icons.category, color: AppColors.accentPrimary),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        title,
        style: AppTextStyles.headlineSmall.copyWith(letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      validator: validator,
      onChanged: onChanged,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.accentPrimary),
      ),
    );
  }
}

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (text.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final value = int.parse(text);
    final formatted = (value / 100).toStringAsFixed(2).replaceAll('.', ',');

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}