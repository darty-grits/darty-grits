part of grits_shared;

class EnergyCanister extends Entity {
  var physBody;
  
  EnergyCanister(x, y, settings) /*: super(x, y, settings)*/ {
    var startPos = {'x':x,'y':y}; // TODO: change to vec2
    var guid = newGuid_short();
    //create our physics body;
    var entityDef = {
      'id': "EnergyCanister${guid}",
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
        "id": "EnergyCanister${guid}",
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
    if (physBody == null) {
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
      
      if (physOwner.energy < physOwner.maxEnergy) {
        physOwner.energy = Math.min(physOwner.maxEnergy, physOwner.energy + 10);
      }
        
      this.markForDeath = true; 
    }

    return true; //return false if we don't validate the collision
  }
}