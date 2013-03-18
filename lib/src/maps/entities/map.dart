part of grits_shared;

class GritsMap {
  int height;
  int width;
  List<MapLayer> layers;
  MapOrientation orientation;
  Map<String, String> properties;
  int tileheight;
  int tilewidth;
  List<MapTileSet> tilesets;
  int version;
}

class MapOrientation {
  const String ORTHOGONAL = 'orthogonal';
}