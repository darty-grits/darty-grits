part of grits_shared;

class QuadDamage extends Entity {
  var physBody;
  
  QuadDamage(x, y, settings) /* : super(x, y, settings) */ {
    var startPos = {'x':x,'y':y};
    var guid = newGuid_short();
    //create our physics body;
    var entityDef = {
      'id': "QuadDamage${guid}",
      'type': 'static',
      'x': startPos['x'],
      'y': startPos['y'],
      'halfHeight': 18 * 0.5,
      'halfWidth': 19 * 0.5,
      'damping': 0,
      'angle': 0,
      'categories': ['projectile'],
      'collidesWith': ['player'],
      'userData': {
        "id": "QuadDamage${guid}",
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
  
  onTouch(otherBody, point, impulse) {
    if (this.physBody == null) {
      return false;
    }

    if (otherBody.GetUserData() == null) {
      return false; //invalid object??
    }
    
    var physOwner = otherBody.GetUserData().ent;
    
    if (physOwner != null) {
      if (physOwner._killed) {
        return false;
      }
      
      physOwner.powerUpTime = 30; // Quad damage lasts 30 seconds.
      
      this.markForDeath = true;
    }

    return true; //return false if we don't validate the collision
  }
}