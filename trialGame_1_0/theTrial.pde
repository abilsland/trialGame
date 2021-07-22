class theTrial {
//THERE IS A BUG IN TABLE 2 AND TABLE 3!
//WE CURRENTLY NEED AT LEAST 2 DOSE LEVELS TO PLOT ANY DATA BECAUSE OF THE ARRAY INDICES
  
  
// theTrial uses an ArrayList to hold patients
//Note use of syntax "<Patient>" to indicate our intention to fill this ArrayList with Patient objects
ArrayList<Patient> patients;
String drug;  //this will be a class in the end
int numPatients;
int numMale; //sex M is 0 in Patient class - get from Patient.sex
int numFemale; //sex F is 1 in Patient class - get from Patient.sex
short minAge;
short maxAge;
int totalAge;
float meanAge;
int deaths;

 theTrial(String compound){
   //begin a fresh trial with a new compound
   drug = compound;
   //initialise patient array list  
   patients = new ArrayList<Patient>();
   
   numPatients = 0;
   numMale = 0;
   numFemale = 0;
   totalAge = 0;
   minAge = 0;
   maxAge = 0;
   meanAge = 0;
   deaths = 0;
 }
 
 void addPatient(Patient currentPatient){
   patients.add(currentPatient);
   numPatients = patients.size();
   totalAge = totalAge + currentPatient.age;
   meanAge = totalAge / numPatients;
 }
 
 void printTrialHeader(){
   textSize(20);
   text(drug, width/2, 20);
   String header = "evaluable patients: " + numPatients;
   text(header, width/2 - 50, 50);
 }
 
  void printTrialHeaderUsingFlag(boolean Flag){
   textSize(20);
   if(Flag){
   pushMatrix();
   rotateX(radians(180));
   text(drug, 0, -height/2 + 20);
   String header = "patients: " + numPatients;
   text(header, 0, -height/2 +50);
   popMatrix();
 }
  }
 
 void showPatients(){
 for (int i = 0; i < patients.size(); i++) {
  Patient P = patients.get(i);
  P.display(i);
}
 }
 
 int numMale(){
   numMale=0;
 //this gets number of males
 //males have sex = 0
 //scans the array list
 for (int i = 0; i < patients.size(); i++) {
  Patient P = patients.get(i);
  if(P.sex==0){
    numMale++;
  }
  }
  return numMale;
 }

 int numFemale(){
 numFemale =0;
 //this gets number of females
 //females have sex = 1
 //scans the array list
 for (int i = 0; i < patients.size(); i++) {
  Patient P = patients.get(i);
  if(P.sex==1){
    numFemale++;
  }
  }
  return numFemale;
 }   

 float meanAge(){
 meanAge =0;
 //this gets mean age
 //scans the array list
 for (int i = 0; i < patients.size(); i++) {
  Patient P = patients.get(i);
  meanAge=meanAge+P.age;
  }
  meanAge = meanAge/patients.size();
  return meanAge;
 }   

 short minAge(){
 minAge = 1000;
 //this gets minimum age
 //scans the array list
 for (int i = 0; i < patients.size(); i++) {
  Patient P = patients.get(i);
  if(P.age<minAge){
  minAge = P.age;
  }
  }
  return minAge;
 }

 short maxAge(){
 maxAge = 0;
 //this gets maximum age
 //scans the array list
 for (int i = 0; i < patients.size(); i++) {
  Patient P = patients.get(i);
  if(P.age>maxAge){
  maxAge = P.age;
  }
  }
  return maxAge;
 }

int[] numDisease(){
  //probably want a better way to do this if want to add tumour types
  //at the moment, array positions are 0:prostate, 1: breast, 2: NSCLC, 3: colorectal, 4: melanoma, 5: renal, 6: glioblastoma
  //to make more general, the patient class will also need to be modified
  int[] tempArray = {0,0,0,0,0,0,0};
  for (int i = 0; i < patients.size(); i++) {
  Patient P = patients.get(i);
  if(P.primary == "prostate cancer"){
  tempArray[P.tumourType]++;
  } else {
  //all other array positions are shifted by +1 because of the choice between M/F for tumourType = 0
  tempArray[(P.tumourType+1)]++;
  }
  }
  return tempArray;
}

int[] numPS(){
  //find the number with each ECOG PS - currently this is randomised for each patient between 0-2
  //if we want to introduce worse scores then the size of tempArray needs to be increased
  int[] tempArray = {0,0,0};
  for (int i = 0; i < patients.size(); i++) {
  Patient P = patients.get(i);
  //add one to the element of temp array corresponding to patient performance score
  tempArray[P.PS]++;
  }
  return tempArray;
}

void table1(){
 //prints patient characteristics
 int offset = 1;
 //again, might want to change the disease routines to be more general to allow addition of new types
 int[] diseases = numDisease();
 int[]perfScore = numPS();
 String[] types = {"Prostate", "Breast", "NSCLC", "Colorectal", "Melanoma", "Renal", "Glioblastoma"};
 pushMatrix();
 textAlign(LEFT);
 textSize(15);
 line(40, 60, 270, 60);
 text("Table 1: Patient characteristics", 40, 80);
 line(40, 85, 270, 85);
 text("Patients: " + numPatients, 40, 105);
 text("Sex", 40, 125);
 text("Male: " + numMale(), 60, 145);
 text("Female: " + numFemale(), 60, 165); 
 text("Age: " + String.format("%.1f",meanAge()) + " (" + minAge() + ", " + maxAge()+ ")", 40, 185);
 text("ECOG PS: ", 40, 205);
  for(int i = 0; i < 3; i++){
     text(i + ": " + perfScore[i], 60, 205 + 20*offset);
     offset++;
   }
   //reset offset
   offset = 1;

 int numDiseases = 0;
 text("Site of primary tumour: ", 40, 285);
 for(int i = 0; i < 7; i++){
   if(diseases[i]!=0){
     numDiseases++; //this is a counter to draw the line at the bottom of the table
     text(types[i], 60, 285 + 20*offset);
     text(diseases[i], 140, 285 + 20*offset);
     offset++;
   }
 }
 
 line(40, 290+numDiseases*20, 270, 290+numDiseases*20);
 popMatrix();
}

void table2(){
 //prints adverse event data
 
 //float array stores patient dose data
 float[] allDoses = new float[patients.size()];
 float[] levels;//unique dose levels
 int[] numTreated;//number treated at each dose
 int numDoses = 1;//must be at least one dose - increment below if find new dose
 int[][] numG1G2;//number of tox grades 1 or 2 for each dose level and each tox
 int[][] numG3G4;//number of tox grades 3 or 4 for each dose level and each tox
 
 pushMatrix();
 textAlign(LEFT);
 textSize(15);

 text("Table 2: Summary of adverse events by dose", 40, 440);
 line(40, 420, 370, 420);
 line(40, 445, 370, 445); 
 text("Dose:", 40, 465);
 text("Grades:", 40, 485);
 line(40, 490, 370, 490);
 line(40, 600, 370, 600); 
 //Print the toxicities
 Patient Pzero = patients.get(0);
 for(int i = 0; i < Pzero.toxicities.length; i++){
 text(Pzero.toxicities[i], 40, 510 + i*20);
 }
 
 //Get and print the doses given
 for (int i = 0; i < patients.size(); i++) {
  Patient P = patients.get(i);
  //assign doses to array for searching
  allDoses[i] = P.doseGiven;
 } 
 //Find out how many different doses were given
 //First, sort doses array
 allDoses = sort(allDoses);
 //search to find unique elements
 for(int i = 0; i < allDoses.length - 1; i++){
 if(allDoses[i] != allDoses[i+1]){
 numDoses++;
 }
 }
 //assign unique doses to doseLevels array and find number treated at each dose
 levels = new float[numDoses];
 numTreated = new int[numDoses];
 for(int i = 0; i < numDoses; i++){
 numTreated[i]=0;
 }
 //repeat search on doses and assign unique elements to dose levels
 for(int i = 0; i < allDoses.length - 1; i++){
 if(allDoses[i] != allDoses[i+1]){
 levels[numDoses-1]=allDoses[i];
 levels[numDoses-2]=allDoses[i+1];
 numDoses--;
 }
 }
 levels = sort(levels);
 //find number of patients treated at each dose level
 for(int i = 0; i < levels.length; i++){
 for(int j = 0; j < allDoses.length; j++){
   if(levels[i]==allDoses[j]){
     numTreated[i]++;
   }
 }
 } 
 //Finally, print the unique dose levels and number treated in the table
 for(int i = 0; i < levels.length; i++){
   text(String.format("%.1f", levels[i]) + " (n=" + numTreated[i] + ")", 200 + i* 100, 465);
   text("1/2", 200 + i* 100, 485);
   text("3/4", 250 + i* 100, 485);
 }
 //extend table borders according to number of dose levels
 line(40, 420, 200 + levels.length * 100, 420);
 line(40, 445, 200 + levels.length * 100, 445);
 line(40, 490, 200 + levels.length * 100, 490);
 
 /*now we need to get the toxicity data
 for (int i = 0; i < patients.size(); i++) {
 Patient P = patients.get(i);
 for(int j = 0; j < P.toxicities.length; j++){
 numG1G2 = new int[levels.length];
 numG3G4 = new int[levels.length];
 for(int k = 0; k < levels.length; k++){
 if(P.doseGiven == levels[k]){
 //need to populate an array here
 }
 }
 }
 }*/
 
 numG1G2 = new int[levels.length][Pzero.toxicities.length];
 numG3G4 = new int[levels.length][Pzero.toxicities.length]; 
 
 for (int i = 0; i < levels.length; i++) {//loop through dose levels
 for (int j = 0; j < Pzero.toxicities.length; j++) {//loop through toxicities
 numG1G2[i][j]=0; //start from zero for each tox
 numG3G4[i][j]=0; //start from zero for each tox
 for (int k = 0; k < patients.size(); k++) {//loop through patients
 Patient P = patients.get(k);
 if(P.doseGiven == levels[i]){//check if each patient received the current dose from ith entry of levels[]
 if(P.grades[j]==1 || P.grades[j]==2){
  numG1G2[i][j]++;
 } else if(P.grades[j]==3 || P.grades[j]==4){
  numG3G4[i][j]++;   
 }
 
 }//end check patient dose if
 }//end patients loop
 }//end toxicities loop
 }//end levels loop
 
 //AND, FINALLY ..... add the number of adverse events to the table
 for (int i = 0; i < levels.length; i++) {
 for (int j = 0; j < Pzero.toxicities.length; j++){
 text(numG1G2[i][j], 200 + i*100, 510 + j*20);
 text(numG3G4[i][j], 250 + i*100, 510 + j*20);
 }
 }
 line(40, 600, 200 + levels.length * 100, 600); 
 popMatrix();
}


void table3(){
 //prints response data
 
  //float array stores patient dose data
 float[] allDoses = new float[patients.size()];
 float[] levels;//unique dose levels
 int[] numTreated;//number treated at each dose
 int numDoses = 1;//must be at least one dose - increment below if find new dose
 
 pushMatrix();
 textAlign(LEFT);
 textSize(15);
 line(400, 60, 750, 60);
 text("Table 3: Best response by dose", 400, 80);
 line(400, 85, 750, 85);
 text("Response type:", 400, 105);
 text("CR", 550, 105);
 text("PR", 600, 105);
 text("SD", 650, 105);
 text("PD", 700, 105);
 text("Dose level", 400, 125);
 line(400, 130, 750, 130);
 
  //Get and print the doses given
 for (int i = 0; i < patients.size(); i++) {
  Patient P = patients.get(i);
  //assign doses to array for searching
  allDoses[i] = P.doseGiven;
  //(allDoses[i]);
 } 
 //Find out how many different doses were given
 //First, sort doses array
 allDoses = sort(allDoses);
 //search to find unique elements
 for(int i = 0; i < allDoses.length - 1; i++){
 if(allDoses[i] != allDoses[i+1]){
 numDoses++;
 }
 }
 //assign unique doses to doseLevels array and find number treated at each dose
 levels = new float[numDoses];
 numTreated = new int[numDoses];
 for(int i = 0; i < numDoses; i++){
 numTreated[i]=0;
 }
 //repeat search on doses and assign unique elements to dose levels
 for(int i = 0; i < allDoses.length - 1; i++){
 if(allDoses[i] != allDoses[i+1]){
 levels[numDoses-1]=allDoses[i];
 levels[numDoses-2]=allDoses[i+1];
 numDoses--;
 }
 }
 levels = sort(levels);
 //find number of patients treated at each dose level
 for(int i = 0; i < levels.length; i++){
 for(int j = 0; j < allDoses.length; j++){
   if(levels[i]==allDoses[j]){
     numTreated[i]++;
   }
 }
 }
 
 //now we need responses at each dose
 int[][] responseTypes = new int[levels.length][4];
 
 //zero the response type array
 for (int i = 0; i < levels.length; i++) {//loop through dose levels
 for (int j = 0; j < 4; j++) {//loop through response types: 0=CR, 1=PR, 2=SD, 3=PD
 responseTypes[i][j]=0; 
 }
 }
 
 //get the responses at each dose level
 for (int i = 0; i < patients.size(); i++) {//loop through patients
 Patient P = patients.get(i);
 for (int j = 0; j < levels.length; j++) {//loop through dose levels
 if(P.doseGiven == levels[j]){//check if each patient received the current dose from jth entry of levels[]
 if("CR".equals(P.responseType)){
 responseTypes[j][0]++;
 } else  if("PR".equals(P.responseType)){
 responseTypes[j][1]++;
 } else  if("SD".equals(P.responseType)){
 responseTypes[j][2]++;
 } else  if("PD".equals(P.responseType)){
 responseTypes[j][3]++;
 } 
  
 }//end levels check
 }//end levels loop
 }//end patients loop 
 
 
 //Finally, print the unique dose levels, number treated, and responses in the table
 for(int i = 0; i < levels.length; i++){
   text(String.format("%.1f", levels[i]) + " (n=" + numTreated[i] + ")", 400, 155 + i* 20);
   for(int j = 0; j < 4; j++){
     text(responseTypes[i][j], 550 + 50*j, 155 + i* 20);
   }
 }
 line(400, 145 + levels.length*20, 750, 145 + levels.length*20);  
 popMatrix();
 

 
}

 
 void publishTrial(){
   //Print a summary of patient data, toxicity grades and responses
   println("deaths: "+deaths);
   stroke(255);
   strokeWeight(2);
   table1();
   table2();
   table3();
 }
 
 }
