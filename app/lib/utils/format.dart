import 'package:intl/intl.dart';

String money(double value, [String currency = 'TRY']) {
  final symbol = switch (currency) {
    'TRY' => '\u20BA',
    'USD' => '\$',
    'EUR' => '\u20AC',
    _ => '',
  };
  final f = NumberFormat('#,##0.00', 'tr_TR');
  return '$symbol${f.format(value)}';
}

String shortDate(DateTime d) => DateFormat('dd.MM.yyyy').format(d.toLocal());
String dateTimeLabel(DateTime d) => DateFormat('dd.MM.yyyy HH:mm').format(d.toLocal());
