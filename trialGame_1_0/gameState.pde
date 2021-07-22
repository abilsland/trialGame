class gameState{
  int state;
  int lastState; //returning from gamestates 7 and 10, the text needs to be offset because of 3D translations - this keeps track of the last state
  int offset;
  
 //number of player options for trial drug - call from length of drug array
  int numDrugs;

 //String array holds options for player selection of the trial drug 
 //Drug array should be initialised first and drugArray[].compoundName used for theDrugs[] 
  String[] theDrugs;
  int arrayPosition;
  String[][] drugInfo;
  
  //floats to hold the dose ranges - pass these to the drug slider object minDOse and maxDose variables in the main game
  float minDose;
  float maxDose;
  
  //flag to check if we have a cohort or not
  Boolean cohortFlag;

  //flag to check if the cohort is treated or not
  Boolean cohortTreated;
  
  //cohort array position
  int cohortArrayPosn;
  
  //number of deaths in a cohort
  int numDead;
  
 //change the game state  
  Button start; //move to compound selection game state
  Button compoundSelect; //choose compound and move to new gamestate
  Button shuffleCompounds; //move through the Drug array
  Button requestConsent; //move away from patient information at recruitment - doubles as "return to clinic" after treatment
  
  //choose dose levels (gstate9)
  Button range1;
  Button range2;
  Button range3;
  Button range4;
  
  //SimpleOpenNI object - pass kinect to this variable
  SimpleOpenNI context;
 
  //class for drawing radiology features
  PETscanFeatures scan;
  
  //image array to display compounds
  PImage[] cpdStructures;
  
 //array for user pixels
 int[] userMap;

 //PImage to draw user scan in gstate(8) - pass to the PETscanFeatures object
 PImage userImage = new PImage(640,480);
 
 //counter for delay on gstate(8) and gstate(10)
 int counter;
 
 //instantiate with gState = 1 to call start screen
  gameState(int gState, int compounds, SimpleOpenNI tempNI){
    state = gState;
    numDrugs = compounds;
    theDrugs = new String[numDrugs];
    drugInfo = new String[numDrugs][3];//currently only store target, ic50 and animal dose
    cpdStructures = new PImage[numDrugs]; //pass in the images from the drug object
    start = new Button(width/2-100, height/2-100, 50, "gamestate");
    compoundSelect = new Button(width/2+120, height/2-100, 50, "gamestate");
    shuffleCompounds = new Button(width/2 + 120, height/2 -200, 50, "gamestate");
    requestConsent = new Button(width/2, 175,50, "gamestate");
    
    range1 = new Button(width/2-150, height/2 +25, 50, "gamestate");
    range2 = new Button(width/2-50, height/2 +25, 50, "gamestate");
    range3 = new Button(width/2+50, height/2 +25, 50, "gamestate");
    range4 = new Button(width/2+150, height/2 +25, 50, "gamestate");
    arrayPosition = 0;
    counter = 200;
    context = tempNI;
    scan = new PETscanFeatures(context, userImage);
    cohortArrayPosn = 0;
    numDead = 0;
  }
  
    
  int display(int gstate){
      if(gstate==1){//start screen
      background(0);
      fill(255);
      textSize(50);
      text("Phase I Cancer Trial: The Game", 120, height/2-200);
      text("do you dare to escalate the dose?", 110, height/2+200);      
      text("start", width/2 -150, height/2);
      
      start.showButton();       
    if((start.buttonPressed() || start.vectorButtonPressed(getRightHandVector(context)))  && !start.isPressed()){
      state++;
      start.clear();
      return state; 
      }
      } 
      
      else if(gstate == 2){//drug selection screen
      background(0);      
      fill(255);
      //two buttons - one to flip through compounds, one to select player choice and move to next game state
      textSize(20);
      text("change drug", width/2 + 170, height/2-200);
      shuffleCompounds.showButton();
      textSize(20);
      text("select drug", width/2 +170, height/2-100);
      compoundSelect.showButton();

      textSize(30);
      text("use top button to choose compound then press select", 80, 50);//right button is shuffleCompounds
      
      //arrow to indicate function of shuffleCompound button
      //noStroke();
      //rect(width - 180, height/2 -220, 20, 80);
      //triangle(width - 200, height/2 -220, width - 170, height/2 -250,width- 140, height/2 -220);
      
      //show the drug structure
      cpdStructures[arrayPosition].resize(0, 250);
      stroke(255);
      image(cpdStructures[arrayPosition], width/2+100, height/2);
      
      for(int i = 0; i < 3; i++){
        text(drugInfo[arrayPosition][i], 20, height/2 + 100 + i *50);
      }

      if((shuffleCompounds.buttonPressed() || shuffleCompounds.vectorButtonPressed(getRightHandVector(context))) && !shuffleCompounds.isPressed()){
      
      if(arrayPosition==numDrugs-1){
      arrayPosition = 0;
      }  else {
      arrayPosition++;
      }

      }   
        textSize(40);
       fill(255);
      text(("current selection: " + theDrugs[arrayPosition]), 50, height/2);    
      
      if((compoundSelect.buttonPressed() || compoundSelect.vectorButtonPressed(getRightHandVector(context))) && !compoundSelect.isPressed()){
      state = 3;
      //text(state , 100, 100);
      }
      if(context == null){ //kinectConnected is false
      compoundSelect.clear();
      shuffleCompounds.clear();
      } else { //if kinect is on, need to use the vector clear funtion to set button.wasJustPressed
      compoundSelect.clearVector(getRightHandVector(context));
      shuffleCompounds.clearVector(getRightHandVector(context));
      }    
      return arrayPosition;
      }
      
      else if(gstate==8){
      //checkLastState10();
      textAlign(LEFT);
      //display patient details
      //we will call this after each new patient is recruited and after treatment
      //we now need to check if we have a patient or a cohort
      //we assign the boolecan cohortFlag in the recruitment state(3)



      textSize(50);
      fill(255);
      
      if(!cohortFlag){
      //if(counter>0){
      //check the patient object in the PETscanFeatures object to find out if the patient is treated
      //if not, scan is baseline - otherwise scan is "best response"

      textSize(30);
      fill(255);
      if(!scan.thePatient.isTreated()){
      requestConsent.centreX=width/2;
      requestConsent.centreY=175;
      text("Displaying baseline clinicopathology", 20, 50);
      text("Request patient consent", 100, 185);
      
      //ONLY DISPLAY THE HISTOLOGY AT BASELINE
      //THIS GIVES SPACE ON THE SCREEN TO MOVE THE BUTTON THAT SHIFTS THE GAMESTATE
      //RETURN TO RECUITMENT BUTTON NEEDS TO BE FAR AWAY FROM THE RECRUIT PATIENTS BUTTONS
      scan.drawHistology();      
      fill(0);
      textSize(45);
      text("archival core image", 10, 320);
      fill(255);       
      } else if(scan.thePatient.isTreated()){
      requestConsent.centreX=width/2;
      requestConsent.centreY=height/2;        
      text("Clinicopathology at worst event", 20, 50);
      text("Return patient case report", 60, height/2+10);
      }

      requestConsent.showButton(); //to move on from current patient details
      
      textSize(30);
      //display patient data from the patient object in the PETscanFeatures object
      text(scan.thePatient.age + "y old", 640, 50);
      if(scan.thePatient.sex == 0){
        text(" male patient", 755, 50);
      } else {
        text(" female patient", 755, 50);       
      } 
      text("Stage " + scan.thePatient.stage + " " +scan.thePatient.primary, 640, 100);
      
      //SUV is adjusted depending on whether the patient responds to treatment
      //this is done by Drug.applyRecistToSUV()
      //this is used to adjust the ellipse size in the PETscanFeatures object pre/post treatment
      text("SUVmax " + String.format("%.1f",scan.thePatient.SUV) + " g/ml", 640, 150);     
      text("Patient number " + scan.thePatient.patientNumber, 640, 300);
      text("Neutrophils " + String.format("%.1f",scan.thePatient.neutrophils)+ "/ul", 640, 350);
      text("Platelets " + String.format("%.1f",scan.thePatient.platelets) + " E9/l", 640, 400);
      text("Hb " + String.format("%.1f",scan.thePatient.haemoglobin) + " g/dl", 640, 450);
      text("ALT " + String.format("%.1f",scan.thePatient.ALT) + " U/l", 640, 500);
      text("AST " + String.format("%.1f",scan.thePatient.AST) + " U/l", 640, 550);
      text("Bilirubin " + String.format("%.1f",scan.thePatient.bilirubin) + " mg/dl", 640, 600);      
      text("Renal rate " + String.format("%.1f",scan.thePatient.glom_filt), 640, 650); 
 
      //if patient treated, show dose
      if(scan.thePatient.isTreated()){
      text("treatment dose:", 640, 200);
      text(scan.thePatient.doseGiven, 640, 250);
      } else if(!scan.thePatient.isTreated()){
      //show the baseline performance score if not yet treated
      text("ECOG PS: " + scan.thePatient.PS, 640, 200);     
      }
      

      
      if((requestConsent.buttonPressed() || requestConsent.vectorButtonPressed(getRightHandVector(context))) && !requestConsent.isPressed()){
        //now swap the gamestate
        //if the patient is not yet treated, go to dose selection and reset counter
        //if the patient is already treated, back to recruitment page
        
      if(!scan.thePatient.isTreated()){
        state=7;
        return 0;    
      } else if(scan.thePatient.isTreated()){
        state=3;
        return 0;    
      }         
      }
      
      
      
      } else if (cohort) {//if we have a cohort, we need to work with a patient array rather than single patient
      //PETscanFeatures.drawScan() uses a Patient object called thePatient to draw the scan
      //to avoid a null pointer exception, we need to let scan.thePatient equal the current element of scan.theCohort
      //println("got to here in state 8");
      
       background(0);

           
      //drawScan uses scan.thePatient - we have to set this variable to avoid a null pointer
      //this also means the code above could be tidied by setting this at the top and working with thePatient instead of the array
      scan.thePatient = scan.theCohort[cohortArrayPosn];

      //WE HAVE A COHORT, SO WE NEED TO DO THE DISPLAY FOR EACH PATIENT IN THE ARRAY
      //check the patient objects in the PETscanFeatures patient array to find out if the cohort is treated
      //if not, scan is baseline - otherwise scan is "best response"
     
      textSize(30);
      fill(255);
      if(!cohortTreated){
      requestConsent.centreX=width/2;
      requestConsent.centreY=175;
      text("Displaying baseline clinicopathology", 20, 50);
      text("Request patient consent", 100, 185);
      
      //ONLY DRAW HISTOLOGY AT BASELINE
      scan.drawHistology();
      fill(0);
      textSize(45);
      text("archival core image", 10, 320);
      fill(255);
      textSize(30); 
      
      } else if(cohortTreated){
      requestConsent.centreX=width/2;
      requestConsent.centreY=height/2;
      text("Clinicopathology at worst event", 20, 50);
      text("Return patient case report", 60, height/2+10);
      }      
      
      requestConsent.showButton(); //to move on from current patient details
      
      //display patient data from the patient array in the PETscanFeatures object
      textSize(30);
      fill(255);
      
      //NOTE THAT THE BACKGROUND IS SET TO 0 BELOW TO OVERDRAW EACH PATIENT IN THE COHORT
      //IF WE NEED TO DRAW ON TOP (THE REQUEST CONSENT BUTTON) IT NEEDS TO COME AFTER THIS INSTRUCTION
        if((requestConsent.buttonPressed() || requestConsent.vectorButtonPressed(getRightHandVector(context))) && !requestConsent.isPressed()){
        //now swap the gamestate
        //if the patient is not yet treated, go to dose selection and reset counter
        //if the patient is already treated, back to recruitment page
      
      if(cohortArrayPosn<2){
        cohortArrayPosn++;
      } else if(cohortArrayPosn==2){
        if(!cohortTreated){
        state=7;//if not treated, go to dose selectiion
        cohortArrayPosn = 0;
        return 0;      
        } else if(cohortTreated){
        state=3;//if treated go to tox checking
        cohortArrayPosn = 0;
        return 0;    
        }
        }        
      }//requestConsent
      
      fill(255);
      
      //only attempt to display data if the array position is not null
      if(scan.theCohort[cohortArrayPosn] != null){
      text(scan.theCohort[cohortArrayPosn].age + "y old", 640, 50);
      if(scan.theCohort[cohortArrayPosn].sex == 0){
        text(" male patient", 755, 50);
      } else {
        text(" female patient", 755, 50);       
      } 
      text("Stage " + scan.theCohort[cohortArrayPosn].stage + " " + scan.theCohort[cohortArrayPosn].primary, 640, 100);
      
      //SUV is adjusted depending on whether the patient responds to treatment
      //this is done by Drug.applyRecistToSUV()
      //this is used to adjust the ellipse size in the PETscanFeatures object pre/post treatment
      text("SUVmax " + String.format("%.1f",scan.theCohort[cohortArrayPosn].SUV) + " g/ml", 640, 150);     
      text("Patient number " + scan.theCohort[cohortArrayPosn].patientNumber, 640, 300);
      text("Neutrophils " + String.format("%.1f",scan.theCohort[cohortArrayPosn].neutrophils)+ "/ul", 640, 350);
      text("Platelets " + String.format("%.1f",scan.theCohort[cohortArrayPosn].platelets) + " E9/l", 640, 400);
      text("Hb " + String.format("%.1f",scan.theCohort[cohortArrayPosn].haemoglobin) + " g/dl", 640, 450);
      text("ALT " + String.format("%.1f",scan.theCohort[cohortArrayPosn].ALT) + " U/l", 640, 500);
      text("AST " + String.format("%.1f",scan.theCohort[cohortArrayPosn].AST) + " U/l", 640, 550);
      text("Bilirubin " + String.format("%.1f",scan.theCohort[cohortArrayPosn].bilirubin) + " mg/dl", 640, 600);      
      text("Renal rate " + String.format("%.1f",scan.theCohort[cohortArrayPosn].glom_filt), 640, 650); 
      
      //if patient treated, show dose
      if(cohortTreated){
      text("treatment dose:", 640, 200);
      text(scan.theCohort[cohortArrayPosn].doseGiven, 640, 250);
      } else if(!cohortTreated){
      //show the baseline performance score if not yet treated
      text("ECOG PS: " + scan.theCohort[cohortArrayPosn].PS, 640, 200);
      }


      } else {//check for nullity
      counter=0; //if position is null, set the counter to zero to avoid delay
      }
      }//check on cohort
      lastState = 8;
      
      requestConsent.clear();
      requestConsent.clearVector(getRightHandVector(context));
      
    }//gstate(8)
    else if(gstate==9){ //new gamestate to choose an initial dose range
    //checkLastState();
    textAlign(LEFT);
    textSize(30);
    fill(255);
    text("choose dose range to test (mg/m^2 daily)", (width/2-250), 100);
    text("10^0-10^1", range1.centreX-80, range1.centreY-70);
    range1.showButton();
    text("10^1-10^2", range2.centreX-80, range2.centreY+70);        
    range2.showButton();
    text("10^2-10^3", range3.centreX-80, range3.centreY-70);    
    range3.showButton();
    text("10^3-10^4", range4.centreX-80, range4.centreY+70);     
    range4.showButton();
    if(range1.buttonPressed() && !range1.isPressed()){
    minDose = 1;// this will be the min value of the drug slider object
    maxDose = 10;// this will be the max value of the drug slider object
    state = 8;//go to radiology and dose selection   
    } else if(range2.buttonPressed() && !range2.isPressed()){
    minDose = 10;
    maxDose = 100;
    state = 8;  
    } else if(range3.buttonPressed() && !range3.isPressed()){
    minDose = 100;
    maxDose = 1000;
    state = 8;  
    } else if(range4.buttonPressed() && !range4.isPressed()){
    minDose = 1000;
    maxDose = 10000;
    state = 8;  
    }
    
   //clear the buttons
   if(context == null){ //kinectConnected is false
   range1.clear();
   range2.clear();
   range3.clear();
   range4.clear();
   } else {//if kinect on, use vector clear
   range1.clearVector(getRightHandVector(context));
   range2.clearVector(getRightHandVector(context));
   range3.clearVector(getRightHandVector(context));
   range4.clearVector(getRightHandVector(context));
   }
    } else if(gstate==10){//gstate(9) end
     lastState = 10;
    //THIS IS THE TOXIC DEATH SCREEN!!!!
    //WE ALSO WANT TO CALL A MINIM OBJECT HERE FOR THE MACHINE THAT GOES "ooooooooooo"
      if(counter>0){
      textSize(50);
      color bckgd1 = color(0,0,0);
      color bckgd2 = color(255,0,0);
      if(frameCount%5==0){
      background(bckgd1);
      }else{
      background(bckgd2);
      }
      if(frameCount%5==0){
      fill(255);
      }else{
      fill(0);
      } 
      textSize(100);
      text("TOXIC DEATH", width/2-50, height/2);
      
      //if we have a cohort, display the patient numbers that died
      if(cohortFlag){
        for(int i=0; i<scan.theCohort.length; i++){
         if(scan.theCohort[i].fatalToxicity){//if the patient in array position i is dead
         textSize(50);
          text("Patient " + scan.theCohort[i].patientNumber + " died" , width/2-50, 100+i*50);
         }//fatality check
        }//loop through patients
      }//cohort check
      counter=counter-1;
      return 0;//do not increment the deaths on trial until the counter hits zero
      } else if(counter==0){
      //swap the game state back to recruitment, reinitialise the counter
      //NOTE: for a single patient, we can nullify the patient in the game
      state = 3;
      counter = 200;

      //for a cohort, we are passing the newCohort to scan.theCohort every time this code runs
      //so, we need to nullify them here only once the counter hits zero then pass this back to newCohort in the game
      //OTHERWISE WE WILL HAVE A NULL POINTER!
      if(cohortFlag){
        numDead = 0;
        for(int i=0; i<scan.theCohort.length; i++){
          if(scan.theCohort[i].fatalToxicity){
            scan.theCohort[i] = null;
            numDead++;
          }
        }
      //return numDead in the cohort to increment deaths in the game
      return numDead;
      } else {
      //return the value 1 to increment numDeaths in the game for a single patient
      }
      return 1;
      }//counter
      }//gstate(10)
  
      
//default return 
return 0;
  }
  
  PVector getRightHandVector(SimpleOpenNI tempContext){
  //make vector list of ints to store users
  
  //check if SimpleOpenNI object is initialised
  //if not, kinectConnected flag from gamespace is false
  IntVector userList = new IntVector();
  PVector convertedRightHand = new PVector();

  //check if SimpleOpenNI object is initialised
  //if not, kinectConnected flag from gamespace is false
  
  if(tempContext != null){
    //write list of detected users to vector
  tempContext.getUsers(userList);
  
  //if find users
  if(userList.size() > 0) {
    //get first user ID
    int userID = userList.get(0);
    
    //if calibration successful
    if(context.isTrackingSkeleton(userID)){
      //make vector to store skeleton left hand
      //NOTE L/R in skeleton tracking are from POINT OF VIEW OF SCREEN: left on screen = right of user facing kinect
      //so, call skeleton left hand to track user right hand
      PVector rightHand = new PVector();
      
      //put posiion of skeleon left hand ino vecor
      float confidence = context.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_LEFT_HAND, rightHand);
      
      //convert detected hand position to projective coords to match depth image
      context.convertRealWorldToProjective(rightHand, convertedRightHand);
      
      //move the ellipse right when the user moves their hand right
      //NOTE that this also has an effect on the return vector which is used in vectorButtonPress() in button class     
      convertedRightHand.x = width-convertedRightHand.x;
      //now, display
      pushMatrix();
      noStroke();
      fill(255,0,0);
      ellipse(convertedRightHand.x, convertedRightHand.y, 20, 20);
      popMatrix();
    } // end if(isTrackinhSkeleton)
  } //end if(userList > 0)
  
  return convertedRightHand;
  } else {//if the SimpleOpenNI object is not initialised
  //default return
  PVector defaultVector = new PVector();
  defaultVector.set(0.0,0.0,0.0);
  return defaultVector;
  }//end check for kinect
  }//end getRightHandVector
  
  
  /*.................................
  WE DON'T NEED THESE. WE JUST NEED TO CALL TextAlign(LEFT) in states 3, 5, 8, 9
  void checkLastState(){
    if(lastState == 7 || lastState == 10){
      offset = 50;
    } else {
      offset = 0;
    }
  }

  void checkLastState10(){
    if(lastState == 10){
  rotateX(radians(-180)); 
  }
  }
  
  ........................................*/
  
  }//end class
