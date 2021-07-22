class SlidingScale{
  //This class is used by Drug to control dose level
  //displays a sliding scale selector
  
  //coordinates of the 2 slider rectangles
  float rect1vertex1X;
  float rect1vertex1Y;
  float rect1width;
  float rect1height;
  float rect2vertex1X;
  float rect2vertex1Y;
  float rect2width;
  float rect2height;
  String sliderInstructions;
  
  //we will now constrain the displayed slider outvalue to be one of several levels defined by the drug numDoses variable
  //the drug object will call getSliderValue() and apply Drug.assignDose() to determine the dose level
  //this is then passed back to the variable outVal to be displayed in SlidingScale.displayUsingFlag()
  float outVal;
  
  //upper and lower values of the slider
  float maxVal;
  float minVal;
  
  //actual value of the slider
  float sliderOutVal;
  
  SlidingScale(float[] sliderData, float min, float max, String instructions){
    rect1vertex1X = sliderData[0];
    rect1vertex1Y = sliderData[1];
    rect1width = sliderData[2];
    rect1height = sliderData[3];
    rect2vertex1X = rect1vertex1X - 10;
    rect2vertex1Y = rect1vertex1Y + rect1height;
    rect2width = rect1width + 20;
    rect2height = rect1height/10;
    minVal = min;
    maxVal = max;
    sliderInstructions = instructions;
    outVal = 0; //default - the drug object will assign this
  }
  
  void display(){
    textSize(20);
    textAlign(CENTER);
    pushMatrix();
    translate(rect1vertex1X + rect1width + 20, rect1vertex1Y + rect1height/2);    
    rotate(HALF_PI);
    text(sliderInstructions,0 ,0);
    popMatrix();
    fill(0);
    rect(rect1vertex1X, rect1vertex1Y, rect1width, rect1height);
    fill(155);
    rect(rect2vertex1X, rect2vertex1Y, rect2width, rect2height);
    fill(0);
    textSize(20);
    text(getSliderValue(), rect1vertex1X - 50, rect1vertex1Y + rect1height/2);
    text(("max = " + maxVal), rect1vertex1X - 50, rect1vertex1Y);
    text(("min = " + minVal), rect1vertex1X - 50, rect1vertex1Y + rect1height);
  }

  void displayUsingFlag(boolean Flag){
    //use this version if kinectConnected flag is true
    //need to adjust for translations and rotations to display kinect and syringe model
    textSize(20);
    if(Flag){
    textAlign(CENTER);
    pushMatrix();
    rotateX(radians(180));
    translate(-width/2, -height/2, 0);
    fill(0);
    rect(rect1vertex1X, rect1vertex1Y, rect1width, rect1height);
    fill(155);
    rect(rect2vertex1X, rect2vertex1Y, rect2width, rect2height);
    fill(0);
    textSize(50);
    text((int) outVal, rect1vertex1X - 100, rect1vertex1Y + rect1height/2);
    textSize(20);
    text(("max = " + maxVal), rect1vertex1X - 50, rect1vertex1Y);
    text(("min = " + minVal), rect1vertex1X - 50, rect1vertex1Y + rect1height);
        pushMatrix();
        translate(rect1vertex1X + rect1width + 20, rect1vertex1Y + rect1height/2);    
        rotate(HALF_PI);
        text(sliderInstructions,0 ,0);
        popMatrix();
    popMatrix();
    }//end if
  }
  
  void moveSliderByVectorMagnitude(float mag){
    //range chosen based on experiment with kinect
    //we are taking the value of mag from the distance between a users' hands
    //obtained from kinect data - may need to hone range
    rect2vertex1Y = map(mag, 50, 1300, rect1vertex1Y + rect1height, rect1vertex1Y);
  }
  
  boolean moveSliderUp(){
    //test if mouse is within X range of slider rectangle 2
    //AND if is in upper half of rectangle 2
    //STOP if mouseY reaches top of first rectangle
    return mouseX>rect2vertex1X && mouseX<rect2vertex1X+rect2width && mouseY<rect2vertex1Y+rect2height/2 && mouseY>rect2vertex1Y && rect2vertex1Y > rect1vertex1Y;
  }
  
  boolean moveSliderDown(){
    //test if mouse is within X range of slider rectangle 2
    //AND if is in lower half of rectangle 2
    //STOP if mouseY reaches bottom of first rectangle
    return mouseX>rect2vertex1X && mouseX<rect2vertex1X+rect2width && mouseY>rect2vertex1Y+rect2height/2 && mouseY<rect2vertex1Y+rect2height && rect2vertex1Y < rect1vertex1Y + rect1height;
  } 
  
  void moveScale(){
   if(moveSliderUp()){
     rect2vertex1Y = rect2vertex1Y - 1;
   } else if(moveSliderDown()){
     rect2vertex1Y = rect2vertex1Y + 1;
   }
   display();
  }
  
  float getSliderValue(){
  //map top edge of rect2 to slider range
  //remember that rect1vertex1Y + rect1height is lower edge
  sliderOutVal = map(rect2vertex1Y, rect1vertex1Y + rect1height, rect1vertex1Y, minVal, maxVal);
  return sliderOutVal;
  }
  
}

