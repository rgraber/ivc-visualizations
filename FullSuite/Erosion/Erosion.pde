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

PImage img;
PFont font;
int x;
int y;
ArrayList black;
boolean bBlack;


int scene;

void setup()
{
  size(500,500);
  font = createFont("Calibri.ttf",18);
  textFont(font);
  scene = 1;
  frameRate(5);
  x = y = 0;
  black = new ArrayList();
}

void draw()
{
  background(0,0,0);
  stroke(100);
  fill(255,255,255);

  //draw initial shape
 
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
  
  //fill in any additional pixels that have been set to black
  fill(0);
  for(int i = 0; i < black.size(); i++)
  {
    Point p = (Point) black.get(i);
    rect(p.x,p.y,20,20);
  }

//don't bother with the edges for this visualization
   if(x > 460)
   {
     y+=20;
     x = 0;
   }
   if(y > 460)
   {
     x = 0;
     y = 0;
     black = new ArrayList();
   }
   
   loadPixels();
   //get color of neighboring pixels (using a real pixel within the visualization pixel)
   color cTR = pixels[(y+2)*500+(x + 2)];
   color cTL = pixels[(y+22)*500+(x + 2)];
   color cBR = pixels[(y+2)*500+(x + 22)];
   color cBL = pixels[(y+22)*500+(x + 22)];
   
   
   float ctr = red(cTR) + blue(cTR) + green(cTR);
   float ctl = red(cTL) + blue(cTL) + green(cTL);
   float cbr = red(cBR) + blue(cBR) + green(cBR);
   float cbl = red(cBL) + blue(cBL) + green(cBL);
   
   bBlack = false;
   
   //if pixels in mask are black, this pixel is now black
   if(ctr == 0 || ctl == 0 || cbr == 0 || cbl == 0)
   {
     bBlack = true;
     rect(x,y,20,20);
     black.add(new Point(x,y));
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
 
       x+=20;
 
  

}