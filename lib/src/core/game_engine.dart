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
  double timeSinceGameUpdate = 0.0;
  double timeSincePhysicsUpdate = 0.0;
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
  double lastFpsSec = 0.0;

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

    //var entityClass = Factory.nameClassMap[typeName];
    var a = [];
    for (var i = 0; i < this.entities.length; i++) {
      var ent = this.entities[i];
      if (ent.runtimeType.name == typeName && !ent._killed) {
        a.add(ent);
      }
    }
    return a;
  }

  nextSpawnId() => this.spawnCounter++;

  var onSpawned;
  var onUnspawned;

  spawnEntity(typename, x, y, settings) {

    var entityClass = Factory.nameClassMap[typename];

    var es = settings == null ? new Settings() : settings;
    es.type = typename;

    var ent = new(entityClass)(x, y, es);
    var msg = "SPAWNING $typename WITH ID ${ent.id}";

    if (ent.name) {
      msg = "$msg WITH NAME ${ent.name}";
    }

    if (es.displayName) {
      msg = "$msg WITH displayName ${es.displayName}";
    }

    if (es.userID) {
      msg = "$msg WITH userID ${es.userID}";
    }

    if (es.displayName) {
      //Logger.log(msg);
      // TODO: replace with real logging
      print(msg);
    }

    gGameEngine.entities.push(ent);

    if (ent.name) {
      gGameEngine.namedEntities[ent.name] = ent;
    }

    gGameEngine.onSpawned(ent);

    if (ent.type == "Player") {
      this.gPlayers[ent.name] = ent;
    }
    return ent;
  }

  respawnEntity(respkt) {

    if(IS_SERVER) {
      var player = this.namedEntities[respkt.from];
      if(!player)
      {
        //Logger.log("player.id = " + respkt.from  + " Not found for respawn");
        print("player.id = ${respkt.from} Not found for respawn");
        return;
      }

      this._deferredRespawn.add(respkt);

    }
  }

  removeEntity(ent) {
    if (!ent) return;

    this.onUnspawned(ent);

    // Remove this entity from the named entities
    if (ent.name) {
      this.namedEntities.remove(ent.name);
      this.gPlayers.remove(ent.name);
    }

    // We can not remove the entity from the entities[] array in the midst
    // of an update cycle, so remember all killed entities and remove
    // them later.
    // Also make sure this entity doesn't collide anymore and won't get
    // updated or checked
    ent._killed = true;

    this._deferredKill.add(ent);
  }

  run() {
    this.fps++;
    GlobalTimer.step();

    var timeElapsed = this.clock.tick();
    this.timeSinceGameUpdate += timeElapsed;
    this.timeSincePhysicsUpdate += timeElapsed;

    while (this.timeSinceGameUpdate >= Constants.GAME_LOOP_HZ &&
      this.timeSincePhysicsUpdate >= Constants.PHYSICS_LOOP_HZ) {
      // JJG: We should to do a physics update immediately after a game update to avoid
      //      the case where we draw after a game update has run but before a physics update
      this.update();
      this.updatePhysics();
      this.timeSinceGameUpdate -= Constants.GAME_LOOP_HZ;
      this.timeSincePhysicsUpdate -= Constants.PHYSICS_LOOP_HZ;
    }

    while (this.timeSincePhysicsUpdate >= Constants.PHYSICS_LOOP_HZ) {
      // JJG: Do extra physics updates
      this.updatePhysics();
      this.timeSincePhysicsUpdate -= Constants.PHYSICS_LOOP_HZ;
    }

    if(this.lastFpsSec < this.currentTick/Constants.GAME_UPDATES_PER_SEC && this.currentTick % Constants.GAME_UPDATES_PER_SEC == 0) {
      this.lastFpsSec = this.currentTick / Constants.GAME_UPDATES_PER_SEC;
      this.fps = 0;
    }
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