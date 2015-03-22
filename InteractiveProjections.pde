void setup () { 
  size(200,200,P3D);
}

float scale = 1;
float angleX = 0;
float angleY = 0;

void mouseDragged(){
  if(pmouseY < mouseY){
    scale = scale*1.1;
  }
  else if(pmouseY > mouseY)
  scale = scale / 1.1;
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      angleX += PI/18;
    } 
    else if (keyCode == DOWN) {
      angleX -= PI/18;
    } 
    else if (keyCode == RIGHT) {
      angleY += PI/18;
    } 
    else {
      angleY -= PI/18;
    } 
  }
}

void draw() {
  background(255, 255, 255);
  My3DPoint eye = new My3DPoint(0, 0, -5000);
  My3DPoint origin = new My3DPoint(0, 0, 0);
  My3DBox input3DBox = new My3DBox(origin, 100, 150, 300);
  translate(100,100);
  //rotated around x
  float[][] transform1 = rotateXMatrix(angleX); 
  input3DBox = transformBox(input3DBox, transform1); 
  //projectBox(eye, input3DBox).render();
  
  //rotated and translated
  float[][] transform2 = rotateYMatrix(angleY); 
  input3DBox = transformBox(input3DBox, transform2); 
  //projectBox(eye, input3DBox).render();
  
  //rotated, translated, and scaled
  float[][] transform3 = scaleMatrix(2*scale, 2*scale, 2*scale); 
  input3DBox = transformBox(input3DBox, transform3); 
  projectBox(eye, input3DBox).render();
}

class My2DPoint { 
  float x;
  float y;
  My2DPoint(float x, float y) {
    this.x = x;
    this.y = y; 
  }
}

class My3DPoint { 
  float x;
  float y;
  float z;
  My3DPoint(float x, float y, float z) {
    this.x = x; 
    this.y = y; 
    this.z = z;
  } 
}

// builds the point {Xp, Yp, -ez, 1} and returns the point {Xp, Yp}
My2DPoint projectPoint(My3DPoint eye, My3DPoint p) {
  float[][] P = {{1,0,0,0}, {0,1,0,0}, {0,0,1,0}, {0,0,-1/eye.z,0}};
  float[][] T = {{1,0,0,-eye.x}, {0,1,0,-eye.y}, {0,0,1,-eye.z}, {0,0,0,1}};
  float[] pPoint = {p.x, p.y, p.z, 1};
  float[] resultPoint = matrixProduct(matrixMultiplication(P,T), pPoint);
  float w = resultPoint[3];
  // return the point normalized 
  return new My2DPoint(resultPoint[0]/w, resultPoint[1]/w);
}

float[][] matrixMultiplication(float[][] A, float[][] B) { 
  float[][] C = new float[A.length][B[0].length];
  for(int i=0; i<A.length; i++){
    for(int j=0; j<B.length; j++){
      for(int k=0; k<B[0].length; k++){
        C[i][j] += A[i][k]*B[k][j];
      }
    }
  }
  return C;
}

float[] matrixProduct(float[][] a, float[] b) {
  float[] c = new float[b.length];
  for(int i=0; i<a.length; i++){
    for(int j=0; j<b.length; j++){
      c[i] += a[i][j]*b[j];
    }
  }
  return c;
}

class My2DBox { 
  My2DPoint[] s; 
  My2DBox(My2DPoint[] s) {
    this.s = s; 
  }
  
  // the edges of the box cube 
  void render(){
    line(s[0].x, s[0].y, s[1].x, s[1].y);
    line(s[0].x, s[0].y, s[3].x, s[3].y);
    line(s[0].x, s[0].y, s[4].x, s[4].y);
    line(s[1].x, s[1].y, s[2].x, s[2].y);
    line(s[1].x, s[1].y, s[5].x, s[5].y);
    line(s[2].x, s[2].y, s[3].x, s[3].y);
    line(s[2].x, s[2].y, s[6].x, s[6].y);
    line(s[3].x, s[3].y, s[7].x, s[7].y);
    line(s[4].x, s[4].y, s[5].x, s[5].y);
    line(s[4].x, s[4].y, s[7].x, s[7].y);
    line(s[5].x, s[5].y, s[6].x, s[6].y);
    line(s[6].x, s[6].y, s[7].x, s[7].y);
  } 
}

/* takes the position and dimensions of the box, 
   initializes x, y, and z values of 8 vertices */
class My3DBox {
  My3DPoint[] p;
  My3DBox(My3DPoint origin, float dimX, float dimY, float dimZ){
    float x = origin.x;
    float y = origin.y;
    float z = origin.z;
    this.p = new My3DPoint[]{new My3DPoint(x-dimX/2, y+dimY/2, z+dimZ/2),
                             new My3DPoint(x-dimX/2, y-dimY/2, z+dimZ/2),
                             new My3DPoint(x+dimX/2, y-dimY/2, z+dimZ/2),
                             new My3DPoint(x+dimX/2, y+dimY/2, z+dimZ/2), 
                             new My3DPoint(x-dimX/2, y+dimY/2, z-dimZ/2),
                             new My3DPoint(x-dimX/2, y-dimY/2, z-dimZ/2),
                             new My3DPoint(x+dimX/2, y-dimY/2, z-dimZ/2),
                             new My3DPoint(x+dimX/2, y+dimY/2, z-dimZ/2)
                           };
  }
  My3DBox(My3DPoint[] p) {
    this.p = p; 
  }
}

/*function to create a function 
  that takes the eye position and a My3DBox object 
  and returns its projection as My2DBox.*/
My2DBox projectBox (My3DPoint eye, My3DBox box) {
  My2DPoint[] projectedPoints = new My2DPoint[8]; //beacause 8 vertices
  for(int i=0; i<projectedPoints.length; i++){
    // Projection of each point of the 3DBox 
    projectedPoints[i] = projectPoint(eye, box.p[i]);
  }
  return new My2DBox(projectedPoints);
}

float[] homogeneous3DPoint (My3DPoint p) { 
  float[] result = {p.x, p.y, p.z , 1};
  return result; 
}

float[][] rotateXMatrix(float angle) { 
  return(new float[][] {{1, 0,           0,          0},
                        {0, cos(angle),  sin(angle), 0},
                        {0, -sin(angle), cos(angle), 0},
                        {0, 0,           0,          1}});
}

float[][] rotateYMatrix(float angle) {
  return(new float[][] {{cos(angle),  0, sin(angle), 0},
                        {0,           1, 0,          0},
                        {-sin(angle), 0, cos(angle), 0},
                        {0,           0, 0,          1}});
}

float[][] rotateZMatrix(float angle) {
  return(new float[][] {{cos(angle), -sin(angle), 0, 0},
                        {sin(angle), cos(angle),  0, 0},
                        {0,          0,           1, 0},
                        {0,          0,           0, 1}});
}

float[][] scaleMatrix(float x, float y, float z) {
   return(new float[][] {{x, 0, 0, 0},
                         {0, y, 0, 0},
                         {0, 0, z, 0},
                         {0, 0, 0, 1}});
}

float[][] translationMatrix(float x, float y, float z) {
  return(new float[][] {{1, 0, 0, x},
                        {0, 1, 0, y},
                        {0, 0, 1, z},
                        {0, 0, 0, 1}});
}

My3DBox transformBox(My3DBox box, float[][] transformMatrix) {
  // Table containing new vertices of the transformed box 
  My3DPoint[] transformedPoints = new My3DPoint[8];
  for(int i=0; i<box.p.length; i++){
    // the transformMatrix is applied to each vertex 
    transformedPoints[i] = euclidian3DPoint(matrixProduct(transformMatrix, homogeneous3DPoint(box.p[i])));
  }
  return new My3DBox(transformedPoints);
}

My3DPoint euclidian3DPoint (float[] a) {  
  return new My3DPoint(a[0]/a[3], a[1]/a[3], a[2]/a[3]);
}


