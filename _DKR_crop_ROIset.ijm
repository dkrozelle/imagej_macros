//20120807 _DKR_crop_ROIset.ijm
//  arguments: open im age and ROIs corresponding to what you want cropped (usually cells)
//	function:  select ROI, rename ROI, crop ROI region from image, save cropped image under ROI name
//
//  follow-up: individually cropped ROIs can then be used for gathering 
//		         automated measurements (mean, area, etc) 
//               manually scored with the "_DKR_Batch_categorize.ijm" macro



macro "go"{

// vars
setBatchMode("TRUE");

// prepare environment 
{
if(nImages>1) exit ("close all images before proceeding");
	if(isOpen("Results")){
		selectWindow("Results");
		run("Close");
		}
	if(isOpen("Log")){
		selectWindow("Log");
		run("Close");
		}
}

// define directories
{
dir2 = getDirectory("Choose where to save cropped images");
if (dir2=="")
      exit("No directory available");
  
}


// the image to be cropped should already be open
// get the name of the current image
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
	
roiManager("Deselect");
showMessage("Macro Done \n make sure to save the renamed ROIset.zip");
	
}
