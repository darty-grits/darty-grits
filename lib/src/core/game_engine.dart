part of grits_shared;

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
    clock = new TimerClass();
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

  _getConstructedClass(typename, x, y, settings) {
    // TODO: find a better way to handle this. Maybe using factory that implements Entity
    switch (typename) {
      case "Spawner": return new Spawner(x, y, settings);
      case "SpawnerPort": return new SpawnerPort(x, y, settings);
      case "Teleporter": return new Teleporter(x, y, settings);
      case "EnergyCanister": return new EnergyCanister(x, y, settings);
      case "HealthCanister": return new HealthCanister(x, y, settings);
      case "QuadDamage": return new QuadDamage(x, y, settings);
      case "BounceBallGun": return new BounceBallGun(x, y, settings);
      case "ChainGun": return new ChainGun(x, y, settings);
      case "Landmine": return new Landmine(x, y, settings);
      case "MachineGun": return new MachineGun(x, y, settings);
      case "RocketLauncher": return new RocketLauncher(x, y, settings);
      case "Shield": return new Shield(x, y, settings);
      case "ShotGun": return new ShotGun(x, y, settings);
      case "Sword": return new Sword(x, y, settings);
      case "Thrusters": return new Thrusters(x, y, settings);
      case "BounceBallBulletInstance": return new BounceBallBulletInstance(x, y, settings);
      case "LandmineDiskInstance": return new LandmineDiskInstance(x, y, settings);
      case "ShieldInstance": return new ShieldInstance(x, y, settings);
      case "SimpleProjectileInstance": return new SimpleProjectileInstance(x, y, settings);
      case "SwordInstance": return new SwordInstance(x, y, settings);
    }
  }

  spawnEntity(typename, x, y, settings) {

    //var entityClass = Factory.nameClassMap[typename];

    var es = settings == null ? new Settings() : settings;
    es.type = typename;

    //var ent = new(entityClass)(x, y, es);
    var ent = _getConstructedClass(typename, x, y, es);

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

  void update() {
    this.currentTick++;

    // entities
    for (var i = 0; i < this.entities.length; i++) {
      var ent = this.entities[i];
      if (!ent._killed) {
        ent.update();
      }
    }

    // remove all killed entities
    for (var i = 0; i < this._deferredKill.length; i++) {
      this.entities.remove(this._deferredKill[i]);
    }
    this._deferredKill = [];

    for (var p in this.gPlayers.keys) {
      this.gPlayers[p].applyInputs();
    }

    //respawn entities
    for (var i = 0; i < this._deferredRespawn.length; i++) {

      var pkt = this._deferredRespawn[i];
      var p = this.namedEntities[pkt.from];
      var spawnPoint = "Team${p.team}Spawn0";
      var ent = this.getEntityByName(spawnPoint);

      if(!ent) {
        print("Did not find spawn point");
        return;
      }

      p.resetStats();
      p.centerAt(ent.pos);
      var wep_pktt = { 'from': p.name,
                       'wep0': pkt.wep0,
                       'wep1': pkt.wep1,
                       'wep2': pkt.wep2
      };

      p.on_setWeapons(wep_pktt);
      p.toAll.q_setWeapons(wep_pktt);
      p.toAll.q_setPosition(ent.pos);


      print("Respawned entity ${p.name} at location ${p.pos.x}, ${p.pos.y}");
    }
    this._deferredRespawn.length=0;
  }

  void updatePhysics() {
    gPhysicsEngine.update();

    for (var p in this.gPlayers.keys) {
      var plyr = this.gPlayers[p];
      var pPos = plyr.physBody.GetPosition();
      plyr.pos.x = pPos.x;
      plyr.pos.y = pPos.y;
    }
  }

  dealDmg(fromObj, toPlayer, amt) {
    if(!IS_SERVER)return;

    var objOwner = fromObj.owningPlayer;
    if (toPlayer == null || toPlayer._killed) return false;

    if(toPlayer.takeDamage) {
      toPlayer.takeDamage(amt);
    }

    if(toPlayer.health <=0) {
      this.notifyPlayers("${toPlayer.displayName} was killed by ${objOwner.displayName}");
      objOwner.numKills++;
    }
  }

  on_collision(msg) {
    var ent0 = this.getEntityByName(msg.ent0);
    var ent1 = this.getEntityByName(msg.ent1);

    if(ent0 == null) ent0 = this.getEntityById(msg.ent0);
    if(ent1 == null) ent1 = this.getEntityById(msg.ent1);

    var body0 = null;
    var body1 = null;

    if(ent0 != null)
      body0 = ent0.physBody;
    if(ent1 != null)
      body1 = ent1.physBody;


    this.onCollisionTouch(body0,body1,msg.impulse);
  }

  spawnPlayer(id, teamID, spname, typename, userID, displayName) {

    print("spawn $id at $spname");
    var ent = this.getEntityByName(spname);
    if(ent == null)
    {
      print("could not find ent $spname");
      return -1;
    }

    var s = new Settings();
    s.name = "!$id";
    s.team = teamID;
    s.userID = userID;
    s.displayName = displayName;

    this.gPlayers[id] = this.spawnEntity(typename, ent.pos.x, ent.pos.y, s);
    this.gPlayers[id].health = 0;
    return this.gPlayers[id];
  }

  unspawnPlayer(id) {
    if(this.gPlayers.containsKey(id)) {
      this.notifyPlayers("${this.gPlayers[id].displayName} disconnected.");
    }

    this.removeEntity(this.gPlayers[id]);
  }
}