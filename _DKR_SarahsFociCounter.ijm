//*********************************************************  
//    
//    
//
//*********************************************************

function colonycounter();

macro "go"{
setBatchMode(false);

	if(nImages>0) exit ("close all images before proceeding");

	if(isOpen("Results")){
		selectWindow("Results");
		run("Close");
		}


//find the source images
dir1 = getDirectory("Choose source directory");
if (dir1=="")
      exit("No directory available");

// Create an output directory within dir1
dir2 = dir1+File.separator+"results"+File.separator;
  File.makeDirectory(dir2);
  if (!File.exists(dir2))
      exit("Unable to create directory");	  

//get list of images to process, open and count colonies function on each
list = getFileList(dir1); 
for (i=0; i<list.length; i++) {
	showProgress(i+1, list.length);
	name=list[i];
	
	if(endsWith(name,"tif")) {
		open(dir1+name); 
		colonycount(dir1,dir2,name);
		close();
		}
	}



  }



function colonycount(dir1,dir2,name) {

//separate the dapi channel
selectWindow(name);
setSlice(1);
run("Duplicate...", "title=ch1 channels=1-2");


//threshold mask the nuclei and watershed
selectWindow("ch1");
setAutoThreshold("Default dark");
run("Convert to Mask");
run("Watershed");
run("Convert to Mask");

roiManager("Reset");
selectWindow("ch1");
run("Analyze Particles...", "size=50-500 circularity=0.00-1.00 show=Nothing summarize add");
roiManager("Deselect");
roiManager("Save", dir2+name+"_ch1_RoiSet.zip");
selectWindow("ch1");
close();

//separate the virus channel
selectWindow(name);
setSlice(2);
run("Duplicate...", "title=ch2 channels=1-2");

//prefiltering steps to improve threshold
//initialize and define looping variables
run("Smooth");
run("Smooth");
run("Smooth");
run("Variance...", "radius=10");

run("Threshold...");
waitForUser("adjust Threshold\nand continue");


//you are happy,s continuing//		
run("Convert to Mask");
run("Watershed");
run("Convert to Mask");
roiManager("Reset");
run("Analyze Particles...", "size=50-500 circularity=0.00-1.00 show=Nothing summarize add");
roiManager("Deselect");
roiManager("Save", dir2+name+"_ch2_RoiSet.zip");

selectWindow("ch2");
close();

}


