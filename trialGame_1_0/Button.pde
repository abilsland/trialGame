class Button {
  int centreX;
  int centreY;
  int diameter;
  String buttonType;
  int buttonColour;
  int fillDefault = 255;
  Patient currentPatient;
  boolean wasJustPressed;
  int timesPressed;
  int callsToButton;
  
  //an ellipse can be drawn using skeleton joint data from kinect
  //this can be used to trigger the button
  PVector kinectJointData;
  int ellipseDiameter;
  
  Button(int cX, int cY, int diam, String type){
    centreX = cX;
    centreY = cY;
    diameter = diam;
    buttonType = type;
    timesPressed = 0;
    buttonColour = fillDefault;
    wasJustPressed = false;
    callsToButton = 0;
  }
  
  void showButton(){
    pushMatrix();
    fill(buttonColour);
    ellipse(centreX, centreY, diameter, diameter);
    popMatrix();
  }

//re-set button coords
void moveButton(int cX, int cY){
  centreX = cX;
  centreY = cY;
}

boolean vectorButtonPressed(PVector coords){
  //for use with kinect
  //pass coordinates of a joint position obtained from depth data to function
    //gives visual indication that button is pressed
    //the button is assumed to be circular and unpressed at the start
    boolean result = false;
    //use basic geometry to test if mouse is in the button area
    if(((centreX-coords.x)*(centreX-coords.x)+(centreY-coords.y)*(centreY-coords.y) < (diameter/2)*(diameter/2))){
      //button pressed
      pushMatrix();
      buttonColour = 155;
      //timesPressed++;
      result = true;
      popMatrix();     
    } else {
    //default button unpressed
    buttonColour = fillDefault;
    }    
    return result;
}
  
  boolean buttonPressed(){
    //gives visual indication that button is pressed
    //the button is assumed to be circular and unpressed at the start
    boolean result = false;
    //use basic geometry to test if mouse is in the button area
    if(((centreX-mouseX)*(centreX-mouseX)+(centreY-mouseY)*(centreY-mouseY) < (diameter/2)*(diameter/2))){
      //button pressed
      pushMatrix();
      buttonColour = 155;
      //timesPressed++;
      result = true;
      popMatrix();    
    } else {
    //default button unpressed
    buttonColour = fillDefault;
    }    
    return result;
    }

  boolean isPressed(){
    return wasJustPressed;
  }
  
  void clear(){
    wasJustPressed = buttonPressed();
  }
  
  void clearVector(PVector vec){
    wasJustPressed = vectorButtonPressed(vec);
  }

   String buttonHelp(){
     fill(255);
     String help = "This button does nothing at the moment";
     String other = "keep calm and carry on";
     if(buttonType == "help"){
     return help;
     } else { 
     return other;
   }
   }
   
   Patient addPatient(int numPatients){
   //This instantiates an object from the patient class and rtturns to the game space
   //sex and age currently random, patient number is number of times button pressed
   //ensure in game that each time button is pressed addPatient() is called
   currentPatient = new Patient((short) random(2), (short) random(50,80), numPatients);
   return currentPatient;
   }
   
    
    }//end class
