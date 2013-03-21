part of grits_shared;

class Teleporter extends Entity {
  var physicsDef, destination;
  var physBody;
  Teleporter(this.physicsDef, this.destination) {
    physBody = gPhysicsEngine.addBody(physicsDef);
  }

  kill() { }
  
  update() {}
  
  onTouch(otherBody, point, impulse) {
    var otherEnt = otherBody.GetUserData().ent;
    
    if (otherEnt.lastCloseTeleportPos == null) {
      otherEnt.centerAt(destination);
      // TODO: check the type for lastCloseTeleportPos 
      otherEnt.lastCloseTeleportPos = {'x': destination.x, 'y': destination.y};
    }
    
    return true;
  }
}