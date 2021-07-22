class Patient {
  
  //M = 0, F = 1
  short sex;
  short age;
  short stage;
  
  //ClinicoPathologic features
  //performance score
  //randomise 0-2 at the moment - if inclusions/exclusions introduced this might be changed to allow worse scores
  short PS;
  
  //Liver & kidneys function
  float ALT;
  float AST;
  float bilirubin;
  float glom_filt;
  
  //Bloods
  float haemoglobin;
  float neutrophils;
  float platelets;
  
  
  //primary tumour site and mets status - this will be randomly assigned at the moment by the int type in intialisation
  //this assumes an "all-comers" trial
  //might want to change this to present only certain patients if inclusion/exclusion criteria are introduced
  //also - a specific probability distribution might be more appropriate to reflect tumour incidence
  String primary;
  int tumourType;
  Boolean mets;
  
  //we assign the dose from the drug object contained in myTrial
  float doseGiven;
  
  //get this from recruitPatient buttonPressed number
  int patientNumber;
  
  //from file in sketch folder
  String[] toxicities;
  short[] grades;
  short toxArrayPosn;
  boolean treated;
  boolean fatalToxicity;
  
  //ORR is NOT implemented ENTIRELY ACCORDING TO CURRENT RECIST CRITERIA (AUG 2016)
  //we find out what response type the patient has from the drug object
  //assign response to a change in SUV to a call to applyRecistToPatient() from the drug object - this is not RECIST but is easier to implement in code for game v1
  
  //SUV should be assigned from IAEA atlas of radiology - at the moment we are putting all tumours in the same bracket
  float SUV;
  String responseType;
  
  //Histological core image fo the patient
  //We will load this in the main game from the histology arrays declared there
  //A call to the histoCounter array below tells the game which position to access
  PImage histology;
  
  //Counter to move through histology arrays - initialise as 2x7 - row 0 is stage 3, row 1 is stage 4
  //col(0): prostate, col(1):breast, col(2): NSCLC, col(3): colon, col(4):melanoma, col(5): renal, col(6):glioma
  //increment the value in each position each time a new patient with the correct stage and disease is recruited by a call to histoCount() function below
  short histoCounter[][];  
  
  //dose is obtained from a call to drug.assignDose()
  Patient(short gender, short howOld, int number) {
    sex = gender;
    age = howOld;
    float rnd = random(1);
    if(rnd<0.5){stage = 3;} else {stage=4;}
    patientNumber = number;
    
    //Normal reference ranges for clinicopahology - might change these if find out are frequently elevated in cancer patients on phase I
    //bilirubn, alt, ast, neutro, platelet ranges set to low+15%, high-15% 
    //Hb glom_filt ranges set +/- 1.5%
    //because post-treatment we will call varyBiochemistry()
    //this which adjusts bilirubn, alt, ast, neutro, platelet ranges by +/- 10%, Hb, glom_filt by 1%
    bilirubin = random(0.23, 1.02);//total (Tbil) bilirubin reference range
    ALT = random(8.05, 47.6);
    AST = random(5.75,34);    
    glom_filt = random(91.35,118.2);
    haemoglobin = random(12.18, 13.79);
    neutrophils = random(2300, 6800);
    platelets = random(172.5, 382.5);
    
    toxicities = new String[5]; //we will only consider top 5 toxicities for any drug
    grades = new short[5];
    toxArrayPosn = 0;
    treated = false;
    fatalToxicity = false;
    doseGiven = 0;
    
    //this needs to be taken in to the tumour type assignment function according to what radiology ranges are for the tumour type
    SUV = random(10.0, 20.0);
    
    //we could change this to allow patients with a worse score if exclusions are introduced
    PS = (short) random(2);
    
    //initialise the histoCounter array and set all to 0
    histoCounter = new short[2][7];
    
    for (int i=0; i<2; i++){
      for (int j=0; j<7; j++){
        histoCounter[i][j]=0;
      }
    }
    
    //histology=loadImage("Breast_stage3_1.jpg");
  }
  
//set and return tumour type
  String getDisease(){
      //NOTE- we could use a probability distribution based on disease frequency    
      tumourType = (int) random(5);
      //check if patient is M or F
      if(sex == 0 && tumourType == 0 ){
      primary = "prostate cancer";
      }  
      else if(sex == 1 && tumourType == 0) {
      primary = "breast cancer";
      }      
      else if(tumourType == 1) {      
      primary = "NSCLC";
      }
      else if(tumourType == 2) {      
      primary = "colon cancer";
      }
      else if(tumourType == 3) {      
      primary = "melanoma";
      }      
      else if(tumourType == 4) {      
      primary = "renal cancer";
      }
      else if(tumourType == 5) {      
      primary = "glioma";
    }
      return primary;
    }
      
//show basic patient data
  void display(int i){
    String patientData = "Patient " + patientNumber + ": Age " + age + " Sex " + sex + " dose " + doseGiven + " type " + tumourType;
    color(255);
    textSize(10);
    text(patientData, 10, 10 + i*10);
    for(int j = 0; j < 5; j++){
      if(toxicities[j] != null){
      text((toxicities[j] + " grade " + grades[j]), 200 + 100* j, 10 + i* 10);
      }
    }
  }

  
  //check if patient has been treated 
    boolean isTreated(){
    return treated;
  }
  
  //Give the patient neutropenia or thrombocytopenia
  void inflictNeutropenia(int toxgrade){
    switch(toxgrade){
      case 1:
      neutrophils = random(1500, 1999);
      break;
      case 2:
      neutrophils = random(1000, 1499);
      break;      
      case 3:
      neutrophils = random(500, 999);
      break;    
      case 4:
      neutrophils = random(100, 499);
      break;
      default:
      break;
    }
  }

  void inflictThrombocytopenia(int toxgrade){
    switch(toxgrade){
      case 1:
      platelets = random(75, 149);
      break;
      case 2:
      platelets = random(50, 74);
      break;      
      case 3:
      platelets = random(25, 49);
      break;    
      case 4:
      platelets = random(5, 24);
      break;
      default:
      break;
    }
  }


 //adjust biochemical parameters after treatment - this is a little more realistic than the exact same values at recruitment and post-treatment
 void varyBiochemistry(){
    bilirubin = bilirubin + (bilirubin * random(-0.1, 0.1));
    ALT = ALT + (ALT * random(-0.1, 0.1));
    AST = AST + (AST * random(-0.1, 0.1));  
    glom_filt = glom_filt + (glom_filt * random(-0.01, 0.01));
    haemoglobin = haemoglobin +(haemoglobin * random(-0.01, 0.01));
    neutrophils = neutrophils + (neutrophils * random(-0.1, 0.1));
    platelets = platelets + (platelets * random(-0.1, 0.1));
 }  
  /*........................WE ARE NOW DOING THIS IN THE MAIN GAME.......................
  //Increment the histoCounter arrays
  //This keeps the position so far in the histology image arrays in the main game
  int histoCount(){
   int row = 0;
   int col = 0;
   
   //get the stage = stage 3 is row 0 of the histoCounter array, stage 4 is row 1
   if(stage==3){
     row = 0;
   } else if (stage==4){
     row = 1;
   }
  
  //get the disease - assign the column of the histoCounter array  
  if(tumourType==0){
  col = sex;
  }  else {
  col = tumourType+1;
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
  .......................UNCOMMENT IF NEEDED.............................*/
  
}//end class
