// created by Dan Rozelle 20110324
//used to create a similarly scaled montage for each image in a file
//this will only work with flat composite images (multi channel, single slice)


macro "go [q]"{
setBatchMode(true);

if(nImages>0) exit ("close all images before proceeding");

	if(isOpen("Results")){
		selectWindow("Results");
		run("Close");
		}
	if(isOpen("Log")){
		selectWindow("Log");
		run("Close");
		}


/**********************************************************/
Dialog.create("Select Options");
	Dialog.addNumber("Rolling Ball Radius", 5);
	Dialog.show();
	
	radius=Dialog.getNumber();

/**********************************************************/

//find the source images
dir1 = getDirectory("Choose source directory");
if (dir1=="")
      exit("No directory available");
parent = File.getParent(dir1);
	  
//create an array with image names
list = getFileList(dir1);
	
//starting with the first image, we increment through each image, checking the aspect ratio and resize
  for(i=0; i<list.length; i++){

	open(dir1+list[i]);
	selectWindow(list[i]);
	getDimensions(width, height, channels, slices, frames);
	
	for(j=1; j<=channels; j++){
		setSlice(j);
		run("Subtract Background...", "rolling="+radius);	
		}	
	
	saveAs("Tiff", dir1+list[i]+"_bkgd.tif");
	
	close();
	
	}


}


