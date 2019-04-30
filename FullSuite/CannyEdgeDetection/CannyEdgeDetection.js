// Visualization: Canny Edge Detection

import java.util.Map;


PImage img;
int img_height,img_width;
int scene;
int frame;
double[][] filter;
Point[] points;

// store information about each pixel
class Point
{
  int x;
  int y;
  color c;
  color img_color; //color of the original image at this pixel
  double dx; // x gradient
  double dy; // y gradient
  boolean suppressed;
  
  Point(int x, int y)
  {
    this.x = x;
    this.y = y;
    c = color(0);
    dx = dy = 0;
    img_color = img.get(x,y);
    suppressed = false;
  }
  
  //actual color at this pixel
  color getImageColor() 
  {
    return img_color;
  }
  
  //original image color at pixel
  int getImageGreyVal()
  {
    if(x >= 0 && y >= 0 && x < img_width && y < img_width) return (int) red(img_color);
    else return 0;
  }
  
  //index into pixel array
  int getPixelIndex()
  {
    return y*img_width + x;
  }
  
  void setColor(int c)
  {
    this.c = color(c); 
  }
  
  int getGreyVal()
  {
    return (int) red(c); //<>//
  }
  
  double getGradientMag()
  {
    return Math.sqrt(Math.pow(dx,2) + Math.pow(dy,2));
  }
  
  double getAngle()
  {
    //we use atan here so the range will be restricted to -pi/2 to pi/2
    if(dx == 0) return 2*Math.PI; //out of range of atan;
    else 
    {
      double ret = Math.atan(dy/dx);
    return ret;
    }
  }
  
  //for non-maximum suppression
  void setSuppressed()
  {
    suppressed = true;
  }
  
  boolean getSuppressed()
  {
    return suppressed;
  }
}

void setup()
{
  //size must be hardcoded
  size(256,256);
  scene = 0;
  img_width = img_height = 256;
  img = loadImage("../LennaSmallGrey.png");
  
  //make a gaussian filter with k=2, sd = 1.4
  filter = makeGaussianFilter(2,1.4);
  init();
}

void init()
{
  //initialize point array
  points = new Point[img_width*img_width];
  for(int i = 0; i < img_width; i++)
  {
    for(int j = 0; j < img_width; j++)
    {
      points[j*img_width+i] = new Point(i,j);
    }
  }
}

void draw()
{
  frame++;
  
  //draw the image
  image(img,0,0);
  
  //step 1: gaussian blur
  if(frame >= 20)
  {
    loadPixels(); //get px array
    int pxCount = 0;
    for(Point p: points)
    {
      if(pxCount == (frame-20)*256) break; //only update 1 row per frame to show progress
      applyFilterToPixel(filter, p);
      pxCount ++;
    } 
    pxCount = 0;
    for(Point p: points)
    {
      if(pxCount == (frame-20)*256) break;
      if(red(p.c) >= 0 && red(p.c) <= 255)
      {
        pixels[p.getPixelIndex()] = p.c; //update image to show new blurred values
      }
      pxCount++;
    }
    updatePixels(); //update px array
  } //end if frame <= 20
  
  //step 2: Sobel filter
  if(frame >= 300)
  {
    int pxCount = 0;
    loadPixels();
  
    for(Point p: points)
    {
      if(pxCount == (frame-300)*256) break;
      applySobelToPixel(p);
      pxCount++;
    }
    
    pxCount = 0;
     for(Point p: points)
    {
      if(pxCount == (frame-300)*256) break;
      
      //color pixels based on gradient magnitude
      pixels[p.getPixelIndex()] = color(min(255,(int)Math.round(p.getGradientMag())));
      pxCount++;
    }
    updatePixels();
  } // end if frame >= 300
  
  //step 3: non-maximum suppression
  if(frame >= 600)
  {
    int pxCount = 0;
    loadPixels();
    for(Point p: points)
    {
      Point pc;
      if(pxCount == (frame-600)*256) break;
      double angle = p.getAngle();

      if((angle >= (-Math.PI/8d)) && (angle < Math.PI/8d))
      {
        //gradient is vertical --> get gradients to the right and left
        if(p.y - 1 >= 0)
        {
          pc = points[getPixelIndex(p.x,p.y-1)];
          if(pc!= null && pc.getGradientMag() > p.getGradientMag())
          {
            p.setSuppressed(); //if neighboring pixels have higher gradients, suppress
          }
        }
        if(p.y + 1 < img_width)
        {
          pc = points[getPixelIndex(p.x,p.y+1)];
          if(pc!= null && pc.getGradientMag() > p.getGradientMag())
          {
            p.setSuppressed();
          }
        }
      }
      
      else if((angle >= (3*Math.PI/8d)) || (angle < -3*Math.PI/8d))
      {
        //gradient is horizontal --> get gradients up and down
        if(p.x - 1 >= 0)
        {

         pc = points[getPixelIndex(p.x-1,p.y)];
          if(pc!= null && pc.getGradientMag() > p.getGradientMag())
          {
            p.setSuppressed();
          } //<>//
        }
        if(p.x + 1 < img_width)
        {
          pc = points[getPixelIndex(p.x+1,p.y)];
          if(pc!= null && pc.getGradientMag() > p.getGradientMag())
          {
            p.setSuppressed();
          } //<>//
        }
      }
      
       else if((angle >= (Math.PI/8d)) && (angle < 3*Math.PI/8d))
      {
        //45 degree angle. get gradients northeast & southwest
        if(p.x + 1 < img_width && p.y - 1 >= 0)
        {
          pc = points[getPixelIndex(p.x+1,p.y-1)];
          if(pc!= null && pc.getGradientMag() > p.getGradientMag())
          {
            p.setSuppressed();
          } //<>//
        }
        if(p.x - 1 >= 0 && p.y + 1 < img_width)
        {
          pc = points[getPixelIndex(p.x-1,p.y+1)];
          if(pc!= null && pc.getGradientMag() > p.getGradientMag())
          {
            p.setSuppressed();
          } //<>//
        }
      }
      
      else if((angle > (-3*Math.PI/8d)) && (angle < -Math.PI/8d))
      {
        //135 degree angle. get gradients northwest & southeast
        if(p.x - 1 >= 0 && p.y - 1 >= 0)
        {
         pc = points[getPixelIndex(p.x-1,p.y-1)];
          if(pc!= null && pc.getGradientMag() > p.getGradientMag())
          {
            p.setSuppressed();
          } //<>//
        }
        if(p.x + 1 < img_width && p.y + 1 < img_width)
        {
          pc = points[getPixelIndex(p.x+1,p.y+1)];
          if(pc!= null && pc.getGradientMag() > p.getGradientMag())
          {
            p.setSuppressed();
          } //<>//
        }
      }
      
      pxCount++;
    }
    pxCount = 0;
    
    //set all suppressed pixels to 0 to thin edges
    for(Point p: points)
    {
      if(p.getSuppressed()) pixels[p.getPixelIndex()] = color(0);
      else pixels[p.getPixelIndex()] = color(min(255,(int)Math.round(p.getGradientMag()))); //<>//
    }
    updatePixels();
  } //end if frame >= 600
  
  //step 4: first threshold (100)
  if(frame >= 900)
  {
    int pxCount = 0;
    loadPixels();
    for(Point p: points)
    {
      if(pxCount == (frame-900)*256) break;
      //simple threshold: only keep values > 100
      if(p.getGradientMag() > 100 &&!p.getSuppressed()) pixels[p.getPixelIndex()] = color(255);
      else pixels[p.getPixelIndex()] = color(0);
      pxCount++;
    }
    updatePixels();
  }
  
  //step 4: double threshold
  if(frame >= 1200)
  {
     int pxCount = 0;
    loadPixels();
    for(Point p: points)
    {
      if(pxCount == (frame-1200)*256) break;
      //keep all values from previous threshold
      if(p.getGradientMag() > 100 && !p.getSuppressed())
      {
        pixels[p.getPixelIndex()] = color(255);
        pxCount++;
        continue;
      }
      
      //if gradient > 50, check neighbors. if they are proper edges, add pixel to edge
      else if(p.getGradientMag() > 50 && !p.getSuppressed())
      {
        Point n;
        //check n8 for edge pixels
        if(p.x - 1 >= 0)
        {
          if(p.y - 1 >= 0)
          {
            n = points[getPixelIndex(p.x-1,p.y-1)];
            if(n != null && n.getGradientMag() > 100 && !n.getSuppressed())
            {
              pixels[p.getPixelIndex()] = color(255);
              pxCount++;
              continue;
            }
          }
          n = points[getPixelIndex(p.x-1,p.y)];
          if(n != null && n.getGradientMag() > 100 && !n.getSuppressed())
          {
            pixels[p.getPixelIndex()] = color(255);
            pxCount++;
            continue;
          }
          if(p.y + 1 < img_width)
          {
            n = points[getPixelIndex(p.x-1,p.y+1)];
            if(n != null && n.getGradientMag() > 100 && !n.getSuppressed())
            {
              pixels[p.getPixelIndex()] = color(255);
              pxCount++;
              continue;
            }
        }
       }
        
        if(p.y-1 >=0)
        {
        n = points[getPixelIndex(p.x,p.y-1)];
        if(n != null && n.getGradientMag() > 100 && !n.getSuppressed())
        {
          pixels[p.getPixelIndex()] = color(255);
          pxCount++;
          continue;
        }
        }
        
        n = points[getPixelIndex(p.x,p.y)];
        if(n != null && n.getGradientMag() > 100 && !n.getSuppressed())
        {
          pixels[p.getPixelIndex()] = color(255);
          pxCount++;
          continue;
        }
        
        if(p.y+1 < img_width)
        {
        n = points[getPixelIndex(p.x,p.y+1)];
        if(n != null && n.getGradientMag() > 100 && !n.getSuppressed())
        {
          pixels[p.getPixelIndex()] = color(255);
          pxCount++;
          continue;
        }
        }
        
        if(p.x + 1 < img_width)
        {
          if(p.y-1 >= 0)
          {
        n = points[getPixelIndex(p.x+1,p.y-1)];
        if(n != null && n.getGradientMag() > 100 && !n.getSuppressed())
        {
          pixels[p.getPixelIndex()] = color(255);
          pxCount++;
          continue;
        }
          }
        
       n = points[getPixelIndex(p.x+1,p.y)];
        if(n != null && n.getGradientMag() > 100 && !n.getSuppressed())
        {
          pixels[p.getPixelIndex()] = color(255);
          pxCount++;
          continue;
        }
        
        if(p.y + 1 < img_width)
        {
        n = points[getPixelIndex(p.x+1,p.y+1)];
        if(n != null && n.getGradientMag() > 100 && !n.getSuppressed())
        {
          pixels[p.getPixelIndex()] = color(255);
          pxCount++;
          continue;
        }
        }
        
        } 
      }
       pxCount++;
    } //end for loop
    updatePixels();
  } //end if frame >= 1200
  
  //reset and rerun
  if(frame >= 1500)
  {
    init();
    frame = 0;
  }
  
  
}

//multiply pixel by x and y sobel masks with n=9 support to approximate gradient
void applySobelToPixel(Point p)
{
  int px = p.x;
  int py = p.y;
  double dx = 0;
  double dy = 0;
 
  for(int i = max(py - 1,0); i <= min(py + 1,img_width-1); i ++)
  {
    int f = 1;
    if (i == py) f = 2;
    if(px - 1 >= 0)
    {
      Point p0 = points[getPixelIndex(px-1,i)];
      if(p0 != null) dx-= f*p0.getGreyVal();
    }
    if(px + 1 < img_width)
    {
    Point p1 = points[getPixelIndex(px+1,i)];
    if(p1 != null) dx+= f*p1.getGreyVal();
    }
  }
  
  for(int i = max(px - 1,0); i <= min(px + 1,img_width-1); i ++)
  {
    int f = 1;
    if (i == px) f = 2;

  if(py - 1 >= 0)
  {
   Point p0 = points[getPixelIndex(i,py-1)];
   if(p0 != null) dy-= f*p0.getGreyVal();
  }
  if(py + 1 < img_width)
  {
    Point p1 = points[getPixelIndex(i,py+1)];
    if(p1 != null) dy+= f*p1.getGreyVal();
  }
  }
   
   p.dx = dx;
   p.dy = dy;

}

//get grey value of original image at point
int getImageGreyVal(int x, int y)
{
  if(x >= 0 && y >= 0 && x < img_width && y < img_width) return (int) red(img.get(x,y));
    else return 0;
}

//apply a k=2 gaussian filter to a point
void applyFilterToPixel(double[][] gauss, Point p)
{
  int px = p.x;
  int py = p.y;
  double val = 0;

   val += gauss[0][0]*getImageGreyVal(px-2,py-2);
   val += gauss[0][1]*getImageGreyVal(px-2,py-1);
   val += gauss[0][2]*getImageGreyVal(px-2,py);
   val += gauss[0][3]*getImageGreyVal(px-2,py+1);
   val += gauss[0][4]*getImageGreyVal(px-2,py+2);
   
   val += gauss[1][0]*getImageGreyVal(px-1,py-2);
   val += gauss[1][1]*getImageGreyVal(px-1,py-1);
   val += gauss[1][2]*getImageGreyVal(px-1,py);
   val += gauss[1][3]*getImageGreyVal(px-1,py+1);
   val += gauss[1][4]*getImageGreyVal(px-1,py+2);
   
   val += gauss[2][0]*getImageGreyVal(px,py-2);
   val += gauss[2][1]*getImageGreyVal(px,py-1);
   val += gauss[2][2]*getImageGreyVal(px,py);
   val += gauss[2][3]*getImageGreyVal(px,py+1);
   val += gauss[2][4]*getImageGreyVal(px,py+2);
   
   val += gauss[3][0]*getImageGreyVal(px+1,py-2);
   val += gauss[3][1]*getImageGreyVal(px+1,py-1);
   val += gauss[3][2]*getImageGreyVal(px+1,py);
   val += gauss[3][3]*getImageGreyVal(px+1,py+1);
   val += gauss[3][4]*getImageGreyVal(px+1,py+2);
   
   val += gauss[4][0]*getImageGreyVal(px+2,py-2);
   val += gauss[4][1]*getImageGreyVal(px+2,py-1);
   val += gauss[4][2]*getImageGreyVal(px+2,py);
   val += gauss[4][3]*getImageGreyVal(px+2,py+1);
   val += gauss[4][4]*getImageGreyVal(px+2,py+2);
   
    p.setColor((int)Math.round(val));
  
}

//make a Gaussian mask for the given kernel size and standard deviation
double[][] makeGaussianFilter(int k, double sd)
{
  if(k == 0 || sd == 0) return null;
  double[][] ret = new double[2*k+1][2*k+1];
  for(int i = 1; i <= 2*k+1; i++)
  {
    for(int j = 1; j <= 2*k + 1; j++)
    {
  //    println("i = " + i + " j = " + j);
      ret[i-1][j-1] = (Math.pow(Math.E,-(Math.pow(i - (k+1),2) + Math.pow(j - (k+1),2)))/(2*Math.pow(sd,2)));
      //(1.0/(2*Math.PI*sd))*
    }
  }
  return ret;
}

//index into pixel array
int getPixelIndex(int x, int y)
{
  return y*img_width+x;
}
