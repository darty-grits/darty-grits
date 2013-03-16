part of girts_shared;

class GameEngine {

  String clearColor = '#000000';

  int gravity = 0;
  vec2 screen = new vec2(0 ,0);

  List entities = [];
  Map namedEntities = {};
  Map backgroundAnims = {};

  int spawnCounter = 0;

  int cellSize = 64;
  int timeSinceGameUpdate = 0;
  int timeSincePhysicsUpdate = 0;
  var clock = null;

  List _deferredKill = [];
  List _deferredRespawn = [];

  List dataTypes = [];
  int localUserID = -1;
  var gMap = null;
  var gPlayer0 = null;
  Map gPlayers = {};
  int fps = 0;
  int currentTick = 0;
  int lastFpsSec = 0;

  GameEngine() {
    // TODO: add the real timer class
    //clock = new TimerClass();
  }

  void setup() {
    //create physics
    gPhysicsEngine.create(Constants.PHYSICS_UPDATES_PER_SEC, false);

    // TODO: add gPhysicsEngine.addContactListener({
    // TODO: add tile map loader
  }

  void notifyPlayers(msg) {
    if (!IS_SERVER) {
      return;
    }

    Server.broadcaster.q_statusMsg({"msg":msg});
  }

  void onCollisionTouch(bodyA, bodyB, impulse) {

    if (impulse < 0.1) return;
    var uA = bodyA != null ? bodyA.GetUserData() : null;
    var uB = bodyB != null ? bodyB.GetUserData() : null;
    //CLM commented out due to perf spew
    //Logger.log('Touch' + uA + ' ' + uB + ' ' + uA.ent + ' ' + uB.ent);

    if (uA != null) {
      if (uA.ent != null && uA.ent.onTouch) {
        uA.ent.onTouch(bodyB, null, impulse);
      }
    }

    if (uB != null) {
      if (uB.ent != null && uB.ent.onTouch) {
        uB.ent.onTouch(bodyA, null, impulse);
      }
    }
  }

  // return time in seconds
  getTime() => currentTick * 0.05;


  getEntityByName(name) => namedEntities[name];

  getEntityById(id) {
    for (var i = 0; i < this.entities.length; i++) {
      var ent = this.entities[i];
      if (ent.id == id) {
        return ent;
      }
    }
    return null;
  }

  List getEntitiesByLocation(pos) {
    var a = [];
    for (var i = 0; i < this.entities.length; i++) {
      var ent = this.entities[i];
      if (ent.pos.x <= pos.x && ent.pos.y <= pos.y && (ent.pos.x + ent.size.x) > pos.x && (ent.pos.y + ent.size.y) > pos.y) {
        a.add(ent);
      }
    }
    return a;
  }

  List getEntitiesWithinCircle(center, radius) {

    var a = [];
    for (var i = 0; i < this.entities.length; i++) {
      var ent = this.entities[i];
      var dist = Math.sqrt((ent.pos.x - center.x)*(ent.pos.x - center.x) + (ent.pos.y - center.y)*(ent.pos.y - center.y));
      if (dist <= radius) {
        a.add(ent);
      }
    }
    return a;
  }

  List getEntitiesByType(typeName) {
//
//    var entityClass = Factory.nameClassMap[typeName];
//    var a = [];
//    for (var i = 0; i < this.entities.length; i++) {
//      var ent = this.entities[i];
//      if (ent instanceof entityClass && !ent._killed) {
//        a.add(ent);
//      }
//    }
//    return a;
  }

  nextSpawnId() {

  }

  var onSpawned;
  var onUnspawned;

  spawnEntity(typename, x, y, settings) {

  }

  respawnEntity(respkt) {

  }

  removeEntity(ent) {

  }

  run() {

  }

  update() {

  }

  updatePhysics() {

  }

  dealDmg(fromObj, toPlayer, amt) {

  }

  on_collision(msg) {

  }

  spawnPlayer(id, teamID, spname, typename, userID, displayName) {

  }

  unspawnPlayer(id) {

  }
}