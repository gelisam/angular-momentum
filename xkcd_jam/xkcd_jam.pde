float gravity_constant = 0.001;
float min_gravity = 0.1; // otherwise reaching escape velocity means game over

boolean left_pressed = false;
boolean right_pressed = false;
boolean up_pressed = false;
PGraphics planet_graphics;
PImage planet_shading;
PImage helmet_image;
Player global_player;
Planet[] global_planets;

void start_on(Planet planet) {
  global_player = new Player(planet.x, planet.y - planet.r);
  global_player.attach(planet);
}

void load_level(int level) {
  if (level == 1) {
    Planet planet = new Planet(320, 180, 100, "green-blue-planet.png", 0.1);
    start_on(planet);

    global_planets = new Planet[1];
    global_planets[0] = planet;
  } else if (level == 2) {
    Planet left_planet = new Planet(215, 180, 50, "beach-planet.png", 0.1);
    Planet right_planet = new Planet(425, 180, 50, "purple-planet.png", 0.1);
    start_on(left_planet);

    global_planets = new Planet[2];
    global_planets[0] = left_planet;
    global_planets[1] = right_planet;
  }
}

void setup() {
  planet_graphics = createGraphics(186, 186);
  planet_shading = loadImage("planet-shading.png");
  helmet_image = loadImage("helmet.png");

  load_level(2);

  size(640, 360);
  noStroke();
  imageMode(CENTER);
  loop();
}

// (-5) % 4 == -1
// absMod(-5, 4) = 3
float absMod(float x, float y) {
  float r = x % y;
  if (r < 0) {
    return r + y;
  } else {
    return r;
  }
}

float lerpAngle(float theta1, float theta2, float fraction) {
  float dtheta = absMod(theta2 - theta1, TAU);
  if (dtheta < PI) {
    theta2 = theta1 + dtheta;
  } else {
    theta2 = theta1 + dtheta - TAU;
  }

  return lerp(theta1, theta2, fraction);
}

Planet find_closest_planet(float x, float y) {
  Planet closest_planet = null;
  float closest_distance_squared = 0.0; // only valid when closest_planet != null
  for (int i=0; i<global_planets.length; ++i) {
    Planet planet = global_planets[i];
    float distance_squared = sq(x - planet.x) + sq(y - planet.y);
    if (closest_planet == null || distance_squared < closest_distance_squared) {
      closest_planet = planet;
      closest_distance_squared = distance_squared;
    }
  }
  return closest_planet;
}

boolean are_circles_colliding(float x1, float y1, float r1, float x2, float y2, float r2) {
  return sq(x2-x1) + sq(y2-y1) < sq(r1+r2);
}

// null if not colliding
Planet find_colliding_planet(float x, float y, float r) {
  for (int i=0; i<global_planets.length; ++i) {
    Planet planet = global_planets[i];
    if (are_circles_colliding(x, y, r, planet.x, planet.y, planet.r)) {
      return planet;
    }
  }

  return null;
}

// force on a 1 kilogram object, in newtons/kilogram
PVector gravity_force_at(float x, float y) {
  PVector force = new PVector();
  for (int i=0; i<global_planets.length; ++i) {
    Planet planet = global_planets[i];
    PVector towards_planet = new PVector(planet.x - x, planet.y - y);
    towards_planet.normalize();
    float r_squared = sq(planet.x - x) + sq(planet.y - y);
    float gravity = planet.mass / r_squared;
    towards_planet.mult(gravity);
    force.add(towards_planet);
  }

  force.mult(gravity_constant);
  if (force.magSq() < sq(min_gravity)) {
    force.normalize();
    force.mult(min_gravity);
  }
  return force;
}

class Eyes {
  float t = 0.0; // seconds
  float offset = 1.0; // -1.0 to 1.0
  float target_offset = 1.0; // -1.0 to 1.0

  void update(float dt, int dir) {
    t += dt;

    float doffset = dt/0.1;
    target_offset = (dir ==  1) ?  1.0
      : (dir == -1) ? -1.0
      : target_offset;
    if (abs(offset - target_offset) < dt) {
      offset = target_offset;
    } else if (target_offset > offset) {
      offset += doffset;
    } else {
      offset -= doffset;
    }
  }

  void draw() {
    boolean blinking = (t % 3 >= 2.8);
    if (!blinking) {
      pushMatrix();
      translate(offset*8, 0);
      fill(255, 255, 255);
      ellipse(-8, 0, 8, 16);
      ellipse( 8, 0, 8, 16);
      popMatrix();
    }
  }
}

class Foot {
  float offset; // turns
  float cycle = 0.0; // turns

  Foot(float offset_) {
    offset = offset_;
  }

  void update(float dcycle, int dir) {
    float target = (dir ==  1) ? (cycle + 1)
      : (dir == -1) ? (cycle - 1)
      : round(cycle*2.0)/2.0;
    if (abs(cycle - target) < dcycle) {
      cycle = target;
    } else if (target > cycle) {
      cycle += dcycle;
    } else {
      cycle -= dcycle;
    }
  }

  void draw() {
    float theta = (cycle + offset) * TAU;
    fill(255, 128, 128);
    ellipse(14*cos(theta), 4*sin(theta), 24, 16);
  }
}

class Player {
  float x; // pixels
  float y; // pixels
  float theta = 0.0; // radians
  float target_theta = 0.0; // radians
  boolean wearing_helmet = false;
  float r = 16; // pixels
  float walking_speed = 20; // pixels/second
  float last_x;
  float last_y;
  PVector velocity = new PVector(); // pixels/second, only valid when attached_planed == null
  Eyes eyes = new Eyes();
  Foot back_foot = new Foot(0.0);
  Foot front_foot = new Foot(0.5);
  Planet attached_planet = null; // may be null!
  float attached_theta; // radians, only valid when attached_planet != null

  Player(float x_, float y_) {
    last_x = x = x_;
    last_y = y = y_;
  }

  void attach(Planet planet) {
    if (attached_planet == null) {
      attached_planet = planet;
      attached_theta = atan2(y-planet.y, x-planet.x) - attached_planet.theta;
    }
  }

  void detach() {
    if (attached_planet != null) {
      attached_planet = null;
      velocity.x = x - last_x;
      velocity.y = y - last_y;
    }
  }

  void update(float dt, int dir, boolean holding_up) {
    if (holding_up) {
      wearing_helmet = true;
      detach();
    } else {
      wearing_helmet = false;
      Planet planet = find_colliding_planet(x, y, r);
      if (planet != null) {
        attach(planet);
      }
    }

    if (attached_planet == null) {
      dir = 0;
    }

    eyes.update(dt, dir);

    float dcycle = dt / 0.4;
    back_foot.update(dcycle, dir);
    front_foot.update(dcycle, dir);

    last_x = x;
    last_y = y;
    if (attached_planet == null) {
      if (!wearing_helmet) {
        velocity.add(gravity_force_at(x, y));
      }

      x += velocity.x;
      y += velocity.y;

      Planet closest_planet = find_closest_planet(x, y);
      target_theta = atan2(y-closest_planet.y, x-closest_planet.x)+TAU/4;
      theta = lerpAngle(theta, target_theta, 0.1);
    } else {
      // project the walking speed onto the planet, in radians
      float dx = dt * walking_speed;
      float dtheta = atan2(dx, attached_planet.r);
      attached_theta += dir*dtheta;

      float r_ = attached_planet.r + r;
      float theta_ = attached_planet.theta + attached_theta;
      x = attached_planet.x + r_ * cos(theta_);
      y = attached_planet.y + r_ * sin(theta_);
      theta = theta_+TAU/4;
    }
  }

  void draw_body() {
    fill(128, 128, 255);
    ellipse(0, 0, 64, 64);
  }

  void draw() {
    pushMatrix();
    translate(x, y);
    scale(r/32);
    rotate(theta);

    pushMatrix();
    translate(0, 28);
    back_foot.draw();
    popMatrix();

    draw_body();
    eyes.draw();

    pushMatrix();
    translate(0, 30);
    front_foot.draw();
    popMatrix();

    if (wearing_helmet) {
      image(helmet_image, 0, 0, 92, 92);
    }

    popMatrix();
  }
}

class Planet {
  float x; // pixels
  float y; // pixels
  float r; // pixels
  float mass; // kilograms?
  PImage img;
  float speed; // turns/second
  float theta = 0.0; // radians

  Planet(float x_, float y_, float r_, String filename, float speed_) {
    x = x_;
    y = y_;
    r = r_;
    mass = 4*PI*r*r*r/3;
    img = loadImage(filename);
    speed = speed_;
  }

  void update(float dt) {
    theta += speed * dt * TAU;
  }

  void draw() {
    planet_graphics.beginDraw();
    planet_graphics.background(0, 0, 0, 0);
    planet_graphics.pushMatrix();
    planet_graphics.translate(93, 93);
    planet_graphics.rotate(theta);
    planet_graphics.image(img, -93, -93, 186, 186);
    planet_graphics.popMatrix();
    planet_graphics.blend(planet_shading, 0, 0, 186, 186, 0, 0, 186, 186, OVERLAY);
    planet_graphics.endDraw();

    pushMatrix();
    translate(x, y);
    image(planet_graphics, 0, 0, 2*r, 2*r);
    popMatrix();
  }
}

void draw() {
  int dir = (left_pressed ? -1 : 0) + (right_pressed ? 1 : 0); // -1, 0, or 1
  float dt = 1.0/60; // seconds (assumes 60fps)
  for (int i=0; i<global_planets.length; ++i) {
    Planet planet = global_planets[i];
    planet.update(dt);
  }
  global_player.update(dt, dir, up_pressed);

  background(0);
  for (int i=0; i<global_planets.length; ++i) {
    Planet planet = global_planets[i];
    planet.draw();
  }
  global_player.draw();
}

void keyPressed() {
  if (keyCode == LEFT) {
    left_pressed = true;
  } else if (keyCode == RIGHT) {
    right_pressed = true;
  } else if (keyCode == UP) {
    up_pressed = true;
  }
}

void keyReleased() {
  if (keyCode == LEFT) {
    left_pressed = false;
  } else if (keyCode == RIGHT) {
    right_pressed = false;
  } else if (keyCode == UP) {
    up_pressed = false;
  }
}