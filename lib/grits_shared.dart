library grits_shared;

import 'dart:math' as Math;
import 'package:logging/logging.dart';
import 'package:box2d/box2d.dart';

// core parts
part 'src/core/game_timer.dart';
part 'src/core/constants.dart';
part 'src/core/entity.dart';
part 'src/core/game_engine.dart';
part 'src/core/grits_contact_listener.dart';
part 'src/core/physics_engine.dart';
part 'src/core/player.dart';
part 'src/core/tile_map.dart';
part 'src/core/weapon.dart';
part 'src/core/weapon_instance.dart';

// environment parts
part 'src/environment/spawn_point.dart';
part 'src/environment/spawner.dart';
part 'src/environment/teleporter.dart';

// items parts
part 'src/items/energy_canister.dart';
part 'src/items/health_canister.dart';
part 'src/items/quad_damage.dart';

// maps parts
part 'src/maps/entities/map.dart';
part 'src/maps/entities/layer.dart';
part 'src/maps/entities/object.dart';
part 'src/maps/entities/tileset.dart';
part 'src/maps/map1.dart';
part 'src/maps/small_map1.dart';

// weapons parts
part 'src/weapons/bounce_ball_gun.dart';
part 'src/weapons/chain_gun.dart';
part 'src/weapons/landmine.dart';
part 'src/weapons/machine_gun.dart';
part 'src/weapons/rocket_launcher.dart';
part 'src/weapons/shield.dart';
part 'src/weapons/shot_gun.dart';
part 'src/weapons/sword.dart';
part 'src/weapons/thrusters.dart';

// weapons instances
part 'src/weapon_instances/bounce_ball_bullet.dart';
part 'src/weapon_instances/landmine_disk.dart';
part 'src/weapon_instances/shield.dart';
part 'src/weapon_instances/simple_projectile.dart';
part 'src/weapon_instances/sword.dart';

// Global instances. Note, we can refactor this when the time is right.
var gGameEngine;
var gPhysicsEngine;
bool IS_SERVER = false;
var Server;

class Settings {
  var type;
  var displayName;
  var userID;
  var name;
  var team;

}
