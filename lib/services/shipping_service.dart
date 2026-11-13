import 'dart:math';

import '../models/address_model.dart';
import '../utils/formatters.dart';

class ShippingQuote {
  final double distanciaKm;
  final double valor;

  const ShippingQuote({required this.distanciaKm, required this.valor});

  bool get gratis => valor <= 0;

  String get valorFormatado => gratis ? 'Grátis' : formatCurrency(valor);

  String get distanciaFormatada => '${formatDecimal(distanciaKm)} km';
}

class ShippingService {
  /// CEP da sede: São João das Duas Pontes - SP.
  static const String originCep = '15640-049';

  static const double hqLatitude = -20.3880724;
  static const double hqLongitude = -50.3783617;

  static const double freeRadiusKm = 20.0;
  static const double stepKm = 10.0;
  static const double stepPrice = 2.0;
  static const double maxFreight = 80.0;

  static const double _earthRadiusKm = 6371.0;

  ShippingQuote? quoteForAddress(AddressModel address) {
    var latitude = address.latitude;
    var longitude = address.longitude;

    if (latitude == null || longitude == null) {
      final fallback = _cityCoordinates[_normalizeCity(address.cidade)];
      if (fallback == null) return null;
      latitude = fallback[0];
      longitude = fallback[1];
    }

    return quote(latitude: latitude, longitude: longitude);
  }

  ShippingQuote quote({
    required double latitude,
    required double longitude,
  }) {
    final distancia = _haversine(
      hqLatitude,
      hqLongitude,
      latitude,
      longitude,
    );

    var valor = 0.0;
    if (distancia > freeRadiusKm) {
      final passos = ((distancia - freeRadiusKm) / stepKm).ceil();
      valor = min(passos * stepPrice, maxFreight).toDouble();
    }

    return ShippingQuote(distanciaKm: distancia, valor: valor);
  }

  double _haversine(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return _earthRadiusKm * c;
  }

  double _toRadians(double degrees) => degrees * pi / 180.0;

  String _normalizeCity(String city) {
    var value = city.trim().toLowerCase();
    const accents = {
      'á': 'a',
      'à': 'a',
      'â': 'a',
      'ã': 'a',
      'ä': 'a',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'í': 'i',
      'ì': 'i',
      'î': 'i',
      'ï': 'i',
      'ó': 'o',
      'ò': 'o',
      'ô': 'o',
      'õ': 'o',
      'ö': 'o',
      'ú': 'u',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ç': 'c',
    };
    accents.forEach((from, to) {
      value = value.replaceAll(from, to);
    });
    return value;
  }

  // Coordenadas aproximadas usadas quando o CEP não retorna latitude/longitude.
  static const Map<String, List<double>> _cityCoordinates = {
    'sao joao das duas pontes': [-20.3880724, -50.3783617],
    'fernandopolis': [-20.2839, -50.2464],
    "estrela d'oeste": [-20.2878, -50.4008],
    "guarani d'oeste": [-20.0739, -50.3389],
    'ouroeste': [-20.0011, -50.3731],
    'indiapora': [-19.9797, -50.2894],
    'macedonia': [-20.1472, -50.1961],
    'pedranopolis': [-20.2478, -50.1144],
    'jales': [-20.2678, -50.5494],
    'votuporanga': [-20.4228, -49.9728],
    'sao jose do rio preto': [-20.8197, -49.3794],
    'lins': [-21.6789, -49.7422],
    'getulina': [-21.7986, -49.9286],
    'guaicara': [-21.6219, -49.9867],
    'promissao': [-21.5367, -49.8581],
    'sabino': [-21.4667, -49.5833],
    'cafelandia': [-21.8025, -49.6103],
    'guaimbe': [-21.9094, -49.8986],
    'pongai': [-21.7364, -49.3667],
    'reginopolis': [-21.8883, -49.2269],
    'bauru': [-22.3147, -49.0606],
    'marilia': [-22.2139, -49.9458],
    'aracatuba': [-21.2089, -50.4328],
    'sao paulo': [-23.5505, -46.6333],
  };
}
