class MRF {
  Node[][] nodes;

  MRF() {
    initialize(width, height);
  }

  void initialize(int width, int height) {
    nodes = new Node[width][height];

    for (int i = 0; i < width; i++) {
      for (int j = 0; j < height; j++) {
        if (fg_labels.get(i, j) == color(255))
          nodes[i][j] = new Node(0, true, false);
        else if (bg_labels.get(i, j) == color(255))
          nodes[i][j] = new Node(255, true, true);
        else
          nodes[i][j] = new Node(int(red(img.get(i, j))));
      }
    }

    for (int i = 0; i < width; i++) {
      for (int j = 0; j < height; j++) {
        if (i ==0) {
          if (j == 0) {
            nodes[i][j].blanket = new Node[]{
              nodes[i][j + 1],
              nodes[i + 1][j],
            };
          }
          else if (j == height - 1) {
            nodes[i][j].blanket = new Node[]{
              nodes[i][j - 1],
              nodes[i + 1][j],
            };
          } else {
            nodes[i][j].blanket = new Node[]{
              nodes[i][j + 1],
              nodes[i][j - 1],
              nodes[i + 1][j],
            };
          }
        } else if (i == width - 1) {
          if (j == 0) {
            nodes[i][j].blanket = new Node[]{
              nodes[i][j + 1],
              nodes[i - 1][j],
            };
          }
          else if (j == height - 1) {
            nodes[i][j].blanket = new Node[]{
              nodes[i][j - 1],
              nodes[i - 1][j],
            };
          } else {
            nodes[i][j].blanket = new Node[]{
              nodes[i][j + 1],
              nodes[i][j - 1],
              nodes[i - 1][j],
            };
          }
        } else if (j == 0) {
          if (i == 0) {
            nodes[i][j].blanket = new Node[]{
              nodes[i][j + 1],
              nodes[i + 1][j],
            };
          }
          else if (i == width - 1) {
            nodes[i][j].blanket = new Node[]{
              nodes[i][j + 1],
              nodes[i - 1][j],
            };
          } else {
            nodes[i][j].blanket = new Node[]{
              nodes[i + 1][j],
              nodes[i][j + 1],
              nodes[i - 1][j],
            };
          }
        } else if (j == height - 1) {
          if (i == 0) {
            nodes[i][j].blanket = new Node[]{
              nodes[i][j - 1],
              nodes[i + 1][j],
            };
          }
          else if (i == width - 1) {
            nodes[i][j].blanket = new Node[]{
              nodes[i][j - 1],
              nodes[i - 1][j],
            };
          } else {
            nodes[i][j].blanket = new Node[]{
              nodes[i + 1][j],
              nodes[i][j - 1],
              nodes[i - 1][j],
            };
          }
        } else {
          nodes[i][j].blanket = new Node[]{
            nodes[i - 1][j],
            nodes[i + 1][j],
            nodes[i][j + 1],
            nodes[i][j - 1],
          };
        }
      }
    }
  }

  void gibbs(float lambda) {
    res.beginDraw();
    for (int i = 0; i < width; i++) {
      for (int j = 0; j < height; j++) {
        nodes[i][j].setEnergy(lambda);
        color c = nodes[i][j].L == 0 ? color(0, 0, 255) : color(255, 0, 0);
        //println(red(c), blue(c), nodes[i][j].L, i, j);
        res.stroke(c);
        res.strokeWeight(1);
        res.point(i, j);
      }
    }
    res.endDraw();
  }
}
