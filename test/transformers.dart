import 'package:intl/intl.dart';
import 'package:transformer_binding/transformer_binding.dart';

/// A transformer that converts an integer to a nicely formatted string (which
/// contains thousands separators) and vice versa. Invalid inputs will be
/// converted to `null`.
class IntToStringTransformer extends Transformer<int, String> {
  final NumberFormat _formatter;

  /// See [NumberFormat.decimalPattern].
  IntToStringTransformer([String locale])
      : _formatter = new NumberFormat.decimalPattern(locale);

  @override
  String forward(int input) {
    return (input != null) ? _formatter.format(input) : '';
  }

  @override
  int reverse(String input) {
    try {
      return _formatter.parse(input).toInt();
    } catch (_) {
      return null;
    }
  }
}

/// A transformer that converts a currency to a nicely formatted string (which
/// contains thousands separators and a currency symbol) and vice versa.
/// Invalid inputs will be converted to `null`.
///
/// Examples:
///     1234.50 <-> USD1,234.50 (locale=en, symbol=USD)
///     1234.50 <->   $1,234.50 (locale=en, symbol=$)
class CurrencyToStringTransformer extends Transformer<num, String> {
  final NumberFormat _formatter;

  /// See [NumberFormat.currencyPattern].
  CurrencyToStringTransformer([String locale, String nameOrSymbol])
      : _formatter = new NumberFormat.currencyPattern(locale, nameOrSymbol);

  @override
  String forward(num input) {
    return (input != null) ? _formatter.format(input) : '';
  }

  @override
  num reverse(String input) {
    try {
      return _formatter.parse(input);
    } catch (_) {
      return null;
    }
  }
}
