PImage img;
PFont font;
int thresh, thresh1, thresh2;
int scene,frame;
int prevThresh1, prevThresh2;
PixelHistogram mainHist, t1Hist, t2Hist;


static int img_height = 256;
static int img_width = 256;
static int xsize = 512;


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
  size(512,768);
  scene =frame= thresh = thresh1 = thresh2 = prevThresh1 = prevThresh2 = 0;
  font = createFont("Calibri.ttf",32);
  img = loadImage("../appleEdit.jpg");
  mainHist = new PixelHistogram();
  t1Hist = new PixelHistogram();
  t2Hist = new PixelHistogram();
  frameRate(5);
}

void draw()
{
  background(0,0,0);
  frame++;
  image(img,0,img_height+1);
  text("T1 = ", img_width+15,15);
  text("T = ", img_width+15,img_height+15);
  text("T2 = ", img_width+15,2*img_height+15);

if(frame == 1)
{
   loadPixels();
      mainHist = new PixelHistogram();
      t1Hist = new PixelHistogram();
      t2Hist = new PixelHistogram();
      fillHist(mainHist, pixels, img_height+1,2*img_height+1);
      thresh = getAverage(mainHist);
      drawPartialImage(thresh,0,1);
      drawPartialImage(thresh,2*img_height, -1);
      fillHist(t1Hist, pixels, 0, img_height,true);
      fillHist(t2Hist, pixels, 2*img_height, 3* img_height,true);
      thresh1 = getAverage(t1Hist);
      thresh2 = getAverage(t2Hist);
      updatePixels();
}else if(frame%10 == 0)
{
  
  updateState();
}
   
  drawCurrentState();
}

void drawPartialImage(int thresh, int sy, int greater)
{
  //println("Thresh: " + thresh);
  for(int i=0; i < img_width; i++)
  {
    for(int j=0; j< img_height; j++)
    {
      int c = (int) red(pixels[(img_height + 1 + j)*xsize + i]);

      if (greater*c > greater*thresh)
      {
        pixels[(sy + j)*xsize + i] = color(c);
      }
      else
      {
        pixels[(sy + j)*xsize + i] = color(0);
      }
    }
  }
}

void fillHist(PixelHistogram ph, color[]px, int minY, int maxY)
{
  for(int i = minY; i < maxY; i ++)
  {
    for(int j = 0; j < img_width; j++)
    {
      color c = px[i*xsize+j];
      ph.addPX((int)red(c));
    }
  }
}

void fillHist(PixelHistogram ph, color[]px, int minY, int maxY, boolean partial)
{
  for(int i = minY; i < maxY; i ++)
  {
    for(int j = 0; j < img_width; j++)
    {
      int c = (int) red(px[i*xsize+j]);
      if(!partial || c > 0) ph.addPX(c);
    }
  }
}

void updateState()
{
   loadPixels();
      mainHist = new PixelHistogram();
      t1Hist = new PixelHistogram();
      t2Hist = new PixelHistogram();
      fillHist(mainHist, pixels, img_height+1,2*img_height+1);
      thresh = (thresh1 + thresh2)/2;
      println("Thresh 1: " + thresh1);
      println("Thresh 2: " + thresh2);
      println("Thresh 3: " + thresh);
      drawPartialImage(thresh,0,1);
      drawPartialImage(thresh,2*img_height, -1);
      fillHist(t1Hist, pixels, 0, img_height,true);
      fillHist(t2Hist, pixels, 2*img_height, 3* img_height,true);
      thresh1 = getAverage(t1Hist);
      thresh2 = getAverage(t2Hist);
      
      updatePixels();
}


void drawCurrentState()
{
  
  loadPixels();
  drawPartialImage(thresh,0,1);
  drawPartialImage(thresh,2*img_height, -1);
  updatePixels();
  mainHist.drawHist( img_width+20, 2*img_height - 10, color(255,0,0));
  line(img_width+20+thresh, 2*img_height - 10, img_width+20+thresh,img_height + 10 );
  
  t1Hist.drawHist(img_width+20, img_height - 10, color(100));
  line(img_width+20+thresh1, img_height - 10, img_width+20+thresh1, 10);
  
  t2Hist.drawHist(img_width+20, 3*img_height - 10, color(100));
  line(img_width+20+thresh2, 3*img_height - 10, img_width+20+thresh2, 2*img_height +10);
}


int getAverage(PixelHistogram ph)
{
  int sum = 0;
  int n = 0;
  for(int i =0; i <= 255; i++)
  {
    sum+=i*ph.buckets[i].getPxCount();
    n += ph.buckets[i].getPxCount();
    
  }
  
  if (n > 0) return (int) sum/n;
  else return 0;
}