boolean left_pressed = false;
boolean right_pressed = false;
float global_t = 0.0;

void setup() {
  size(640, 360);
  noStroke();
  loop();
}

void draw_foot(float x, float y, float t, boolean other_foot) {
  float angle = t * -TWO_PI / 0.4 + (other_foot ? PI : 0);
  fill(255, 128, 128);
  ellipse(x+8*cos(angle), y+4*sin(angle), 24, 16);
}

void draw_body(float x, float y, float t) {
  fill(128, 128, 255);
  ellipse(x, y, 64, 64);
}

void draw_eyes(float x, float y, float t) {
  boolean blinking = (t % 3 >= 2.8);
  if (!blinking) {
    fill(255, 255, 255);
    ellipse(x-8, y, 8, 16);
    ellipse(x+8, y, 8, 16);
  }
}

void draw_player(float x, float y, float t) {
  draw_foot(x-10, y+28, t, false);
  draw_body(x, y, t);
  draw_eyes(x-8, y, t);
  draw_foot(x+10, y+30, t, true);
}

void draw() {
  background(0);
  draw_player(100, 100, global_t);
  
  float dt = (left_pressed ? 1.0 : 0.0) + (right_pressed ? -1.0 : 0.0);
  global_t += dt/60;
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