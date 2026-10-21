import 'package:flutter/material.dart';

class AdesivoEnvelopamento {
  final String id;
  final String nome;
  final double preco;
  final String descricao;
  final String categoria;
  final int estoque;
  final String marca;
  final String sku;
  final bool ativo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? imagemUrl;

  AdesivoEnvelopamento({
    this.id = '',
    required this.nome,
    required this.preco,
    required this.descricao,
    required this.categoria,
    required this.estoque,
    required this.marca,
    required this.sku,
    this.ativo = true,
    this.imagemUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  static const String categoriaLabel = 'Adesivo/Envelopamento';
  static const IconData categoriaIcon = Icons.layers;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'preco': preco,
      'descricao': descricao,
      'categoria': categoria,
      'estoque': estoque,
      'marca': marca,
      'sku': sku.toUpperCase(),
      'ativo': ativo,
      'imagemUrl': imagemUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  factory AdesivoEnvelopamento.fromJson(Map<String, dynamic> json) {
    return AdesivoEnvelopamento(
      id: json['id']?.toString() ?? '',
      nome: json['nome'] ?? '',
      preco: (json['preco'] as num?)?.toDouble() ?? 0.0,
      descricao: json['descricao'] ?? '',
      categoria: json['categoria'] ?? categoriaLabel,
      estoque: json['estoque'] ?? 0,
      marca: json['marca'] ?? '',
      sku: json['sku'] ?? '',
      ativo: json['ativo'] ?? true,
      imagemUrl: json['imagemUrl'],
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  AdesivoEnvelopamento copyWith({
    String? id,
    String? nome,
    double? preco,
    String? descricao,
    String? categoria,
    int? estoque,
    String? marca,
    String? sku,
    bool? ativo,
    String? imagemUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdesivoEnvelopamento(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      preco: preco ?? this.preco,
      descricao: descricao ?? this.descricao,
      categoria: categoria ?? this.categoria,
      estoque: estoque ?? this.estoque,
      marca: marca ?? this.marca,
      sku: sku ?? this.sku,
      ativo: ativo ?? this.ativo,
      imagemUrl: imagemUrl ?? this.imagemUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedPrice {
    return 'R\$ ${preco.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String get stockStatus {
    if (estoque == 0) return 'Sem estoque';
    if (estoque <= 5) return 'Estoque baixo ($estoque)';
    return 'Em estoque ($estoque)';
  }

  Color get stockColor {
    if (estoque == 0) return Colors.red;
    if (estoque <= 5) return Colors.orange;
    return Colors.green;
  }

  String get formattedCreatedAt {
    return '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';
  }

  String get formattedUpdatedAt {
    return '${updatedAt.day.toString().padLeft(2, '0')}/${updatedAt.month.toString().padLeft(2, '0')}/${updatedAt.year}';
  }
}