boolean left_pressed = false;
boolean right_pressed = false;
Player global_player;
Planet global_planet;
PGraphics planet_graphics;
PImage planet_shading;

void setup() {
  global_player = new Player(320, 180);
  global_planet = new Planet(320, 180, 100, "green-blue-planet.png", 0.1);
  planet_graphics = createGraphics(186, 186);
  planet_shading = loadImage("planet-shading.png");
  
  global_player.y -= global_planet.r;
  global_player.y -= global_player.r;
  global_player.attach(global_planet);

  size(640, 360);
  noStroke();
  imageMode(CENTER);
  loop();
}


class Eyes {
  float t = 0.0;
  float offset = 1.0;
  float target = 1.0;

  void update(float dt, int dir) {
    t += dt;

    float doffset = dt/0.1;
    target = (dir ==  1) ?  1.0
           : (dir == -1) ? -1.0
           : target;
    if (abs(offset - target) < dt) {
      offset = target;
    } else if (target > offset) {
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
  float offset;
  float cycle = 0.0;
  boolean other_foot;

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
  float x;
  float y;
  float r = 16;
  float walking_speed = 200;
  Eyes eyes = new Eyes();
  Foot back_foot = new Foot(0.0);
  Foot front_foot = new Foot(0.5);
  Planet attached_planet = null;
  float attached_theta;

  Player(float x_, float y_) {
    x = x_;
    y = y_;
  }
  
  void attach(Planet planet) {
    attached_planet = planet;
    attached_theta = atan2(y-planet.y, x-planet.x);
  }
  
  void detach() {
    attached_planet = null;
  }

  void update(float dt, int dir) {
    eyes.update(dt, dir);

    float dcycle = dt / 0.4;
    back_foot.update(dcycle, dir);
    front_foot.update(dcycle, dir);
    
    float dx = dt * walking_speed;
    if (attached_planet == null) {
      x += dir*dx;
    } else {
      float r_ = attached_planet.r + r;
      float theta = attached_planet.theta + attached_theta;
      x = attached_planet.x + r_ * cos(theta);
      y = attached_planet.y + r_ * sin(theta);
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
    
    popMatrix();
  }
}

class Planet {
  float x;
  float y;
  float r;
  PImage img;
  float speed;
  float theta = 0.0;
  
  Planet(float x_, float y_, float r_, String filename, float speed_) {
    x = x_;
    y = y_;
    r = r_;
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
  int dir = (left_pressed ? -1 : 0) + (right_pressed ? 1 : 0);
  float dt = 1.0/60;
  global_planet.update(dt);
  global_player.update(dt, dir);

  background(0);
  global_planet.draw();
  global_player.draw();
}

void keyPressed() {
  if (keyCode == LEFT) {
    left_pressed = true;
  } else if (keyCode == RIGHT) {
    right_pressed = true;
  }
}

void keyReleased() {
  if (keyCode == LEFT) {
    left_pressed = false;
  } else if (keyCode == RIGHT) {
    right_pressed = false;
  }
}