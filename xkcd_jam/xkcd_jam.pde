boolean left_pressed = false;
boolean right_pressed = false;
Player global_player;;
Planet global_planet;

void setup() {
  global_player = new Player(320, 300);
  global_planet = new Planet(100, 100, 93, "green-blue-planet.png", 1.0);

  size(640, 360);
  noStroke();
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
    float angle = (cycle + offset) * TAU;
    fill(255, 128, 128);
    ellipse(14*cos(angle), 4*sin(angle), 24, 16);
  }
}

class Player {
  float x;
  float y;
  Eyes eyes = new Eyes();
  Foot back_foot = new Foot(0.0);
  Foot front_foot = new Foot(0.5);

  Player(float x_, float y_) {
    x = x_;
    y = y_;
  }

  void update(float dt, int dir) {
    eyes.update(dt, dir);

    float dcycle = dt / 0.4;
    back_foot.update(dcycle, dir);
    front_foot.update(dcycle, dir);
    
    float dx = dt * 200;
    x += dir*dx;
  }

  void draw_body() {
    fill(128, 128, 255);
    ellipse(0, 0, 64, 64);
  }

  void draw() {
    pushMatrix();
    translate(x, y);

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
  float angle = 0.0;
  
  Planet(float x_, float y_, float r_, String filename, float speed_) {
    x = x_;
    y = y_;
    r = r_;
    img = loadImage(filename);
    speed = speed_;
  }
  
  void update(float dt) {
    angle += speed * dt * TAU;
  }
  
  void draw() {
    pushMatrix();
    translate(x, y);
    rotate(angle);
    imageMode(CENTER);
    image(img, 0, 0);
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