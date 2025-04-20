import 'package:sevaexchange/constants/sevatitles.dart';

List<Map<String, String>> CurrencyNames = [
  {
    "code": "USD",
    "name": "American Dollar",
    "imagePath":
        "https://firebasestorage.googleapis.com/v0/b/sevax-dev-project-for-sevax.appspot.com/o/currency_flags%2Fus.png?alt=media&token=ea4e90bf-bfe2-440b-bed0-3b916b8e9c52"
  },
  {
    "code": "AUD",
    "name": "Australian Dollar",
    "imagePath":
        "https://firebasestorage.googleapis.com/v0/b/sevax-dev-project-for-sevax.appspot.com/o/currency_flags%2Fau.png?alt=media&token=c1710445-f14f-4f08-949f-be69c20c38a1"
  },
  {
    "code": "CAD",
    "name": "Canadian Dollar",
    "imagePath":
        "https://firebasestorage.googleapis.com/v0/b/sevax-dev-project-for-sevax.appspot.com/o/currency_flags%2Fca.png?alt=media&token=23f119c3-253a-4f81-931a-b00b95b6745d"
  },
  {
    "code": "CHF",
    "name": "Swiss Franc",
    "imagePath":
        "https://firebasestorage.googleapis.com/v0/b/sevax-dev-project-for-sevax.appspot.com/o/currency_flags%2Fch.png?alt=media&token=c558eecf-c778-44c4-a337-a3889244ed5d"
  },
  {
    "code": "CNY",
    "name": "Chinese Yuan",
    "imagePath":
        "https://firebasestorage.googleapis.com/v0/b/sevax-dev-project-for-sevax.appspot.com/o/currency_flags%2Fcn.png?alt=media&token=05924543-7249-4e8c-a01a-22a590cb291c"
  },
  {
    "code": "EUR",
    "name": "Euro",
    "imagePath":
        "https://firebasestorage.googleapis.com/v0/b/sevax-dev-project-for-sevax.appspot.com/o/currency_flags%2Feu.png?alt=media&token=505dd2a0-8568-4a31-943c-7e80c26ee61d"
  },
  {
    "code": "GBP",
    "name": "British Pound",
    "imagePath":
        "https://firebasestorage.googleapis.com/v0/b/sevax-dev-project-for-sevax.appspot.com/o/currency_flags%2Fuk.png?alt=media&token=b86b755c-4a0f-456f-b344-ef18aac9242d"
  },
  {
    "code": "HKD",
    "name": "Hong Kong Dollar",
    "imagePath":
        "https://firebasestorage.googleapis.com/v0/b/sevax-dev-project-for-sevax.appspot.com/o/currency_flags%2Fhk.png?alt=media&token=c7866cdd-a7c0-4416-812e-73aba14bb1b0"
  }
];

class CurrencyModel {
  CurrencyModel({
    this.code,
    this.imagePath,
    this.name,
  });

  String? code;
  String? imagePath;
  String? name;

  getCurrency() {
    List<CurrencyModel> currenyList = [];

    currencyItems.forEach((currency) {
      currenyList.add(CurrencyModel(
          name: currency['name'],
          code: currency['code'],
          imagePath: currency['imagePath']));
    });
    return currenyList;
  }
}
