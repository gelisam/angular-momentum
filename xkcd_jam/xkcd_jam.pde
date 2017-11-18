boolean left_pressed = false;
boolean right_pressed = false;
Player global_player = new Player();

void setup() {
  size(640, 360);
  noStroke();
  loop();
}


class Eyes {
  float t = 0.0;
  
  void update(float dt) {
    t += dt;
  }
  
  void draw(float x, float y) {
    boolean blinking = (t % 3 >= 2.8);
    if (!blinking) {
      fill(255, 255, 255);
      ellipse(x-8, y, 8, 16);
      ellipse(x+8, y, 8, 16);
    }
  }
}

class Foot {
  float t = 0.0;
  boolean other_foot;
  
  Foot(boolean other_foot_) {
    other_foot = other_foot_;
  }
  
  void update(float dt) {
    t += dt;
  }
  
  void draw(float x, float y) {
    float angle = t * -TWO_PI / 0.4 + (other_foot ? PI : 0);
    fill(255, 128, 128);
    ellipse(x+8*cos(angle), y+4*sin(angle), 24, 16);
  }
}

class Player {
  Eyes eyes = new Eyes();
  Foot back_foot = new Foot(false);
  Foot front_foot = new Foot(true);
  
  void update(float dt) {
    eyes.update(dt);
    back_foot.update(dt);
    front_foot.update(dt);
  }
  
  void draw_body(float x, float y) {
    fill(128, 128, 255);
    ellipse(x, y, 64, 64);
  }
  
  void draw(float x, float y) {
    back_foot.draw(x-10, y+28);
    draw_body(x, y);
    eyes.draw(x-8, y);
    front_foot.draw(x+10, y+30);
  }
}

void draw() {
  float dir = (left_pressed ? 1.0 : 0.0) + (right_pressed ? -1.0 : 0.0);
  float dt = dir/60;
  global_player.update(dt);
  
  background(0);
  global_player.draw(100, 100);
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