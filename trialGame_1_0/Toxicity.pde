class Toxicity{
  
  //Class Drug stores an array of toxicities
  //Different dose levels are associated with % chance of tox occurring
  //Drug getToxicities function should retrieve this
  
  String toxName;
  
  //toxicity data from a trial at different dose levels
  //the events arrays elements are probabilities between 0, 1 for an AE at the dose
  //in the corresponding element of doseLevels
  float[] doseLevels;
  float[] probAllGrades;
  float[] probG3G4;
  
  //get the current dose from Drug.assignDose();
  float currentDose;
  
  Toxicity(String name, float[] levels, float[] allGrades, float[] G3G4){
    toxName = name;
    doseLevels = levels;
    probAllGrades = allGrades;
    probG3G4 = G3G4;
  }
  
  /*These functions are called by the drug.getToxicities() function */
  
  //determine if current dose gives rise to an SAE
  boolean getSAEs(){
    boolean result = false;
    float low, high;
    float currentClosest = 10000;
    int closestPosn = 0;
    
    //find the array position of the closest dose tested
    //in the trial data to the current dose
    for(int i=0; i < doseLevels.length; i++){
      float distance = dist(currentDose, 0, doseLevels[i], 0);
      if(distance<currentClosest){
        currentClosest=distance;
        closestPosn = i;
        //at the end we have the position of the closest tested dose
      }    
      }
    //generate random numbers between 0, 1
    float R = random(0.00, 1.00);
    
    //if the dose selected is above the highest dose tested, adjust R downward to increase likelihood of an event
    //this will increase the incidence of events among patients who do not die but are tested at a high dose level
    if(currentDose > doseLevels[doseLevels.length-1]){
    R = R/(currentDose/doseLevels[doseLevels.length-1]);
    }
    
    //now check against the probability for an SAE at the closest dose tested    
    if(R<=probG3G4[closestPosn]){
    result = true;
    }
    return result;
    }
   
   //determine if the current dose gives low grade toxicity 
   boolean getAllEvents(){
    boolean result = false;
    float low, high;
    float currentClosest = 10000;
    int closestPosn = 0;
    
    
    for(int i=0; i < doseLevels.length; i++){
      float distance = dist(currentDose, 0, doseLevels[i], 0);
      if(distance<currentClosest){
        currentClosest=distance;
        closestPosn = i;
      }    
      }
    float R = random(0.00, 1.00);
    
    //again, if the dose selected is above the highest dose tested, adjust R downward to increase likelihood of an event
    //this will increase the incidence of events among patients who do not die but are tested at a high dose level
    
    if(currentDose > doseLevels[doseLevels.length-1]){
    R = R/(currentDose/doseLevels[doseLevels.length-1]);
    }
    
    if(R<=probAllGrades[closestPosn]){
    result = true;
    }
    return result;
    }
 
 
    //this function is called in the drug class to assign zero or placebo toxicity
    //We need a better way to do this
    //this is just a linear model that reduces the probability of an event depending on how far we are below the lowest dose tested  
    //ideally a dose-response model would be built for each drug and toxicity
    boolean getPlaceboEffects(){
    boolean result = false;
    float R = random(0.00, 1.00); 
    if(R<=(probAllGrades[0]*(currentDose/doseLevels[0]))){ //the lower currentDose is below the lowest dose tested, the smaller the probability for an event
    result = true;
    }
    return result;
    }
    
    
    //this reports whether the current dose is lower than the lowest dose tested in the trial data
    //if so, getPlaceboEffects() is then called by the drug.getToxicities() function
    boolean placeboDose(){
      boolean result = false;
      if(currentDose<doseLevels[0]){
      result = true;
      }
      return result;
      }

      
}
