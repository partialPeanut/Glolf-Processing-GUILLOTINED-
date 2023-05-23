EventAggression doEventAggression(GlolfEvent le) {
  EventAggression ea = (EventAggression)le;
  PlayState lastPS = feed.lastEvent().playState();
  ea.playState = lastPS.balls == null ? new PlayState() : new PlayState(lastPS);
  ea.nextPhase = feed.lastEvent().nextPhase();
  
  Ball knockedBall = ea.playState.ballOf(ea.knockedPlayer);
  knockedBall.distance += random(1,5)*ea.knockingPlayer.yeetness;
  knockedBall.terrain = Calculation.calculatePostRollTerrain(ea.playState, knockedBall);
  
  return ea;
}

EventGuillotine doEventGuillotine(GlolfEvent le) {
  EventGuillotine eg = (EventGuillotine)le;
  PlayState lastPS = feed.lastEvent().playState();
  eg.playState = lastPS.balls == null ? new PlayState() : new PlayState(lastPS);
  eg.nextPhase = feed.lastEvent().nextPhase();
  
  ArrayList<Player> theRich = eg.theRich;
  for (Player r : theRich) { leagueManager.killPlayer(r, eg.playState); }
  
  int sinsEach = floor(eg.totalSins / playerManager.livePlayers.size());
  for (Player p : playerManager.livePlayers) {
    playerManager.giveSins(p, sinsEach);
  }
  
  if (playerManager.hasRich()) {
    ArrayList<Player> newRich = playerManager.bourgeoisie();
    int ts = 0;
    for (Player r : newRich) { ts += r.networth; }
    leagueManager.interruptWith(new EventGuillotine(newRich, ts));
  }
  
  return eg;
}

EventKomodoAttack doEventKomodoAttack(GlolfEvent le) {
  EventKomodoAttack ka = (EventKomodoAttack)le;
  PlayState lastPS = feed.lastEvent().playState();
  ka.playState = lastPS.balls == null ? new PlayState() : new PlayState(lastPS);
  ka.nextPhase = feed.lastEvent().nextPhase();
  
  playerManager.poisonPlayer(ka.player, ka.playState.hole.par + floor(Slope.loggy(0,4,ka.player.scrappiness)));
  
  return ka;
}

EventKomodoKill doEventKomodoKill(GlolfEvent le) {
  EventKomodoKill kk = (EventKomodoKill)le;
  PlayState lastPS = feed.lastEvent().playState();
  kk.playState = lastPS.balls == null ? new PlayState() : new PlayState(lastPS);
  kk.nextPhase = feed.lastEvent().nextPhase();
  
  kk.playState = leagueManager.killPlayer(kk.player, kk.playState);
  
  return kk;
}

EventMirageSwap doEventMirageSwap(GlolfEvent le) {
  EventMirageSwap ms = (EventMirageSwap)le;
  PlayState lastPS = feed.lastEvent().playState();
  PlayState newPS = lastPS.balls == null ? new PlayState() : new PlayState(lastPS);
  ms.nextPhase = feed.lastEvent().nextPhase();
  
  Ball aBall = newPS.randomActiveBallWithAutism();
  Ball bBall = newPS.randomActiveBallWithAutism();
  
  if (aBall == null || bBall == null) return null;
  
  int aIndex = newPS.balls.indexOf(aBall);
  int bIndex = newPS.balls.indexOf(bBall);
  
  newPS.balls.set(aIndex, bBall);
  newPS.balls.set(bIndex, aBall);
  
  ms.playState = newPS;
  ms.playerA = aBall.player;
  ms.playerB = bBall.player;
  
  return ms;
}

EventMosquitoBite doEventMosquitoBite(GlolfEvent le) {
  EventMosquitoBite mb = (EventMosquitoBite)le;
  PlayState lastPS = feed.lastEvent().playState();
  mb.playState = lastPS.balls == null ? new PlayState() : new PlayState(lastPS);
  mb.nextPhase = feed.lastEvent().nextPhase();
  
  playerManager.changePlayerStat(mb.player, mb.stat, -0.01);
  
  return mb;
}

EventPlayerReplace doEventPlayerReplace(GlolfEvent le) {
  EventPlayerReplace epr = (EventPlayerReplace)le;
  PlayState lastPS = feed.lastEvent().playState();
  epr.playState = lastPS.balls == null ? new PlayState() : new PlayState(lastPS);
  epr.nextPhase = feed.lastEvent().nextPhase();
  
  playerManager.killPlayer(epr.playerA);
  tourneyManager.replacePlayer(epr.playerA, epr.playerB);
  for (Ball b : epr.playState.balls) {
    if (b.player == epr.playerA) {
      b.player = epr.playerB;
    }
  }
  
  return epr;
}

EventQuantumSquid doEventQuantumSquid(GlolfEvent le) {
  EventQuantumSquid qs = (EventQuantumSquid)le;
  PlayState lastPS = feed.lastEvent().playState();
  PlayState squidPlayState = lastPS.balls == null ? new PlayState() : new PlayState(lastPS);
  qs.nextPhase = feed.lastEvent().nextPhase();
  
  Ball oldBall = qs.oldBall;
  playerManager.erasePlayer(oldBall.player);
  Player up = playerManager.addPlayerClone(oldBall.player);
  Player down = playerManager.addPlayerClone(oldBall.player);
  
  playerManager.appendSuffix(up, "UP");
  playerManager.appendSuffix(down, "DOWN");
  playerManager.entanglePlayers(up, down);
  
  for (Ball b : squidPlayState.balls) {
    if (b.player == oldBall.player) {
      b.player = up;
      Ball downBall = new Ball(oldBall);
      downBall.player = down;
      
      squidPlayState.balls.add(squidPlayState.balls.indexOf(b)+1, downBall);
      break;
    }
  }
  
  tourneyManager.replacePlayer(oldBall.player, up, down);
  
  qs.playState = squidPlayState;
  qs.playerUp = up;
  qs.playerDown = down;
  
  return qs;
}

EventQuantumUnsquid doEventQuantumUnsquid(GlolfEvent le) {
  EventQuantumUnsquid qu = (EventQuantumUnsquid)le;
  PlayState lastPS = feed.lastEvent().playState();
  qu.playState = lastPS.balls == null ? new PlayState() : new PlayState(lastPS);
  qu.nextPhase = feed.lastEvent().nextPhase();
  
  Player bestie = playerManager.entangledWith(qu.oldPlayer);
  playerManager.removeMod(bestie, Mod.ENTANGLED);
  playerManager.applyMod(bestie, Mod.HARMONIZED);
  playerManager.detanglePlayer(bestie);
  playerManager.removeSuffix(bestie, "UP");
  playerManager.removeSuffix(bestie, "DOWN");
  
  qu.playState = leagueManager.erasePlayer(qu.oldPlayer, qu.playState);
  qu.restoredPlayer = bestie;
  
  return qu;
}

EventTempestSwap doEventTempestSwap(GlolfEvent le) {
  EventTempestSwap ts = (EventTempestSwap)le;
  PlayState lastPS = feed.lastEvent().playState();
  PlayState newPS = lastPS.balls == null ? new PlayState() : new PlayState(lastPS);
  ts.nextPhase = feed.lastEvent().nextPhase();
  
  ArrayList<Ball> abs = newPS.activeBalls();
  if (abs.size() < 2) return null;
  
  Ball aBall = newPS.randomActiveBallWithAutism();
  Ball bBall = newPS.randomActiveBallWithAutismExceptFor(aBall);
  
  if (aBall == null || bBall == null || (aBall.terrain == Terrain.TEE && bBall.terrain == Terrain.TEE)) return null;
  
  float squidChance = 0.001 * Slope.loggy(0.5, 1.5, aBall.player.autism);
  if (!aBall.player.mods.contains(Mod.HARMONIZED) && random(0,1) < squidChance) {
    bBall = aBall;
    if (aBall.player.mods.contains(Mod.ENTANGLED)) leagueManager.interruptWith(new EventQuantumUnsquid(aBall.player));
    else leagueManager.interruptWith(new EventQuantumSquid(aBall));
  }
  else {
    Ball aBallCopy = new Ball(aBall);
    aBall.teleportTo(bBall);
    bBall.teleportTo(aBallCopy);
  }
  
  ts.playState = newPS;
  ts.playerA = aBall.player;
  ts.playerB = bBall.player;
  
  return ts;
}

EventWormBattle doEventWormBattle(GlolfEvent le) {
  EventWormBattle wb = (EventWormBattle)le;
  PlayState lastPS = feed.lastEvent().playState();
  wb.playState = lastPS.balls == null ? new PlayState() : new PlayState(lastPS);
  wb.nextPhase = feed.lastEvent().nextPhase();
  
  float winChance = Slope.loggy(0, 1, wb.ball.player.scrappiness);
  if (random(1) < winChance) {
    wb.won = true;
    tourneyManager.holeControl.orgasm(wb.playState, wb.ball);
  }
  else {
    wb.won = false;
    wb.ball.reset(wb.playState.hole.realLength);
  }
  
  return wb;
}
