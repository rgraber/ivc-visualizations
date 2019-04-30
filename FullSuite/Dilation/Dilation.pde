//Visualization: Dilation

class Point
{
  int x;
  int y;
  Point(int ex,int ey)
  {
    x = ex;
    y = ey;
  }
}

int x;
int y;
ArrayList white;
boolean bWhite;


int scene;

void setup()
{
  size(500,500);

  scene = 1;
  frameRate(5);
  x = y = 0;
  white = new ArrayList();
}

void draw()
{
  //visualization pixel size = 20
  background(0,0,0);
  stroke(100);
  fill(255,255,255);

  //draw shape made of white rectangles
 
  rect(240,20,20,20);
  rect(240,40,20,20);
  rect(240,60,20,20);
  rect(240,80,20,20);
  
  rect(240,220,20,20);
  rect(240,240,20,20);
  rect(240,260,20,20);
  rect(240,280,20,20);
  rect(240,300,20,20);
  rect(240,320,20,20);
  rect(220,220,20,20);
  rect(220,240,20,20);
  rect(220,260,20,20);
  rect(220,280,20,20);
  rect(220,300,20,20);
  rect(220,320,20,20);
  rect(260,220,20,20);
  rect(260,240,20,20);
  rect(260,260,20,20);
  rect(260,280,20,20);
  rect(260,300,20,20);
  rect(260,320,20,20);
 
  for(int i = 180; i <= 300; i+=20)
  {
     for (int j = 100; j<= 200; j+=20)
     {
      rect(i,j,20,20); 
     }
  }
  
  for(int i = 40; i<180; i+=20)
  {
      for(int j = 200; j <=320;j+=20)
      {
        rect(i,j,20,20);
      }
  }
  
  for(int i = 320; i<460; i+=20)
  {
      for(int j = 200; j <=320;j+=20)
      {
        rect(i,j,20,20);
      }
  }
  
   for(int i = 180; i <= 300; i+=20)
  {
     for (int j = 320; j<= 420; j+=20)
     {
      rect(i,j,20,20); 
     }
  }
  
  fill(255);
  
  //draw any additional points that have since been filled in
  for(int i = 0; i < white.size(); i++)
  {
    Point p = (Point) white.get(i);
    rect(p.x,p.y,20,20);
  }

//for this visualization, can skip the edges
   if(x > 460)
   {
     y+=20;
     x = 0;
   }
   if(y > 460)
   {
     x = 0;
     y = 0;
     white = new ArrayList();
   }
   
   loadPixels();
   color cTR = pixels[(y+2)*500+(x + 2)];
   color cTL = pixels[(y+22)*500+(x + 2)];
   color cBR = pixels[(y+2)*500+(x + 22)];
   color cBL = pixels[(y+22)*500+(x + 22)];
   
   //get grey val of all neighboring pixels
   float ctr = red(cTR) + blue(cTR) + green(cTR);
   float ctl = red(cTL) + blue(cTL) + green(cTL);
   float cbr = red(cBR) + blue(cBR) + green(cBR);
   float cbl = red(cBL) + blue(cBL) + green(cBL);
   
   
   bWhite = false;
   if(ctr == 765 || ctl == 765 || cbr == 765 || cbl == 765)
   {
     //if any neighboring pixel is white (i.e. rgb are all 255), this pixel becomes white
     bWhite = true;
     rect(x,y,20,20);
     white.add(new Point(x,y));
   }
      
       //draw pixel grid and mask last so they're on top
  for(int i = 0; i < 500; i+=20)
  {
    //draw pixel grid
    line(i,0,i,500);
    line(0,i, 500,i);
  }
  stroke(255,0,0);
   line(x,y,x+40,y);
   line(x,y,x,y+40);
   line(x+40,y,x+40,y+40);
   line(x, y+40, x+40,y+40);
 
       x+=20; //visualization pixel size

}