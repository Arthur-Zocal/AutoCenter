import '../models/order_model.dart';
import '../utils/formatters.dart';

class PaymentResult {
  final bool approved;
  final String message;
  final String resumo;

  const PaymentResult({
    required this.approved,
    required this.message,
    required this.resumo,
  });
}

class PaymentService {
  Future<PaymentResult> process({
    required PaymentMethod metodo,
    required double valor,
    String? numeroCartao,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    if (metodo == PaymentMethod.pix) {
      return const PaymentResult(
        approved: true,
        message: 'Pagamento Pix confirmado (simulado).',
        resumo: 'Pix (simulado)',
      );
    }

    final digits = onlyDigits(numeroCartao ?? '');
    final bandeira = cardBrand(digits);
    final final4 = digits.length >= 4
        ? digits.substring(digits.length - 4)
        : '****';

    final tipo = metodo == PaymentMethod.credito ? 'Crédito' : 'Débito';
    final resumo = bandeira.isEmpty
        ? '$tipo •••• $final4'
        : '$tipo $bandeira •••• $final4';

    return PaymentResult(
      approved: true,
      message: 'Pagamento aprovado (simulado).',
      resumo: resumo,
    );
  }

  static String cardBrand(String digits) {
    if (digits.isEmpty) return '';

    if (digits.startsWith('4')) return 'Visa';
    if (RegExp(r'^(5[1-5]|2[2-7])').hasMatch(digits)) return 'Mastercard';
    if (RegExp(r'^(4011|4312|4389|5067|6277|6362|6363)').hasMatch(digits)) {
      return 'Elo';
    }
    if (RegExp(r'^(34|37)').hasMatch(digits)) return 'Amex';
    return 'Cartão';
  }

  static String pixCode(String referencia) {
    return '00020126580014BR.GOV.BCB.PIX0136az-auto-center-$referencia'
        '5204000053039865802BR5913AZ AUTO CENTER6009SAO PAULO62070503***6304ABCD';
  }
}
