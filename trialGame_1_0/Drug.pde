class Drug {
  String compoundName;
  
  String[] compoundInfo;//enter whatever compound information needed in setup
  
  //if we exceed MTD, lose the game - don't need this now - instead toxic death events can occur
  //float MTD;
  
  //PImage to display the drug structure
  PImage structure;
  
  //we get currentDose from the slider
  //min/max dose are passed to the drug object in initialisation and then to the slider
  //these should reflect the doses tested in the clinical trials of the drugs
  float currentDose;
  float minDoseTested;
  float maxDoseTested;
  
  //variable to constrain the number of dose levels
  //if we don't do this, every dose level will be different
  //the value obtained from the slider will be rounded to the nearest maxDose/numDoses
  int numDoses;

  //Controls the dose of drug
  SlidingScale doseLevel;
  String sliderInstruction = "set dose level for next patient";
  
  //we need to pass values from here to patient tox and response functions
  //toxArrayPosn
  Toxicity[] tox;
  Response[] response;
  short toxArrayPosn;
  String[] toxicities; //we will only consider top 5 toxicities for any drug
  String[] responses; //only 4 response types - CR, PR, SD, PD
  short[] grades;
    
  Drug(String name, float[] sliderPosn, float minVal, float maxVal){
    compoundName = name;
    minDoseTested = minVal;
    maxDoseTested = maxVal;
    doseLevel = new SlidingScale(sliderPosn, minDoseTested, maxDoseTested, sliderInstruction);
    toxicities = new String[5];
    compoundInfo = new String[3]; //currently only need target, ic50, animal dose
    tox = new Toxicity[5];
    grades = new short[5];
    toxArrayPosn = 0;
    response = new Response[4]; //only 4 response types: CR,PR,SD,PD
    numDoses = 10; //default - there is code to assign doseNum after initialisation according to the number of doses in the toxicity data but it gives silly numbers
    structure = loadImage(compoundName + ".gif");
  }
  
  
  float assignDose(){
    currentDose = doseLevel.getSliderValue();
    currentDose = Math.round((currentDose + doseLevel.maxVal/(2*numDoses))/(doseLevel.maxVal/numDoses))*(doseLevel.maxVal/numDoses);
    return currentDose;   
  }


  /*.....................................
  //this function is not needed  
  boolean pharmacologicalDose(int toxnum){
    boolean result = false;
    if(tox[toxnum].placeboDose()){
    result = true;
    toxicities[toxnum] = tox[toxnum].toxName;
    grades[toxnum] = 0;
    }
    return result;
  }
  ..........................*/
      
      //this function idetermines whether the dose is so high that toxic death results
      //the model might be better - we are just increasing the probability with log(currentDose/maxDoseTested) adjusted by ((currentDose/maxDoseTested)10)
      //if the function is true we move to the toxic death screen in gamestate(10)
      boolean fatalDose(){
      float R = random(0.00, 1.00); 
      boolean result = false;
      if(currentDose>2*maxDoseTested){//if the dose is more than double the highest dose tested in the trial
      if(R<=(Math.log10(currentDose/maxDoseTested)*((currentDose/maxDoseTested)/10))){
      result = true;
      }
      }
      return result;
      }
  
  
    void getToxicities(int toxnum){ 
    toxicities[toxnum] = tox[toxnum].toxName; //we were previously doing this in an if statement in pharmacologicalDose() - this caused null pointer exceptions
    float R = random(0.00, 1.00);
    if(tox[toxnum].placeboDose()){ //if the dose is lower than the lowest dose tested in the trial
    toxicities[toxnum] = tox[toxnum].toxName;
    //we are making this a very simple model at the moment - the probability of a tox falls off linearly
    if(tox[toxnum].getPlaceboEffects()){
    grades[toxnum] = 1;//only assign low grade toxicity
    } else {
    grades[toxnum] = 0; //no tox if no placebo events
    }
    } else if(tox[toxnum].getSAEs()){
    toxicities[toxnum] = tox[toxnum].toxName;
    if(R<0.50){
      grades[toxnum] = 3;
    } else {
      grades[toxnum] = 4;
    }
    //toxArrayPosn++;
    } else if (tox[toxnum].getAllEvents()){
     toxicities[toxnum] = tox[toxnum].toxName;
    if(R<0.50){
      grades[toxnum] = 1;
    } else {
      grades[toxnum] = 2;
    }
    //toxArrayPosn++;
 
  }     else if (!tox[toxnum].getAllEvents()){
     toxicities[toxnum] = tox[toxnum].toxName;
      grades[toxnum] = 0;
    }    // this captures the case for no AEs
  }
  
  //each dose level is associated with % chance of CR, PR, SD, PD
  //get these from the patient response type variable
  //we modify the patient SUV variable accoridng to RECIST - even though SUV is not the RECIST criterion - it is just easier at the moment
  float applyRecistToSUV(String patientResponse){
    float tempSUV = 0.0;
    
    //pass in the the patient response and suv
    if("CR".equals(patientResponse)){
      tempSUV = 0.0;
    } else if ("PR".equals(patientResponse)){
      tempSUV = random(0.1, 0.7);
    } else if ("SD".equals(patientResponse)){
      tempSUV = random(0.75, 1.15);
    } else if ("PD".equals(patientResponse)){
      tempSUV = random(1.2, 2.0);
    }
   return tempSUV; 
  }
}
