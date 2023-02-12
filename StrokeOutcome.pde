static class StrokeOutcome {
  StrokeOutcomeType type;
  Terrain newTerrain;
  float distance;
  float angle;

  StrokeOutcome(StrokeOutcomeType sot, Terrain nt, float d, float a) {
    type = sot;
    newTerrain = nt;
    distance = d;
    angle = a;
  }
}
