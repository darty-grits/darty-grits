library physics_engine;
import 'package:box2d/box2d.dart';
import 'dart:math' as Math;

part 'grits_contact_listener.dart';

class PhysicsEngine {

  World world;

  static final GRITS_COLLISION_GROUP = {
    'player': 0x0001,
    'team0': 0x0001 << 1,
    'team1': 0x0001 << 2,
    'projectile': 0x0001 << 3,
    'pickupobject': 0x0001 << 4,

    // Map Objects
    'mapobject': 0x0001 << 5,
    'projectileignore': 0x0001 << 6
  };

  void create() {
    world = new World(new vec2(0,0), false);
    Settings.MAX_TRANSLATION = 99999;
    Settings.MAX_TRANSLATION_SQUARED = Settings.MAX_TRANSLATION * Settings.MAX_TRANSLATION;
  }

  void addContactListener({Function BeginContact: null, Function EndContact: null, Function PostSolve: null, Function PreSolve: null}) {
    GritsContactListener listener = new GritsContactListener();
    if (BeginContact != null) {
      listener.beginContact = BeginContact;
    }
    if (EndContact != null ) {
      listener.endContact = EndContact;
    }
    if (PostSolve != null) {
      listener.postSolve = PostSolve;
    }
    if (PreSovle != null) {
      listener.preSolve = PreSolve;
    }
    world.contactListener = listener;
  }

  int update() {
    var start = new DateTime.now();
    world.step(Constants.PHYSICS_LOOP_HZ, //frame-rate
               10, //velocity iterations
               10); //position iterations
    world.clearForces();
    return (new DateTime.now()).millisecondsSinceEpoch - start.millisecondsSinceEpoch;
  }

  Body registerBody(BodyDef bodyDef) {
    var body = world.createBody(bodyDef);
    return body;
  }

  Body addBody(Entity entityDef) {
    var bodyDef = new BodyDef();
    var id = entityDef.id;

    bodyDef.type = (entityDef.type == 'static') ? BodyType.STATIC : BodyType.DYNAMIC;

    bodyDef.position = new vec2(entityDef.x,entityDef.y);
    if (entityDef.userData != null) {
      bodyDef.userData = entityDef.userData;
    }
    if (entityDef.angle != null) {
      bodyDef.angle = entityDef.angle;
    }
    if (entityDef.damping != null) {
      bodyDef.linearDamping = entityDef.damping;
    }
    var body = registerBody(bodyDef);

    var fixtureDefinition = new FixtureDef();
    if (entityDef.useBouncyFixture) {
      fixtureDefinition.density = 1.0;
      fixtureDefinition.friction = 0;
      fixtureDefinition.restitution = 1.0;
    } else {
      fixtureDefinition.density = 1.0;
      fixtureDefinition.friction = 0;
      fixtureDefinition.restitution = 0;
    }

    if (entityDef.categories && entityDef.categories.length) {
      fixtureDefinition.filter.categories = 0x0000;
      for (var category in entityDef.categories) {
        fixtureDefinition.filter.categoryBits |= GRITS_COLLISION_GROUP[category];
      }
    } else {
      fixtureDefinition.filter.categoryBits = 0x0001;
    }

    if (entityDef.collidesWith != null) {
      fixtureDefinition.filter.maskBits = 0x0000;
      for (var collidesWidth in entityDef.collidesWith) {
        fixtureDefinition.filter.maskBits |= GRITS_COLLISION_GROUP[collidesWith];
      }
    } else {
      fixtureDefinition.filter.maskBits = 0xFFFF;
    }

    if (entityDef.radius != null) {
      fixtureDefinition.shape = new CircleShape(entityDef.radius);
      body.createFixture(fixtureDefinition);
    } else if (entityDef.polyPoints != null) {
      var points = entityDef.polyPoints;
      var vecs = [];
      for (var point in points) {
        var vec = new vec2(point.x, point.y);
        vecs[i] = vec;
      }
      fixtureDefinition.shape = new PolygonShape();
      fixtureDefinition.shape.SetAsArray(vecs, vecs.length);
      body.createFixture(fixtureDefinition);
    } else { //we're a box!
      fixtureDefinition.shape = new PolygonShape();
      fixtureDefinition.shape.SetAsBox(entityDef.halfWidth, entityDef.halfHeight);
      body.createFixture(fixtureDefinition);
    }

    return body;
  }

  void removeBodyAsObj(Body object) {
    world.destroyBody(object);
  }

  void getBodySpec(Body object) {
    return {
      'position': object.position,
      'angle': object.angle,
      'worldcenter': object.angle
    };
  }

  void applyImpulse(Body body, num degrees, num power) {
    body.applyLinearImpulse(new Vec2(Math.cos(degrees * (Math.PI/180))*power, Math.sin(degrees * (Math.PI/180))*power), body.worldCenter);
  }

  void clearImpulse(Body body) {
    body.linearVelocity.makeZero();
    body.angularVelocity = 0.0;
  }

  void setVelocity(Body body, num x, num y) {
    body.linearVelocity = new vec2(x, y);
  }

  vec2 getVelocity(Body body) {
    return body.linearVelocity;
  }

  vec2 getPosition(Body body) {
    return body.position;
  }

  void setPosition(Body body, vec2 pos) {
    body.position = pos;
  }
}