class Response{
  //THIS IS NOT A WELL STRUCTURED CLASS!
  //THIS SHOULD OBVIOUSLY INHERIT FROM THE TOXICITY CLASS!!!
  
  
  //Class Drug stores a Response object
  //Different dose levels are associated with % chance of response occurring
  //Drug.getResponses function should retrieve this
  
  
  //CR, PR, SD, PD - return the response type according to results from Drug.getResponses
  //uses the response arrays below for each response type
  String responseTypes;
  
  //toxicity data from a trial object at different dose levels
  //the probResponses array elements are probabilities between 0, 1 for response at the dose
  //in the corresponding element of doseLevels
  //the probabilities need to be CUMULATIVE - the default is PD with p=1
  float[] doseLevels;
  float[] probResponse;

  //get the current dose from Drug.assignDose();
  float currentDose;
  
    Response(String name, float[] levels, float[] prob){
    responseTypes = name;
    doseLevels = levels;
    probResponse = prob;
  }
  
  
  boolean getResponse(){
    boolean result = false;
    
    //call the closestPosition() function
    //find the array position of the closest dose tested
    //in the trial data to the current dose
    
    int closestPosn = closestPosition();
    //generate random numbers between 0, 1
    //check against the probability for an SAE at the closest dose tested
    float R = random(0.00, 1.00);
    if(R<=probResponse[closestPosn]){
    result = true;
    }
    return result;
  }
  
  int closestPosition(){
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
      return closestPosn;
  }
  
}
