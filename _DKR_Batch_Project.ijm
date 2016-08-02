// created by Dan Rozelle 20091005
// edited to project entire volume from folder
//used to quickly open each tif stack, you scroll to the middle frame 
// clicking OK creates a projection of thick # of slices and saves it in a subfolder named 'flat'


macro "go"{
setBatchMode('true')
	
if(nImages>0) exit ("close all images before proceeding");


dir1 = getDirectory("Choose stacks directory");
if (dir1=="")
      exit("No directory available");

// Create a results directory within dir1 if it doesn't already exist
resultsfolder = "projections";
dir2 = dir1+resultsfolder+File.separator;
if(!File.exists(dir2)) File.makeDirectory(dir2);

//ensure it was able to create dir2
if(!File.exists(dir2))
      exit("Unable to create directory");

list = getFileList(dir1);

//starting with the first image, we increment through each image until we have done 6, or finish our list, whichever comes first
  for(i=0; i<list.length; i++) {
  	if(endsWith(list[i],"tif")){
		open(dir1+list[i]);
		getDimensions(width, height, channels, slices, frames);
		run("Z Project...", "start=1 stop="+slices+" projection=[Max Intensity]");
		
		//save and close new projection
		selectWindow("MAX_"+list[i]);
		name=list[i];
		newname=replace(name,".tif","_maxprj.tif");
		saveAs("Tiff", dir2+newname);
		close();
		
		selectWindow(list[i]);
		close();
	}
	}
}


