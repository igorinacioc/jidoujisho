/// Recursively converts PascalCase JSON keys to camelCase.
///
/// Jellyfin API returns PascalCase keys (Id, Name, RunTimeTicks),
/// but freezed-generated fromJson expects camelCase (id, name, runTimeTicks).
/// This transformer bridges the gap.
Map<String, dynamic> pascalToCamelCase(Map<String, dynamic> input) {
  return input.map((key, value) {
    final camelKey = _toCamelCase(key);
    final convertedValue = _convertValue(value);
    return MapEntry(camelKey, convertedValue);
  });
}

String _toCamelCase(String pascal) {
  if (pascal.isEmpty) return pascal;
  // Handle special abbreviations first
  if (pascal == 'Id') return 'id';
  if (pascal == 'Type') return 'type';
  return pascal[0].toLowerCase() + pascal.substring(1);
}

dynamic _convertValue(dynamic value) {
  if (value is Map<String, dynamic>) {
    return pascalToCamelCase(value);
  } else if (value is List) {
    return value.map((e) => _convertValue(e)).toList();
  }
  return value;
}
