String onlyDigits(String value) => value.replaceAll(RegExp(r'\D'), '');

String formatCurrency(double value) =>
    'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';

String formatDecimal(double value, {int decimals = 1}) =>
    value.toStringAsFixed(decimals).replaceAll('.', ',');

String formatCep(String cep) {
  final digits = onlyDigits(cep);
  if (digits.length == 8) {
    return '${digits.substring(0, 5)}-${digits.substring(5)}';
  }
  return cep;
}

String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

String formatDateTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '${formatDate(date)} às $hour:$minute';
}
