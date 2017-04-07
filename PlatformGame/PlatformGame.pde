final int screenWidth = 512;
final int screenHeight = 432;

//determines how much will be "pushed down" towards the 
//ground when they're not standing on anything
float DOWN_FORCE = 2; 

//determines how much they will accelerate 
//while they're falling
float ACCELERATION = 1.3;

//determines what happens when we give players or NPCs
//an impulse (= some speed). With dampening set to "1", 
//the amount of speed is the same from one frame to the next. 
//"0.5" will halve the amount of speed per frame, and "0" 
//will kill off speed complete from one frame to the next.
float DAMPENING = 0.75;

void initialize() {
  PlatformLevel level = new PlatformLevel(width, height);
  addScreen("level", level);
  frameRate(30);
}

void reset() {
  print("RESET");
  clearScreens();
  PlatformLevel level = new PlatformLevel(width, height);
  addScreen("level", level);
}

class PlatformLevel extends Level {
  PlatformLevel(float levelWidth, float levelHeight) {
    super(levelWidth, levelHeight);
    addLevelLayer("layer", new PlatformLayer(this));
  }
}

class PlatformLayer extends LevelLayer {
  PlatformLayer(Level owner) {
    super(owner);
    setBackgroundColor(color(0,100,190));
    Boundary left = new Boundary(0, 0, 0, height);
    left.disable();
    Boundary right = new Boundary(width, height, width, 0);
    right.disable();
    Boundary top = new Boundary(width, 0, 0, 0);
    top.disable();
    Boundary bottom = new Boundary(0, height-25, width, height-25);
    
    addBoundary(left);
    addBoundary(right);
    addBoundary(top);
    addBoundary(bottom);
    
    //angled platforms
    addBoundary(new Boundary(50, height-55, width-50, height-105));
    addBoundary(new Boundary(50, height-180, width-100, height-130));
    addBoundary(new Boundary(100, height-205, width-50, height-255));
    addBoundary(new Boundary(50, height-330, width-100, height-280));
    addBoundary(new Boundary(100, height-355, width-50, height-405));
    showBoundaries = true;
    
    //add Bob to the world
    Bob bob = new Bob(width-50,height-50);
    addPlayer(bob);
    
    //Barrel barrel = new Barrel(width-170,0);
    //addInteractor(barrel);
    
    addForPlayerOnly(new WinCoin(width-55,15));
    
  }

  int lastSecond = 0;

  void spawnEnemies(){
    if (lastSecond != second()){
      if (second()%3 == 0) {
        for (int i = 0 ; i < 1 ; i++ ) {
          Barrel barrel = new Barrel(width-170,0);
          addInteractor(barrel);
        }
      }
      lastSecond = second();
    }
  }

}

class Bob extends Player {
  Bob(float x, float y) {
    super("Bob");
    setupStates();
    setPosition(x,y);
    
    //add forces to apply to Bob
    setForces(0,DOWN_FORCE);
    setAcceleration(0,ACCELERATION);
    setImpulseCoefficients(DAMPENING,DAMPENING);
    
    //handle Keys
    handleKey('A');
    handleKey('D');
    handleKey('W');
  }
  void setupStates() {
    // idling state
    addState(new State("idle", "graphics/Standing-mario.gif"));

    // running state
    addState(new State("running", "graphics/Running-mario.gif", 1, 4));

    // dead state O_O
    State dead = new State("dead", "graphics/Dead-mario.gif", 1, 2);
    dead.setAnimationSpeed(0.25f);
    dead.setDuration(100);
    addState(dead);   
    
    // jumping state
    State jumping = new State("jumping", "graphics/Jumping-mario.gif");
    jumping.setDuration(15);
    addState(jumping);

    // victorious state!
    State won = new State("won", "graphics/Standing-mario.gif");
    won.setDuration(240);
    addState(won);

    // default: just stand around doing nothing
    setCurrentState("idle");
  
  }
  
  void handleInput() {
    // we don't handle any input when we're dead~
    if(active.name=="dead" || active.name=="won") return;
    
    // what do we "do"? (i.e. movement wise)
    if(isKeyDown('A') || isKeyDown('D')) {
      if (isKeyDown('A')) {
        // when we walk left, we need to flip the sprite
        setHorizontalFlip(true);
        // walking left means we get a negative impulse along the x-axis:
        addImpulse(-2, 0);
      }
      if (isKeyDown('D')) {
        // when we walk right, we need to NOT flip the sprite =)
        setHorizontalFlip(false);
        // walking right means we get a positive impulse along the x-axis:
        addImpulse(2, 0);
      }
    }
    
    // if the jump key is pressed, and we're standing on something,
    // let's jump! 
    if(isKeyDown('W') && active.name!="jumping" && boundaries.size()>0) {
      // generate a massive impulse upward
      addImpulse(0,-25);
      // and make sure we look like we're jumping, too
      setCurrentState("jumping");
    }
    
    // and what do we look like when we do this?
    if (active.mayChange())
    {
      // if we're not jumping, but left or right is pressed,
      // make sure we're using the "running" state.
      if(isKeyDown('A') || isKeyDown('D')) {
        setCurrentState("running");
      }
      
      // if we're not actually doing anything,
      // then we change the state to "idle"
      else {
        setCurrentState("idle");
      }
    }
  }
  
  void overlapOccurredWith(Actor other, float[] direction) {
   if (other instanceof Barrel) {
     print("interaction");
     die();
   }
  }
  
  void die() {
   setCurrentState("dead");
   setInteracting(false);
   addImpulse(0,-30);
   setForces(0,3);
  }
  
  void handleStateFinished(State which) {
    print(which.name);
   if (which.name == "dead" || which.name == "won") {
     removeActor();
     reset();
   } else {
    setCurrentState("idle"); 
   }
  }
  
  void pickedUp(Pickup pickup) {
   if (pickup.name=="Win coin"){
     print("WIN");
     setCurrentState("won"); 
   }
  }
}

class Barrel extends Interactor {
  Barrel (float x, float y) {
   super("Barrel");
   setForces(0,DOWN_FORCE*2);
   setAcceleration(0,ACCELERATION*2);
   setImpulseCoefficients(DAMPENING,DAMPENING);
   setPosition(x,y);
   addState(new State("idle", "graphics/Regular-coin.gif",1,4));
  }
}

class BobPickup extends Pickup {
 BobPickup(String name, String spritesheet, int rows, int columns, float x, float y, boolean visible) {
  super(name, spritesheet, rows, columns, x, y, visible); 
 }
}

class WinCoin extends BobPickup {
 WinCoin(float x, float y) {
   super("Win coin", "graphics/Dragon-coin.gif", 1, 10, x, y, true);
 }
}