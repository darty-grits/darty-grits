part of grits_shared;

class LandmineDiskInstance extends WeaponInstance {
  var lifetime = 0.0;
  var physBody = null;
  var team = null;
  
  LandmineDiskInstance(x, y, settings) : super(x, y, settings) {
    var startPos = settings.pos;
  
    
    this.lifetime = 100.0;
    this.team = settings.team;

    //DETERMINE WHAT OUR ROTATION ANGLE IS
    this.rotAngle = 0.0;
    var guid = newGuid_short();
    //create our physics body;
    var entityDef = {
      'id': "wpnLandmineDisk${guid}",
      'type': 'static',
      'x': startPos['x'],
      'y': startPos['y'],
      'halfHeight': 18 * 0.5,
      'halfWidth': 19 * 0.5,
      'damping': 0,
      'angle': 0,
      'categories': ['projectile', this.team == 0 ? 'team0' : 'team1'],
      'collidesWith': [this.team == 0 ? 'team1' : 'team0'],
      'userData': {
        "id": "wpnLandmineDisk${guid}",
        "ent": this
      }
    };
    
    physBody = gPhysicsEngine.addBody(entityDef);

    physBody.SetLinearVelocity(new vec2(0, 0));
  }
  
  kill() {
    //remove my physics body
    gPhysicsEngine.removeBodyAsObj(physBody);
    physBody = null;
    //destroy me as an ent.
    gGameEngine.removeEntity(this);
  }
  
  update() {
    this.lifetime -= 0.05;
    if (this.lifetime <= 0) {
      this.kill();
      return;
    }

    //this.parent();
  }
  
  onTouch(otherBody, point, impulse) {
    if (this.physBody == null) {
      return false;
    }

    if (otherBody == null || otherBody.GetUserData() == null) { 
      return false; //invalid object??
    }
    
    var physOwner = otherBody.GetUserData().ent;
    //spawn impact visual
    if (!IS_SERVER) {
      this.makeBang();
    }
    else
    {
      gGameEngine.dealDmg(this, physOwner, 15 * this.damageMultiplier);
    }
  
    this.markForDeath = true;

    return true; //return false if we don't validate the collision
  }
}