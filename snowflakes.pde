// Falling Snowflakes
// @helenkbailey, @sandsfish

import com.onformative.leap.*;
import com.leapmotion.leap.*;
import com.leapmotion.leap.Gesture;
import com.leapmotion.leap.Gesture.State;
import com.leapmotion.leap.Gesture.Type;
import com.leapmotion.leap.SwipeGesture;

float theta = radians(60);
float minHexRadius = 10;
float maxHexRadius = 50;
//float minFlakeRadius = 50;
float minFlakeRadius = 200;
float maxFlakeRadius = 200;
int initNumFlakes = 25;
int numFlakes = 50;
color flakeColor;
ArrayList<Flake> snowflakes;
float zMin = -2000;
float zMax = 0;
float Z_OFFSET = 900;

LeapMotionP5 leap;

// Forces
PVector gravity;
PVector antiGravity;
PVector wind;

// States
boolean daytime = false;
boolean pause = false;
boolean tornadoMode = false;
boolean rotateFlakes = false;
boolean antiGravityOn = false;
boolean zScatter = true;

float rotation = 0f; 

void setup() {
  size(displayWidth, displayHeight, OPENGL);
  noCursor();
  smooth();
  hint(DISABLE_DEPTH_TEST);

  leap = new LeapMotionP5(this);
  leap.enableGesture(Type.TYPE_SWIPE);

  gravity = new PVector(0f, 0.007);
  antiGravity = new PVector(0f, -0.07);
  wind = new PVector(0.0, 0.0);

  snowflakes = new ArrayList<Flake>();

  for (int i = 0; i < initNumFlakes; i++) {
    float tempZ = random(zMin, zMax);

    if (random(10) < 5) {
      float tHex = map(tempZ, zMin, zMax, 10, 80);
      flakeColor = color(int(random(30, 60)), int(random(60, 200)), int(random(210, 230)), tHex);
      snowflakes.add(new HexFlake(flakeColor, random(-Z_OFFSET, displayWidth+Z_OFFSET), random(-displayHeight, displayHeight), tempZ, int(random(minFlakeRadius, maxFlakeRadius))));
    } else {
      float tLine = map(tempZ, zMin, zMax, 10, 100);
      flakeColor = color(int(random(40, 60)), int(random(60, 200)), int(random(210, 230)), tLine);
      snowflakes.add(new LineFlake(flakeColor, random(-Z_OFFSET, displayWidth+Z_OFFSET), random(-displayHeight, displayHeight), tempZ, int(random(minFlakeRadius, maxFlakeRadius))));
    }
  }
}

void draw() {
  if (daytime) {
    background(240);
  } 
  else {
    background(0);
  }

  createSnowflakes();
  updateSnowflakes();
}

void createSnowflakes() {
  float tempZ = random(zMin, zMax);
  
  if (millis() % 30 == 0) {
    if (snowflakes.size() < numFlakes) {
      for (int i = 0; i < 2; i++) {
        float tHex = map(tempZ, zMin, zMax, 10, 80);
        flakeColor = color(int(random(30, 60)), int(random(60, 200)), int(random(210, 230)), tHex);
        snowflakes.add(new HexFlake(flakeColor, random(-Z_OFFSET, width+Z_OFFSET), random(-height-Z_OFFSET, -Z_OFFSET - maxFlakeRadius), tempZ, int(random(minFlakeRadius, maxFlakeRadius))));
        
        float tLine = map(tempZ, zMin, zMax, 10, 80);
        flakeColor = color(int(random(40, 60)), int(random(60, 200)), int(random(210, 230)), tLine);
        snowflakes.add(new LineFlake(flakeColor, random(-Z_OFFSET, width+Z_OFFSET), random(-height-Z_OFFSET, -Z_OFFSET - maxFlakeRadius), tempZ, int(random(minFlakeRadius, maxFlakeRadius))));
      }
    }
  }
}

void updateSnowflakes() {
  for (int i = snowflakes.size()-1; i >= 0; i--) {
    Flake flake = snowflakes.get(i);
    float tempZ = random(zMin, zMax);

    if (flake instanceof HexFlake) {
      HexFlake tHexFlake = (HexFlake)flake;
      if (tHexFlake.location.y > height+Z_OFFSET) {
        snowflakes.remove(i);
      }
    }
    else if (flake instanceof LineFlake) {
      LineFlake tLineFlake = (LineFlake)flake;
      if (tLineFlake.location.y > height+Z_OFFSET) {
        snowflakes.remove(i);
      }
    }

    if (tornadoMode) {
      translate(width/2, 0);
      rotation += 0.0001;
      rotateY(rotation);
    }

    if (!pause) {
      if (antiGravityOn) {
        flake.applyForce(antiGravity);
      } 
      else {
        flake.applyForce(gravity);
        flake.applyForce(wind);
      }

      flake.update();
    }

    flake.display();
  }
}

/**
 * Apply appropriate force upon Leap interaction
 * X Direction parameter of direction vector used for left/right
 */
public void swipeGestureRecognized(SwipeGesture gesture) {

  if (gesture.state() == State.STATE_STOP) {

    Vector direction = gesture.direction();

    for (int i = 0; i < snowflakes.size(); i++) {
      snowflakes.get(i).applyInteractionForce(direction);
    }

//    Gesture Position Class:  com.leapmotion.leap.Vector
//    println(gesture.position().getClass().getName().toString());

//    Right is Positive, Left is Negative
//    System.out.println("Direction X: " + gesture.direction().getX());
//    System.out.println("Position Z: " + gesture.position().getZ());
//    
//    System.out.println("Position: " + gesture.position());
//    System.out.println("Direction: " + gesture.direction());
//    System.out.println("Speed: " + gesture.speed());
//    System.out.println("Position: " + gesture.position());
//    System.out.println("Duration: " + gesture.durationSeconds() + "s");
  } 
  else if (gesture.state() == State.STATE_START) {
  } 
  else if (gesture.state() == State.STATE_UPDATE) {
  }
}

// Mode changes
public void keyPressed() {
  switch(key) { 
  case 'd':
    daytime = !daytime;
    break;
  case 't':
    tornadoMode = !tornadoMode;
    break;
  case 'r':
    rotateFlakes = !rotateFlakes;
    break;
  case ' ':
    pause = !pause;
    break;
  case 'a':
    antiGravityOn = !antiGravityOn;
    break;
  case 'z':
    zScatter = !zScatter;
  default:
    break;
  }
}

