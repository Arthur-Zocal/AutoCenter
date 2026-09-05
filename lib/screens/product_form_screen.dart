import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
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

  ProductCategory _selectedCategory = ProductCategory.mecanicaGeral;
  bool _ativo = true;
  bool _isLoading = false;
  bool _isEditing = false;

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

    if (widget.product != null) {
      _selectedCategory = widget.product!.categoryEnum;
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
        categoria: _selectedCategory.label,
        ativo: _ativo,
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
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop(true);
    } on FormatException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preço ou estoque inválido. Verifique os valores.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${e.toString()}'),
          backgroundColor: Colors.red,
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
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Produto' : 'Novo Produto'),
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('Informações Básicas', isDark),

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

              const SizedBox(height: 16),

              _buildDropdownField<ProductCategory>(
                label: 'Categoria *',
                hint: 'Selecione a categoria',
                icon: Icons.category,
                value: _selectedCategory,
                items: ProductCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Row(
                      children: [
                        Icon(cat.icon, size: 20, color: const Color(0xFFD32F2F)),
                        const SizedBox(width: 8),
                        Text(cat.label),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedCategory = value);
                },
                validator: (value) => value == null ? 'Selecione uma categoria' : null,
              ),

              const SizedBox(height: 16),

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

              const SizedBox(height: 16),

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

              const SizedBox(height: 24),
              _buildSectionTitle('Preço e Estoque', isDark),

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
                  const SizedBox(width: 16),
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

              const SizedBox(height: 24),
              _buildSectionTitle('Descrição', isDark),

              _buildTextField(
                controller: _descricaoController,
                label: 'Descrição',
                hint: 'Detalhes do produto, aplicações, especificações...',
                icon: Icons.description,
                maxLines: 3,
                validator: (value) => null,
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Status', isDark),

              Card(
                color: cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: SwitchListTile(
                  secondary: Icon(
                    _ativo ? Icons.check_circle : Icons.cancel,
                    color: _ativo ? Colors.green : Colors.red,
                  ),
                  title: Text(
                    _ativo ? 'Produto Ativo' : 'Produto Inativo',
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    _ativo
                        ? 'Visível nas listagens e disponível para venda'
                        : 'Oculto das listagens, não disponível para venda',
                    style: TextStyle(color: hintColor, fontSize: 12),
                  ),
                  value: _ativo,
                  activeColor: const Color(0xFFD32F2F),
                  onChanged: (value) => setState(() => _ativo = value),
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          _isEditing ? 'SALVAR ALTERAÇÕES' : 'CADASTRAR PRODUTO',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      validator: validator,
      onChanged: onChanged,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
        hintStyle: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
        prefixIcon: Icon(icon, color: const Color(0xFFD32F2F)),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required String hint,
    required IconData icon,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      dropdownColor: cardColor,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
        prefixIcon: Icon(icon, color: const Color(0xFFD32F2F)),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
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