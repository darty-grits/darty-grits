part of grits_shared;

class ShieldInstance extends WeaponInstance {
  var physBody = null;
  var team = null;
  var owningPlayer = null;
  
  ShieldInstance(x, y, settings) : super(x, y, settings) {
    this.owningPlayer = gGameEngine.namedEntities[settings.owner];
    var startPos = settings.pos;
    
    this.team = this.owningPlayer.team;

    //DETERMINE WHAT OUR ROTATION ANGLE IS
    rotAngle = 0;
    var guid = newGuid_short();
    //create our physics body;
    var entityDef = {
      'id': "ShieldInstanceClass${guid}",
      'type': 'static',
      'x': startPos['x'],
      'y': startPos['y'],
      'halfHeight': 15,
      'halfWidth': 15,
      'damping': 0,
      'angle': 0,
      'categories': [this.owningPlayer.team == 0 ? 'team0' : 'team1'],
      'collidesWith': [this.owningPlayer.team == 0 ? 'team1' : 'team0'],
      'userData': {
        "id": "ShieldInstanceClass${guid}",
        "ent": this
      }
    };
    this.physBody = gPhysicsEngine.addBody(entityDef);

    this.physBody.SetLinearVelocity(new Vec2(0, 0));
    this.energyCost = 0.05;
  
    if(!IS_SERVER)
    {
      gGameEngine.playWorldSound("./sound/shield_activate.ogg", x, y);
      this.zIndex = 20;
    }
  }
  
  kill() {
    //remove my physics body
    gPhysicsEngine.removeBodyAsObj(physBody);
    physBody = null;
    //destroy me as an ent.
    gGameEngine.removeEntity(this);
  }
  
  update() {
    if(!IS_SERVER)
    {
      if(this.owningPlayer.pInput.fire2 == null || this.owningPlayer.energy<=0) {
        this.markForDeath = true;
      }
    }
    
    //we're still alive
    this.physBody.SetPosition(this.owningPlayer.physBody.GetPosition());

    //this.parent();
  }
  
  draw(fractionOfNextPhysicsUpdate) {
    //rotate based upon velocity
    var pPos = this.pos;
    if (this.physBody) {
      pPos = this.physBody.GetPosition();
    }
  
    drawSprite("shield_defensive.png", pPos.x, pPos.y);  
  }
}