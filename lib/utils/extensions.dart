extension Capitalization on String {
  String firstWordUpperCase() =>
      this[0].toUpperCase() + this.substring(1).toLowerCase();

  String sentenceCase() {
    List<String> temp = this.split(' ');
    String result = '';
    temp.forEach((v) => result += v.firstWordUpperCase() + ' ');
    return result;
  }
}
