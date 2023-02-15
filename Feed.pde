class Feed {
  ArrayList<GlolfEvent> everyEvent = new ArrayList<GlolfEvent>();
  
  Feed() {
    everyEvent.add(new EventVoid());
  }
  
  void addEvent(GlolfEvent e) { everyEvent.add(e); }
  GlolfEvent lastEvent() { return everyEvent.get(everyEvent.size()-1); }
  GlolfEvent lastLastEvent() { return everyEvent.get(everyEvent.size()-2); }
  void removeLastEvent() { everyEvent.remove(lastEvent());}
}
