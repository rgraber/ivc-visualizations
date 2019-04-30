PImage img;

int direction = 1;

int signalx = 0;
int signaly = 0;

void setup() {
  size(512, 512);
  noFill();

 
  frameRate(30);
  // The image file must be in the data folder of the current sketch 
  // to load successfully
  img = loadImage("../Lenna.png");  // Load the image into the program  
}

void draw() {
  float maxg = 0;
  println("X: " + signalx); //<>//
  println("Y: " + signaly);
  if(signaly >= 512)
  {
    signaly=0;
    signalx+=1;
  }
  if(signalx >= 512)
  {
    signaly=0;
    signalx=0;
  }
  
  else
  { 
    if(signalx == 0 && signaly == 0)
    {
      image(img,0,0);
    }
      
    loadPixels();
    color c = img.get(signaly,signalx);
    float red = red(c);
    float green = green(c);
    float blue = blue(c);
    println("RGB: " + red + "," + green + "," + blue);
    maxg = max(red,green);
    println("Max: " + maxg);
    maxg = max(maxg,blue);
    
    if(maxg > 200)
    {
      pixels[signalx*512+signaly]=color(255);
    }
    else
    {
      pixels[signalx*512+signaly]=color(0);
    }
      updatePixels();
   }
 signaly++;
}