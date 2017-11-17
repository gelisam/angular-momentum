float global_t = 0.0;

void setup() {
  size(640, 360);
  noStroke();
  loop();
}

void draw_foot(float x, float y, float t, boolean other_foot) {
  
  fill(255, 128, 128);
  ellipse(x, y, 24, 16);
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
  draw_foot(x-16, y+28, t, false);
  draw_body(x, y, t);
  draw_eyes(x-8, y, t);
  draw_foot(x+8, y+30, t, true);
}

void draw() {
  background(0);
  draw_player(100, 100, global_t);  
  global_t += 1.0/60;
}