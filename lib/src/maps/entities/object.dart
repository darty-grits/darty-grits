part of grits_shared;

class MapObject {
  int width;
  int height;
  String name;
  Map<String, String> properties;
  String type;
  num x;
  num y;
  PolygonShape polygon;
}

class MapObjectType {
  static const String SPAWNER = 'Spawner';
  static const String SPAWN_POINT = 'SpawnPoint';
  static const String TELEPORTER = 'teleporter';
}