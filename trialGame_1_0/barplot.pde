class barplot{
  
 int fillColour;
 float oriX; //x axis origin
 float oriY; //y axis origin
 float W; //width of bars
 float H; //height of bars
 Patient myPatient;
 
 barplot(float orix, float oriy, float w, float h, Patient P){
   oriX = orix;
   oriY = oriy;
   W = w;
   H = h;
   fillColour = 255;
   myPatient = P;
 }
 
 void display(){
  stroke(255);
  line(oriX, oriY, oriX+W, oriY);
  line(oriX, oriY, oriX, oriY+((myPatient.grades.length*H)+15));  
  for(int i = 0; i < myPatient.grades.length; i++){
  fill(255);
  stroke(255);
  textAlign(LEFT);
  textSize(20);
  text(myPatient.toxicities[i], oriX + W +15, oriY + H/2 + i*H);
  if(myPatient.grades[i]<3){
    fill(0,255,0);
  } else if(myPatient.grades[i]==3){
       fill(200,100,0);
  } else if(myPatient.grades[i]==4){
    fill(255,0,0);
  }
  rect(oriX, oriY + 5 + (i*H), (W/4)*myPatient.grades[i], H);
  }
  } 

}
