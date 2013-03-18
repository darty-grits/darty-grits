part of grits_shared;

class MapLayer {
  List<int> data;
  int height;
  int width;
  String name;
  num opacity;
  String type;
  bool visible;
  int x;
  int y;
  List<MapObject> objects;
}

class MapLayerType {
  static const String OBJECT_GROUP = 'objectgroup';
  static const String TILE_LAYER = 'tilelayer';
}