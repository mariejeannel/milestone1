private final int WIDTH = 800;
private final int HEIGHT = 800;

void setup(){
  size(WIDTH, HEIGHT, P3D);
}

private final float g = 0.0981;
private final float eps = 0.01;

private final float DIM_BOX_X = 300;
private final float DIM_BOX_Y = 20;
private final float DIM_BOX_Z = 300;
private float angleX = 0;
private float angleZ = 0;
private float angleY = 0;

private final float SPHERE_RADIUS = 10;
private PVector sphereLocation = new PVector(0, -SPHERE_RADIUS-DIM_BOX_Y/2, 0);
private PVector sphereSpeed = new PVector(0, 0, 0);

private final float ANGLE_VARIATION = PI/60;
private float coefWheel = 1;
private final float REBOUND_COEFF = 0.95;
private final float mu = 0.995; 

private final float CYLINDER_BASE_SIZE = Cylinder.CYLINDER_BASE_SIZE;
private final float CYLINDER_HEIGHT = Cylinder.CYLINDER_HEIGHT; 
private final int CYLINDER_RESOLUTION = Cylinder.CYLINDER_RESOLUTION;
private ArrayList<Cylinder> cylinders = new ArrayList<Cylinder>();
private boolean pause = false;


void draw(){
  lights();
  background(255, 255, 255);
  translate(WIDTH/2, HEIGHT/2);
  
  if(pause){
    for(int i=0; i<cylinders.size(); i++){
      shape(cylinders.get(i).cylinder);
    }
    rotateX(-PI/2);
  }

  else {
    rotateX(angleX);
    //rotateY(angleY);
    rotateZ(angleZ);
  }

  box(DIM_BOX_X, DIM_BOX_Y, DIM_BOX_Z);
    
  if(!pause){
    translate(sphereLocation.x, sphereLocation.y, sphereLocation.z);  
    sphere(SPHERE_RADIUS);
    translate(-sphereLocation.x, -sphereLocation.y, -sphereLocation.z);
    sphereRoll();

    rotateX(PI/2);
    for(int i =0; i<cylinders.size(); i++){
      shape(cylinders.get(i).cylinder);
    }
    translate(-WIDTH/2, -HEIGHT/2);
  }
}

// method to add new cylinders to our list of cylinders that we draw
void addCylinder(float centerX, float centerZ){
  Cylinder newCylinder = new Cylinder(centerX, centerZ);
  float distanceWithBall = newCylinder.center.dist(sphereLocation);
  // we ensure that the cylinder that we want to create is not outside of the box
  if(centerX + CYLINDER_BASE_SIZE/2 < DIM_BOX_X/2 && centerX - CYLINDER_BASE_SIZE/2 > -DIM_BOX_X/2
  && centerZ + CYLINDER_BASE_SIZE/2 < DIM_BOX_Z/2 && centerZ - CYLINDER_BASE_SIZE/2 > -DIM_BOX_Z/2){
    /* we check if the cylinder that we want to create
       will not overlap with another cylinder which has been already created... */
    boolean isDistinct = true;
    for(Cylinder thatCylinder : cylinders){
      float distance = sqrt(pow(thatCylinder.center.x - centerX, 2) + 
                            pow(thatCylinder.center.z - centerZ, 2));
      if(distance - 2*CYLINDER_BASE_SIZE < 0){
        isDistinct = false;
      }
    }
    // ...if not and also if it's not on the ball, we add it to our list
    if(isDistinct && distanceWithBall > SPHERE_RADIUS + CYLINDER_BASE_SIZE){
      cylinders.add(new Cylinder(centerX, centerZ).build());
    }
    else {
      println("Cannot create a cylinder here : conflict of position");
    }
  }
}

// method to simulate the rolling of the ball
void sphereRoll() {

  checkEdges();
  checkCylindersBorder();
  
  PVector gravityForce = new PVector(sin(angleZ)*g, 0, -sin(angleX)*g);
  sphereSpeed.add(gravityForce);
  sphereSpeed.mult(mu);
  sphereLocation.add(sphereSpeed);
}

// method to simulate the collisions with the border of the box
void checkEdges() {
    
  PVector cheatLeft = new PVector(eps * SPHERE_RADIUS, 0, 0);
  PVector cheatRight = new PVector(-eps * SPHERE_RADIUS, 0, 0);
  PVector cheatDown = new PVector(0, 0, eps * SPHERE_RADIUS);
  PVector cheatUp = new PVector(0, 0, -eps * SPHERE_RADIUS );
  
  if(sphereLocation.x + SPHERE_RADIUS > (DIM_BOX_X/2)){
    sphereSpeed.x *= -REBOUND_COEFF;
    sphereLocation.add(cheatRight);
  }
  if(sphereLocation.x - SPHERE_RADIUS < -(DIM_BOX_X/2)){
    sphereSpeed.x *= -REBOUND_COEFF;
    sphereLocation.add(cheatLeft);
  } 
  
  if(sphereLocation.z + SPHERE_RADIUS > (DIM_BOX_Z/2)){
    sphereSpeed.z *= -REBOUND_COEFF;
    sphereLocation.add(cheatUp);
  }
  if(sphereLocation.z - SPHERE_RADIUS < -(DIM_BOX_Z/2)){ 
    sphereSpeed.z *= -REBOUND_COEFF;
    sphereLocation.add(cheatDown);
  }
}

// method to simulate the collisions with the cylinders
void checkCylindersBorder(){
  // for all cylinder that we have built...
  for(Cylinder thatCylinder : cylinders){
    //...we compute the distance between the sphere and that cylinder
    float distance = sphereLocation.dist(thatCylinder.center);
    // and we check if there is a collision or not 
    if(distance <= SPHERE_RADIUS + CYLINDER_BASE_SIZE){
      PVector n = new PVector(sphereLocation.x - thatCylinder.center.x, 
                              sphereLocation.y - thatCylinder.center.y, 
                              sphereLocation.z - thatCylinder.center.z);
      n.normalize();
      n.mult(-2*n.dot(sphereSpeed));
      sphereSpeed.add(n);
      sphereSpeed.mult(REBOUND_COEFF);
      
      // as for the edges of the box, we add a "cheat" to avoid bugs
      PVector cheat = new PVector(sphereLocation.x - thatCylinder.center.x, 
                                  sphereLocation.y - thatCylinder.center.y, 
                                  sphereLocation.z - thatCylinder.center.z);
      cheat.mult(eps);
      sphereLocation.add(cheat);
    }
  }
}

/* Methods for keyboard and mouse actions 
======================================================================== */

// Rotation around X and Z with mouse drag by using the mouse drag
void mouseDragged(){
  
  if(pmouseX < mouseX){
    angleZ += coefWheel * ANGLE_VARIATION;
    if(angleZ > PI/3){
      angleZ = PI/3;
      
    }
  }
  else if(pmouseX > mouseX){
    angleZ -= coefWheel * ANGLE_VARIATION;
    if(angleZ < -PI/3){
      angleZ = -PI/3;
    }
  }
  
  if(pmouseY < mouseY){
    angleX -= coefWheel * ANGLE_VARIATION;
    if(angleX < -PI/3){
      angleX = -PI/3;
    }
  }
  else if(pmouseY > mouseY){
    angleX += coefWheel * ANGLE_VARIATION;
    if(angleX > PI/3){
      angleX = PI/3;
    }
  }
}

// speed up or slow down rotation by using the mouse wheel 
void mouseWheel(MouseEvent event){
  
  float e = event.getCount();
  if(e>0) {
    if(coefWheel < 2) {
      coefWheel += 0.1;
    }
    else coefWheel = 2;
  }
  else if(e<0){
    if(coefWheel > 0.2) {
      coefWheel -= 0.1;
    }
    else coefWheel = 0.2;
  }
}

void keyPressed() {
  if (key == CODED) {
    // Rotation around y axis with left and right arrows of the keyboard
    if (keyCode == RIGHT) {
      angleY += coefWheel * ANGLE_VARIATION;
    } 
    if (keyCode == LEFT) {
      angleY -= coefWheel * ANGLE_VARIATION;
    }
    /* put the game in pause mode if the key SHIFT is pressed 
     in order to put the cylinders on the box */
    if(keyCode == SHIFT){
      pause = true;
    }
  }
}

/* put back the game at its previous configuration before we press the SHIFT key
   but more with the added cylinders, when we release this key */
void keyReleased(){
  if(keyCode == SHIFT){
      pause = false;
  }
}

/* draw a cylinder with center position the position of the mouse when we press it 
   if we are in pause mode */
void mousePressed(){
  if(pause){
    addCylinder(pmouseX - WIDTH/2, pmouseY - HEIGHT/2);
  }
}


/* Class to create and build the cylinders
======================================================================== */

class Cylinder {

  private final static float CYLINDER_BASE_SIZE = 10; 
  private final static float CYLINDER_HEIGHT = 40; 
  private final static int CYLINDER_RESOLUTION = 40;

  private PVector center;
  private PShape cylinder;

  //constructor of the cylinder of center position (centerX, -SPHERE_RADIUS-DIM_BOX_Y/2, centerZ)
  public Cylinder(float centerX, float centerZ){
    this.center = new PVector(centerX, -SPHERE_RADIUS-DIM_BOX_Y/2, centerZ);
    this.cylinder = new PShape();
  }
  
  //method to create a cylinder of center position (centerX, centerY)
  public Cylinder build(){
    
    PShape openCylinder = new PShape(); 
    PShape downFace = new PShape(); 
    PShape upFace = new PShape();
      
    float angle;
    float[] x = new float[CYLINDER_RESOLUTION + 1]; 
    float[] y = new float[CYLINDER_RESOLUTION + 1];
    //get the x and y position on a circle for all the sides
    for(int i = 0; i < x.length; i++) {
      angle = (TWO_PI / CYLINDER_RESOLUTION) * i; 
      x[i] = sin(angle) * CYLINDER_BASE_SIZE + center.x; 
      y[i] = cos(angle) * CYLINDER_BASE_SIZE + center.z;
    }
    
    openCylinder = createShape();
    openCylinder.beginShape(QUAD_STRIP);
    // create the border of the cylinder
    for(int i = 0; i < x.length; i++) { 
      openCylinder.vertex(x[i], y[i], DIM_BOX_Y/2); 
      openCylinder.vertex(x[i], y[i], DIM_BOX_Y/2 + CYLINDER_HEIGHT);
    }
    openCylinder.endShape();
    
    downFace = createShape();
    downFace.beginShape(TRIANGLES);
    // create the down face of the cylinder
    for(int i = 0; i < x.length-1; i++) { 
      downFace.vertex(center.x, center.z, DIM_BOX_Y/2);
      downFace.vertex(x[i], y[i], DIM_BOX_Y/2); 
      downFace.vertex(x[i+1] , y[i+1], DIM_BOX_Y/2); 
    }
    downFace.endShape();
    
    upFace = createShape();
    upFace.beginShape(TRIANGLES);
    // create the up face of the cylinder
    for(int i = 0; i < x.length-1; i++) { 
      upFace.vertex(center.x, center.z, DIM_BOX_Y/2 + CYLINDER_HEIGHT);
      upFace.vertex(x[i], y[i], DIM_BOX_Y/2 + CYLINDER_HEIGHT); 
      upFace.vertex(x[i+1], y[i+1], DIM_BOX_Y/2 + CYLINDER_HEIGHT); 
    }
    upFace.endShape();
    
    // create the closed cylinder that we need 
    cylinder = createShape(GROUP);
    cylinder.addChild(openCylinder);
    cylinder.addChild(downFace);
    cylinder.addChild(upFace);
    //return the closed cylinder which we just created
    return this;
  }
}
