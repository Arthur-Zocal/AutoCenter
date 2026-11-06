import '../utils/formatters.dart';
import 'product_model.dart';

class CartItem {
  final String productId;
  final String nome;
  final double preco;
  final int quantidade;
  final int estoque;
  final String categoria;
  final String? imagemUrl;

  const CartItem({
    required this.productId,
    required this.nome,
    required this.preco,
    required this.quantidade,
    required this.estoque,
    required this.categoria,
    this.imagemUrl,
  });

  factory CartItem.fromProduct(Product product, {int quantidade = 1}) {
    return CartItem(
      productId: product.id,
      nome: product.nome,
      preco: product.preco,
      quantidade: quantidade,
      estoque: product.estoque,
      categoria: product.categoria,
      imagemUrl: product.imagemUrl,
    );
  }

  double get subtotal => preco * quantidade;

  String get precoFormatado => formatCurrency(preco);

  String get subtotalFormatado => formatCurrency(subtotal);

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'nome': nome,
      'preco': preco,
      'quantidade': quantidade,
      'estoque': estoque,
      'categoria': categoria,
      'imagemUrl': imagemUrl,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId']?.toString() ?? '',
      nome: json['nome']?.toString() ?? '',
      preco: (json['preco'] as num?)?.toDouble() ?? 0.0,
      quantidade: (json['quantidade'] as num?)?.toInt() ?? 0,
      estoque: (json['estoque'] as num?)?.toInt() ?? 0,
      categoria: json['categoria']?.toString() ?? '',
      imagemUrl: json['imagemUrl']?.toString(),
    );
  }

  CartItem copyWith({
    String? productId,
    String? nome,
    double? preco,
    int? quantidade,
    int? estoque,
    String? categoria,
    String? imagemUrl,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      nome: nome ?? this.nome,
      preco: preco ?? this.preco,
      quantidade: quantidade ?? this.quantidade,
      estoque: estoque ?? this.estoque,
      categoria: categoria ?? this.categoria,
      imagemUrl: imagemUrl ?? this.imagemUrl,
    );
  }
}

class CartModel {
  final String userId;
  final List<CartItem> items;
  final DateTime updatedAt;

  CartModel({
    required this.userId,
    List<CartItem>? items,
    DateTime? updatedAt,
  })  : items = List.unmodifiable(items ?? const []),
        updatedAt = updatedAt ?? DateTime.now();

  factory CartModel.empty(String userId) => CartModel(userId: userId);

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  int get totalItens =>
      items.fold(0, (total, item) => total + item.quantidade);

  double get subtotal =>
      items.fold(0.0, (total, item) => total + item.subtotal);

  String get subtotalFormatado => formatCurrency(subtotal);

  CartItem? itemByProductId(String productId) {
    for (final item in items) {
      if (item.productId == productId) return item;
    }
    return null;
  }

  CartModel copyWith({
    String? userId,
    List<CartItem>? items,
    DateTime? updatedAt,
  }) {
    return CartModel(
      userId: userId ?? this.userId,
      items: items ?? this.items,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
            .whereType<Map>()
            .map((item) => CartItem.fromJson(Map<String, dynamic>.from(item)))
            .toList()
        : <CartItem>[];

    return CartModel(
      userId: json['userId']?.toString() ?? '',
      items: items,
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value).toLocal();
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }
}
