part of grits_shared;

class Spawner extends Entity {
  double timeUntilSpawn = 0.0;
  var lastSpawned = null;
  var spawnItem = null;
  double nextSpawnTime = 0.0;

  Spawner(this.spawnItem);
  
  kill() {}
  
  update() {
    if(!IS_SERVER)  return;
    
    if (lastSpawned == null) {
      if (nextSpawnTime > gGameEngine.getTime()) {
        return;
      }
      
      // Create entity on spawner
      var startPoint = new vec2(pos.x, pos.y);
      var ent_name = "${name}_${spawnItem}";
      if (gGameEngine.getEntityByName(ent_name) != null) {
        return;
      }
      
      var ent = gGameEngine.spawnEntity(spawnItem, pos.x, pos.y, {"name": "!${ent_name}"});
      lastSpawned = ent;
    } else {
      if (lastSpawned._killed == true) {
        nextSpawnTime = gGameEngine.getTime() + 20.0;
        lastSpawned = null;
      }
    }
  }
}