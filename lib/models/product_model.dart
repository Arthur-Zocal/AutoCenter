import 'package:cloud_firestore/cloud_firestore.dart';

enum ProductCategory {
  mecanicaGeral('Mecânica Geral', Icons.build),
  esteticaAutomotiva('Estética Automotiva', Icons.clean_hands),
  suspensaoFreios('Suspensão e Freios', Icons.directions_car),
  faroisLampadas('Faróis e Lâmpadas', Icons.light_mode),
  lubrificantes('Lubrificantes', Icons.local_gas_station),
  baterias('Baterias', Icons.battery_charging_full);

  final String label;
  final IconData icon;

  const ProductCategory(this.label, this.icon);

  static ProductCategory fromString(String value) {
    return ProductCategory.values.firstWhere(
      (e) => e.label == value,
      orElse: () => ProductCategory.mecanicaGeral,
    );
  }
}

class Product {
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

  Product({
    this.id = '',
    required this.nome,
    required this.preco,
    required this.descricao,
    required this.categoria,
    required this.estoque,
    required this.marca,
    required this.sku,
    this.ativo = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'preco': preco,
      'descricao': descricao,
      'categoria': categoria,
      'estoque': estoque,
      'marca': marca,
      'sku': sku.toUpperCase(),
      'ativo': ativo,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'nome': nome,
      'preco': preco,
      'descricao': descricao,
      'categoria': categoria,
      'estoque': estoque,
      'marca': marca,
      'sku': sku.toUpperCase(),
      'ativo': ativo,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map, String documentId) {
    return Product(
      id: documentId,
      nome: map['nome'] ?? '',
      preco: (map['preco'] as num?)?.toDouble() ?? 0.0,
      descricao: map['descricao'] ?? '',
      categoria: map['categoria'] ?? ProductCategory.mecanicaGeral.label,
      estoque: map['estoque'] ?? 0,
      marca: map['marca'] ?? '',
      sku: map['sku'] ?? '',
      ativo: map['ativo'] ?? true,
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  factory Product.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return Product.fromMap(data, snapshot.id);
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  Product copyWith({
    String? id,
    String? nome,
    double? preco,
    String? descricao,
    String? categoria,
    int? estoque,
    String? marca,
    String? sku,
    bool? ativo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      preco: preco ?? this.preco,
      descricao: descricao ?? this.descricao,
      categoria: categoria ?? this.categoria,
      estoque: estoque ?? this.estoque,
      marca: marca ?? this.marca,
      sku: sku ?? this.sku,
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  ProductCategory get categoryEnum => ProductCategory.fromString(categoria);

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
}