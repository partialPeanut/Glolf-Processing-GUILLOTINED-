interface Effect {
  boolean procCheck();
  boolean procCheck(PlayState ps);
}

interface ModifyEffect extends Effect {
  float changeFactor(FactorType ct);
  float changeFactor(FactorType ct, PlayState ps);
}

interface BespokeEffect extends Effect {
  boolean procCheck(PlayState ps, EventPhase before);
  void doEffect();
  GlolfEvent effectEvent();
}

interface OverrideEffect extends Effect {
  boolean procCheck(PlayState ps, EventPhase insteadOf);
  void doEffect();
  GlolfEvent effectEvent();
}
