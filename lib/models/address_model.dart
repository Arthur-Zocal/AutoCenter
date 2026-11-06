import '../utils/formatters.dart';

class AddressModel {
  final String cep;
  final String logradouro;
  final String numero;
  final String complemento;
  final String bairro;
  final String cidade;
  final String estado;
  final double? latitude;
  final double? longitude;

  const AddressModel({
    required this.cep,
    required this.logradouro,
    required this.numero,
    required this.complemento,
    required this.bairro,
    required this.cidade,
    required this.estado,
    this.latitude,
    this.longitude,
  });

  bool get hasCoordinates => latitude != null && longitude != null;

  String get cepFormatado => formatCep(cep);

  String get linha1 {
    final partes = <String>[
      if (logradouro.trim().isNotEmpty) logradouro.trim(),
      if (numero.trim().isNotEmpty) numero.trim(),
    ];
    return partes.join(', ');
  }

  String get linha2 {
    final partes = <String>[
      if (bairro.trim().isNotEmpty) bairro.trim(),
      if (cidade.trim().isNotEmpty)
        '${cidade.trim()}${estado.trim().isNotEmpty ? '/${estado.trim()}' : ''}',
    ];
    return partes.join(' - ');
  }

  String get completo {
    final partes = <String>[
      if (linha1.isNotEmpty) linha1,
      if (complemento.trim().isNotEmpty) complemento.trim(),
      if (linha2.isNotEmpty) linha2,
      if (cepFormatado.isNotEmpty) 'CEP $cepFormatado',
    ];
    return partes.join(' • ');
  }

  Map<String, dynamic> toMap() {
    return {
      'cep': cep,
      'logradouro': logradouro,
      'numero': numero,
      'complemento': complemento,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      cep: map['cep']?.toString() ?? '',
      logradouro: map['logradouro']?.toString() ?? '',
      numero: map['numero']?.toString() ?? '',
      complemento: map['complemento']?.toString() ?? '',
      bairro: map['bairro']?.toString() ?? '',
      cidade: map['cidade']?.toString() ?? '',
      estado: map['estado']?.toString() ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }

  AddressModel copyWith({
    String? cep,
    String? logradouro,
    String? numero,
    String? complemento,
    String? bairro,
    String? cidade,
    String? estado,
    double? latitude,
    double? longitude,
  }) {
    return AddressModel(
      cep: cep ?? this.cep,
      logradouro: logradouro ?? this.logradouro,
      numero: numero ?? this.numero,
      complemento: complemento ?? this.complemento,
      bairro: bairro ?? this.bairro,
      cidade: cidade ?? this.cidade,
      estado: estado ?? this.estado,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
