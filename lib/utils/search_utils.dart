/// Utilidades para búsqueda y filtrado de texto
class SearchUtils {
  /// Filtra por palabras individuales (case-insensitive)
  ///
  /// Busca coincidencias con cualquier palabra de la consulta.
  /// Ejemplo: "press banca" encuentra "Press de banca"
  static bool matchesQuery(String text, String query) {
    if (query.isEmpty) return true;

    final lowerText = text.toLowerCase();
    final queryWords = query
        .toLowerCase()
        .trim()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .toList();

    return queryWords.any((word) => lowerText.contains(word));
  }

  /// Filtra múltiples campos por palabras individuales
  ///
  /// Busca coincidencias en cualquiera de los campos proporcionados
  static bool matchesQueryMultipleFields(List<String> fields, String query) {
    if (query.isEmpty) return true;

    final lowerFields = fields.map((f) => f.toLowerCase()).toList();
    final queryWords = query
        .toLowerCase()
        .trim()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .toList();

    return queryWords.any(
      (word) => lowerFields.any((field) => field.contains(word)),
    );
  }
}
