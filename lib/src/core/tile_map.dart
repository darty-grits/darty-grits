part of grits_shared;

class TileMapViewRect {
  var x = 0;
  var y = 0;
  var w = 512;
  var h = 512;
}

class TileMapTiles {
  int numYTiles = 100;
  int numXTiles = 100;
  int tileSizeX = 64;
  int tileSizeY = 64;
  int pixelSizeX = 64;
  int pixelSizeY = 64;
}

class TileMap {
  Map curMapData = null;
  List<TileSet> tileSets = new List<tileSets>();
  var viewRect = new TileMapViewRect();
  var tmt = new TileMapTiles();

  void load(Map map) {
    curMapData = map;
    tmt.numXTiles = map['width'];
    tmt.numYTiles = map['height'];
    tmt.tileSizeX = map['tilewidth'];
    tmt.tileSizeY = map['tileheight'];

    for (var layer in currMapData.layers) {
      if (layer['type'] != "objectgroup") continue;

      if (layer.name == "collison") {
        for (var object in layer.objects) {
          var collidesWithArray = new List();
          var collisionTypeArray = new List();

          if (object.properties.length != 0) {
            if (object.properties['collisionFlags']) {
              var flagsArray = object.properties['collisionFlags'].split(',');
              for (var props in flagsArray) {
                if (props == 'projectileignore') {
                  collisionTypeArray.add('projectileignore');
                  collidesWithArray.add('player');
                }
              }
            }
          }

          if (collisionTypeArray.length == 0) {
            collisionTypeArray.add('mapobject');
          }

          if (collidesWithArray.length == 0) {
            collidesWithArray.add('all');
          }

          if (object.polygon == null) {
            var entityDef = new Entity();
            entityDef.id = object.name;
            entityDef.x = object.x + (object.width * 0.5);
            entityDef.y = object.y + (object.height * 0.5);
            entityDef.halfWidth = object.width * 0.5;
            entityDef.halfHeight = object.height * 0.5;
            entityDef.dampen = 0;
            entityDef.angle = 0;
            entityDef.type = 'static';
            entityDef.categories = collisionTypeArray;
            entityDef.collidesWith = collidesWithArray;
            entityDef.userData = {
                'id': object.name
            };

            gPhysicsEngine.addBody(entityDef);
          }
        }
      } else if (layer.name == "environment") {
        var counter = 0;
        for (var object in layer.objects) {
          if (object.type.toLowerCase() == 'teleporter') {
            var posArray = object.properties['destination'].split(','); //TODO: Fix the BS
            var destPos = new vec2(int.parse(posArray[0].replace(' ', '')) * tmt.tileSizeX);

            var ent = gGameEngine.spawnEntity("Teleporter", object.x, object.y, {
                'name': "${object.name}_${counter}"
            });

            var physicsDef = new Entity();
            physicsDef.id = object.name;
            physicsDef.x = object.x + (object.width * 0.5);
            physicsDef.y = object.y = (object.height * 0.5);
            physicsDef.halfWidth = object.width * 0.5;
            physicsDef.halfHeight = object.width * 0.5;
            physicsDef.dampen = 0;
            physicsDef.angel = 0;
            physicsDef.type = 'static';
            physicsDef.categories = ['mapobject'];
            physicsDef.userData = {
                'id': object.name, 'ent': ent
            };

            ent.onInit(physicsDef, destPos);
          } else if (object.type.toLowerCase() == 'spawnpoint') {
            var settings = {
                'name': object.name,
                'hsize': {
                    'x': object.width / 2,
                    'y': object.height / 2
                },
                'team': Int.parse(object.properties['team'])
            };
            var ent = gGameEngine.spawnEntity("SpawnPoint", object.x + object.width / 2, object.y + object.height / 2, settings);
          } else if (object.type.toLowerCase() == 'spawner') {
            var settings = {
                'name': "${object.name}_${counter}",
                'hsize': {
                    'x': object.width / 2,
                    'y': object.height / 2
                },
                'team': Int.parse(object.properties['team'])
            };
            var ent = gGameEngine.spawnEntity("Spawner", object.x + object.width / 2, object.y + object.height / 2, settings);

          } else {
            Logger.log("Tried to load an unknown object: " + lobj.type);
          }
          counter++;
        }
      }
    }
  }

  void getTilePacket(int tileIndex) {
    var pkt = {
        "img": null,
        "px": 0,
        "py": 0
    };
    var i = 0;
    for (i = tileSets.length - 1; i >= 0; i--) {
      if (tileSets[i].firstgid <= tileIndex) break;
    }

    pkt.img = this.tileSets[i].image;
    var localIdx = tileIndex - this.tileSets[i].firstgid;
    var lTileX = (localIdx % tileSets[i].numXTiles).floor();
    var lTileY = (localIdx / tileSets[i].numXTiles).floor();    //TODO: Bug it?
    pkt.px = (lTileX * tmt.tileSizeX);
    pkt.py = (lTileY * tmt.tileSizeY);

    return pkt;
  }

  // Web stuff that is overridden for the Web implemention.
  void draw() {
  }

  void preDrawCache() {
  }

}