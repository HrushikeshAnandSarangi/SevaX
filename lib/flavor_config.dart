import 'package:meta/meta.dart';

enum Flavor {
  APP,
  HUMANITY_FIRST,
  TULSI,
}

class FlavorValues {
  final String name;

  FlavorValues({
    @required this.name,
  });
}

class FlavorConfig {
  final Flavor flavor;
  final FlavorValues values;
  static FlavorConfig _instance;

  factory FlavorConfig({
    @required Flavor flavor,
    @required FlavorValues values,
  }) {
    FlavorConfig._instance ??= FlavorConfig._internal(
      flavor: flavor,
      values: values,
    );
    return _instance;
  }

  FlavorConfig._internal({
    @required this.flavor,
    @required this.values,
  });
}
