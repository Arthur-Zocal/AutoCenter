import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../utils/formatters.dart';
import 'address_model.dart';
import 'cart_model.dart';

enum PaymentMethod {
  pix('Pix', Icons.pix),
  credito('Cartão de Crédito', Icons.credit_card),
  debito('Cartão de Débito', Icons.account_balance);

  final String label;
  final IconData icon;

  const PaymentMethod(this.label, this.icon);

  String get subtitle {
    switch (this) {
      case PaymentMethod.pix:
        return 'Aprovação imediata • simulado';
      case PaymentMethod.credito:
        return 'Pagamento simulado';
      case PaymentMethod.debito:
        return 'Débito à vista • simulado';
    }
  }

  static PaymentMethod fromName(String? name) {
    return PaymentMethod.values.firstWhere(
      (method) => method.name == name,
      orElse: () => PaymentMethod.pix,
    );
  }
}

class OrderItem {
  final String productId;
  final String nome;
  final String categoria;
  final double preco;
  final int quantidade;
  final String? imagemUrl;

  const OrderItem({
    required this.productId,
    required this.nome,
    required this.categoria,
    required this.preco,
    required this.quantidade,
    this.imagemUrl,
  });

  double get subtotal => preco * quantidade;

  String get subtotalFormatado => formatCurrency(subtotal);

  factory OrderItem.fromCartItem(CartItem item) {
    return OrderItem(
      productId: item.productId,
      nome: item.nome,
      categoria: item.categoria,
      preco: item.preco,
      quantidade: item.quantidade,
      imagemUrl: item.imagemUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'nome': nome,
      'categoria': categoria,
      'preco': preco,
      'quantidade': quantidade,
      'imagemUrl': imagemUrl,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId']?.toString() ?? '',
      nome: map['nome']?.toString() ?? '',
      categoria: map['categoria']?.toString() ?? '',
      preco: (map['preco'] as num?)?.toDouble() ?? 0.0,
      quantidade: (map['quantidade'] as num?)?.toInt() ?? 0,
      imagemUrl: map['imagemUrl']?.toString(),
    );
  }
}

class OrderModel {
  final String id;
  final String codigo;
  final String userId;
  final String clienteNome;
  final String clienteEmail;
  final String clienteTelefone;
  final List<OrderItem> itens;
  final AddressModel endereco;
  final PaymentMethod pagamentoMetodo;
  final String pagamentoResumo;
  final double subtotal;
  final double frete;
  final double distanciaKm;
  final double total;
  final String status;
  final DateTime createdAt;

  const OrderModel({
    this.id = '',
    required this.codigo,
    required this.userId,
    required this.clienteNome,
    required this.clienteEmail,
    required this.clienteTelefone,
    required this.itens,
    required this.endereco,
    required this.pagamentoMetodo,
    required this.pagamentoResumo,
    required this.subtotal,
    required this.frete,
    required this.distanciaKm,
    required this.total,
    this.status = 'confirmado',
    required this.createdAt,
  });

  static String generateCode() {
    final base = DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase();
    final suffix = base.length > 6 ? base.substring(base.length - 6) : base;
    return 'AZ-$suffix';
  }

  int get totalItens => itens.fold(0, (total, item) => total + item.quantidade);

  String get totalFormatado => formatCurrency(total);

  String get subtotalFormatado => formatCurrency(subtotal);

  String get freteFormatado => frete == 0 ? 'Grátis' : formatCurrency(frete);

  String get dataFormatada => formatDateTime(createdAt);

  Map<String, dynamic> toMap() {
    return {
      'codigo': codigo,
      'userId': userId,
      'cliente': {
        'nome': clienteNome,
        'email': clienteEmail,
        'telefone': clienteTelefone,
      },
      'itens': itens.map((item) => item.toMap()).toList(),
      'endereco': endereco.toMap(),
      'pagamento': {
        'metodo': pagamentoMetodo.name,
        'resumo': pagamentoResumo,
      },
      'subtotal': subtotal,
      'frete': frete,
      'distanciaKm': distanciaKm,
      'total': total,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory OrderModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    return OrderModel.fromMap(snapshot.data() ?? {}, snapshot.id);
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    final clienteRaw = map['cliente'];
    final cliente = clienteRaw is Map
        ? Map<String, dynamic>.from(clienteRaw)
        : <String, dynamic>{};

    final pagamentoRaw = map['pagamento'];
    final pagamento = pagamentoRaw is Map
        ? Map<String, dynamic>.from(pagamentoRaw)
        : <String, dynamic>{};

    final enderecoRaw = map['endereco'];
    final endereco = enderecoRaw is Map
        ? AddressModel.fromMap(Map<String, dynamic>.from(enderecoRaw))
        : const AddressModel(
            cep: '',
            logradouro: '',
            numero: '',
            complemento: '',
            bairro: '',
            cidade: '',
            estado: '',
          );

    final itensRaw = map['itens'];

    return OrderModel(
      id: id,
      codigo: map['codigo']?.toString() ?? id,
      userId: map['userId']?.toString() ?? '',
      clienteNome: cliente['nome']?.toString() ?? '',
      clienteEmail: cliente['email']?.toString() ?? '',
      clienteTelefone: cliente['telefone']?.toString() ?? '',
      itens: itensRaw is List
          ? itensRaw
              .whereType<Map>()
              .map((item) => OrderItem.fromMap(Map<String, dynamic>.from(item)))
              .toList()
          : <OrderItem>[],
      endereco: endereco,
      pagamentoMetodo: PaymentMethod.fromName(pagamento['metodo']?.toString()),
      pagamentoResumo: pagamento['resumo']?.toString() ?? '',
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      frete: (map['frete'] as num?)?.toDouble() ?? 0.0,
      distanciaKm: (map['distanciaKm'] as num?)?.toDouble() ?? 0.0,
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      status: map['status']?.toString() ?? 'confirmado',
      createdAt: _parseDateTime(map['createdAt']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
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
