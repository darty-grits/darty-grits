part of grits_shared;

class SimpleProjectileInstance extends WeaponInstance {

  var rotAngle = 0.0;
  var lifetime = 0.0;
  var physBody = null;
  var _spriteAnim = null;
  var _impactFrameNames = null;
  var _impactSound = null;
  var _speed = 800;
  var _dmgAmt = 10;
  
  SimpleProjectileInstance(x, y, settings) : super(x, y, settings) {
    var startPos = settings.pos;
    // TODO: make vec2
    this.dir = {'x':settings.dir.x, 'y':settings.dir.y};
    this.lifetime = 2.0;  //in seconds
    var spd = 800;
    this.rotAngle = settings.faceAngleRadians;   
    
    if(settings)
    {
      if(settings.speed)
        this._speed = settings.speed;
      
      if(settings.lifetimeInSeconds)
        this.lifetime = settings.lifetimeInSeconds;
      
      if(settings.damage)
        this._dmgAmt = settings.damage;
      
      if(settings.impactFrameName)
        this._impactFrameNames = settings.impactFrameName;
      
      if(settings.impactSound)
        this._impactSound = settings.impactSound;
    }
    
    var guid = newGuid_short();
    //create our physics body;
    var entityDef = {
      'id': "SimpleProjectile${guid}",
      'x': startPos['x'],
      'y': startPos['y'],
      'halfHeight': 5 * 0.5,
      'halfWidth': 5 * 0.5,
      'damping': 0,
      'angle': 0,
      'categories': ['projectile', settings.team == 0 ? 'team0' : 'team1'],
      'collidesWith': ['mapobject', settings.team == 0 ? 'team1' : 'team0'],
      'userData': {
        "id": "wpnSimpleProjectile${guid}",
        "ent": this
      }
    };
    
    physBody = gPhysicsEngine.addBody(entityDef);

    physBody.SetLinearVelocity(new vec2(settings.dir.x * this._speed, settings.dir.y * this._speed));
  
    if(!IS_SERVER)
    {
      this.zIndex = 20;
      this._spriteAnim = new SpriteSheetAnimClass();
      this._spriteAnim.loadSheet('grits_effects',"img/grits_effects.png");

      if(settings)
      {
        if(settings.animFrameName)
        {
          var sprites = getSpriteNamesSimilarTo(settings.animFrameName);
          for(var i =0; i < sprites.length; i++)
            this._spriteAnim.pushFrame(sprites[i]);
        }

        if(settings.spawnSound)
        {
          gGameEngine.playWorldSound(settings.spawnSound,x,y);
        }
      }
    }
  }
  
  update() {
    this.lifetime -= 0.05;
    if (this.lifetime <= 0) {
      this.kill();
      return;
    }

    var adjust = this.getPhysicsSyncAdjustment();
    this.physBody.SetLinearVelocity(new vec2(this.dir.x * this._speed + adjust.x,
                                             this.dir.y * this._speed + adjust.y));

    if (this.physBody != null) {
      var pPos = this.physBody.GetPosition();
      this.pos.x = pPos.x;
      this.pos.y = pPos.y;
    }

    //this.parent();
  }
  
  draw(fractionOfNextPhysicsUpdate) {
    var gMap = gGameEngine.gMap;
    
    //rotate based upon velocity
    var pPos = this.pos;
    if (this.physBody != null) { 
      pPos = this.physBody.GetPosition();
    }

    var interpolatedPosition = {'x':pPos.x, 'y':pPos.y};

    if(this.physBody != null) {
      var velocity = this.physBody.GetLinearVelocity();
      interpolatedPosition.x += (velocity.x * Constants.PHYSICS_LOOP_HZ) * fractionOfNextPhysicsUpdate;
      interpolatedPosition.y += (velocity.y * Constants.PHYSICS_LOOP_HZ) * fractionOfNextPhysicsUpdate;
    }

    this._spriteAnim.draw(interpolatedPosition.x,interpolatedPosition.y,{'rotRadians':this.rotAngle});
  
  }
  
  kill() {
    //remove my physics body
    gPhysicsEngine.removeBodyAsObj(physBody);
    physBody = null;
    //destroy me as an ent.
    gGameEngine.removeEntity(this);
  }
  
  sendUpdates() {
    this.sendPhysicsUpdates();
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
      if(this._impactFrameNames != null)
      {
        var pPos = this.physBody.GetPosition();
        var efct = gGameEngine.spawnEntity("InstancedEffect", pPos.x, pPos.y, null);
        // TODO: change this to a constructor
        efct.onInit({'x':pPos.x,'y':pPos.y},
          { 
            'playOnce':true, 
            'similarName':this._impactFrameNames, 
            'uriToSound':this._impactSound 
          });
      }
          
    } else {
      gGameEngine.dealDmg(this, physOwner, this._dmgAmt * this.damageMultiplier);
    }

    this.markForDeath = true;

    return true; //return false if we don't validate the collision
  }
}