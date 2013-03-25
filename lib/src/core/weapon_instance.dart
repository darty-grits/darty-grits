part of grits_shared;

class WeaponInstance extends Entity {
  double damageMultiplier = 1.0;
  var owningPlayer = null;
  
  WeaponInstance(x, y, settings) /*: super(x, y, settings) */ {
    this.owningPlayer = gGameEngine.namedEntities[settings.owner];
    
    if (this.owningPlayer != null && this.owningPlayer.powerUpTime > 0) {
      this.damageMultiplier *= 4.0;
    }
  }
}