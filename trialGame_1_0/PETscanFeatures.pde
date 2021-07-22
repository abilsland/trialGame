//PETSCANFEATURES WILL BE DEPRECATED - WE DO NOT NEED THE "SCAN"
//CLINICO-PATHOLOGY IS MORE RELEVANT

class PETscanFeatures{
  
  //SimpleOpenNI object - pass kinect to this variable
  SimpleOpenNI scanContext;
  
  //selector for tumour type
  int type;
  
  //metastasis present?
  boolean mets;
  
  //body positions: get from kinect user skeleton
  //each "scan feature" (body position) will be displayed in relation to paired joints (eg shoulders)
  PVector bodyPosition;
  PVector convertedBodyPosition;
  PVector joint1;
  PVector convertedJoint1;
  PVector joint2;
  PVector convertedJoint2;
  PVector diff;

  //A patient object to store the current patient
  //Used to obtain data on treatment and tumour type
  Patient thePatient;
  
  //If a cohort is recruited we need a patient array
  Patient[] theCohort;
  
  
  //PImage to display - this will be superimposed on the user pixels obtained in gamestate(8)
  PImage hotspots;


 //array for user pixels
 int[] userMap;

 
  PETscanFeatures(SimpleOpenNI NIobject, PImage tempImage){
    scanContext = NIobject;
    bodyPosition = new PVector();
    convertedBodyPosition = new PVector();
    joint1 = new PVector();
    convertedJoint1 = new PVector();
    joint2 = new PVector();
    convertedJoint2 = new PVector();
    diff = new PVector();  
    hotspots = tempImage;
  }

  void updatePatient(Patient somePatient){
    thePatient = somePatient;
  }

  void updateCohort(Patient[] someCohort){
    theCohort = new Patient[someCohort.length];
    for(int i=0; i<someCohort.length; i++){      
    theCohort[i] = someCohort[i];
    }
  }
  
  Patient[] returnCohort(){
    return theCohort;
  }


//THIS VERSION OF drawScan IS DEPRECATED
//We now use a histology image instead
//see below
/*  .............................................................................................
  void drawScan(){
      scanContext.update(); 
     //if we need to force the tumour type within this function to adjust hotspot placement:
     //thePatient.tumourType=3;
     //REMEMBER TO RECOMMENT!!!!
     
      //if any users detected
      hotspots = scanContext.depthImage();
      
      
      //make vector list of ints to store users  
      IntVector userList = new IntVector();
  
      //write list of detected users to vector
       scanContext.getUsers(userList);
  
       //if find users
        if(userList.size() > 0) {
    
         //get first user ID
        int userID = userList.get(0);
        //find which pixels have users in
         userMap = scanContext.userMap();
         
          //populate the pixel array from the sketch contents
         loadPixels();
         
      for(int i=0; i<userMap.length; i++){
      //if current pixel is on a user
      if(userMap[i] != 0){
        //colour it
        hotspots.pixels[i]=color(140);
      } else {
        hotspots.pixels[i]= color(255,255,255);
        
      }//if(userMap)
      }//for
      

        if(scanContext.isTrackingSkeleton(userID)){
          
          //AT THE MOMENT WE ARE REMOVING DEFAULT HOTSPOTS IN FAVOUR OF JUST THE TUMOUR MASSES
          //uncomment ellipse() statements to show
          //Default hotspots - bladder, brain
          //assign skeleton data to the bodyPosition PVector
          //THIS IS FOR THE HEAD - WE WANT TO INTRODUCE A SWITCH TO DRAW SPECIFIC TUMOUR MASSES
          scanContext.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_HEAD, bodyPosition);
          scanContext.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_LEFT_SHOULDER, joint1);
          scanContext.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_RIGHT_SHOULDER, joint2);
          
          //convert detected skeleton position to projective coords to match depth image
          scanContext.convertRealWorldToProjective(bodyPosition, convertedBodyPosition);
          scanContext.convertRealWorldToProjective(joint1, convertedJoint1);
          scanContext.convertRealWorldToProjective(joint2, convertedJoint2);  
          
          //find distance between joint1 and joint2
          diff = PVector.sub(joint1, joint2);
          float magnitd = diff.mag();
          
          //now, display

          image(hotspots, 0, 0);
          if(thePatient.tumourType == 5){//blur brain if brain tumour
          fill(136);
          } else {
          fill(80);//shadow brain if not brain tumour
          }
          noStroke();
          ellipse(convertedBodyPosition.x, convertedBodyPosition.y-(50*magnitd/convertedBodyPosition.z), 280*magnitd/convertedBodyPosition.z, 220*magnitd/convertedBodyPosition.z);
          
          //assign skeleton data to the bodyPosition PVector
          //THIS IS FOR THE BLADDER - WE WANT TO INTRODUCE A SWITCH TO DRAW SPECIFIC TUMOUR MASSES
          scanContext.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_TORSO, bodyPosition);
          scanContext.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_LEFT_HIP, joint1);
          scanContext.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_RIGHT_HIP, joint2);
          
          //convert detected skeleton position to projective coords to match depth image
          scanContext.convertRealWorldToProjective(bodyPosition, convertedBodyPosition);
          scanContext.convertRealWorldToProjective(joint1, convertedJoint1);
          scanContext.convertRealWorldToProjective(joint2, convertedJoint2);  
          
          //find distance between joint1 and joint2
          diff = PVector.sub(joint1, joint2);
          magnitd = diff.mag();
          
          //now, display
          //ellipse(convertedBodyPosition.x, convertedBodyPosition.y+(0.75*magnitd), 250*magnitd/convertedBodyPosition.z, 100*magnitd/convertedBodyPosition.z);
          
          
          //THIS IS THE SWITCH FOR THE SPECIFIC TUMOUR SITE!!!!!!!!!!!
          //WE USE THE DATA FROM THE PATIENT OBJECT PASSED INTO THE CLASS
          //we need a way to set the feature ellipse size according to patient response to treatment
          //we are not doing this at the moment
          switch(thePatient.tumourType){
          case 0:
          //check if patient is M or F
          if(thePatient.sex == 0){
          //prostate cancer    
          //position relative to torso and hips, as for the bladder
          scanContext.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_TORSO, bodyPosition);
          scanContext.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_LEFT_HIP, joint1);
          scanContext.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_RIGHT_HIP, joint2);
          
          //convert detected skeleton position to projective coords to match depth image
          scanContext.convertRealWorldToProjective(bodyPosition, convertedBodyPosition);
          scanContext.convertRealWorldToProjective(joint1, convertedJoint1);
          scanContext.convertRealWorldToProjective(joint2, convertedJoint2);  
          
          //find distance between joint1 and joint2
          diff = PVector.sub(joint1, joint2);
          magnitd = diff.mag();
          
          //now, display
          //sizing according to patient SUV
          fill(0);
          noStroke();
          ellipse(convertedBodyPosition.x, convertedBodyPosition.y+(1100*magnitd/convertedBodyPosition.z), (3*thePatient.SUV)*magnitd/convertedBodyPosition.z, (5*thePatient.SUV)*magnitd/convertedBodyPosition.z); 
          
          } else if(thePatient.sex ==1) {
          //breast cancer
          scanContext.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_NECK, bodyPosition);
          scanContext.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_LEFT_SHOULDER, joint1);
          scanContext.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_RIGHT_SHOULDER, joint2);
          
          //convert detected skeleton position to projective coords to match depth image
          scanContext.convertRealWorldToProjective(bodyPosition, convertedBodyPosition);
          scanContext.convertRealWorldToProjective(joint1, convertedJoint1);
          scanContext.convertRealWorldToProjective(joint2, convertedJoint2);  
          
          //find distance between joint1 and joint2
          diff = PVector.sub(joint1, joint2);
          magnitd = diff.mag();
          
          //now, display
          //sizing is according to patient SUV variable
          fill(0);
          noStroke();
          ellipse(convertedBodyPosition.x-(145*magnitd/convertedBodyPosition.z), convertedBodyPosition.y+(270*magnitd/convertedBodyPosition.z), (3*thePatient.SUV)*magnitd/convertedBodyPosition.z, (3*thePatient.SUV)*magnitd/convertedBodyPosition.z);
                }      
          break;
          
          case 1:
          //NSCLC
          scanContext.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_NECK, bodyPosition);
          scanContext.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_LEFT_SHOULDER, joint1);
          scanContext.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_RIGHT_SHOULDER, joint2);
          
          //convert detected skeleton position to projective coords to match depth image
          scanContext.convertRealWorldToProjective(bodyPosition, convertedBodyPosition);
          scanContext.convertRealWorldToProjective(joint1, convertedJoint1);
          scanContext.convertRealWorldToProjective(joint2, convertedJoint2);  
          
          //find distance between joint1 and joint2
          diff = PVector.sub(joint1, joint2);
          magnitd = diff.mag();
          
          //now, display
          //sizing is according to patient SUV variable
          fill(0);
          noStroke();
          ellipse(convertedBodyPosition.x+(120*magnitd/convertedBodyPosition.z), convertedBodyPosition.y+(400*magnitd/convertedBodyPosition.z), (2*thePatient.SUV)*magnitd/convertedBodyPosition.z, (2*thePatient.SUV)*magnitd/convertedBodyPosition.z);
          break;
          
          case 2:
          //colon cancer
          //position relative to torso and hips, as for the bladder
          scanContext.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_TORSO, bodyPosition);
          scanContext.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_LEFT_HIP, joint1);
          scanContext.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_RIGHT_HIP, joint2);
          
          //convert detected skeleton position to projective coords to match depth image
          scanContext.convertRealWorldToProjective(bodyPosition, convertedBodyPosition);
          scanContext.convertRealWorldToProjective(joint1, convertedJoint1);
          scanContext.convertRealWorldToProjective(joint2, convertedJoint2);  
          
          //find distance between joint1 and joint2
          diff = PVector.sub(joint1, joint2);
          magnitd = diff.mag();
          
          //now, display
          //sizing according to patient SUV
          fill(0);
          noStroke();
          ellipse(convertedBodyPosition.x+(20*magnitd/convertedBodyPosition.z), convertedBodyPosition.y+(900*magnitd/convertedBodyPosition.z), (3*thePatient.SUV)*magnitd/convertedBodyPosition.z, (5*thePatient.SUV)*magnitd/convertedBodyPosition.z);
          break;
          
          case 3:
          //melanoma - we will make diffuse on torso
          //position relative to torso and hips, as for the bladder
          scanContext.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_TORSO, bodyPosition);
          scanContext.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_LEFT_HIP, joint1);
          scanContext.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_RIGHT_HIP, joint2);
          
          //convert detected skeleton position to projective coords to match depth image
          scanContext.convertRealWorldToProjective(bodyPosition, convertedBodyPosition);
          scanContext.convertRealWorldToProjective(joint1, convertedJoint1);
          scanContext.convertRealWorldToProjective(joint2, convertedJoint2);  
          
          //find distance between joint1 and joint2
          diff = PVector.sub(joint1, joint2);
          magnitd = diff.mag();
          
          //now, display
          //sizing according to patient SUV
          fill(0);
          noStroke();
          ellipse(convertedBodyPosition.x+(150*magnitd/convertedBodyPosition.z), convertedBodyPosition.y+(30*magnitd/convertedBodyPosition.z), (2*thePatient.SUV)*magnitd/convertedBodyPosition.z, (2*thePatient.SUV)*magnitd/convertedBodyPosition.z);
          ellipse(convertedBodyPosition.x-(100*magnitd/convertedBodyPosition.z), convertedBodyPosition.y+(500*magnitd/convertedBodyPosition.z), (2.5*thePatient.SUV)*magnitd/convertedBodyPosition.z, (2.5*thePatient.SUV)*magnitd/convertedBodyPosition.z);
          ellipse(convertedBodyPosition.x+(40*magnitd/convertedBodyPosition.z), convertedBodyPosition.y-(300*magnitd/convertedBodyPosition.z), (1.5*thePatient.SUV)*magnitd/convertedBodyPosition.z, (1.5*thePatient.SUV)*magnitd/convertedBodyPosition.z);
          ellipse(convertedBodyPosition.x, convertedBodyPosition.y-(10*magnitd/convertedBodyPosition.z), (1.5*thePatient.SUV)*magnitd/convertedBodyPosition.z, (1.5*thePatient.SUV)*magnitd/convertedBodyPosition.z);          
          break;   
          
          case 4:
          //renal cancer
          scanContext.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_NECK, bodyPosition);
          scanContext.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_LEFT_SHOULDER, joint1);
          scanContext.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_RIGHT_SHOULDER, joint2);
          
          //convert detected skeleton position to projective coords to match depth image
          scanContext.convertRealWorldToProjective(bodyPosition, convertedBodyPosition);
          scanContext.convertRealWorldToProjective(joint1, convertedJoint1);
          scanContext.convertRealWorldToProjective(joint2, convertedJoint2);  
          
          //find distance between joint1 and joint2
          diff = PVector.sub(joint1, joint2);
          magnitd = diff.mag();
          
          //now, display
          //sizing is according to patient SUV variable
          fill(0);
          noStroke();
          ellipse(convertedBodyPosition.x-(120*magnitd/convertedBodyPosition.z), convertedBodyPosition.y+(650*magnitd/convertedBodyPosition.z), (3*thePatient.SUV)*magnitd/convertedBodyPosition.z, (3*thePatient.SUV)*magnitd/convertedBodyPosition.z);
          break;
          case 5:
          //Glioblastoma
          scanContext.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_HEAD, bodyPosition);
          scanContext.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_LEFT_SHOULDER, joint1);
          scanContext.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_RIGHT_SHOULDER, joint2);
          
          //convert detected skeleton position to projective coords to match depth image
          scanContext.convertRealWorldToProjective(bodyPosition, convertedBodyPosition);
          scanContext.convertRealWorldToProjective(joint1, convertedJoint1);
          scanContext.convertRealWorldToProjective(joint2, convertedJoint2);  
          
          //find distance between joint1 and joint2
          diff = PVector.sub(joint1, joint2);
          magnitd = diff.mag();
          
          //display
          fill(0);
          noStroke();
          ellipse(convertedBodyPosition.x+(40*magnitd/convertedBodyPosition.z), convertedBodyPosition.y-(100*magnitd/convertedBodyPosition.z), (1.5*thePatient.SUV)*magnitd/convertedBodyPosition.z, (1.5*thePatient.SUV)*magnitd/convertedBodyPosition.z);     
          break;
          
          default:
          break;
          }
          
    } // end if(isTrackinhSkeleton
  } //end if(userList > 0)
  }//end drawHead()
 
.................................................................................................................................... */   

  void drawHistology(){
  //insert histology image from patient object to the call from gamestate(8)
  image(thePatient.histology, 0, 270);
  }
  
}//class end
  
