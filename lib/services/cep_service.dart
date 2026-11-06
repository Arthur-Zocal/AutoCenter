import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/address_model.dart';
import '../utils/formatters.dart';

class CepService {
  static const Duration _timeout = Duration(seconds: 10);

  Future<AddressModel> lookup(String cep) async {
    final digits = onlyDigits(cep);
    if (digits.length != 8) {
      throw Exception('CEP inválido. Informe os 8 dígitos.');
    }

    final awesome = await _tryAwesomeApi(digits);
    if (awesome != null) return awesome;

    final brasil = await _tryBrasilApi(digits);
    if (brasil != null) return brasil;

    final viaCep = await _tryViaCep(digits);
    if (viaCep != null) return viaCep;

    throw Exception('CEP não encontrado. Confira o número e tente novamente.');
  }

  Future<AddressModel?> _tryAwesomeApi(String cep) async {
    try {
      final response = await http.get(
        Uri.parse('https://cep.awesomeapi.com.br/json/$cep'),
        headers: const {'Accept': 'application/json'},
      ).timeout(_timeout);

      if (response.statusCode != 200) return null;

      final data = json.decode(response.body);
      if (data is! Map) return null;
      if (data['error'] != null || data['cep'] == null) return null;

      return AddressModel(
        cep: formatCep(cep),
        logradouro: data['address']?.toString() ?? '',
        numero: '',
        complemento: '',
        bairro: data['district']?.toString() ?? '',
        cidade: data['city']?.toString() ?? '',
        estado: data['state']?.toString() ?? '',
        latitude: _parseDouble(data['lat']),
        longitude: _parseDouble(data['lng']),
      );
    } catch (_) {
      return null;
    }
  }

  Future<AddressModel?> _tryBrasilApi(String cep) async {
    try {
      final response = await http.get(
        Uri.parse('https://brasilapi.com.br/api/cep/v2/$cep'),
        headers: const {'Accept': 'application/json'},
      ).timeout(_timeout);

      if (response.statusCode != 200) return null;

      final data = json.decode(response.body);
      if (data is! Map) return null;
      if (data['city'] == null) return null;

      final location = data['location'];
      final coordinates = location is Map ? location['coordinates'] : null;
      final coordinatesMap = coordinates is Map ? coordinates : null;

      return AddressModel(
        cep: formatCep(cep),
        logradouro: data['street']?.toString() ?? '',
        numero: '',
        complemento: '',
        bairro: data['neighborhood']?.toString() ?? '',
        cidade: data['city']?.toString() ?? '',
        estado: data['state']?.toString() ?? '',
        latitude: _parseDouble(coordinatesMap?['latitude']),
        longitude: _parseDouble(coordinatesMap?['longitude']),
      );
    } catch (_) {
      return null;
    }
  }

  Future<AddressModel?> _tryViaCep(String cep) async {
    try {
      final response = await http.get(
        Uri.parse('https://viacep.com.br/ws/$cep/json/'),
        headers: const {'Accept': 'application/json'},
      ).timeout(_timeout);

      if (response.statusCode != 200) return null;

      final data = json.decode(response.body);
      if (data is! Map) return null;
      if (data['erro'] == true || data['erro'] == 'true') return null;
      if (data['localidade'] == null) return null;

      return AddressModel(
        cep: formatCep(cep),
        logradouro: data['logradouro']?.toString() ?? '',
        numero: '',
        complemento: '',
        bairro: data['bairro']?.toString() ?? '',
        cidade: data['localidade']?.toString() ?? '',
        estado: data['uf']?.toString() ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
