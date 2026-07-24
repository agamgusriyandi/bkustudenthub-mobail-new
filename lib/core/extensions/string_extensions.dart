extension StringCasingExtension on String {
  /// Converts a string to Title Case (e.g., "hello_world" -> "Hello World").
  String toTitleCase() {
    if (trim().isEmpty) return this;
    return split(RegExp(r'[_\s]+'))
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  /// Returns the same string but with only the first character capitalized.
  /// Useful for status labels like "menunggu" -> "Menunggu".
  String capitalizeFirstLetter() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
