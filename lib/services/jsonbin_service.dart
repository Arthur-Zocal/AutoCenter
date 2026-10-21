import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/adesivo_envelopamento_model.dart';

class JsonBinService {
  static const String _baseUrl = 'https://api.jsonbin.io/v3/b';
  static const String _binId = '6ad02873ac6210605a32616e';
  static const String _masterKey =
      '\$2a\$10\$qGjJzTXcxvG/xvDRQ.z4muLRUu1Ityf0BZ6.uvP.KogB7VaHVVGny';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'X-Master-Key': _masterKey,
  };

  String get _binUrl => '$_baseUrl/$_binId';
  String get _latestUrl => '$_baseUrl/$_binId/latest';

  Future<List<dynamic>> _fetchBinData() async {
    final response = await http.get(Uri.parse(_latestUrl), headers: _headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['record'] as List<dynamic>? ?? [];
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw _handleError(response);
    }
  }

  Future<void> _updateBinData(List<dynamic> data) async {
    final response = await http.put(
      Uri.parse(_binUrl),
      headers: _headers,
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw _handleError(response);
    }
  }

  Exception _handleError(http.Response response) {
    String message;
    switch (response.statusCode) {
      case 400:
        message = 'Requisição inválida';
        break;
      case 401:
        message = 'Não autorizado - verifique a Master Key';
        break;
      case 403:
        message = 'Acesso negado';
        break;
      case 404:
        message = 'Bin não encontrado';
        break;
      case 429:
        message = 'Limite de requisições excedido';
        break;
      case 500:
        message = 'Erro interno do servidor JSONBin';
        break;
      default:
        message = 'Erro HTTP: ${response.statusCode}';
    }
    try {
      final errorData = json.decode(response.body);
      if (errorData['message'] != null) {
        message = '${errorData['message']}';
      }
    } catch (_) {}
    return Exception(message);
  }

  AdesivoEnvelopamento _jsonToAdesivo(Map<String, dynamic> json) {
    return AdesivoEnvelopamento.fromJson(json);
  }

  Map<String, dynamic> _adesivoToJson(AdesivoEnvelopamento adesivo) {
    return adesivo.toJson();
  }

  Future<List<AdesivoEnvelopamento>> listarAdesivos() async {
    final data = await _fetchBinData();
    return data
        .whereType<Map<String, dynamic>>()
        .map(_jsonToAdesivo)
        .toList();
  }

  Future<AdesivoEnvelopamento?> consultarAdesivoPorId(String id) async {
    final data = await _fetchBinData();
    for (final item in data) {
      if (item is Map<String, dynamic> && item['id'] == id) {
        return _jsonToAdesivo(item);
      }
    }
    return null;
  }

  Future<void> cadastrarAdesivo(AdesivoEnvelopamento adesivo) async {
    final data = await _fetchBinData();

    final skuExists = data.any(
      (item) =>
          item is Map<String, dynamic> &&
          item['sku']?.toString().toUpperCase() == adesivo.sku.toUpperCase(),
    );

    if (skuExists) {
      throw Exception('SKU já cadastrado. Use um código único.');
    }

    final newAdesivo = _adesivoToJson(adesivo.copyWith(id: _generateId()));
    data.add(newAdesivo);
    await _updateBinData(data);
  }

  Future<void> atualizarAdesivo(AdesivoEnvelopamento adesivo) async {
    final data = await _fetchBinData();

    final skuExists = data.any(
      (item) =>
          item is Map<String, dynamic> &&
          item['id'] != adesivo.id &&
          item['sku']?.toString().toUpperCase() == adesivo.sku.toUpperCase(),
    );

    if (skuExists) {
      throw Exception('SKU já cadastrado para outro produto.');
    }

    final index = data.indexWhere(
      (item) => item is Map<String, dynamic> && item['id'] == adesivo.id,
    );

    if (index == -1) {
      throw Exception('Produto não encontrado no JSONBin.');
    }

    data[index] = _adesivoToJson(adesivo);
    await _updateBinData(data);
  }

  Future<void> excluirAdesivo(String id) async {
    final data = await _fetchBinData();

    final index = data.indexWhere(
      (item) => item is Map<String, dynamic> && item['id'] == id,
    );

    if (index == -1) {
      throw Exception('Produto não encontrado no JSONBin.');
    }

    data.removeAt(index);
    await _updateBinData(data);
  }

  Future<bool> checkSkuExistsAdesivo(String sku, {String? excludeId}) async {
    final data = await _fetchBinData();
    for (final item in data) {
      if (item is Map<String, dynamic>) {
        final itemSku = item['sku']?.toString().toUpperCase();
        final itemId = item['id']?.toString();
        if (itemSku == sku.toUpperCase() && itemId != excludeId) {
          return true;
        }
      }
    }
    return false;
  }

  String _generateId() {
    return 'env-${DateTime.now().millisecondsSinceEpoch}-${(Math.random() * 1000).floor()}';
  }
}

class Math {
  static double random() => DateTime.now().microsecond / 1000000.0;
}