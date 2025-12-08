
class FormatUtils {
  /// - 500 -> "500 kg"
  /// - 1500 -> "1.5 T"
  /// - 2340.5 -> "2.3 T"
  static String formatWeight(double valueInKg, {int decimals = 1}) {
    if (valueInKg >= 1000) {
      // Convert to tonnes (1 tonne = 1000 kg)
      final tonnes = valueInKg / 1000;
      return '${tonnes.toStringAsFixed(decimals)} T';
    } else {
      // Show as kg
      if (valueInKg == valueInKg.truncateToDouble()) {
        return '${valueInKg.toInt()} Kg';
      }
      return '${valueInKg.toStringAsFixed(decimals)} Kg';
    }
  }

  static ({String value, String unit}) formatWeightParts(double valueInKg, {int decimals = 1}) {
    if (valueInKg >= 1000) {
      final tonnes = valueInKg / 1000;
      return (value: tonnes.toStringAsFixed(decimals), unit: 'T');
    } else {
      if (valueInKg == valueInKg.truncateToDouble()) {
        return (value: valueInKg.toInt().toString(), unit: 'Kg');
      }
      return (value: valueInKg.toStringAsFixed(decimals), unit: 'Kg');
    }
  }
}
