import java.util.stream.IntStream;
import java.util.Arrays;

class MRF {
  Node[][] nodes;
  Node[][] nodesN;

  float sMax;
  float prevWcj;

  MRF(int w, int h) {
    initialize(w, h);
  }

  void initialize(int w, int h) {
    nodes = new Node[w][h];
    nodesN = new Node[w][h];

    for (int i = 0; i < w; i++) {
      for (int j = 0; j < h; j++) {
        int L = floor(random(labelsCount));
        nodes[i][j] = new Node(int(red(img.get(i, j))), L);
        nodesN[i][j] = new Node(int(red(img.get(i, j))), L);
      }
    }
    for (int k = 0; k < labelsCount; k++) {
      for (int i = 0; i < w; i++) {
        for (int j = 0; j < h; j++) {
          if (red(labels[k].get(i, j)) != 0) {
            nodes[i][j] = new Node(int(red(img.get(i, j))), k);
            nodesN[i][j] = new Node(int(red(img.get(i, j))), k);

            nodes[i][j].visited = true;
            nodes[i][j].movible = false;
            nodesN[i][j].visited = true;
          }
        }
      }
    }

    for (int i = 0; i < w; i++) {
      for (int j = 0; j < h; j++) {
        nodes[i][j].blanket = getBlanketNodes(i, j, w, h, nodes);
        nodesN[i][j].blanket = getBlanketNodes(i, j, w, h, nodesN);
      }
    }
  }

  void ICMIteration(float beta, float[] mu, float[] sigma, int l) {
    for (int i = 0; i < nodes.length; i++) {
      for (int j = 0; j < nodes[0].length; j++) {
        float mxLE = 0;
        int mxL = 0;

        Node node = nodes[i][j];

        int stL = node.L;

        for (int m = 0; m < l; m++) {
          node.L = m;
          float e = node.nBEnergy(beta, mu[m], sigma[m]);
          node.L = stL;
          if (e > mxLE) {
            mxLE = e;
            mxL = m;
          }
        }

        nodes[i][j].L = mxL;
      }
    }
  }

  void fmax(float[] mu, float[] sigma) {
    for (int i = 0; i < nodes.length; i++) {
      for (int j = 0; j < nodes[0].length; j++) {
        Node node = nodes[i][j];
        float emin = 0;
        for (int k = 0; k < labelsCount; k++) {
          float e = (1 / (sqrt(2 * PI) * sigma[node.L])) - exp(-((node.O - mu[node.L])/( 2 * sigma[node.L] * sigma[node.L])));
          if (e > emin) {
            emin = e;
            node.L = k;
          }
        }
      }
    }
  }

  void gICMIteration(float[] mu, float[] sigma, int l, int k, int kgicm, float W, float beta) {
    for (int i = 0; i < nodes.length; i++) {
      for (int j = 0; j < nodes[0].length; j++) {
        Node node = nodes[i][j];

        if (!node.movible)
          continue;

        //float smax = node.smax(sigma);

        float W0 = min(1/kgicm, W);
        //float wcj = 0;

        float mxLE = 0;
        int mxL = 0;

        int stL = node.L;

        for (int m = 0; m < l; m++) {
          node.L = m;
          //float e = node.nBEnergy(beta, mu[m], sigma[m]);
          float e = node.gEnergyUp(sigma[m], mu[m], node.L, W0, k, kgicm, beta);
          //println(e);
          node.L = stL;
          if (e > mxLE) {
            mxLE = e;
            mxL = m;
          }
        }

        nodes[i][j].L = mxL;
        nodes[i][j].visited = true;
      }
    }
  }

  float systemEnergy(float[] sigma, float[] mu, float beta) {
    float e = 0;

    for (int i = 0; i < nodes.length; i++) {
      for (int j = 0; j < nodes[0].length; j++) {
        Node node = nodes[i][j];
        e += node.nBEnergy(beta, sigma[node.L], mu[node.L]);
      }
    }

    return e;
  }

  void show() {
    for (int i = 0; i < nodes.length; i++) {
      for (int j = 0; j < nodes[0].length; j++) {
        if (nodes[i][j].movible)
          nodes[i][j].visited = false;

        colorMode(HSB, 100);
        color inpC = color(map(nodes[i][j].L, 0, labelsCount, 0, 100), 100, 100);
        stroke(inpC);
        fill(inpC);
        strokeWeight(1);
        point(280 + img.width + i, j);
      }
    }
  }

  Node[] getBlanketNodes(int i, int j, int h, int w, Node[][] base) {
    if (i == 0) {
      if (j == 0) {
        return new Node[]{
          getNodeToTheBottom(i, j, base),
          getNodeToTheRight(i, j, base),
        };
      } else if (j == w - 1) {
        return new Node[]{
          getNodeToTheBottom(i, j, base),
          getNodeToTheLeft(i, j, base),
        };
      }
      return new Node[]{
        getNodeToTheBottom(i, j, base),
        getNodeToTheLeft(i, j, base),
        getNodeToTheRight(i, j, base),
      };
    } else if (j == 0) {
      if (i == h - 1) {
        return new Node[]{
          getNodeToTheTop(i, j, base),
          getNodeToTheRight(i, j, base),
        };
      }
      return new Node[]{
        getNodeToTheTop(i, j, base),
        getNodeToTheBottom(i, j, base),
        getNodeToTheRight(i, j, base),
      };
    } else if (i == h - 1) {
      if (j == w - 1) {
        return new Node[]{
          getNodeToTheTop(i, j, base),
          getNodeToTheLeft(i, j, base),
        };
      }
      return new Node[]{
        getNodeToTheTop(i, j, base),
        getNodeToTheLeft(i, j, base),
        getNodeToTheRight(i, j, base),
      };
    } else if (j == w - 1) {
      return new Node[]{
        getNodeToTheTop(i, j, base),
        getNodeToTheLeft(i, j, base),
        getNodeToTheBottom(i, j, base),
      };
    }

    return new Node[]{
      getNodeToTheTop(i, j, base),
      getNodeToTheBottom(i, j, base),
      getNodeToTheLeft(i, j, base),
      getNodeToTheRight(i, j, base),
    };
  }

  Node getNodeToTheTop(int i, int j, Node[][] base) {
    return base[i - 1][j];
  }

  Node getNodeToTheBottom(int i, int j, Node[][] base) {
    return base[i + 1][j];
  }

  Node getNodeToTheRight(int i, int j, Node[][] base) {
    return base[i][j + 1];
  }

  Node getNodeToTheLeft(int i, int j, Node[][] base) {
    return base[i][j - 1];
  }
}
