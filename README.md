Contains the code for the Processing game Phase I Cancer Trial using Micrsoft Kinect motion tracking.

The game is used in teaching differences between A+B and Bayesian model-based phase I safety trial designs within the University of Glasgow MSc Cancer Research and Precision Oncology.
Full description of the tutorial activity will be reported elsewhere in a manuscript outlining an investigation into student responses to the activity.
Kinect skeleton tracking functions in the code are adapted (not very much!) from Making Things See by Greg Borenstein (Maker Media, 2012).
Permission to publish the game source code including these code examples was kindly provided by Maker Media and the author.

Objective of the game: 
- Find the maximum tolerated dose and dose-limiting toxicities of drug X, without killing any patients.

Background:
- Drug X is a fictional inhibitor of Very Important Cancer Target 1 (VICT1). It is not orally bioavailable and is usually administered with an enormous syringe.
- In the tutorial setting, students play the SAXOPHONES (Single Agent drug X Once daily PHase ONE Study) trial because all cancer trials must have silly acronyms by law.
- The inclusions/exclusions and endpoints are unremarkable for a cancer phase I.
- However, the investigators have not decided on dose range to investigate or recruitment design - that is the player's job.

Notes:
- In normal use, the game includes a dose selection screen in which said enormous syringe features prominently.
- The syringe 3D model was obtained from Turbosquid (New Orleans, LA, USA; product ID 590149) and cannot be provided with the code for licensing reasons.
- Instead, we provide the "Stanford bunny" .obj as an even sillier replacement (http://graphics.stanford.edu/data/3Dscanrep/).
- If you want to change it, just change the obj and mtl files in the main folder and change this line in the main sketch to point to the new file:

  model = new OBJModel(this, "stanford_bunny.obj", "relative", POLYGON);
 
- In normal use, a number of histopathology images are also included illustrating different tumour sites and stages.
- These were obtained from online sources under fair educational use and are not distributed.
- In order not to have to modify the code, these have been replaced with blank jpg files. If you want this aspect reactivated, replace these blank jpg files with appropriate images of the same filenames.

How to play:
- Preclinical toxicology studies in dog found a No Adverse Events Level for drug X of 50 mg/kg/day.
- Severe neutropenic and thrombocytopenic events and rare cardiac toxicities were observed at a doses of 400 mg/kg/day.
- Appropriate human equivalent starting dose in mg/m^2 can be determined by allometric scaling (Nair and Jacob, 2016, J Basic Clin Pharm, 7(2), 27-31)
- The game is mainly navigated by a series of buttons activated by the Kinect user's right hand.
- The user recruits a cohort (or possibly individual patients for model based designs).
- A dose for the current patient or cohort is chosen and toxicities are checked.
- The user should then decide whether dose-limiting toxicities are observed and make an appropriate decision to escalate/de-escalate/expand the cohort/stop.
- This decision is made differently for different designs - eg, 3+3; continuous reassessment method; modified toxicity probability interval design.
- The dose selection for a current cohort is adjusted with a sliding scale tracking distance between the user's hands.
- This version of the code is intended to be played interactively with both a tutor and a student.
- Some buttons are disabled for kinect activation since first time users can find the game hard to control.
- These can be activated by the tutor with the cursor.
- Once MTD is identified, the user can publish the trial. The tutor can then reiterate major features of the trial based on summary tables shown which resemble clinical trial publication tables.
- Generally, a trial played according to model-based designs will treat more patients close to MTD than A+B designs.
- This is a key real-world operating characteristic of such designs.

The game also allows for selection of several other oncology agents that have been tested in phase I (or later, including approved agents).
If these are selected instead of drug X, the player should arrive at similar conclusions to those in the trial references included in the data folder.
Since I don't want to be sued, the ability of these agents to cause fatal toxicty has been disabled. I DO NOT claim that can happen with any of them. It can for drug X, however...

************* Requirements *****************************************************************************************************************************
- Ubuntu 14+
- Processing 2.2.1 (not tested on other releases - probably incompatible with Processing 3)
- Microsoft Kinect v1 with power cable and usb
- Simple Open NI libraries - installation instructions can be found at: https://code.google.com/archive/p/simple-openni/wikis/Installation.wiki
- OBJ loader library - installation instructions at https://code.google.com/archive/p/saitoobjloader/

*******************************************************************************************************************************************************

Game installation: after installation of Processing, simply place the game folder in your sketchbook, open Processing > Sketches > trialGame_1_0 and play

Happy trialling! Keep your patients safe...
