part of grits_shared;

class SwordInstance extends WeaponInstance {

  var physBody = null;
  var team = null;
  var owningPlayer = null;
  var rotAmt = 0.0;
  
  SwordInstance(x, y, settings) : super(x, y, settings) {
    this.owningPlayer = gGameEngine.namedEntities[settings.owner];
    var startPos = settings.pos;
    
    this.team = this.owningPlayer.team;
    
    //DETERMINE WHAT OUR ROTATION ANGLE IS
    rotAngle = 0.0;
    var guid = newGuid_short();
    //create our physics body;
    var entityDef = {
      'id': "SwordInstanceClass${guid}",
      'type': 'static',
      'x': startPos['x'],
      'y': startPos['y'],
      'halfHeight': 64,
      'halfWidth': 64,
      'damping': 0,
      'angle': 0,
      'categories': [this.owningPlayer.team == 0 ? 'team0' : 'team1'],
      'collidesWith': [this.owningPlayer.team == 0 ? 'team1' : 'team0'],
      'userData': {
        "id": "SwordInstanceClass${guid}",
        "ent": this
      }
    };
    
    physBody = gPhysicsEngine.addBody(entityDef);

    physBody.SetLinearVelocity(new vec2(0, 0));
    this.energyCost = 0.05;
    
    if(!IS_SERVER) {
      gGameEngine.playWorldSound("./sound/sword_activate.ogg", x, y);
      this.zIndex=20;
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
    physBody.SetPosition(this.owningPlayer.physBody.GetPosition());
    // this.parent();
  }
  
  draw(fractionOfNextPhysicsUpdate) {
    //rotate based upon velocity
    var pPos = this.pos;
    if (this.physBody) { 
      pPos = this.physBody.GetPosition();
    }
  
    drawSprite("shield_offensive.png", pPos.x, pPos.y,{'rotRadians':this.rotAmt});
    this.rotAmt += 8*(Math.PI/180.0);
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
      
          
    }
    else
    {
      gGameEngine.dealDmg(this,physOwner, 15 * this.damageMultiplier);
    }

    return true; //return false if we don't validate the collision
  }
}