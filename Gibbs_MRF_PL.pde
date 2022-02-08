import controlP5.*;

final String IMG_NAME = "7.jpg";
final float IMG_H = 700;
final float MAX_STROKE = 300;
final int MAX_K = 500;

float lambda = 1;
float stroke = 10;

float beta = 0.4;

float vari;

int k = 0;

int prevLabelsCount = 0;
int labelsCount = 2;
int currentLabel = 1;

float[] mu;
float[] sigma;

PImage img;

PGraphics canvas;
PGraphics[] labels;

float[][] nodes;

boolean drawMode;
boolean initModel;
boolean stop;

MRF mrf;

ControlP5 cp5;
Accordion accordion;

float maxEnergy = 0;

void setup() {
  size(100, 100);
  background(0);

  img = loadImage("./images/" + IMG_NAME);

  float imgR = img.height / img.width;

  img.resize(int(IMG_H * imgR), int(IMG_H));
  img.filter(GRAY);

  surface.setResizable(true);
  surface.setSize(img.width * 2 + 250, img.height);
  surface.setResizable(false);

  smooth();
  gui();

  colorMode(HSB, 100);

  nodes = new float[width][height];

  drawMode = true;
  initModel = false;
  stop = false;

  canvas = createGraphics(width, height);
  updateGui();
}

void draw() {
  background(0);

  handleKey();

  updateGui();
  image(canvas, 280, 0);

  if (!drawMode) {
    if (!initModel) {
      mrf = new MRF(img.width, img.height);
      initModel = true;
      mrf.fmax(mu, sigma);
      k = 0;
    }

    mrf.ICMIteration(beta, mu, sigma, labelsCount);
    //mrf.gICMIteration(mu, sigma, labelsCount, k, 4, 1/8.0, beta);
    mrf.show();

    float cE = mrf.systemEnergy(sigma, mu, beta);

    print(k + " ");
    k++;
  }
}

void stop() {
}

void handleKey() {
  if (keyPressed) {
    if (key == '+') {
      stroke = stroke + 1 > MAX_STROKE ? MAX_STROKE : ++stroke;
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

    if (key == ' ') {
      setTrain(int(mouseX), int(mouseY), int(stroke), int(currentLabel));
    }
  }
}

void setTrain(int x, int y, int s, int cL) {
  labels[cL].beginDraw();
  for (int i = int(x - (s / 4.0)); i < x + (s / 4.0); i ++) {
    for (int j = int(y - (s / 4.0)); j < y + (s / 4.0); j ++) {
      labels[cL].colorMode(RGB, 255);
      labels[cL].strokeWeight(1);
      labels[cL].stroke(255);
      labels[cL].point(i, j);
    }
  }

  float sum = 0;
  float total = 0;

  float mi = 1000;
  float ma = 0;

  colorMode(RGB, 255);

  for (int i = 0; i < img.width; i++) {
    for (int j = 0; j < img.height; j++) {
      if (red(labels[cL].get(i, j)) == 255) {
        sum += red(img.get(i, j));
        total++;
      }
    }
  }

  mu[cL] = sum / total;

  sum = 0;

  for (int i = 0; i < img.width; i++) {
    for (int j = 0; j < img.height; j++) {
      if (red(labels[cL].get(i, j)) == 255) {
        sum += abs(red(img.get(i, j)) - mu[cL]);
        total++;
      }
    }
  }

  sigma[cL] = sqrt(sum / total);
  sum = 0;
  for (float mus : mu) sum = abs(mus - sum);
  for (int i = 0; i < sigma.length; i++) sigma[i] = sum;

  labels[cL].endDraw();
  colorMode(HSB, 100);
}

void mouseWheel(MouseEvent event) {
  currentLabel = ++currentLabel % labelsCount;
}

void updateGui() {
  if (labelsCount != prevLabelsCount) {
    prevLabelsCount = labelsCount;
    cp5.get(Slider.class, "currentLabelF").setRange(1, labelsCount).setNumberOfTickMarks(labelsCount);

    mu = new float[labelsCount];
    sigma = new float[labelsCount];
    labels = new PGraphics[labelsCount];

    for (int i = 0; i < labelsCount; i++)
      labels[i] = createGraphics(img.width, img.height);
  }

  //cp5.get(Slider.class, "currentLabelF").setValue(currentLabel);

  cp5.get(Textlabel.class, "mu").setText(arr2str(mu));
  cp5.get(Textlabel.class, "sigma").setText(arr2str(sigma));

  cp5.get(Slider.class, "stroke").setValue(stroke);

  canvas.beginDraw();

  canvas.background(0);

  canvas.image(img, 0, 0);

  for (int k = 0; k < labelsCount; k++) {
    labels[k].beginDraw();
    for (int i = 0; i < width; i++) {
      for (int j = 0; j < height; j++) {
        //print(red(labels[k].get(i, j)));
        if (red(labels[k].get(i, j)) != 0) {

          canvas.strokeWeight(1);
          canvas.colorMode(HSB, 100);
          color inpC = color(map(k, 0, labelsCount, 0, 100), 100, 100);
          canvas.stroke(inpC);
          canvas.fill(inpC);
          canvas.point(i, j);
        }
      }
    }
    labels[k].endDraw();
  }



  if (drawMode) {
    canvas.colorMode(HSB, 100);
    color inpC = color(map(currentLabel, 0, labelsCount, 0, 100), 100, 100);
    canvas.stroke(inpC);
    canvas.fill(inpC);
    canvas.strokeWeight(1);
    canvas.rectMode(CENTER);
    canvas.rect(mouseX, mouseY, stroke/2, stroke/2);
  }


  canvas.endDraw();
}

String arr2str(float[] arr) {
  String res = "";

  for (int i = 0; i < arr.length; i++) {
    if (i % 5 == 0)
      res += "\n";
    res += nf(arr[i], 0, 2) + "  ";
  }

  return res;
}

void startSim() {
  println("Begin Draw");
  drawMode = false;
  initModel = false;
}

void stopSim() {
  println("End Draw");
  drawMode = true;
  initModel = false;


  mu = new float[labelsCount];
  sigma = new float[labelsCount];
  labels = new PGraphics[labelsCount];

  for (int i = 0; i < labelsCount; i++)
    labels[i] = createGraphics(img.width, img.height);
}

void sig(float s) {
  sigma = new float[labelsCount];
  for (int i = 0; i < labelsCount; i++) {
    sigma[i] = s;
  }
}

void currentLabelF(int cL) {
  currentLabel = cL - 1;
}

void gui() {

  cp5 = new ControlP5(this);

  Group tA = cp5.addGroup("Parameters")
    .setBackgroundColor(color(10, 10, 10))
    .setBackgroundHeight(150)
    .setSize(300, 180)
    ;

  cp5.addSlider("labelsCount")
    .setPosition(10, 20)
    .setSize(180, 20)
    .setRange(2, 30)
    .setValue(labelsCount)
    .setNumberOfTickMarks(30)
    .moveTo(tA)
    ;

  cp5.addSlider("sig")
    .setSize(180, 20)
    .setPosition(10, 60)
    .setRange(0, 255)
    .moveTo(tA)
    ;

  cp5.addSlider("beta")
    .setSize(180, 20)
    .setPosition(10, 100)
    .setRange(0, 2)
    .setValue(beta)
    .moveTo(tA)
    ;

  Group lT = cp5.addGroup("Label training")
    .setBackgroundColor(color(10, 10, 10))
    .setBackgroundHeight(150)
    .setSize(300, 40)
    ;

  cp5.addSlider("currentLabelF")
    .setPosition(10, 20)
    .setSize(180, 20)
    .setRange(1, labelsCount)
    .setNumberOfTickMarks(labelsCount)
    .moveTo(lT)
    ;

  cp5.addSlider("stroke")
    .setPosition(10, 60)
    .setSize(180, 20)
    .setRange(1, MAX_STROKE)
    .setNumberOfTickMarks(int(MAX_STROKE))
    .moveTo(lT)
    ;

  Group sm = cp5.addGroup("sim")
    .setBackgroundColor(color(10, 10, 10))
    .setBackgroundHeight(110)
    .setSize(300, 240)
    ;

  cp5.addTextlabel("muL")
    .setText("Mu:")
    .setPosition(11, 10)
    .setColorValue(color(255, 255, 255))
    .setFont(createFont("Roboto", 12))
    .moveTo(sm)
    ;

  cp5.addTextlabel("mu")
    .setPosition(11, 20)
    .setColorValue(color(255, 255, 255))
    .setFont(createFont("Roboto", 12))
    .moveTo(sm)
    ;

  cp5.addTextlabel("sigmaL")
    .setText("Sigma^2:")
    .setPosition(11, 120)
    .setColorValue(color(255, 255, 255))
    .setFont(createFont("Roboto", 12))
    .moveTo(sm)
    ;

  cp5.addTextlabel("sigma")
    .setPosition(11, 130)
    .setColorValue(color(255, 255, 255))
    .setFont(createFont("Roboto", 12))
    .moveTo(sm)
    ;

  Group sc = cp5.addGroup("Sim control")
    .setBackgroundColor(color(10, 10, 10))
    .setBackgroundHeight(110)
    .setSize(300, 150)
    ;

  cp5.addBang("startSim")
    .setPosition(10, 20)
    .setSize(260, 40)
    .setTriggerEvent(Bang.RELEASE)
    .setLabel("Start")
    .moveTo(sc)
    ;

  cp5.addBang("stopSim")
    .setPosition(10, 80)
    .setSize(260, 40)
    .setTriggerEvent(Bang.RELEASE)
    .setLabel("Stop")
    .moveTo(sc)
    ;

  accordion = cp5.addAccordion("acc")
    .setPosition(0, 0)
    .setWidth(280)
    .addItem(tA)
    .addItem(lT)
    .addItem(sm)
    .addItem(sc)
    ;

  accordion.open(0, 1, 2, 3);
  accordion.setCollapseMode(Accordion.MULTI);
}
