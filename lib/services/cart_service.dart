import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/cart_model.dart';
import '../models/product_model.dart';
import 'jsonbin_config.dart';

class CartBinService {
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'X-Master-Key': JsonBinConfig.masterKey,
  };

  String get _binUrl => '${JsonBinConfig.baseUrl}/${JsonBinConfig.cartsBinId}';

  String get _latestUrl => '$_binUrl/latest';

  Future<Map<String, dynamic>> _fetchRecord() async {
    final response = await http
        .get(Uri.parse(_latestUrl), headers: _headers)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final record = decoded is Map ? decoded['record'] : null;
      if (record is Map) return Map<String, dynamic>.from(record);
      return {'carts': <String, dynamic>{}};
    }

    if (response.statusCode == 404) {
      return {'carts': <String, dynamic>{}};
    }

    throw _handleError(response);
  }

  Future<void> _updateRecord(Map<String, dynamic> record) async {
    final response = await http
        .put(
          Uri.parse(_binUrl),
          headers: _headers,
          body: json.encode(record),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw _handleError(response);
    }
  }

  Future<CartModel> fetchCart(String userId) async {
    final record = await _fetchRecord();
    final cartsRaw = record['carts'];
    final carts = cartsRaw is Map
        ? Map<String, dynamic>.from(cartsRaw)
        : <String, dynamic>{};

    final cartRaw = carts[userId];
    if (cartRaw is Map) {
      return CartModel.fromJson(Map<String, dynamic>.from(cartRaw));
    }

    return CartModel.empty(userId);
  }

  Future<void> saveCart(CartModel cart) async {
    final record = await _fetchRecord();
    final cartsRaw = record['carts'];
    final carts = cartsRaw is Map
        ? Map<String, dynamic>.from(cartsRaw)
        : <String, dynamic>{};

    carts[cart.userId] = cart.toJson();
    record['carts'] = carts;

    await _updateRecord(record);
  }

  Future<void> clearCart(String userId) async {
    final record = await _fetchRecord();
    final cartsRaw = record['carts'];
    final carts = cartsRaw is Map
        ? Map<String, dynamic>.from(cartsRaw)
        : <String, dynamic>{};

    carts.remove(userId);
    record['carts'] = carts;

    await _updateRecord(record);
  }

  Exception _handleError(http.Response response) {
    String message;
    switch (response.statusCode) {
      case 400:
        message = 'Requisição inválida para o carrinho.';
        break;
      case 401:
        message = 'Não autorizado - verifique a Master Key do JSONBin.';
        break;
      case 403:
        message = 'Acesso negado ao bin do carrinho.';
        break;
      case 404:
        message = 'Bin do carrinho não encontrado.';
        break;
      case 429:
        message = 'Limite de requisições do JSONBin excedido. Tente novamente.';
        break;
      case 500:
        message = 'Erro interno do servidor JSONBin.';
        break;
      default:
        message = 'Erro HTTP: ${response.statusCode}';
    }

    try {
      final errorData = json.decode(response.body);
      if (errorData is Map && errorData['message'] != null) {
        message = '${errorData['message']}';
      }
    } catch (_) {}

    return Exception(message);
  }
}

class CartController extends ChangeNotifier {
  CartController._();

  static final CartController instance = CartController._();

  final CartBinService _service = CartBinService();

  CartModel? _cart;
  String? _loadedUid;
  bool _loading = false;
  Future<void>? _loadFuture;
  Future<void> _writeQueue = Future.value();

  CartModel? get cart => _cart;

  bool get isLoading => _loading;

  List<CartItem> get items => _cart?.items ?? const [];

  int get totalItens => _cart?.totalItens ?? 0;

  double get subtotal => _cart?.subtotal ?? 0.0;

  Future<void> ensureLoaded() {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      _cart = null;
      _loadedUid = null;
      notifyListeners();
      return Future.value();
    }

    if (_loadedUid == uid && _cart != null) {
      return Future.value();
    }

    final pending = _loadFuture;
    if (pending != null) return pending;

    final future = _doLoad(uid);
    _loadFuture = future;

    return future.whenComplete(() {
      if (identical(_loadFuture, future)) {
        _loadFuture = null;
      }
    });
  }

  Future<void> _doLoad(String uid) async {
    _loading = true;
    notifyListeners();

    try {
      final loaded = await _service.fetchCart(uid);
      _cart = loaded;
      _loadedUid = uid;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(Product product) async {
    final cart = await _ensureCart();

    if (product.estoque <= 0) {
      throw Exception('Produto indisponível no estoque.');
    }

    final index = cart.items.indexWhere(
      (item) => item.productId == product.id,
    );
    final quantidadeAtual = index == -1 ? 0 : cart.items[index].quantidade;

    if (quantidadeAtual + 1 > product.estoque) {
      throw Exception('Estoque máximo atingido para este produto.');
    }

    final items = [...cart.items];
    if (index == -1) {
      items.add(CartItem.fromProduct(product));
    } else {
      items[index] = items[index].copyWith(
        quantidade: quantidadeAtual + 1,
      );
    }

    await _commit(cart.copyWith(items: items));
  }

  Future<void> updateQuantity(String productId, int quantidade) async {
    final cart = await _ensureCart();
    final index = cart.items.indexWhere(
      (item) => item.productId == productId,
    );

    if (index == -1) return;

    if (quantidade <= 0) {
      await removeItem(productId);
      return;
    }

    final item = cart.items[index];
    if (quantidade > item.estoque) {
      throw Exception('Estoque máximo disponível: ${item.estoque}.');
    }

    final items = [...cart.items];
    items[index] = item.copyWith(quantidade: quantidade);

    await _commit(cart.copyWith(items: items));
  }

  Future<void> removeItem(String productId) async {
    final cart = await _ensureCart();
    final items = cart.items
        .where((item) => item.productId != productId)
        .toList();

    await _commit(cart.copyWith(items: items));
  }

  Future<void> clear() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _cart = CartModel.empty(uid);
    _loadedUid = uid;
    notifyListeners();

    await _queueWrite(() => _service.clearCart(uid));
  }

  Future<CartModel> _ensureCart() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('Usuário não autenticado.');
    }

    if (_cart == null || _loadedUid != uid) {
      await ensureLoaded();
    }

    final cart = _cart;
    if (cart == null) {
      throw Exception('Não foi possível carregar o carrinho.');
    }

    return cart;
  }

  Future<void> _commit(CartModel updated) async {
    final previous = _cart;

    _cart = updated;
    _loadedUid = updated.userId;
    notifyListeners();

    try {
      await _queueWrite(() => _service.saveCart(updated));
    } catch (error) {
      if (identical(_cart, updated)) {
        _cart = previous;
        notifyListeners();
      }
      rethrow;
    }
  }

  Future<void> _queueWrite(Future<void> Function() action) {
    final next = _writeQueue.then((_) => action());
    _writeQueue = next.then<void>((_) {}, onError: (_, _) {});
    return next;
  }

  void reset() {
    _cart = null;
    _loadedUid = null;
    _loadFuture = null;
    _loading = false;
    _writeQueue = Future.value();
    notifyListeners();
  }
}
