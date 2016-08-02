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
	Dialog.addNumber("Width in Pixels", 3000);
	Dialog.show();
	
	newWidth=Dialog.getNumber();

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
	run("Select None");
	getDimensions(width, height, channels, slices, frames);
	newHeight= (width*newWidth)/height;
	
	run("Size...", "width="+newWidth+" height="+newHeight+" depth="+channels+" constrain average interpolation=Bilinear");
	
	//selectWindow(list[i]);	
	
	
	saveAs("Tiff", dir1+list[i]+"_"+newWidth+"px.tif");
	
	//close the window after returning from function
	//selectWindow(list[i]+"_"+newWidth+"px.tif");
	close();
	
	}

print("done");
}


