
final String IMG_NAME = "5.jpg";

float lambda = 1;
float stroke = 10;

PImage img;

PGraphics canvas;
PGraphics fg_labels;
PGraphics bg_labels;
PGraphics res;

float[][] nodes;

boolean is_bg;
boolean drawMode;
boolean initModel;
boolean stop;

MRF mrf;

void setup() {
  size(100, 100);
  background(0);

  img = loadImage("./images/" + IMG_NAME);
  img.filter(GRAY);

  surface.setResizable(true);
  surface.setSize(img.width, img.height);
  surface.setResizable(false);

  nodes = new float[width][height];

  is_bg = true;
  drawMode = true;
  initModel = false;
  stop = false;

  canvas = createGraphics(width, height);
  fg_labels = createGraphics(width, height);
  bg_labels = createGraphics(width, height);
  res = createGraphics(width, height);

  res.beginDraw();
  res.background(0);
  res.endDraw();

  fg_labels.beginDraw();
  fg_labels.background(0);

  bg_labels.beginDraw();
  bg_labels.background(0);
}

void draw() {
  println(frameCount);
  handleKey();

  if (drawMode) {
    drawGUI();
    image(canvas, 0, 0);
  } else {
    if (!initModel) {
      mrf = new MRF();
      initModel = true;
    }
    mrf.gibbs(lambda);
    image(res, 0, 0);
  }

  if (stop)
    noLoop();
}

void stop() {
  fg_labels.endDraw();
  bg_labels.endDraw();
}

void handleKey() {
  if (keyPressed) {
    if (key == '+') {
      stroke++;
    }
    if (key == '-') {
      stroke = stroke - 1 >= 1 ? --stroke : 1;
    }
    if (key == 'b') {
      println("End Draw");
      drawMode = false;
      initModel = false;
    }
    if (key == 'f') {
      println("Begin Draw");
      drawMode = true;
      initModel = false;
    }
    if (key == 's') {
      stop = true;
    }
    if (key == 'o') {
      lambda--;
    }
    if (key == 'p') {
      lambda++;
    }
  }
}

void drawGUI() {
  canvas.beginDraw();

  canvas.image(img, 0, 0);

  for (int i = 0; i < width; i++) {
    for (int j = 0; j < height; j++) {
      canvas.strokeWeight(1);
      if (fg_labels.get(i, j) == color(255)) {
        canvas.stroke(255, 0, 0);
        canvas.fill(255, 0, 0);
        canvas.point(i, j);
      }
      if (bg_labels.get(i, j) == color(255)) {
        canvas.stroke(0, 0, 255);
        canvas.fill(0, 0, 255);
        canvas.point(i, j);
      }
    }
  }

  color inpC = is_bg ? color(255, 0, 0) : color(0, 0, 255);
  canvas.stroke(inpC);
  canvas.noFill();
  canvas.strokeWeight(1);

  canvas.ellipse(mouseX, mouseY, stroke, stroke);

  canvas.endDraw();
}

void mouseDragged()
{
  if (mouseX >= 0 && mouseX < width && mouseY >= 0 && mouseY < height) {
    if (is_bg) {
      fg_labels.strokeWeight(stroke);
      fg_labels.fill(255);
      fg_labels.stroke(255);
      fg_labels.point(mouseX, mouseY);
    } else {
      bg_labels.strokeWeight(stroke);
      bg_labels.fill(255);
      bg_labels.stroke(255);
      bg_labels.point(mouseX, mouseY);
    }
  }
}

void mouseClicked() {
  if (mouseX >= 0 && mouseX < width && mouseY >= 0 && mouseY < height) {
    if (is_bg) {
      fg_labels.strokeWeight(stroke);
      fg_labels.fill(255);
      fg_labels.stroke(255);
      fg_labels.point(mouseX, mouseY);
    } else {
      bg_labels.strokeWeight(stroke);
      bg_labels.fill(255);
      bg_labels.stroke(255);
      bg_labels.point(mouseX, mouseY);
    }
  }
}

void mouseWheel(MouseEvent event) {
  is_bg = !is_bg;
}
