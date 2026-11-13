import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/address_model.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import '../services/cart_service.dart';
import '../services/cep_service.dart';
import '../services/order_service.dart';
import '../services/payment_service.dart';
import '../services/product_service.dart';
import '../services/shipping_service.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/input_formatters.dart';
import 'my_orders_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardFormKey = GlobalKey<FormState>();

  final CartController _cartController = CartController.instance;
  final CepService _cepService = CepService();
  final ShippingService _shippingService = ShippingService();
  final OrderService _orderService = OrderService();
  final PaymentService _paymentService = PaymentService();
  final ProductService _productService = ProductService();
  final UserService _userService = UserService();

  final _cepController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();

  final _numeroCartaoController = TextEditingController();
  final _nomeCartaoController = TextEditingController();
  final _validadeController = TextEditingController();
  final _cvvController = TextEditingController();

  PaymentMethod _paymentMethod = PaymentMethod.pix;
  ShippingQuote? _quote;
  AddressModel? _address;
  UserModel? _userModel;

  bool _isLookingUpCep = false;
  bool _isSubmitting = false;
  String? _cepError;
  String? _lastLookedUpCep;
  int _cepRequestId = 0;
  Timer? _cepDebounce;
  late final String _pixCode;

  @override
  void initState() {
    super.initState();

    _pixCode = PaymentService.pixCode(
      DateTime.now().millisecondsSinceEpoch.toString(),
    );

    _cartController.addListener(_onCartChanged);

    _loadUserProfile();

    _cartController.ensureLoaded().catchError((Object error) {
      if (!mounted) return;
      _showError(_cleanError(error));
    });
  }

  @override
  void dispose() {
    _cepDebounce?.cancel();
    _cartController.removeListener(_onCartChanged);

    _cepController.dispose();
    _logradouroController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();

    _numeroCartaoController.dispose();
    _nomeCartaoController.dispose();
    _validadeController.dispose();
    _cvvController.dispose();

    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = await _userService.getCurrentUserProfile();
      if (!mounted) return;
      setState(() => _userModel = user);
    } catch (_) {}
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

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: AppDurations.snackBar,
      ),
    );
  }

  double get _total =>
      _cartController.subtotal + (_quote?.valor ?? 0.0);

  void _onCepChanged(String value) {
    final digits = onlyDigits(value);
    _cepDebounce?.cancel();

    if (digits != _lastLookedUpCep) {
      setState(() {
        _quote = null;
        _address = null;
        _cepError = null;
      });
    }

    if (digits.length != 8) return;

    _cepDebounce = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      _lookupCep(digits);
    });
  }

  Future<void> _lookupCep(String digits, {bool force = false}) async {
    if (!force && digits == _lastLookedUpCep && _address != null) return;

    final requestId = ++_cepRequestId;

    setState(() {
      _isLookingUpCep = true;
      _cepError = null;
      _quote = null;
      _address = null;
      _logradouroController.clear();
      _numeroController.clear();
      _complementoController.clear();
      _bairroController.clear();
      _cidadeController.clear();
      _estadoController.clear();
    });

    try {
      final address = await _cepService.lookup(digits);
      if (!mounted || requestId != _cepRequestId) return;

      final quote = _shippingService.quoteForAddress(address);

      setState(() {
        _lastLookedUpCep = digits;
        _address = address;
        _logradouroController.text = address.logradouro;
        _bairroController.text = address.bairro;
        _cidadeController.text = address.cidade;
        _estadoController.text = address.estado;
        _quote = quote;
        _cepError = quote == null
            ? 'Não foi possível calcular o frete para este CEP. Use um CEP com logradouro.'
            : null;
      });
    } catch (error) {
      if (!mounted || requestId != _cepRequestId) return;

      setState(() {
        _lastLookedUpCep = null;
        _cepError = _cleanError(error);
      });
    } finally {
      if (mounted && requestId == _cepRequestId) {
        setState(() => _isLookingUpCep = false);
      }
    }
  }

  AddressModel _buildAddress() {
    return AddressModel(
      cep: formatCep(_cepController.text),
      logradouro: _logradouroController.text.trim(),
      numero: _numeroController.text.trim(),
      complemento: _complementoController.text.trim(),
      bairro: _bairroController.text.trim(),
      cidade: _cidadeController.text.trim(),
      estado: _estadoController.text.trim().toUpperCase(),
      latitude: _address?.latitude,
      longitude: _address?.longitude,
    );
  }

  bool _validateBeforeSubmit() {
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid) return false;

    if (_quote == null) {
      _showError('Informe um CEP válido e aguarde o cálculo do frete.');
      return false;
    }

    if (_paymentMethod != PaymentMethod.pix) {
      final cardValid = _cardFormKey.currentState?.validate() ?? false;
      if (!cardValid) return false;
    }

    if (_cartController.items.isEmpty) {
      _showError('Seu carrinho está vazio.');
      return false;
    }

    return true;
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_validateBeforeSubmit()) return;

    setState(() => _isSubmitting = true);

    try {
      final cart = _cartController.cart;
      if (cart == null || cart.isEmpty) {
        throw Exception('Seu carrinho está vazio.');
      }

      for (final item in cart.items) {
        final product = await _productService.getProductById(item.productId);

        if (product == null) {
          throw Exception(
            'O produto "${item.nome}" não está mais disponível.',
          );
        }

        if (!product.ativo) {
          throw Exception('O produto "${item.nome}" está inativo.');
        }

        if (product.estoque < item.quantidade) {
          throw Exception(
            'Estoque insuficiente para "${item.nome}". Disponível: ${product.estoque}.',
          );
        }
      }

      final payment = await _paymentService.process(
        metodo: _paymentMethod,
        valor: _total,
        numeroCartao: _paymentMethod == PaymentMethod.pix
            ? null
            : _numeroCartaoController.text,
      );

      if (!payment.approved) {
        throw Exception(payment.message);
      }

      final order = OrderModel(
        codigo: OrderModel.generateCode(),
        userId: cart.userId,
        clienteNome: _userModel?.name ?? '',
        clienteEmail: _userModel?.email ??
            FirebaseAuth.instance.currentUser?.email ??
            '',
        clienteTelefone: _userModel?.phone ?? '',
        itens: cart.items.map(OrderItem.fromCartItem).toList(),
        endereco: _buildAddress(),
        pagamentoMetodo: _paymentMethod,
        pagamentoResumo: payment.resumo,
        subtotal: cart.subtotal,
        frete: _quote!.valor,
        distanciaKm: _quote!.distanciaKm,
        total: _total,
        status: 'confirmado',
        createdAt: DateTime.now(),
      );

      await _orderService.createOrder(order);

      final stockErrors = <String>[];

      for (final item in cart.items) {
        try {
          await _productService.decrementStock(
            item.productId,
            item.quantidade,
          );
        } catch (_) {
          stockErrors.add(item.nome);
        }
      }

      try {
        await _cartController.clear();
      } catch (_) {}

      if (!mounted) return;

      _showSuccessDialog(
        order,
        warning: stockErrors.isEmpty
            ? null
            : 'A compra foi registrada, mas não foi possível atualizar o estoque de: ${stockErrors.join(', ')}.',
      );
    } catch (error) {
      if (!mounted) return;
      _showError(_cleanError(error));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog(OrderModel order, {String? warning}) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            side: AppBorder.thin,
          ),
          title: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 28,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Compra confirmada!',
                  style: AppTextStyles.headlineSmall,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pedido ${order.codigo}',
                style: AppTextStyles.monoMedium.copyWith(
                  color: AppColors.accentPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Total: ${order.totalFormatado}',
                style: AppTextStyles.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Pagamento: ${order.pagamentoResumo}',
                style: AppTextStyles.bodySmall,
              ),
              if (warning != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  warning,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Text(
                'Acompanhe o pedido em "Minhas compras".',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text(
                'CONTINUAR COMPRANDO',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textDim,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.none),
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const MyOrdersScreen(),
                  ),
                  (route) => route.isFirst,
                );
              },
              child: const Text('VER MINHAS COMPRAS'),
            ),
          ],
        );
      },
    );
  }

  String? Function(String?) _requiredValidator(String message) {
    return (value) {
      if (value == null || value.trim().isEmpty) return message;
      return null;
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceDeep,
      appBar: AppBar(
        title: Text('Finalizar Compra', style: AppTextStyles.headlineSmall),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _buildSectionTitle(
              'Endereço de entrega',
              subtitle: 'Informe o CEP para calcular o frete automaticamente.',
            ),
            _buildAddressCard(),
            const SizedBox(height: AppSpacing.lg),
            _buildSectionTitle(
              'Forma de pagamento',
              subtitle: 'Pagamentos.',
            ),
            _buildPaymentCard(),
            const SizedBox(height: AppSpacing.lg),
            _buildSectionTitle('Resumo do pedido'),
            _buildSummaryCard(),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSectionTitle(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.headlineSmall.copyWith(letterSpacing: 0.3),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(subtitle, style: AppTextStyles.bodySmall),
          ],
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      decoration: AppDecorations.card,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _cepController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CepInputFormatter(),
            ],
            onChanged: _onCepChanged,
            style: AppTextStyles.bodyLarge,
            decoration: InputDecoration(
              labelText: 'CEP *',
              hintText: '00000-000',
              prefixIcon: const Icon(
                Icons.location_on_outlined,
                color: AppColors.accentPrimary,
              ),
              suffixIcon: _isLookingUpCep
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.search, size: 20),
                      tooltip: 'Buscar CEP',
                      onPressed: () {
                        final digits = onlyDigits(_cepController.text);
                        if (digits.length == 8) {
                          _cepDebounce?.cancel();
                          _lookupCep(digits, force: true);
                        } else {
                          _showError('Informe um CEP com 8 dígitos.');
                        }
                      },
                    ),
            ),
            validator: (value) {
              final digits = onlyDigits(value ?? '');
              if (digits.length != 8) return 'Informe um CEP válido';
              return null;
            },
          ),
          if (_cepError != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 16,
                  color: AppColors.error,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    _cepError!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (_quote != null) ...[
            const SizedBox(height: AppSpacing.md),
            _buildFreightBox(_quote!),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _logradouroController,
                  style: AppTextStyles.bodyLarge,
                  decoration: const InputDecoration(
                    labelText: 'Logradouro *',
                    prefixIcon: Icon(
                      Icons.signpost_outlined,
                      color: AppColors.accentPrimary,
                    ),
                  ),
                  validator: _requiredValidator('Informe o logradouro'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextFormField(
                  controller: _numeroController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: AppTextStyles.bodyLarge,
                  decoration: const InputDecoration(labelText: 'Número *'),
                  validator: _requiredValidator('Informe o número'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _complementoController,
            style: AppTextStyles.bodyLarge,
            decoration: const InputDecoration(
              labelText: 'Complemento',
              prefixIcon: Icon(
                Icons.meeting_room_outlined,
                color: AppColors.accentPrimary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _bairroController,
            style: AppTextStyles.bodyLarge,
            decoration: const InputDecoration(
              labelText: 'Bairro *',
              prefixIcon: Icon(
                Icons.map_outlined,
                color: AppColors.accentPrimary,
              ),
            ),
            validator: _requiredValidator('Informe o bairro'),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _cidadeController,
                  style: AppTextStyles.bodyLarge,
                  decoration: const InputDecoration(
                    labelText: 'Cidade *',
                    prefixIcon: Icon(
                      Icons.location_city_outlined,
                      color: AppColors.accentPrimary,
                    ),
                  ),
                  validator: _requiredValidator('Informe a cidade'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              SizedBox(
                width: 90,
                child: TextFormField(
                  controller: _estadoController,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 2,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
                  ],
                  style: AppTextStyles.bodyLarge,
                  decoration: const InputDecoration(
                    labelText: 'UF *',
                    counterText: '',
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().length != 2) return 'UF';
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFreightBox(ShippingQuote quote) {
    final color = quote.gratis
        ? AppColors.success
        : AppColors.accentPrimary;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.local_shipping_outlined, color: color, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Frete ${quote.gratis ? 'grátis' : quote.valorFormatado}',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Distância aproximada: ${quote.distanciaFormatada}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard() {
    return Container(
      decoration: AppDecorations.card,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          ...PaymentMethod.values.map(
            (method) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _PaymentTile(
                method: method,
                selected: _paymentMethod == method,
                onTap: () => setState(() => _paymentMethod = method),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (_paymentMethod == PaymentMethod.pix)
            _buildPixPanel()
          else
            _buildCardForm(),
        ],
      ),
    );
  }

  Widget _buildPixPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceOverlay,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.qr_code_2,
              size: 150,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('QR Code', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Use o QR Code acima ou copie o código Pix abaixo para efetuar o pagamento.',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: AppDecorations.input,
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    _pixCode,
                    style: AppTextStyles.monoSmall,
                    maxLines: 3,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  tooltip: 'Copiar código Pix',
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: _pixCode));
                    _showSuccess('Código Pix copiado.');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardForm() {
    return Form(
      key: _cardFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _numeroCartaoController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CardNumberInputFormatter(),
            ],
            style: AppTextStyles.monoLarge,
            decoration: const InputDecoration(
              labelText: 'Número do cartão *',
              hintText: '0000 0000 0000 0000',
              prefixIcon: Icon(
                Icons.credit_card,
                color: AppColors.accentPrimary,
              ),
            ),
            validator: (value) {
              final digits = onlyDigits(value ?? '');
              if (digits.length < 13 || digits.length > 16) {
                return 'Número inválido';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _nomeCartaoController,
            textCapitalization: TextCapitalization.characters,
            style: AppTextStyles.bodyLarge,
            decoration: const InputDecoration(
              labelText: 'Nome impresso no cartão *',
              prefixIcon: Icon(
                Icons.person_outline,
                color: AppColors.accentPrimary,
              ),
            ),
            validator: (value) {
              if ((value ?? '').trim().length < 3) {
                return 'Informe o nome impresso';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _validadeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ExpiryDateInputFormatter(),
                  ],
                  style: AppTextStyles.monoLarge,
                  decoration: const InputDecoration(
                    labelText: 'Validade *',
                    hintText: 'MM/AA',
                  ),
                  validator: (value) {
                    final text = (value ?? '').trim();
                    if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(text)) {
                      return 'MM/AA';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  style: AppTextStyles.monoLarge,
                  decoration: const InputDecoration(
                    labelText: 'CVV *',
                    hintText: '123',
                  ),
                  validator: (value) {
                    final digits = onlyDigits(value ?? '');
                    if (digits.length < 3) return 'CVV';
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final items = _cartController.items;

    return Container(
      decoration: AppDecorations.card,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.quantidade}x ${item.nome}',
                      style: AppTextStyles.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    item.subtotalFormatado,
                    style: AppTextStyles.monoSmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: AppSpacing.xl),
          _summaryRow('Subtotal', formatCurrency(_cartController.subtotal)),
          const SizedBox(height: AppSpacing.xs),
          _summaryRow('Frete', _quote?.valorFormatado ?? 'A calcular'),
          const Divider(height: AppSpacing.xl),
          _summaryRow('TOTAL', formatCurrency(_total), highlight: true),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool highlight = false,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: highlight
              ? AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)
              : AppTextStyles.labelLarge,
        ),
        const Spacer(),
        Text(
          value,
          style: highlight
              ? AppTextStyles.monoLarge.copyWith(
                  color: AppColors.accentPrimary,
                  fontWeight: FontWeight.w700,
                )
              : AppTextStyles.monoMedium,
        ),
      ],
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
              Text('Total', style: AppTextStyles.labelMedium),
              const Spacer(),
              Text(
                formatCurrency(_total),
                style: AppTextStyles.monoLarge.copyWith(
                  color: AppColors.accentPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textOnAccent,
                      ),
                    )
                  : const Icon(Icons.lock_outline, size: 18),
              label: Text(
                _isSubmitting ? 'PROCESSANDO...' : 'FINALIZAR COMPRA',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.accentPrimary.withValues(alpha: 0.08)
                : AppColors.surfaceOverlay,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: selected
                  ? AppColors.accentPrimary
                  : AppColors.borderSubtle,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                method.icon,
                color: selected
                    ? AppColors.accentPrimary
                    : AppColors.textMuted,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.label,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(method.subtitle, style: AppTextStyles.caption),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected
                    ? AppColors.accentPrimary
                    : AppColors.textDim,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
