//20110428 ciclistadan
//  crops individual cells images and allows you to specify ROIs, 
//  from which it makes duplicates and saves each
//  originally used for AVG examples but can be used for any ROI
//  later you can go through these saves crops and get stats from them
dir1="";
dir2="";

macro "go"{
//make sure only one image is open
{
if(nImages>1) exit ("close all images before proceeding");

setBatchMode("TRUE");

	if(isOpen("Results")){
		selectWindow("Results");
		run("Close");
		}
	if(isOpen("Log")){
		selectWindow("Log");
		run("Close");
		}
}

//where to save cropped images
dir1 = getDirectory("Choose where to save cropped images");
if (dir1=="")
      exit("No directory available");
  // Create a results directory in dir1

dir2 = dir1+"results"+File.separator;
  File.makeDirectory(dir2);
  if (!File.exists(dir2))
      exit("Unable to create directory");

//get the name of the current image
name = "survey";
id = getImageID();	  
rename(name);
selectWindow(name);
getDimensions(imageWidth, imageHeight, channels, slices, frames);  

cells = roiManager("count")+1;

for(cell=1; cell<cells; cell++){
	cellname="cell#"+cell;
	roiManager("Select", cell-1);
	roiManager("Rename", cellname);
	run("Duplicate...", "title="+cellname+" duplicate channels=1-"+channels);
	selectWindow(cellname);
	//run("Clear Outside");
	saveAs("Tiff", dir2+cellname);
	run("Close");
	}

}
