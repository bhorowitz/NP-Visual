float x, y;
float angle = 0;
float  prevX=0.0, prevY=-500/3;
int samples = 200;
int bins = 50;
int flagsampling = 0;
float[] dataPoints = new float[samples];

int rectX, rectY;      // Position of square button
int rectSizeX = 90;     
int rectSizeY = 20;     

color rectColor, rectHighlight;
boolean rectOver = false;

int binrectX, binrectY;      // Position of square button
int binrectSizeX = 400;     
int binrectSizeY = 20;     
int boxlocation = 50;
int sboxlocation = 50;
int samplerectY;
boolean binrectOver = false;
boolean samplerectOver = false;

void setup()
{
  size(500, 500);
  background(100);
  smooth();
  stroke(255);
  noLoop();
  rectColor = color(51);
  rectHighlight = color(0);
  
  rectX = width-(width/5);
  rectY = rectSizeY;
  binrectX = width/10;
  binrectY = height - 70;
  samplerectY = height - 30;
    ellipseMode(CENTER);

}


void draw()
{
  background(0); 
  // Draw Text
  fill(200);
  text("sample rate: " + str(samples), 10, 30); 
  text("bin rate: " + str(bins), 10, 50); 

  text("Bins", 10, 445); 
  text("Points", 10, 485); 

  // Draw resampling button
  update(mouseX, mouseY);
   fill(rectHighlight);

  rect(rectX, rectY, rectSizeX, rectSizeY);
  fill(200);
  text("resample", rectX+rectSizeX/4, rectY+2*rectSizeY/3); 
  fill(rectColor);
  
  // Draw bin rectangle
  
  draw_binrect();
  fill(rectColor);
  draw_samplerect();
  fill(rectColor);
  translate(0, height/2);
  scale(1, -1);
  if(flagsampling ==0){
  dataPoints = gaussianDistribute(3000, samples, 0, 500);
  }
  
  draw_histogram(samples, dataPoints, bins);
  
 // Draw data points
 
 draw_datapoints(samples, dataPoints);
 
 // draw kde
 
 draw_kdegaussian(samples, dataPoints);
 
  
}
 
void draw_binrect(){
  rect(binrectX, binrectY, binrectSizeX, binrectSizeY);
  if(binrectOver){
  if(mouseX<binrectX){
    boxlocation=binrectX;
  }
  else{
    if(mouseX>binrectX+binrectSizeX-binrectSizeY){
    boxlocation=binrectSizeX+binrectX-binrectSizeY;
    }
    else{
      boxlocation=mouseX;
    }
  }
  }
  fill(200);
  rect(boxlocation, binrectY, binrectSizeY, binrectSizeY);
}

void draw_samplerect(){
  rect(binrectX, samplerectY, binrectSizeX, binrectSizeY);
  if(samplerectOver){
  if(mouseX<binrectX){
    sboxlocation=binrectX;
  }
  else{
    if(mouseX>binrectX+binrectSizeX-binrectSizeY){
    sboxlocation=binrectSizeX+binrectX-binrectSizeY;
    }
    else{
      sboxlocation=mouseX;
    }
  }
  }
  fill(200);
  rect(sboxlocation, samplerectY, binrectSizeY, binrectSizeY);
}

void draw_datapoints(int samples, float[] dataPoints){

for(int count=0; count < samples; ++count)
  {
    ellipse(int(dataPoints[count]), int(2*height/5 -10), 1, 1);
  }
}

void draw_histogram(int samples, float[] dataPoints, int bins){


  int[] histograms = Histogram(dataPoints, bins, 0, width);
  int histfactor = floor((height/(samples))*bins/4);

  float binsf = (float) bins;
  float widthf = (float) width;
  float stepsize = (float) (widthf/binsf);
  
   for(int count=0; count < bins; ++count)
   {
      rect(int(count*stepsize), int(-height/3), int(stepsize-4), int(histfactor*histograms[count]));
    }
  }
  
void draw_kdegaussian(int samples, float[] dataPoints){
  float[] kde_points = new float[width];
 float[] gaussian_points = new float[width];
 float kde_int = 0;
 float gaussian_int = 0;
 for(int count=0; count <width; ++count)
 {
   kde_points[count]=kde(count, dataPoints, 400);
   kde_int = kde_int + kde_points[count];
   gaussian_points[count]=gaussian(count-width/2, 3000);
   gaussian_int = gaussian_int + gaussian_points[count];
 }
 float kde_factor = gaussian_int/kde_int;
   for(int count=0; count < width; ++count)
  {
    x = count;
 
    //y = (float) gaussian(x-width/2, numOfWaves*300); ////sin(angle*(numOfWaves/2.0));
    y = (float) kde_points[count]*kde_factor;///samples*3.5;
    y = map(y,-1,1,-height,int(height/3));
 
    line(int(prevX), int(prevY), int(x), int(y));
 
    prevX = x;
    prevY = y;
  }
 
  prevX = 0.0;
  prevY = -height/3;
     stroke(105);


   for(int count=0; count < width; ++count)
  {
    x = count;
 
    y = (float) gaussian_points[count]; ////sin(angle*(numOfWaves/2.0));
    //y = (float) kde(x, dataPoints, 50)/samples*5;
    y = map(y,-1,1,-height,int(height/3));
 
    line(int(prevX), int(prevY), int(x), int(y));
 
    prevX = x;
    prevY = y;
  }
    prevX = 0.0;
  prevY = -height/3;
      stroke(255);

}


void mouseReleased()
{
  update(mouseX,mouseY);
  switch(mouseButton)
  {
  case LEFT:
   // numOfWaves = 6;//int(1+mouseX/20.0);
   
    flagsampling = 1;
    if (rectOver) {
      flagsampling =0;
    }
    else{
      if (binrectOver){
    bins = int(mouseX/10 + 10);
      }
      if (samplerectOver){
      samples=int(mouseX);
      }
    }
    background(0);
    redraw();
    break;
  }
}

void update(int x, int y) {
  if ( overRect(rectX, rectY, rectSizeX, rectSizeY) ) {
    rectOver = true;
  } else {
    rectOver = false;
  }
 
  if ( overRect( binrectX, binrectY, binrectSizeX, binrectSizeY) ) {
    binrectOver = true;
  } else {
    binrectOver = false;
  }
  
  if ( overRect( binrectX, samplerectY, binrectSizeX, binrectSizeY) ) {
    samplerectOver = true;
    flagsampling =0;
  } else {
    samplerectOver = false;
  }
  
}


boolean overRect(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}


public float doublegaussian(float x, float std)
{
  return exp(-(x)*(x)/(std));
}

public float gaussian(float x, float std)
{
  return 0.5*(0.5*exp(-(x+200)*(x+200)/(std))+ 0.3*exp(-(x+100)*(x+100)/(std))+1.5*exp(-(x)*(x)/(std))+exp(-(x-100)*(x-100)/(std)));
}

public float kde(float x, float[] samples, float std)
{
    int size = samples.length;
    float y = 0;
  for(int count=0; count < size; ++count)
  {
    float offset = samples[count];
    y = y + exp(-(x-offset)*(x-offset)/(std));
    }
  return y;
}

public float[] gaussianDistribute(float std, int sample,double minX, double maxX)
{
  float values[] = new float[sample];
  double range = maxX - minX;
  //System.out.println(range);
  for(int count=0; count < sample;)
  {
    double xG1 = Math.random()*range + minX;
    float xG = (float) xG1;
    double yG1 = Math.random()*2;
    float yG = (float) yG1;
    if(gaussian(xG-width/2,std)>yG)
    {
      //float x = map(xG,(float) minX, (float) maxX,0,width);
      values[count]=xG;
      ++count;
    }
  }
  return values;
}


public int[] Histogram(float[] samples, int bins, double minX, double maxX)
{
  int values[] = new int[bins];
  float range = (float) (maxX - minX);
  float stepsize = (float) (range/bins);
  //System.out.println(range);
  int size = samples.length;
  for(int count=0; count < size; ++count)
  {
    int i = floor( (float) ((samples[count]-minX)/stepsize));
    ++values[i];
    }
 
  return values;
}


