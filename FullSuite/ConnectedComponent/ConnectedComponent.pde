//Visualization: Connected Component labeling

import java.util.Map;

int x;
int y;

PFont font;

//Store label at points
HashMap<Point,Integer> labels;

//Equivalence classes
ArrayList<EquivalenceClass> eqs;
int scene;
int labelCount;

final int pxwidth = 20;
final int gridw = 25;
int realw;

//and equivalence class is a group of labels that all belong to the same component
class EquivalenceClass
{
  int label;
  ArrayList<Integer> members;
  
  boolean isInClass(int i)
  {
    return members.contains(i);
  }
  
  void addMember(int i)
  {
    if(!members.contains(i)) members.add(i);
  }
  
  EquivalenceClass(int label, int i)
  {
    this.label = label;
    members = new ArrayList<Integer>();
    members.add(i);
  }
  
  public boolean equals(EquivalenceClass e)
  {
    return label == e.label;
  }
  public int hashCode()
  {
    return label;
  }
}

//for easier referencing
class Point
{
  int x;
  int y;
  Point(int ex,int ey)
  {
    x = ex;
    y = ey;
  }

public boolean equals(Object po)
  {
    Point p = (Point)po;
    return x==p.x && y==p.y;
  }
  public int hashCode()
{
  int hash = 17;
        hash = ((hash + x) << 5) - (hash + x);    
        hash = ((hash + y) << 5) - (hash + y);    
        return hash;
}
}


void setup()
{
  labelCount = 1;
//size must be hardcoded, which somewhat defeats the purpose of the height and width
//variables, but that's how it goes
realw = pxwidth*gridw;
  size(700,500);
  
  //load font
  font = createFont("Calibri.ttf",12);
  textFont(font);
  
  //slow frame rate
  frameRate(5);
  scene = 0;
  
  init();
}

//draw a red box
void drawBox(int x, int y, int w, int h)
{
  stroke(255,0,0);
   //top
   line(x*pxwidth,y*pxwidth,(x+w)*pxwidth,y*pxwidth);
   
   //bottom line
   line(x*pxwidth,(y+h)*pxwidth,(x+w)*pxwidth,(y+h)*pxwidth);
   
   //left line
   line(x*pxwidth,y*pxwidth,x*pxwidth,(y+h)*pxwidth);
   
   //right line
   line((x+w)*pxwidth, y*pxwidth, (x+w)*pxwidth,(y+h)*pxwidth);
}

void init()
{
  x = y = 0;
  labelCount = 1;
  labels = new HashMap<Point,Integer>();
  eqs = new ArrayList<EquivalenceClass>();
  
  //populate the binary image with some components
  
//two big blocks joined
  for(int i = 9; i <= 15; i+=1)
  {
     for (int j = 0; j<= 5; j+=1)
     {
      labels.put(new Point(i,j),1);
     }
  }
  
  
   for(int i = 2; i<=9; i+=1)
  {
      for(int j = 5; j <=10;j+=1)
      {
        labels.put(new Point(i,j),1);
      }
  }
  
  //pyramid
  labels.put(new Point(20,9),1);
  labels.put(new Point(19,10),1);
  labels.put(new Point(20,10),1);
  labels.put(new Point(21,10),1);
  labels.put(new Point(18,11),1);
  labels.put(new Point(19,11),1);
  labels.put(new Point(20,11),1);
  labels.put(new Point(21,11),1);
  labels.put(new Point(22,11),1);
  labels.put(new Point(17,12),1);
  labels.put(new Point(18,12),1);
  labels.put(new Point(19,12),1);
  labels.put(new Point(20,12),1);
  labels.put(new Point(21,12),1);
  labels.put(new Point(22,12),1);
  labels.put(new Point(23,12),1);
  labels.put(new Point(16,13),1);
  labels.put(new Point(17,13),1);
  labels.put(new Point(18,13),1);
  labels.put(new Point(19,13),1);
  labels.put(new Point(20,13),1);
  labels.put(new Point(21,13),1);
  labels.put(new Point(22,13),1);
  labels.put(new Point(23,13),1);
  labels.put(new Point(24,13),1);
  
  
  //three small blocks
   for(int i = 9; i <= 11; i+=1)
  {
     for (int j = 16; j<= 18; j+=1)
     {
      labels.put(new Point(i,j),1);
     }
     for (int j = 20; j<= 22; j+=1)
     {
      labels.put(new Point(i,j),1);
     }
  }
  
  //block with a hole
  labels.put(new Point(7,17),1);
  labels.put(new Point(6,18),1);
     for(int i = 7; i <= 9; i+=1)
  {
     for (int j = 18; j<= 20; j+=1)
     {
      labels.put(new Point(i,j),1);
     }
  }
}

void mergeEqClasses(EquivalenceClass eq1, EquivalenceClass eq2)
{
  eq2.members.addAll(eq1.members);
  eqs.remove(eq1);
}

void addEquivalenceClass()
{
  labelCount++;
  EquivalenceClass eq = new EquivalenceClass(labelCount,labelCount);
  eqs.add(eq);
}

void draw()
{
  background(0,0,0);
  stroke(100);
  fill(255);
  
  int boxx = 0;
  int boxy = 0;
  int boxw = 0;
  int boxh = 0;
  
  //keep track of which pixel we're looking at
  if(x >= gridw)
    {
       y++;
       x = 0;
     }
  
  //scene 0: labeling
  if(scene == 0)
  {
  
   if(y >= gridw)
   {
     scene=1;
     x = 0;
     y = 0;
   }

   Point a = new Point(x,y);
   if(labels.containsKey(a))
   {
     //labels doesn't have any zeros
     int blabel = 0;
     int clabel = 0;
     int dlabel = 0;
     
     //get labels of other pixels in mask group
     if (x > 0 && y > 0)
     {
       Point d = new Point(x-1,y-1);
       if(labels.containsKey(d)) dlabel = labels.get(d);
     }
     if(x > 0)
     {
       Point b = new Point(x-1,y);
       if(labels.containsKey(b)) blabel = labels.get(b);
     }
     if(y > 0)
     {
       Point c = new Point(x,y-1);
       if(labels.containsKey(c)) clabel = labels.get(c);
     }
     
     //case 1: d is labeled, b and c are not
     if(dlabel > 0 && blabel == 0 && clabel == 0)
     {
       labels.put(a,dlabel);
     }
     //case 2a: b is labeled, c is not
     if(blabel > 0 && clabel == 0)
     {
       labels.put(a,blabel);
     }
     //case 2b: c is labeled, b is not
     if(clabel > 0 && blabel == 0)
     {
       labels.put(a,clabel);
     }
    //case 3: none are labeled
    if(blabel == 0 && clabel == 0 && dlabel == 0)
    {
      addEquivalenceClass();
      labels.put(a,labelCount);
      
    }
    //case 4a: B & C are labeled the same
    if(blabel > 0 && clabel > 0 && blabel == clabel)
    {
      labels.put(a,blabel);
    }
    //case 4a: B & C are labeled differently
    if(blabel > 0 && clabel > 0 && blabel != clabel)
    {
      labels.put(a,blabel);
      //merge equivalence classes of b and c
      EquivalenceClass e1 = new EquivalenceClass(0,0);
      EquivalenceClass e2 = new EquivalenceClass(0,0);
      for(EquivalenceClass e : eqs)
      {
        if(e.isInClass(blabel)) e1 = e;
        if(e.isInClass(clabel)) e2 = e;
      }
      if(!e1.equals(e2)) mergeEqClasses(e1,e2);
    }
     
     
   }

  
 
   stroke(255,0,0);
   
   //vertices of mask
   int yupdiff = 1;
   int xleftdiff = 1;
   if(x == 0) xleftdiff = 0;
   if(y == 0) yupdiff = 0;
  
    boxx = x - xleftdiff;
    boxy = y - yupdiff;
    boxw = 1 + xleftdiff;
    boxh = 1 + yupdiff;
  } //end scene = 0
  
  //scene 1: merging labels
  else 
  {
   if(y >= gridw)
   {
    
     scene=0;
     init();
     
     x = 0;
     y = 0;
   }
   Point a = new Point(x,y);
   if(labels.containsKey(a))
   {
     int alabel = labels.get(a);
     int newlabel = alabel;
     for(EquivalenceClass e: eqs)
     {
       //find corresponding equivalence class
       if(e.isInClass(alabel))
       {
         newlabel = e.label;
       }
     }
     labels.put(a,newlabel);
   }
   
   //draw box around pixel
   boxx = x;
   boxy = y;
   boxw = 1;
   boxh = 1;

  }//end scene = 1
  
  //draw current scene
  for(int i = 0; i < gridw; i++)
  {
    for(int j = 0; j < gridw; j++)
    {
      Point p = new Point(i,j);
      //if the label > 0, pixel is white
      int l = 0;
      if(labels.containsKey(p)) l = labels.get(p);
      fill(255);
      
      // if the pixel is currently being looked at, color it grey
      if(i == x && j == y) fill(100);
      
      // if pixel is in the mask but not being looked at, color it lighter grey
      else if (scene == 0 && ((p.x == x-1 && (p.y == y || p.y == y-1)) || (p.y == y -1 && (p.x == x || p.x == x-1)))) fill(200);
      else if (l == 0) fill(0);
      
    //fill in pixel
    rect(i*pxwidth,j*pxwidth,pxwidth,pxwidth);
   
    if(l > 0) 
    {
      //add label to pixels
      fill(0);
      text(" " + Integer.toString(l),p.x*pxwidth,p.y*pxwidth,pxwidth,pxwidth);
    }
    }
   
  }
 
  //draw equivalence key 
  for(EquivalenceClass eq : eqs)
  {
    fill(255,0,255);
    int k = eq.label;
    ArrayList<Integer> mems = eq.members;
    
    //draw class label
    text(" " + Integer.toString(k), gridw*pxwidth,k*pxwidth,pxwidth,pxwidth);
    int xval = 550;
    
    //show class members
    for(int mem: mems)
    {
      text(" " + Integer.toString(mem), xval,k*pxwidth,pxwidth,pxwidth); 
      xval += pxwidth;
    }
    
  }
   x+=1;
   //draw the actual grid
  stroke(150);
  for(int i = 0; i <= gridw; i+=1)
  {
    int reali = i *pxwidth;
    //draw pixel grid
    line(reali,0,reali,realw);
    line(0,reali, realw,reali);
  }
  line(550,0,550,500);
  
  //draw mask or box around pixel
  drawBox(boxx,boxy,boxw,boxh);
 
}