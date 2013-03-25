part of grits_shared;

class BounceBallBulletInstance extends WeaponInstance {
  var rotAngle = 0.0;
  var lifetime = 0.0;
  var physBody = null;

  BounceBallBulletInstance(x, y, settings) : super(x, y, settings) {
    var owningPlayer = gGameEngine.namedEntities[settings.owner];
    var startPos = settings.pos;
    var dir = settings.dir;
    
    //this.parent(owningPlayer);
    
    this.lifetime = 101;

    //DETERMINE WHAT OUR ROTATION ANGLE IS
    rotAngle = 0;
    var guid = newGuid_short();
    //create our physics body;
    var entityDef = {
      'id': "MachineBullet${guid}",
      'x': startPos['x'],
      'y': startPos['y'],
      'halfHeight': 5 * 0.5,
      'halfWidth': 11 * 0.5,
      'damping': 0,
      'angle': rotAngle,
      'useBouncyFixture': true,
      'categories': ['projectile', owningPlayer.team == 0 ? 'team0' : 'team1'],
      'collidesWith': ['mapobject', owningPlayer.team == 0 ? 'team1' : 'team0'],
      'userData': {
        "id": "wpnMachineBullet${guid}",
        "ent": this
      }
    };
    
    physBody = gPhysicsEngine.addBody(entityDef);

    physBody.SetLinearVelocity(new vec2(dir.x * 800, dir.y * 800));
  }
  
  kill() {
    //remove my physics body
    gPhysicsEngine.removeBodyAsObj(physBody);
    physBody = null;
    //destroy me as an ent.
    gGameEngine.removeEntity(this);
  }
  
  update() {
    this.lifetime--;
    if (this.lifetime <= 0) {
      this.kill();
      return;
    }

    if (this.physBody != null) {
      this.autoAdjustVelocity();
      var pPos = this.physBody.GetPosition();
      this.pos['x'] = pPos['x'];
      this.pos['y'] = pPos['y'];
    }
    // TODO: what would calling the constructor with empty arguments do??
    //this.parent();
  }
  
  sendUpdates() {
    this.sendPhysicsUpdates();
  }
  
  onTouch(otherBody, point, impulse) {
    if (this.physBody == null) {
      // The object has already been killed, ignore
      return false;
    }
  
    if (otherBody == null || otherBody.GetUserData() == null) {
      print("Invalid collision object");
      return false; //invalid object??
    }
    
    var physOwner = otherBody.GetUserData().ent;
    
    if (physOwner != null) {
      if (physOwner._killed) { 
        return false;
      }

      //spawn impact visual
      if (!IS_SERVER) {
        var pPos = this.physBody.GetPosition();
        var ent = gGameEngine.spawnEntity("BounceBallImpact", pPos['x'], pPos['y'], null);
        // TODO: pass in settings
        ent.onInit(pPos);
      }
      else
      {
        gGameEngine.dealDmg(this, physOwner, 5 * this.damageMultiplier);
      }

      this.markForDeath = true;
    } else {
      // The bullet should bounce off walls and other things using box2d
    }

    return true; //return false if we don't validate the collision
  }
}