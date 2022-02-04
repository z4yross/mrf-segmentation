class Node {

  Node[] blanket;

  float bgProb;
  float fgProb;

  boolean isLabeled;
  boolean isBg;

  int O;
  int L;

  Node(int O) {
    this.O = O;
    this.L = random(10) >= 5? 1 : 0;
  }

  Node(int O, boolean isLabeled, boolean isBg) {
    this.O = O;
    this.L = random(10) >= 5 ? 1 : 0;
    this.isLabeled = isLabeled;
    this.isBg = isBg;
  }

  float individualPotential(int L) {
    if (isLabeled) {
      if (isBg)
        return L == 0 ? 0: Float.POSITIVE_INFINITY;
      else
        return L == 0 ? Float.POSITIVE_INFINITY: 0;
    } else {
      return L == 0 ? this.O : 255 - this.O;
    }
  }

  float pairPotential(float lambda, float L1, float O1, float L2, float O2) {
    return lambda * abs(L1 - L2) * exp(-(pow(O1 - O2, 2) / (2 * (O1 * O1))));
  }

  float blanketPotential(float lambda, int L) {
    float sum = 0;
    for (Node n : this.blanket)
      sum += pairPotential(lambda, L, this.O, n.L, n.O);
    return sum;
  }

  void setEnergy(float lambda) {
    float p = -exp(individualPotential(this.L) + blanketPotential(lambda, this.L));
    if (this.L == 0) {
      bgProb = p;
      fgProb = -exp(individualPotential(1) + blanketPotential(lambda, 1));
    } else {
      fgProb = p;
      bgProb = -exp(individualPotential(0) + blanketPotential(lambda, 0));
    }


    //fgProb = exp(individualPotential(1) + blanketPotential(lambda, 1));

    this.L = bgProb > fgProb ? 0 : 1;
  }
}
