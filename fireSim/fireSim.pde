// Vector Class
class Vector {
  float x;
  float y;
  float z;
  
  Vector(float xtemp,float ytemp,float ztemp) {
    x = xtemp;
    y = ytemp;
    z = ztemp;
  }
  
  Vector() {
  x = 0;
  y = 0;
  z = 0;
  }
  
  float getX() {
    return x;
  }
  
  float getY() {
    return y;
  }
  
  float getZ() {
    return z;
  }
  
  //dot product 
  float dot(Vector anotherV) {
    return x*anotherV.x + y*anotherV.y + z*anotherV.z;
  }
  
  float dot(float xtemp, float ytemp, float ztemp){
    return x*xtemp+y*ytemp+z*ztemp;
  }
  
  //subtraction
  void sub(Vector anotherV) {
    x -= anotherV.x;
    y -= anotherV.y;
    z -= anotherV.z;
  }
  
  void sub(float xtemp, float ytemp, float ztemp) {
    x -= xtemp;
    y -= ytemp;
    z -= ztemp;
  }
  
  //add
  void add(Vector anotherV) {
    x += anotherV.x;
    y += anotherV.y;
    z += anotherV.z;
  }
  
  void add(float xtemp, float ytemp, float ztemp) {
    x += xtemp;
    y += ytemp;
    z += ztemp;
  }
  
  //division by scalar
  void div(float scalar) {
    x /= scalar;
    y /= scalar;
    z /= scalar;
  }
  
  //multiplication by scalar
  void multi(float scalar) {
    x *= scalar;
    y *= scalar;
    z *= scalar;
  }
  
  
  Vector copy() {
    Vector newVec = new Vector();
    newVec.x = x;
    newVec.y = y;
    newVec.z = z;
    return newVec;
  }
  
  float mag() {
    return sqrt(x*x+y*y+z*z);
  }
  void normalize() {
    div(mag());
  }
  
  void reflect(Vector n, float alpha) {// n is the normal vector of a surface. When this vector hit the surface, the vector will be reflected
    n.normalize();
    n.multi((1+alpha)*(this.dot(n)));
    this.sub(n); // v - 2v*n/|n|, v and n are vectors.
  }
  
  float distanceTo(Vector v) {
    return sqrt((x-v.x)*(x-v.x) + (y-v.y)*(y-v.y) + (z-v.z)*(z-v.z));
  }
  
  float distanceTo(float x2, float y2, float z2) {
    return sqrt((x-x2)*(x-x2) + (y-y2)*(y-y2) + (z-z2)*(z-z2));
  }
    
  
  
  String toString() {
    return "("+x+","+y+","+z+")";
  
  }
  
  
}



String projectTitle = "Water Simulation";








int genRate = 5000;  // particles/sec


//lifespan
float maxLife = 1.5;
int numParticles = 0;
//Global array

Vector[] posList = new Vector[0];
Vector[] velList = new Vector[0];
color[] colList = new color[0];
float[] lifeList = new float[0];

//wind effect acceleration
float windEffect = -9; // going up


float startFrame;
float elapsedTime;
float endFrame;



PShape torch;





Vector ballPos = new Vector(mouseX,mouseY,-700);
int ballRadius = 200;


void pointGenerate(Vector pos, float radius, float dt) {
  float r;
  float theta;
  Vector tempVec = pos.copy();
  for(int i = 0; i < floor(genRate*dt); i ++) {
    r = radius*sqrt(random(1));
    theta = random(2*PI);
    tempVec.add(new Vector(r*cos(theta), 0 ,-r*sin(theta)));
    posList = (Vector[])append(posList,tempVec);
    
    tempVec = new Vector(0, -500 , 0);
    tempVec.add(new Vector(0.5*random(-500,500) , 0.7*random(-200,200), 0.5*random(-500,500)));
    velList = (Vector[])append(velList,tempVec);
    
    tempVec = pos.copy();
    
    colList = (color[])append(colList, color(253,207,88));
    
    
    lifeList = (float[])append(lifeList,0);
  }
  numParticles += floor(genRate*dt);// update total num of particles
  
}


void moveParticle(float dt) {
  Vector tempVec = new Vector();
  for(int i = 0; i < numParticles; i++) {
    tempVec = velList[i].copy();
    tempVec.multi(dt);
    posList[i].add(tempVec);
    
    
    if(posList[i].distanceTo(ballPos) < ballRadius) {
      Vector normal = posList[i].copy();
      normal.sub(ballPos);
      normal.normalize();
      normal.multi(ballRadius*1.01);
      Vector temp = ballPos.copy();
      temp.add(normal);
      posList[i] = temp;
    }
    
    
    if(lifeList[i] > 0.5 && lifeList[i] <= 1) {
      colList[i] = color(242,125,12);
    }
    
    if(lifeList[i] > 1) {
      colList[i] = color(117,118,118);
      velList[i].add(0,windEffect,0);
    }
    
    lifeList[i] += dt;
    
  }
}



void particleDeath() {
  int[] liveP = new int[0];
  for(int i = 0; i < numParticles; i ++) { // extract index of those who live
    if(lifeList[i] < maxLife) {
      liveP = append(liveP, i);
    }
  }
  int liveNum = liveP.length;
  
  Vector[] tempList1 = new Vector[liveNum];
  Vector[] tempList2 = new Vector[liveNum];
  float[] tempList3 = new float[liveNum];
  for(int j = 0; j < liveNum; j++) {    // cope the living particles' information to temp arrays
    tempList1[j] = posList[liveP[j]];
    tempList2[j] = velList[liveP[j]];
    tempList3[j] = lifeList[liveP[j]];
  }
  
  for(int k = 0; k < liveNum; k++) {
    posList[k] = tempList1[k];
    velList[k] = tempList2[k];
    lifeList[k] = tempList3[k];
  }
  
  for(int p = 0; p < numParticles - liveNum; p++) {
    posList = (Vector[])shorten(posList);
    velList = (Vector[])shorten(velList);
    lifeList = shorten(lifeList);
  }
  
  
  numParticles = liveNum;
}



void setup() {
  torch = loadShape("torch.obj");
  size(1600,1000,P3D);
  noSmooth();
  strokeWeight(10);
  torch.scale(20);
}


void drawScene() {
  background(0,0,0);
  lights();
  
  pushMatrix();
  translate(800,1100,-700);
  shape(torch);
  popMatrix();
  Vector pos;
  for(int i = 0; i < numParticles; i++) {
    if(lifeList[i] > 1) {
      tint(255, 128);
    }
    pos = posList[i];
    stroke(colList[i]);
    point(pos.getX(),pos.getY(),pos.getZ());
  }
  
  
  noStroke();
  if(!keyPressed){
    ballPos.x = mouseX;
    ballPos.y = mouseY;
    ballPos.z = -700;
  }
  translate(ballPos.x, ballPos.y, ballPos.z);
  fill(255,0,0);
  sphere(ballRadius);
  
}



void draw() {
  float startFrame = millis();
  //Compute the physics update
  pointGenerate(new Vector(800,800, -700), 50, 0.015);
   
  moveParticle(0.015);  //Question: Should this be a fixed number?
  float endPhysics = millis();
  
  if(keyPressed){
    if(key == UP){
      //translate(0,0,-50);
      
    }
    else if(key == DOWN){
      //translate(0,0,50);
      
    }
    else {
      //translate(400,200,-300);
      rotateX(map(mouseY, 0, height, -PI, PI));
      rotateY(map(mouseX, 0, width, -PI, PI));
    }
  }
  //Draw the scene
  drawScene();
  
  float endFrame = millis();
  //pointGenerate(new Vector(200, 300, -300), 100);
  particleDeath();
  
  String runtimeReport = "Frame: "+str(endFrame-startFrame)+"ms,"+
        " Physics: "+ str(endPhysics-startFrame)+"ms,"+
        " FPS: "+ str(round(frameRate)) + ", Num of particles: " + str(numParticles) + "\n";
  surface.setTitle(projectTitle+ "  -  " +runtimeReport);
  //print(runtimeReport);
}  
