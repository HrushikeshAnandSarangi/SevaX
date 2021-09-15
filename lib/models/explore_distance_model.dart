class ExploreDistanceModel {
  final int distance;
  final DistancType type;

  ExploreDistanceModel(
    this.distance,
    this.type,
  );
}

enum DistancType {
  mi,
  km,
}
