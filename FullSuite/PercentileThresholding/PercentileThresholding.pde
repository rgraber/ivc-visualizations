//Visualization: Percentile thresholding

PImage img, imgDark;
int frame;
int scene;
int x,y;
PixelHistogram hist, histDark;
PFont font;
int xsize;
int imgxsize, imgysize;
int thresh1, thresh2, sum1, sum2;
int percentile;
int goalpx;
boolean thresh1found, thresh2found;

//Bucket in a histogram
class HistBucket
{
  int greyVal;
  int pxCount;
  HistBucket(int g)
  {
    greyVal = g;
    pxCount = 0;
  }
  public int getPxCount()
  {
    return pxCount;
  }
  public int getGreyVal()
  {
    return greyVal;
  }
  public void addPX()
  {
    pxCount++;
  }
 
  
}

//Histogram for keeping track of pixel distributions
class PixelHistogram
{
  HistBucket[] buckets;
  PixelHistogram()
  {
    buckets = new HistBucket[256];
    for(int i = 0; i < 256; i++)
    {
      buckets[i] = new HistBucket(i);
    }
  }
  public void addPX(int g)
  {
    buckets[g].addPX();
  }
  public void drawHist(int sx, int sy, int c)
  {
    stroke(c);
    line(sx,sy,sx+255,sy);
    for(int i = 0; i < 256; i++)
    {
      HistBucket h = buckets[i];
      line(sx+i,sy,sx+i,sy-(int)(h.getPxCount()/10));
    }
  }
  
  public void drawHist(int sx, int sy, int c0, int c1, int thresh)
  {
    stroke(c0);
    line(sx,sy,sx+255,sy);
    for(int i = 0; i < 256; i++)
    {
      HistBucket h = buckets[i];
      if(i >= thresh)
      {
        stroke(c1);
      }
      else
      {
        stroke(c0);
      }
      line(sx+i,sy,sx+i,sy-(int)(h.getPxCount()/10));
    }
  }
  
  //get threshold corresponding to a given percentile
   public int getThreshPercentile(int percentile)
  {
    int total = 0;
    for(HistBucket h: buckets)
    {
      total+=h.getPxCount();
    }
    int num_pix= Math.round(total*(percentile/100.0));
    int running_total = 0;

    for(int i = 255; i > 0; i--)
    {
      running_total += buckets[i].getPxCount();
      if(running_total > num_pix)
      {
        return i + 1;
      }
    }
    return 0;
  }
}

void setup()
{
  size(600,512);
  xsize = 600;
  imgxsize = imgysize = 256;
  //two images for comparison
  img = loadImage("../LennaSmall.png");  // Load the image into the program
  imgDark = loadImage("../LennaDarkSmall.png");
  frame = 0;
  scene = 0;
  frameRate(10);
  x = 0;
  y = 0;
  hist = new PixelHistogram();
  histDark = new PixelHistogram();
  font = createFont("Calibri.ttf",18);
  textFont(font);
  frame = scene = x = y  = sum1 = sum2;
  thresh1 = thresh2 = 255;
  thresh1found = thresh2found = false;
  percentile = 25;
  goalpx = Math.round(imgxsize * imgysize * (percentile/100.0));
}

void draw()
{
    frame++;
  background(0,0,0);
    image(img,0,0);
    image(imgDark,0,imgysize);
  if(scene == 0) //scene 1: greyscale
  {
   
    if(frame <= 10) return;
    else
    {
      text("Step 1: Grey scale", xsize - 260, 15);
      if(frame >=20)
      {
         loadPixels();
    doGreyscale(pixels);
    updatePixels();
    }
    if(frame > 40)
    {
      scene = 1;
      frame = 0;
    }
  }
  }
  else if (scene == 1) //histogram
  {
    loadPixels();
    doGreyscale(pixels);
    if(frame == 1)
    {
      //fill histograms
      hist = new PixelHistogram();
      histDark = new PixelHistogram();
      fillHist(hist, pixels, 0, imgysize);
      fillHist(histDark, pixels, imgysize, 2*imgysize);
    }
   updatePixels();
   if(frame >= 10)
   {
     //draw histograms
     hist.drawHist(xsize - 260, imgysize, color(255));
     histDark.drawHist(xsize - 260, imgysize*2 - 10, color(255));
   }
    
    text("Step 2: Histogram",xsize - 260,15);
    
    if (frame > 40)
    {
      frame = 0;
      scene = 2;
    }
  }
  else if (scene == 2) //finding threshold
  {
    loadPixels();
    doGreyscale(pixels);
    updatePixels();
    text("Step 3: Percentile",xsize - 260,15);
    if(frame < 10)
    {
       hist.drawHist(xsize - 260, imgysize, color(255));
       histDark.drawHist(xsize - 260, imgysize*2 - 10, color(255));
      return;
    }
    if(frame <= 265)
    {
      //decrement threshold, see if percentile is reached
      if(!thresh1found)
      {
        if(sum1 >= goalpx) 
        {
          thresh1found = true;
          thresh1 = thresh1 + 1;
        }
        else
        {
          sum1 += hist.buckets[thresh1].getPxCount();
          thresh1--;
          
        }
      }
      if(!thresh2found)
      {
        if(sum2 >= goalpx)
        {
          thresh2found = true;
          thresh2 = thresh2 + 1;
        }
        else
        {
          sum2 += histDark.buckets[thresh2].getPxCount();
          thresh2--;
        }
      }
      hist.drawHist(xsize - 260, imgysize, color(255), color(100),thresh1);
      histDark.drawHist(xsize - 260, 2*imgysize - 10, color(255), color(100),thresh2);
      if(frame == 265)
      {
        scene = 3;
        frame = 0;
      }
    }
  }
  else if(scene == 3) //simple thresholding with found value
  {
 //   println("thresh1: " + thresh1);
 //   println("thresh2: " + thresh2);
    loadPixels();
    doGreyscale(pixels);
    if(frame > 10)
    {
      for(int i = 0; i < imgysize; i++)
      {
        for(int j=0; j < imgxsize; j++)
        {
          color c = pixels[i*xsize+j];
          if(red(c) >= thresh1) pixels[i*xsize+j] = color(255);
          else pixels[i*xsize+j] = color(0);
        }
      }
      
      for(int i = imgysize; i < imgysize*2; i++)
      {
        for(int j=0; j < imgxsize; j++)
        {
          color c = pixels[i*xsize+j];
          if(red(c) >= thresh2) pixels[i*xsize+j] = color(255);
          else pixels[i*xsize+j] = color(0);
        }
      }
    }
    updatePixels();
    
    //show histograms
    hist.drawHist(xsize - 260, imgysize, color(255), color(100),thresh1);
    histDark.drawHist(xsize - 260, 2*imgysize - 10, color(255), color(100),thresh2);
    text("Step 4: Threshold",xsize - 260,15);
  }
 
  
}

//fill histogram from pixel histogram selection
void fillHist(PixelHistogram ph, color[]px, int minY, int maxY)
{
  println("in fill hist");
  for(int i = minY; i < maxY; i ++)
  {
    for(int j = 0; j < imgxsize; j++)
    {
      color c = px[i*xsize+j];
      ph.addPX((int)red(c));
    }
  }
}

//convert pixel array to grey scale
void doGreyscale(color[]px)
{
    for(int i = 0; i < px.length; i++)
    {
     color c = px[i]; 
     float red = red(c);
     float green = green(c);
     float blue = blue(c);
     float maxg = max(red,green);
     maxg = max(maxg,blue);
     px[i]=color(maxg);
    }
}