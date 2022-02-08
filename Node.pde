class Node {

  Node[] blanket;

  int O;
  int L;

  boolean visited = false;
  boolean movible = true;

  Node(int O, int L) {
    this.O = O;
    this.L = L;
  }

  float individualPotential(float sigma, float mu) {
    return (1/2) * log(sigma * sigma) + pow(this.O - mu, 2) / (2.0 * sigma * sigma);
  }

  float pairPotential(float L1, float L2) {
    return L1 == L2 ? -1 : 0;
  }

  float blanketPotential(float beta, int L) {
    float sum = 0;
    for (Node n : this.blanket)
      sum += pairPotential(L, n.L) * beta;
    return sum ;
  }

  float nBEnergy(float beta, float sigma, float mu) {
    return individualPotential(sigma, mu) + blanketPotential(beta, this.L);
  }

  float gpairPotential(float sigma, float L1, float L2, float Oj) {
    return L1 == L2 ? -1 : 0;
  }

  float smax(float[] sigma) {
    float max = 0;
    for (Node n : this.blanket) {
      float pp = gpairPotential(sigma[n.L], this.L, n.L, n.O);
      if(pp > max) max = pp;
    }
    return max;
  }
  
  float gblanketPotential(float sigma, int L, float W0, int k, int kgicm, float beta) {
    float sum = 0;
    float wcj = 0;
    for (Node n : this.blanket) {
      if(k >= 1 && k <= kgicm && n.visited) wcj = W0 * (kgicm / (kgicm - k + 1));
      if(k >= kgicm && n.visited) wcj = 1;
      sum += gpairPotential(sigma, L, n.L, n.O) * wcj * beta;
    }
    return sum ;
  }

  float gEnergyUp(float sigma, float mu, int L, float W0, int k, int kgicm, float beta) {
    return individualPotential(sigma, mu) + gblanketPotential(sigma, L, W0, k, kgicm, beta);
  }
}
