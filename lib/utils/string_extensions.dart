extension StringExtensions on String {
  String firstLetterUpperCase() {
    if (this != null)
      return this[0].toUpperCase() + this.substring(1).toLowerCase();
    else
      return null;
  }
}
