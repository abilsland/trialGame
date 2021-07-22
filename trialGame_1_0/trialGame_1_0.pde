/*

VERY VERY VERY IMPORTANT!!!!!!!!!!!!!
SAVE AS NEW VERSION BEFORE YOU START WORKING!!!!!!
SAVE AS NEW VERSION BEFORE YOU START WORKING!!!!!!
SAVE AS NEW VERSION BEFORE YOU START WORKING!!!!!!
SAVE AS NEW VERSION BEFORE YOU START WORKING!!!!!!
SAVE AS NEW VERSION BEFORE YOU START WORKING!!!!!!
SAVE AS NEW VERSION BEFORE YOU START WORKING!!!!!!
SAVE AS NEW VERSION BEFORE YOU START WORKING!!!!!!
SAVE AS NEW VERSION BEFORE YOU START WORKING!!!!!!
SAVE AS NEW VERSION BEFORE YOU START WORKING!!!!!!
SAVE AS NEW VERSION BEFORE YOU START WORKING!!!!!!
 */

/*

clinical trial v1

Phase1 trial simulator.....
THIS IS THE KINECT VERSION
THE WORKING CODE FOR THE KINECT OFFLINE VERSION IS trialGame_0_2_5 - THIS IS MISSING LOTS OF STUFF THOUGH

THE GAMESTATES:
1. 
2.
3.
4.
5.
6.
7.
8.
9.
10.

*/


//There are kinect variables here and in:
//gameState, PETscanFeatures - you need to put the conditions into the states, Button.buttonPressed(), ...............

//Use this flag to toggle whether game controlled by kinect during development
boolean kinectConnected = true;

//setup the kinect and 3D object libraries
import SimpleOpenNI.*;
import processing.opengl.*;
import saito.objloader.*;

//declare kinect and 3D obj model
SimpleOpenNI kinect;
OBJModel model;

//variables to draw head on user skeleton
// postion of head to draw circle
PVector headPosition = new PVector();
// turn headPosition into scalar form
float distanceScalar;
// diameter of head drawn in pixels
float headSize = 200;

//PVector for righthand data in gamestate(3) and gamestate(4)
PVector userHand;

//trial object
theTrial myTrial;

//patients so far
int patNumber;

//flags to determine if anyone died when the player doses a cohort
boolean deathInCohort;
int numDeaths;

//button object - creates a patient, assigns dose
//and adds patient to array list in trial object
Button myPatientButton;
int buttonRadius = 50;

//button object swaps to dose selection screen
Button recruitPatient;

//this is for recruitment of a cohort of 3 - this needs to raise a flag that a cohort is assigned rather than a single patient
Button recruitCohort;
Boolean cohort;

//button object to check tox
Button checkTox;

//button object to return to game
Button returnToGame;

//button object to restart game
Button restart;

//button object to publish trial
Button publishTrial;

//button objects for player to call DLT if found
Button callDLT1;
Button callDLT2;
Button callDLT3;
Button callDLT4;
Button callDLT5;
float toxButtonsXposn;

//Patient objects declared
//New patients created using calls to myPatientButton
Patient newPatient;
Patient[] newCohort;//this recruits a cohort of 3

//Image arrays hold histology images for display once patient tumour type and stage is detemined
//Currently each array is 7x5 - 6 tumour types, arbitrarily 5 images per type and stage
//row(0): prostate, row(1): breast, row(2): NSCLC, row(3): colon, row(4): melanoma, row(5): renal, row(6): glioma
//mapping is according to Patient.tumourType (tT) variable - tT = 0 is both prostate/breast depending on sex (0=M, 1=F)
//if tT=0 array accessed as histoArray[tT+sex][i]; if tT>0 access as histoArray[tT+1][i]
String[][] stage3_histoArray;
String[][] stage4_histoArray;

//histoCounter array keeps track of how many patients with each disease and stage have been seen so far
//this is used to access the column position of the histoArrays
//there are currently only 5 images of each type, so we need to reset the value in any element to 0 if it reaches 5
//this is done with callback function histoCount() at the end
//array is 2x7: row(0) = stage 3, row(1) = stage 4
//cols are defined as above
short histoCounter[][];


//we need a flag to check if a cohort has been treated
//checking the Patient.isTreated flag for an array element can give a null pointer exception if a patient died and the array position is nullified
boolean cohortIsTreated;

//array of drug objects declared myChoice variable is for selection using gameState function
Drug[] myDrugChoices;
int myChoice; 

//for flipping the cohort array positions
int counter;
int arrayPosn;

//string array to read drug tox data from file
String[] drugToxData;

//string array to read drug response data from file
String[] drugResponseData;

//string array to read drug target data from file
String[] drugTargetData;

//NUMBER OF DRUGS IN THE FILE!!!!!
//IMPORTANT!!!!!!!!!!!!!
int numDrugs;

//declare drug tox data variables to be read from file drugdata.txt
//these used to populate myDrugChoices array according to player choice
String myDrugName;
String tox1;
float[] doses;
float[] SAEprobs;
float[] allAEprobs;
barplot toxBarPlot; //to display tox data for current patient

//declare drug response variables to be read from file drugresponsedata.txt
//these used to populate response object in myDrugChoices array according to player choice
String resType;
//we already have an array for doses declared above - only need the response probability array
float[] responseProb;


//gameState variable to shift views of the game
gameState GAMESTATE;


void setup(){
  size(1024, 768, OPENGL);
  background(0);
  smooth(4);

  //set up a new kinect object
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableUser();
  kinect.setMirror(true);

  //setup syringe model
  model = new OBJModel(this, "stanford_bunny.obj", "relative", POLYGON);
  model.translateToCenter();
  
  //translate model so that its origin is at its left side
  BoundingBox box = new BoundingBox(this, model);
  model.translate(box.getMin());
 
 //initialise the vector for the right hand data in gamestates 3 and 4 
 userHand = new PVector();
 
 //start with zero patients
 patNumber=0;
 
 //at the start, no cohort has been treated
 cohortIsTreated = false;
 
 //the counter starts at 200 and the cohort array position is zero
 counter = 200;
 arrayPosn = 0;
 
 // Load drug tox data from file
  drugToxData = loadStrings("drugtoxdata.txt");
  numDrugs = drugToxData.length/17; //17 lines define drug, doses and tox data in the drug file

  //we already know numDrugs so this just needs to match up
  //note that only 10 lines define drug, doses, and response types rather than 17 for the tox data
  drugResponseData = loadStrings("drugresponsedata.txt");

  // Load drug target data from file
  drugTargetData = loadStrings("drugtargetdata.txt");
   
   
  //initialise the dose control slider position for the drug object  
  float [] sliderPosns = {width-80, height/2, 20, 200};

  
  //we now initialise drug and tox data from the array drugData
  //this is read from text file drugdata.txt in the sketch folder
  //line1 drug name
  //line2 tox name
  //line3 doses from trial data
  //line4 all events data from papers
  //line5 SAE data from papers
  //add as many drugs as required
  //currently only 2 drugs with one tox per drug
  //when adding new toxicities, need to change the bounds on j below
  
  myDrugChoices = new Drug[numDrugs];//need to change if want more or less drugs
  myChoice = 0;//this will be selected by a gameState function
  
  //get the tox data
  for(int i = 0; i < drugToxData.length/17; i++){//currently store name, dose and 5 x 3 tox lines against each drug = 17 lines
  //the min and max dose arguments 0, 1000 are temporary to initialise the slider - we get these later when the choice is made
  //the slider values are chosen in ganestate(9) - the drug max, min doses are taken below from the datafiles for the selected drug
  myDrugChoices[i] = new Drug(drugToxData[i*17], sliderPosns, 0, 1000);

  
  //assign to drug toxicity objects - currently only have one per drug
  for(int j = 0; j < 5; j++){
  //get the rest of the data for each drug
  tox1 = drugToxData[(i*17)+(j*3)+2];
  doses = float(split(drugToxData[(i*17)+1], ','));
  allAEprobs = float(split(drugToxData[(i*17)+(j*3)+3], ','));
  SAEprobs = float(split(drugToxData[(i*17)+(j*3)+4], ','));    
  myDrugChoices[i].tox[j] = new Toxicity(tox1, doses, allAEprobs, SAEprobs);
  }
  myDrugChoices[i].maxDoseTested = doses[doses.length-1];
  myDrugChoices[i].minDoseTested = doses[0];
  
  //myDrugChoices[i].doseLevel.maxVal = myDrugChoices[i].maxDoseTested;//can only go up to the max dose used in the trial
  
  //constrain dose levels to specific values according to the number of doses tested in the trial
  //allow 2 extra doses for user experimentation
  //exact dose levels are determined for each drug by Drug.assignDose() in gamestate(7)
  
  //actually, I don't like this - it gives stupid numbers
  //myDrugChoices[i].numDoses = myDrugChoices[i].tox.length + 2; 
  }
  

  //get the response data for each drug
  for(int i = 0; i < drugResponseData.length/10; i++){//currently store name, dose and 4 x 2 response lines against each drug = 10 lines
  //NOTE THAT THE PROBABILITIES OF ALL RESPONSE TYPES NEED TO SUM TO UNITY FOR ANY DOSE LEVEL!!!!!

  //assign to drug response object array - one slot for each of CR,PR,SD,PD for each drug
  //each slot in the response array carries an array of probabilities for each dose level
  for(int j = 0; j < 4; j++){//4 response types - 1 slot in the drug.response[] array for each

  //get the rest of the data for each drug
  resType = drugResponseData[(i*10)+(j*2)+2];
  
  //each of the elements of the response[] array carries an array of dose levels
  doses = float(split(drugResponseData[(i*10)+1], ','));
  
  //each dose level corresponds to a probability to have the response
  //response probabilities need to be CUMULATIVE in the drugresponsedata.txt file over all response types
  //each will be tested in turn at the dose level
  responseProb = float(split(drugResponseData[(i*10)+(j*2)+3], ','));  
  myDrugChoices[i].response[j] = new Response(resType, doses, responseProb);
  }
  } 
  
  //get the compound target data
  for(int i = 0; i < drugTargetData.length/4; i++){//currently store 4 lines - name, targets, cell free IC50, animal doses
  myDrugChoices[i].compoundInfo[0] = drugTargetData[i*4 + 1];//target
  myDrugChoices[i].compoundInfo[1] = drugTargetData[i*4 + 2];//IC50
  myDrugChoices[i].compoundInfo[2] = drugTargetData[i*4 + 3];//animal dose
  }

  //instantiate the trial using a temporary name
  //pass in the actual drug once chosen during play
  myTrial = new theTrial("someDrug");

  //buttons to assign new patients, check patient data and return to game
  myPatientButton = new Button(width/2, height/2, buttonRadius, "blah");
  
  recruitPatient = new Button(width/2-100, height/2-200, buttonRadius, "blah");
  recruitCohort = new Button(width/2+100, height/2-200, buttonRadius, "blah");
  checkTox = new Button(width/2, height/2 -100, buttonRadius, "blah");
  returnToGame = new Button(width/2+200, height/2 , buttonRadius, "blah");

  cohort = false; //at initialisation we don't know yet whether a cohort or a single patient will be recruited

  //The DLT call buttons
  toxButtonsXposn = width - 100;
  callDLT1 = new Button((int)toxButtonsXposn, 200, buttonRadius, "blah");
  callDLT2 = new Button((int)toxButtonsXposn, 300, buttonRadius, "blah");
  callDLT3 = new Button((int)toxButtonsXposn, 400, buttonRadius, "blah");
  callDLT4 = new Button((int)toxButtonsXposn, 500, buttonRadius, "blah");
  callDLT5 = new Button((int)toxButtonsXposn, 600, buttonRadius, "blah"); 
  
  //The publish trial button
  publishTrial = new Button(width-100, height/2, buttonRadius, "blah");

  //The restart button
  restart = new Button(width - 100, 50, buttonRadius, "blah");
  
  //set the gameState to the start screen  
  GAMESTATE = new gameState(1, myDrugChoices.length, kinect);
  for(int i = 0; i < myDrugChoices.length; i++){
    GAMESTATE.theDrugs[i] = myDrugChoices[i].compoundName;
    GAMESTATE.cpdStructures[i] = myDrugChoices[i].structure;
    GAMESTATE.drugInfo[i] = myDrugChoices[i].compoundInfo;  
  }
  
  //load the histology images into histoArray
  //the patient object will retrieve them from the array
  //currently, 6 tumour tyes and 5 images of each
  stage3_histoArray = new String[7][5];
  stage4_histoArray = new String[7][5];
  histoCounter = new short[2][7];
  
  //initialise the histoArrays with the filenames we need to load into PImages for each patient
  for (int i=0; i<5; i++){
  stage3_histoArray[0][i] = "Prostate_stage3_" + (i+1) + ".jpg";
  stage3_histoArray[1][i] = "Breast_stage3_" + (i+1) + ".jpg";
  stage3_histoArray[2][i] = "NSCLC_stage3_" + (i+1) + ".jpg";
  stage3_histoArray[3][i] = "Colon_stage3_" + (i+1) + ".jpg";
  stage3_histoArray[4][i] = "Melanoma_stage3_" + (i+1) + ".jpg";
  stage3_histoArray[5][i] = "Renal_stage3_" + (i+1) + ".jpg";  
  stage3_histoArray[6][i] = "Glioma_stage3_" + (i+1) + ".jpg";


  stage4_histoArray[0][i] = "Prostate_stage4_" + (i+1) + ".jpg";
  stage4_histoArray[1][i] = "Breast_stage4_" + (i+1) + ".jpg";
  stage4_histoArray[2][i] = "NSCLC_stage4_" + (i+1) + ".jpg";
  stage4_histoArray[3][i] = "Colon_stage4_" + (i+1) + ".jpg";
  stage4_histoArray[4][i] = "Melanoma_stage4_" + (i+1) + ".jpg";
  stage4_histoArray[5][i] = "Renal_stage4_" + (i+1) + ".jpg";
  stage4_histoArray[6][i] = "Glioma_stage4_" + (i+1) + ".jpg";  
  }
  
  //initialise the histoCounter array to be 0 for all stages/diseases (no patients seen yet)
  for (int i =0; i<2; i++){
    for (int j = 0; j<7; j++){
      histoCounter[i][j]=0;
    }
  }
  
} //end setup

void draw(){
  background(0);
  
  if(kinectConnected){
  //update kinect if flag is true
  kinect.update();
  
  //initialise the GAMESTATE SimpleOpenNI variable
  GAMESTATE.context = kinect;   
  }
 
 

 
 if(GAMESTATE.state==1){
  GAMESTATE.display(GAMESTATE.state); //start screen if button pushed, increment game state to trial scenario
 } else if(GAMESTATE.state==2) {
  myChoice=GAMESTATE.display(GAMESTATE.state); //choose a drug to work with
 } else if(GAMESTATE.state==3) {
  //gamestate(3) is for checking tox, publishing the trial and shifting to gamestate(7) where patients are added to the trial
   
  //GAMESTATE.checkLastState();
  
  //this assignment could be elsewhere - we are currently resetting the drug each time gamestate(3) called 
  myTrial.drug = myDrugChoices[myChoice].compoundName;
 
  //show current trial information
  myTrial.printTrialHeader();
  
  //button swaps to kinect dose selection screen in gamestate(7)
  recruitPatient.showButton();
  textAlign(LEFT);
  fill(255);
  text("recruit new patient", recruitPatient.centreX-90, recruitPatient.centreY-50);

  recruitCohort.showButton();
  fill(255);
  text("recruit new cohort", recruitCohort.centreX-90, recruitCohort.centreY-50);
  
  //get kinect rightHand data
  userHand = GAMESTATE.getRightHandVector(kinect);
  
  //WE NEED TO DO SOME CHECKING IN CASE WE ARE RETURNING TO THIS STATE WITH A FULL COHORT OF DEAD PATIENTS
  if(cohort && GAMESTATE.numDead == 3){//if we have already dosed a cohort and they all died
  cohort = false; //we no longer have a cohort
  //set numDead to zero
  //if we don't do this, we can recruit a cohort and kill everybody, setting numDead to 3
  //we could then recruit another cohort and have no deaths but numDead will still be 3 the next time we return to state(3)
  //in this case, cohort is still set to false which allows another patient to be recruited before the cohort response has been checked
  GAMESTATE.numDead = 0;
  newCohort = null;//nullify the current cohort if it exists
  }//we can now recruit a new patient or cohort
  
  //THESE CONDITIONALS ADD A SINGLE PATIENT!
  //THE CHECKS FOR A COHORT ARE BELOW  
  //only assign a patient if the first patient not yet assigned or current patient is treated
  if((newPatient == null || newPatient.isTreated()) && (newCohort == null || cohortIsTreated)){//we need to make sure that a new patient is not recruited while an untreated cohort exists
  //check if button has just been newly pressed
  if((recruitPatient.buttonPressed() || recruitPatient.vectorButtonPressed(userHand)) && !recruitPatient.isPressed()){
  //add new patient on button press - increment patient number and pass this to the button addPatient() function
  //currently, age and sex are randomly assigned by the call to Button.addPatient()
  //could change this if needed
    patNumber++;
    newPatient = recruitPatient.addPatient(patNumber);
    newPatient.getDisease();
    
    //Get an image from the histology array depending on patient disease and stage
    //newPatient.histoCount();
    switch(newPatient.stage){
      case 3:
      if(newPatient.tumourType==0){
        newPatient.histology = loadImage(stage3_histoArray[newPatient.sex][histoCount(newPatient)]);
      } else {
        newPatient.histology = loadImage(stage3_histoArray[newPatient.tumourType+1][histoCount(newPatient)]);
      }
      break;
      
      case 4:
      if(newPatient.tumourType==0){
        newPatient.histology = loadImage(stage4_histoArray[newPatient.sex][histoCount(newPatient)]);
      } else {
        newPatient.histology = loadImage(stage4_histoArray[newPatient.tumourType+1][histoCount(newPatient)]);
      }
      break;  
      
      default:
      break;
    }
    
    newPatient.histology.resize(450,450);
    
    checkTox.callsToButton = 0;
    
    //if there is an existing cohort, nullify so their results do not carry through
    if(newCohort != null){
      newCohort = null;
      cohort = false;
      cohortIsTreated = false;
    }
    
    
    //add patient to the gamestate PETscanFeatures object
    //we will use the data from the patient object (tumour type, mets, etc) to determine the scan
    //we will repeat the update when the patient has a dose assigned
    //this will allow to determine if we have PR, CR, SD, PD for a new scan - note that these are not currently assigned
    GAMESTATE.scan.updatePatient(newPatient);
    

    //we first send to state = 9 which is a dose RANGE selection screen
    //this will mean the player has less idea what the dose should be and will need to have strategy for escalation
    //from there, send for a PET scan in gamestate(8), then divert back to gamestate(7) for actual dose selection
    GAMESTATE.state = 9;

  }// end patient button routine
  } else if((recruitPatient.buttonPressed() || recruitPatient.vectorButtonPressed(userHand)) && !recruitPatient.isPressed() && (checkTox.callsToButton<1 || cohort)){ 
    // if try to add new patient before current patient treated swap to gamestate 5 OR, if there is an existing untreated cohort
    // this brings a screen to advise that current patient should be treated
    GAMESTATE.state=5;
  }//end check on patient status
  
  
  //THIS IS FOR ADDING A COHORT!!!  
  //only assign a cohort if the first cohort not yet assigned or current cohort is treated
  if(newCohort == null || cohortIsTreated){//if no untreated cohort exists
  //if a single patient exists, they must be treated to allow recruitment of the cohort
  if(newPatient == null || newPatient.isTreated()){
  //check if button has just been newly pressed
  if((recruitCohort.buttonPressed() || recruitCohort.vectorButtonPressed(userHand)) && !recruitCohort.isPressed()){
  //add 3 new patients to the array on button press - increment patient number by 3
  //SET THE COHORT FLAG TRUE!!!!
  //currently, age and sex are randomly assigned by the call to Button.addPatient()
  //could change this if needed
    cohort = true;
    newCohort = new Patient[3];
    cohortIsTreated = false;
    GAMESTATE.cohortTreated = cohortIsTreated;
    
    //if there is an existing single patient, nullify so their results do not carry through
    if(newPatient != null){
      newPatient = null;
    }
    
    for(int i = 0; i<3; i++){
    patNumber++;
    newCohort[i] = recruitCohort.addPatient(patNumber);
    newCohort[i].getDisease();
    
        //Get an image from the histology array depending on patient disease and stage
    //newPatient.histoCount();
    switch(newCohort[i].stage){
      case 3:
      if(newCohort[i].tumourType==0){
        newCohort[i].histology = loadImage(stage3_histoArray[newCohort[i].sex][histoCount(newCohort[i])]);
      } else {
        newCohort[i].histology = loadImage(stage3_histoArray[newCohort[i].tumourType+1][histoCount(newCohort[i])]);
      }
      break;
      
      case 4:
      if(newCohort[i].tumourType==0){
        newCohort[i].histology = loadImage(stage4_histoArray[newCohort[i].sex][histoCount(newCohort[i])]);
      } else {
        newCohort[i].histology = loadImage(stage4_histoArray[newCohort[i].tumourType+1][histoCount(newCohort[i])]);
      }
      break;  
      
      default:
      break;
    }
    newCohort[i].histology.resize(450,450);
    println(newCohort[i].patientNumber, newCohort[i].primary);
    }
    checkTox.callsToButton = 0;

    //add cohort to the gamestate PETscanFeatures object
    //we will use the data from the patient array (tumour type, mets, etc) to determine the scan
    //we will repeat the update when the patient has a dose assigned
    //this will allow to determine if we have PR, CR, SD, PD for a new scan - note that these are not currently assigned
    GAMESTATE.scan.updateCohort(newCohort);
    
    //we first send to state = 9 which is a dose RANGE selection screen
    //this will mean the player has less idea what the dose should be and will need to have strategy for escalation
    //from there, send for a PET scan in gamestate(8), then divert back to gamestate(7) for actual dose selection
    GAMESTATE.state = 9;
    
  //NOTE THAT THE COHORT HAS NOT YET BEEN ADDED TO THE GAMESTATE PETSCANFEATURES OBJECT
  //FOR THE COHORT WE WILL NEED TO DO THIS IN A LOOP DURING GAMESTATE(8)
  
  }// end cohort button routine
  } else if((recruitCohort.buttonPressed() || recruitCohort.vectorButtonPressed(userHand)) && !recruitCohort.isPressed() && newPatient != null){
    if(!newPatient.isTreated()){//if a single patient exists and is untreated, send to gamestate 5
      GAMESTATE.state=5;
    } 
  } // single patient treated  
 } else if((recruitCohort.buttonPressed() || recruitCohort.vectorButtonPressed(userHand)) && !recruitCohort.isPressed() && checkTox.callsToButton<1){ //if the cohort is untreated
    // if try to add new cohort before current cohort treated swap to gamestate 5
    // this brings a screen to advise that current cohort should be treated
    GAMESTATE.state=5;
  }//end check on cohort status
  
  //THIS TELLS THE GAMESTATE OBJECT WHETHER WE HAVE A COHORT OR SINGLE PATIENT
  //WE NEED THIS IN SEVERAL GAMESTATES
  GAMESTATE.cohortFlag = cohort;
  
    //button switches to GAMESTATE 4 and confirms patient is treated
    //we need also to check if the current patient has been treated at 2 dose levels by mistake (new patient not recruited)
    //give an appropriate error message
    //do this in gamestate 4
  fill(255);
  text("check patient toxicities", checkTox.centreX-110, checkTox.centreY-50);
  checkTox.showButton();
  
  //check if button has just been newly pressed
  //THIS IS FOR A SINGLE PATIENT!!!!!!!!!
  if(!cohort){
  if((checkTox.buttonPressed() || checkTox.vectorButtonPressed(userHand)) && !checkTox.isPressed() && newPatient != null){
   //set patient status to treated
    newPatient.treated = true;
    checkTox.callsToButton = checkTox.callsToButton+1;
    
  //swap to gamestate4
  GAMESTATE.state=4;
  }//end button routine
  } else if(cohort){//end check for single patient
  if((checkTox.buttonPressed() || checkTox.vectorButtonPressed(userHand)) && !checkTox.isPressed() && newCohort != null){
   //set cohort status to treated
    cohortIsTreated = true;
    GAMESTATE.cohortTreated = cohortIsTreated;
    //cohort=false;
    checkTox.callsToButton = checkTox.callsToButton+1;
    
  //swap to gamestate4
  GAMESTATE.state=4;
  }//end button routine
  }//end check for cohort  
  
  //only activate buttons if not already pressed
  recruitPatient.clear();
  recruitCohort.clear();
  checkTox.clear();

  //button finishes trial
  publishTrial.showButton();
  text("publish trial", width-150, height/2-50);
    
 //we need to check there is at least one patient and that the current patient has been treated before publishing trial
 //AND AND AND THAT THE CURRENT PATIENT IS NOT NULL!!!!!!
 //THIS CAN HAPPEN IF WE NULLIFY THE PATIENT AFTER TOXIC DEATH AND THEN TRY TO PUBLISH
 if(newPatient!=null){
   //if we have nullified the patient because of death
 if(publishTrial.buttonPressed() && !publishTrial.isPressed() && myTrial.numPatients >0 && newPatient.treated){
   GAMESTATE.state=6;
 } 
 } else if(newPatient==null && publishTrial.buttonPressed() && (!publishTrial.isPressed()&& myTrial.numPatients >0)){
   //if the patient is null we still need more than zero patients on-trial
   GAMESTATE.state=6;  
 }

 
 
 publishTrial.clear();
  
 }//end GAMESTATE(3) check
 
 else if(GAMESTATE.state==4){//show patient data
 
 /* .................................................................
 //this bit is probably irrelevant now because we can only move to dose selection by recruiting a new patient
 //this was implemented when the recruitPatient button was added
 //if there are no issues having this commented out, then delete
  background(0);
  
 if((myDrugChoices[myChoice].assignDose() != newPatient.doseGiven) && checkTox.callsToButton>1){
   textSize(30);
   text("Cannot treat the same patient at 2 dose levels!",150,230);
   text("Recruit a new patient in order to continue!",175,270);
   text("Previous results for this patient are:",220,310);
 } else {
 
 ............................................................... */
 
 
 /* ............................................................... 
 //at the moment, we are not using the DLT buttons - might want to put these back in, however
 //may need to move them around - the returnToGame button has been moved to allow it to be activated by the user hand
 callDLT1.showButton();
 callDLT2.showButton();
 callDLT3.showButton();
 callDLT4.showButton();
 callDLT5.showButton();
 pushMatrix();
 translate(width-50, 150);
 textSize(40);   
 rotate(HALF_PI);
 text("call dose limiting toxicity",0 ,0);
 popMatrix();
 ................................................................ */
 
 
 /* ........................................
 //this bracket goes with the commented out if statements above - delete if no problems in game
 } 
 ...................................................... */

 background(0);
 //get kinect rightHand data
 userHand = GAMESTATE.getRightHandVector(kinect);
 
 if(!cohort){
 returnToGame.showButton(); 
 textSize(30);   
 text("check patient bloods",width/2+50 ,height/2-50);
 toxBarPlot = new barplot(100, height/2 - 180, 250, 60, newPatient);
 toxBarPlot.display();

 fill(255);
 text(("patient " + newPatient.patientNumber + " toxicities:"), 100, height/2 - 210);
 } else if(cohort){
   
      if(counter>0){
        counter--;
       if(newCohort[arrayPosn] != null){//do not attempt to display data if the array position is null because the patient died
       toxBarPlot = new barplot(100, height/2 - 180, 250, 60, newCohort[arrayPosn]);
       toxBarPlot.display();
       returnToGame.showButton();
      textSize(20);   
      text("check patient bloods",width/2+50 ,height/2-50);
       fill(255);
       textSize(30);
       text(("patient " + newCohort[arrayPosn].patientNumber + " toxicities:"), 100, height/2 - 210);
       } else {//check for nullity
       counter = 0; //if the array position is null, set counter to zero to avoid delay
       }
      } else if(counter==0 && arrayPosn<2){
      arrayPosn = arrayPosn+1;
      counter = 200;
      toxBarPlot.display();
      returnToGame.showButton();
      textSize(20);   
      text("check best responses",width/2+50 ,height/2-50);
      } else if(counter==0 && arrayPosn==2){
      returnToGame.showButton();
      arrayPosn = 0;
      counter = 200;       
      textSize(20);   
      text("check best responses",width/2+50 ,height/2-50);
      }//array position flip 
    }//cohort check
    
    
 if((returnToGame.buttonPressed()|| returnToGame.vectorButtonPressed(userHand)) && !returnToGame.isPressed()){
  counter = 200; //reset the counter in case we revisit the screen
  arrayPosn = 0; //reset the array position in case we have a cohort
  
 //send to gamestate(8) for radiology
 //if the patient is treated, this will give radiology with updated SUV then send us to gamestate(3) to continue
 //if the patient is not treated, we get baseline radiology then move to dose selection in gamestate(7)
 GAMESTATE.state=8;
 }
 returnToGame.clear();
 
 }//end GAMESTATE(4) check
 
 else if(GAMESTATE.state==5){//advise current patient must be treated
  background(0);
  textAlign(LEFT);
  //get kinect rightHand data
  userHand = GAMESTATE.getRightHandVector(kinect);
  
 returnToGame.showButton(); 
 textSize(28);   
 text("return to game",returnToGame.centreX-250 ,returnToGame.centreY);
 if(!cohort){
 text("current patient results must be collected before continuing recruitment!",20 ,300);
 } else if(cohort){
 text("current cohort results must be collected before continuing recruitment!",20 ,300);
 } 
 if((returnToGame.buttonPressed() || returnToGame.vectorButtonPressed(userHand)) && !returnToGame.isPressed()){
 GAMESTATE.state=3;
 }
 returnToGame.clear();
 }//end GAMESTATE(5) check
  
  else if(GAMESTATE.state==6){//publish trial;
  background(0);
  textAlign(CENTER);
  restart.showButton(); 
    pushMatrix();
    translate(width - 100, 200);  
    rotate(HALF_PI*3);
    textSize(30);
    text("start new trial", 0, 0);
    popMatrix(); 
  textSize(20);
  text("Phase I dose escalation study of " + myDrugChoices[myChoice].compoundName,width/2 ,30);
  myTrial.publishTrial();
  
  //print list of patients - this is for error checking - it will print over the trial result tables if uncommented
  //myTrial.showPatients();
    
 //Once trial is published restart begins the game from the start screen
  if(restart.buttonPressed() && !restart.isPressed()){   
  //to restart, we need to reinitialise EVERYTHING from setup()
  setup(); 
  //need to cancel the current patient to prevent hanging into the new trial
  newPatient=null;  
  }//end check for restart pressed
 //clear the button
 restart.clear();
 
 } else if (GAMESTATE.state == 7) { //end GAMESTATE(6) check
 
  //THIS IS NOW THE DOSE SELECTION AND PATIENT ASSIGNMENT CODE 
  //WE USE THE KINECT TO MOVE THE DOSE SELECTION SLIDER
  //MIGHT WANT TO REMOVE THE DEPENDENCE ON THE kinectConnected FLAG LATER

  //WE NOW INCLUDE THE OPTION TO RECRUIT A COHORT RATHER THAN SINGLE PATIENTS
  //NEED TO CHECK THE cohort BOOLEAN FLAG WHEN THE BUTTON IS PRESSED 

if(kinectConnected){
 //if the kinect is connected
 // choose the dose level using 3D tracking with the kinect and syringe model
 
 //we now first come to gamestate(3) where the code below is already declared
 //myTrial.drug = myDrugChoices[myChoice].compoundName;
 

  background(255);
  
  //we need this to display the skeleton and 3d model correctly
  translate(width/2,height/2,0);
  rotateX(radians(180));
  
  //we use this to get back to the untransformed position of the right hand
  PVector positionHolder = new PVector();
  
  //display drug level to give next patient
  myDrugChoices[myChoice].doseLevel.outVal = myDrugChoices[myChoice].assignDose(); //this constrains the slider display to levels defined by assignDose() = easier for user
  myDrugChoices[myChoice].doseLevel.displayUsingFlag(kinectConnected);  

  //temporarily move coordinates back to display button and trial header
  pushMatrix();
  rotateX(radians(180));
  translate(-width/2, -height/2);
  myTrial.printTrialHeader();
  
  textSize(35);
  stroke(0);
  text("select dose", width/2, height/2+80);
  myPatientButton.buttonColour = 50;
  //myPatientButton.centreX = myPatientButton.centreX+100;
  myPatientButton.showButton();
  popMatrix();
  
  //get users
  int userList[] = kinect.getUsers();
  
  // loop through each user to see if tracking
  for(int numUsers=0;numUsers<userList.length;numUsers++){
    // if Kinect is tracking certain user then get joint vectors
    if(kinect.isTrackingSkeleton(userList[numUsers])) {
      //get left and right hand positions
      PVector leftHand = new PVector();
      kinect.getJointPositionSkeleton(userList[numUsers], SimpleOpenNI.SKEL_LEFT_HAND, leftHand);
      PVector rightHand = new PVector();
      kinect.getJointPositionSkeleton(userList[numUsers], SimpleOpenNI.SKEL_RIGHT_HAND, rightHand);
      
      //get difference vector to scale 3D object from magnitude
      //before we convert leftHand to unit vector
      
      PVector differenceVector = PVector.sub(leftHand, rightHand);
      float magnitude = differenceVector.mag();
      
      //subtract left from right hand
      //turn leftHand into difference vector
      //then, convert leftHand diff vector to unit vector
      leftHand.sub(rightHand);
      leftHand.normalize();
      
      //model is rotated so that "up" is x-axis
      PVector modelOrientation = new PVector(1, 0, 0);
      
      //dot product calculates angle between x-axis and difference vector
      float angle = acos(modelOrientation.dot(leftHand));
      
      //cross product finds axis perpendicular to both
      PVector axis = modelOrientation.cross(leftHand);
      
      stroke(255,0,0);
      strokeWeight(5);
      
      //note that drawLimb in drawSkeleton is NOT kinect.drawLimb function
      //we define our own drawLimb() function below
      //see sketch 3D-skeleton-withTORSO-axes
      drawSkeleton(userList[numUsers]);
      drawHead(userList[numUsers]);
      
    pushMatrix();   
    //translate to position of right hand
    translate(rightHand.x, rightHand.y, rightHand.z);
   
    //rotate angle amount around axis
    rotate(angle, axis.x, axis.y, axis.z);
  
    noStroke();
    lights();
    scale(magnitude*2);
    model.draw();
    popMatrix();
  
  //components of the vector positionHolder
  //we use these to get to the untransformed position of the rightHand vector
  float posHolderX;
  float posHolderY;
  float posHolderZ;
  
  pushMatrix();
  //undo the rotation
  rotateX(radians(180));
  //undo the translations for the components of positionHolder
  posHolderX = width/2 - rightHand.x;
  posHolderY = height/2 - rightHand.y;
  posHolderZ = rightHand.z;  
  popMatrix();  
  
  //set positionHolder at the untransformed x,y components of rightHand
  positionHolder.set(posHolderX, posHolderY, posHolderZ);
  
  //choose the dose of drug to give to next patient by distance between user hands
  myDrugChoices[myChoice].doseLevel.moveSliderByVectorMagnitude(magnitude);  
  
  //patient button routine
  //check if button has just been newly pressed
  
      pushMatrix();
      noStroke();
      fill(255,0,0);
      ellipse(rightHand.x, rightHand.y, 20, 20);
      popMatrix();
  
  
  if(myPatientButton.buttonPressed() || myPatientButton.vectorButtonPressed(positionHolder) && !myPatientButton.isPressed()){
  //we were previously assigning a new patient at this stage - this has moved to gamestate(3)
  //now we only increment timesPressed and set the treatment status to true
    myPatientButton.timesPressed++;
    checkTox.callsToButton = 0;
    
    //We now assign the dose so we need to check if we have a single patient or cohort
    
    if(!cohort){
    //get the current dose from the drug instance slider object
    newPatient.doseGiven = myDrugChoices[myChoice].assignDose();
    
    //println("assigned dose: " + newPatient.doseGiven);
    
    //We have the dose - we now check if this is a fatal dose way above the max dose tested
    //if so, go to gamestate(10)
    //if not, update the SUV, get the toxicities and responses, add the patient to the trial patient list and return to gamestate(3)
    if(myDrugChoices[myChoice].compoundName.equals("drugX") && myDrugChoices[myChoice].fatalDose()){
      GAMESTATE.state=10;
    } else {    
    
    //DO WE NEED TO DO THIS?????????
    //THE SUV IS UPDATED IN Drug.Response - we should still have the same patient in the scan object
    //REMOVE IF NOT NEEDED!!!!!!!!!!!!!
    GAMESTATE.scan.updatePatient(newPatient);
    
    //IT IS VERY IMPORTANT TO CHECK FOR NULL POINTERS IN THE NEXT LOOP
    //WE ARE NOT DOING SO AT THE MOMENT
    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    //This assigns the drug tox data to the patient for the current dose
    //and displays message on AEs    
    for(int i = 0; i < 5; i++){
     //pass the dose to the drug toxicity objects
    //checking for a pharmacological dose iterates oveer all tox objects, so we need the dose initialise for each 
    myDrugChoices[myChoice].tox[i].currentDose = newPatient.doseGiven;

     //check if we have a pharmacological dose - if not, assign placebo effects, otherwise get toxicities
     //this was causing null pointer exceptions
     //checking for a placebo dose has been taken into getToxicities() as has assignment of Drug.toxicities[i]
    //if(!myDrugChoices[myChoice].pharmacologicalDose(i)){
    myDrugChoices[myChoice].getToxicities(i);
    //}
    newPatient.toxicities[i] = myDrugChoices[myChoice].toxicities[i];
    newPatient.grades[i] = myDrugChoices[myChoice].grades[i];
    
    //adjust clinicopathology from baseline
    newPatient.varyBiochemistry();
    
    //modify neutrophils or platelets if we have a relevant toxicity
    if(newPatient.toxicities[i].equals("neutropenia")){
      newPatient.inflictNeutropenia(newPatient.grades[i]);
    } else if(newPatient.toxicities[i].equals("thrombocytopenia")){
      newPatient.inflictThrombocytopenia(newPatient.grades[i]);
    }
    
   /* ....................................
   //don't really need this
    if(newPatient.grades[i] > 2){
     text("patient has SAE!", 200, 200);
    } else if(newPatient.grades[i] < 3 && newPatient.grades[i] > 0){
     text("adverseevent", 200, 200);      
    }
    .....................................*/
    
    //println("asigned grades" + i);
    }
    

    
     for(int i = 0; i < 4; i++){
     //pass the dose to the drug response objects
     myDrugChoices[myChoice].response[i].currentDose = newPatient.doseGiven;
     if(myDrugChoices[myChoice].response[i].getResponse()){
     newPatient.responseType = myDrugChoices[myChoice].response[i].responseTypes;
     i=4;//exit loop
     }
     }

     //update the patient SUV variable for radiology according to the response type
     //println(newPatient.SUV);
     newPatient.SUV = newPatient.SUV*myDrugChoices[myChoice].applyRecistToSUV(newPatient.responseType);
     //println(newPatient.SUV);
     
    //add the data to the trial   
    myTrial.addPatient(newPatient);
    
    
    //go to gamestate(3) to choose publication, more recruitment, or tox checking
    GAMESTATE.state=3;
    }//end the check for a fatal dose  
    } else if(cohort){
    //nobody is dead until they are given the drug
    deathInCohort = false;
    numDeaths = 0;
    
    //get the current dose from the drug instance slider object
    //assign to each patient in the cohort array
    for(int i=0; i<newCohort.length; i++){
    newCohort[i].doseGiven = myDrugChoices[myChoice].assignDose();
    
    //println("assigned dose: " + newCohort[i].doseGiven);
    
    //We have the dose - we now check if this is a fatal dose for each patient in the array
    //if so, we set the Patient.fatalToxicity flag true for use in gamestate(10)
    //we will also need to nullify those array positions so that the patients are not added to the trial
    //for patients that did not die, we need to update the SUV, get the toxicities and responses, add the patient to the trial patient list and return to gamestate(3)
    if(myDrugChoices[myChoice].compoundName.equals("drugX") && myDrugChoices[myChoice].fatalDose()){
    newCohort[i].fatalToxicity = true;
    deathInCohort = true; // this flag will take us to gamestate(10) once, regardless how many deaths we have
    numDeaths++; //we need this in gamestate(10)
    } //fatality check
    
    //we will now assign toxicities and responses for all patients and later nullify any in the array that died based on the fatalToxicity flag
    
    //TOXICITIES:
    //println("Patient " + i + " toxicity grades:");
    for(int j = 0; j < 5; j++){
    //pass the dose to the drug toxicity objects
    //checking for a pharmacological dose iterates oveer all tox objects, so we need the dose initialise for each 
    myDrugChoices[myChoice].tox[j].currentDose = newCohort[i].doseGiven;
    myDrugChoices[myChoice].getToxicities(j);
    newCohort[i].toxicities[j] = myDrugChoices[myChoice].toxicities[j];
    newCohort[i].grades[j] = myDrugChoices[myChoice].grades[j];
    
    //adjust clinicopathology from baseline
    newCohort[i].varyBiochemistry();
    
    //modify neutrohils and platelets if we have a relevant toxicity
    if(newCohort[i].toxicities[j].equals("neutropenia")){
      newCohort[i].inflictNeutropenia(newCohort[i].grades[j]);
    } else if(newCohort[i].toxicities[j].equals("thrombocytopenia")){
      newCohort[i].inflictThrombocytopenia(newCohort[i].grades[j]);
    }
    
    //println("asigned grades" + j);
    }//tox loop
    
     //RESPONSES:
     for(int j = 0; j < 4; j++){
     //pass the dose to the drug response objects
     myDrugChoices[myChoice].response[j].currentDose = newCohort[i].doseGiven;
     if(myDrugChoices[myChoice].response[j].getResponse()){
     newCohort[i].responseType = myDrugChoices[myChoice].response[j].responseTypes;
     j=4;//exit loop
     }
     }//response loop
    
     //update the patient SUV variable for radiology according to the response type
     //println(newPatient.SUV);
     newCohort[i].SUV = newCohort[i].SUV*myDrugChoices[myChoice].applyRecistToSUV(newCohort[i].responseType);
     //println(newCohort[i].SUV);
     
     //we now add the patient to the trial if not dead
     //WE DON'T NEED TO CHECK FOR NULLITY BECAUSE THIS WILL BE ASSIGNED IN GAMESTATE(10)
    if(!newCohort[i].fatalToxicity){     
    //add the data to the trial   
    myTrial.addPatient(newCohort[i]);
    }//if patient alive    
    }//loop through patient array
    
    //we have exited the patient array loop
    //we now go to gamestate(10) if any patients died or directly to gamestate(3) for publication, recruitment, tox checking otherwise
    //gamestate(10) should nullify any dead patients
    
    if(deathInCohort){
      GAMESTATE.state=10;
      deathInCohort = false;//reset the flag
    } else {
    GAMESTATE.state=3;
    }
    
    } //check for single patient or cohort
  }// end patient button routine

  
  myPatientButton.clear();
  
  }//loop through users
  }// if tracking  
  }//end kinectConnected check
 
 translate(0,0,0);
 GAMESTATE.lastState=7;
 
 } else if(GAMESTATE.state==8){//end gamestate(7) check
  //display "PET scan"
  GAMESTATE.display(GAMESTATE.state);
 } else if(GAMESTATE.state==9){//end gamestate(8) check
  //dose range selection
  GAMESTATE.display(GAMESTATE.state);
  myDrugChoices[myChoice].doseLevel.maxVal = GAMESTATE.maxDose;
  myDrugChoices[myChoice].doseLevel.minVal = GAMESTATE.minDose;   
 } else if(GAMESTATE.state==10){ //end gamestate(9) check
 //this is the toxic death gamestate
 //return value is increments numDeaths
 
 if(!cohort){//if we have a single patient
  myTrial.deaths = myTrial.deaths + GAMESTATE.display(GAMESTATE.state);
  //the patient died so we need to nullify the object
  newPatient = null;
 } else if (cohort) {
  //we can find which patients died by updating the patient array in the PETscanFeatures object
  //this will update the patient fatalToxicity flags
  GAMESTATE.scan.updateCohort(newCohort);
  myTrial.deaths = myTrial.deaths + GAMESTATE.display(GAMESTATE.state);
  //we have specified which patients died in the display, so now we can nullify those objects
  //however, since we pass the cohort to the gamestate each time we hit this section, the patients should only be nullified once the gamestate counter reaches zero
  //so, state(10) nullifies the dead patients in GAMESTATE.scan.theCohort and we then pass this back to newCohort
  newCohort = GAMESTATE.scan.returnCohort();
 }//cohort check
 } //end gamestate(10) check

 
} //end draw()


//THE KINECT CALLBACKS AND FUNCTIONS!!!!!!!!!!!!!!!!!!!!!!!!!

void drawHead(int userId){
   // get 3D position of head
kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_HEAD,headPosition);

//variable to scale head size
distanceScalar = (525/headPosition.z);
pushMatrix();
translate(headPosition.x,headPosition.y,headPosition.z);
sphere(distanceScalar*headSize);
popMatrix();

}

void drawSkeleton(int userId){
  //draw limb from head to neck
  drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);
  //draw limb from neck to left shoulder
  drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  //draw limb from left shoulde to left elbow
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  //draw limb from left elbow to left hand
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);
  //draw limb from neck to right shoulder
  drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  //draw limb from right shoulder to right elbow
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  //draw limb from right elbow to right hand
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
 //draw limb from left shoulder to torso
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  //draw limb from right shoulder to torso
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  //draw limb from torso to left hip
  drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  //draw limb from left hip to left knee
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP,  SimpleOpenNI.SKEL_LEFT_KNEE);
  //draw limb from left knee to left foot
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);
  //draw limb from torse to right hip
  drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  //draw limb from right hip to right knee
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  //draw limb from right kneee to right foot
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
  //draw limb from left hip to right hip
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_LEFT_HIP);
} // void drawSkeleton(int userId)

//own drawLimb() function
void drawLimb(int userID, int jointType1, int jointType2){
  PVector jointPos1 = new PVector();
  PVector jointPos2 = new PVector();  
  
  float confidence = kinect.getJointPositionSkeleton(userID, jointType1, jointPos1);
  confidence += kinect.getJointPositionSkeleton(userID, jointType2, jointPos2);
  
  stroke(100);
  strokeWeight(5);
  
  if(confidence>1){
    line(jointPos1.x, jointPos1.y,jointPos1.z,jointPos2.x,jointPos2.y,jointPos2.z);
  }
}


//User tracking callbacks
void onNewUser(SimpleOpenNI curContext, int userId){
  println("New User Detected - userId: " + userId);
  // start tracking of user id
  curContext.startTrackingSkeleton(userId);
} //void onNewUser(SimpleOpenNI curContext, int userId)

//Print when user is lost. Input is int userId of user lost
void onLostUser(SimpleOpenNI curContext, int userId){
  // print user lost and user id
  println("User Lost - userId: " + userId);
} //void onLostUser(SimpleOpenNI curContext, int userId)

//Called when a user is tracked.
void onVisibleUser(SimpleOpenNI curContext, int userId){
} //void onVisibleUser(SimpleOpenNI cur

//save a screenshot
void keyPressed(){
  saveFrame();
}

  //Increment the histoCounter arrays
  //This keeps the position so far in the histology image arrays in the main game
  int histoCount(Patient p){
   int row = 0;
   int col = 0;
   
   //get the stage = stage 3 is row 0 of the histoCounter array, stage 4 is row 1
   if(p.stage==3){
     row = 0;
   } else if (p.stage==4){
     row = 1;
   }
  
  //get the disease - assign the column of the histoCounter array  
  if(p.tumourType==0){
  col = p.sex;
  }  else {
  col = p.tumourType+1;
  }
  
  //increment the assigned position of the histoCounter array to retrieve histology images
  histoCounter[row][col]++;
  
  //currently, only 5 histology images per tumour type and grade
  //if the value in a histoCounter element = 5, set to 0 to access the array from the start
  //if more tumour types are added, the size of j will need to change
  for (int i = 0; i<2; i++){
    for (int j = 0; j<7; j++){
     if(histoCounter[i][j]==5){
       histoCounter[i][j]=0;
     }
    }
  }
  println(histoCounter[row][col]);
  println("got to here");
  return histoCounter[row][col];
  }
