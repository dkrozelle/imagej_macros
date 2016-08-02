//*********************************************************  
//    20110428 ciclistadan
//    based on my original kinetochore identification and measurement tool
//    this tool is simpler in that it simply makes crops and prints summary measurements for each AVG

//NOT COMPLETE
//*********************************************************

function reduceHyperStack();
function printStackMaxPixel();
function blackout();
function appendMax();
function saveDocumentation();

	
macro "AVG Measure" {

//Dialog to define inputs
	if(isOpen("Results")){
		selectWindow("Results");
		run("Close");
		}
	if(isOpen("Log")){
		selectWindow("Log");
		run("Close");
		}	

	//define each channel
 	Dialog.create("Define Channels");

	Dialog.addString("channel 1","Phase");
	Dialog.addString("channel 2","DAPI");
	Dialog.addString("channel 3","G3BP");
	Dialog.addString("channel 4","dsRNA");
	filter="tif";
	Dialog.addString("Suffix Filter :", filter);
	
	Dialog.show();

	channel1=Dialog.getString();
	channel2=Dialog.getString();
	channel3=Dialog.getString();
	channel4=Dialog.getString();
	filter=Dialog.getString();

	
//get directory information	about where the source stacks are saved
	
  dir1 = getDirectory("Choose source directory");
  if (dir1=="")
      exit("No directory available");

//get a list of all the files in this folder 
  list = getFileList(dir1);

  // Create a results directory in dir1
  dir2 = dir1+"results"+File.separator;
  File.makeDirectory(dir2);
  if (!File.exists(dir2))
      exit("Unable to create directory");

//test each image to see if it passes the filter
 resultNumber=0;
  for(i=0; i<list.length; i++) {
	if (endsWith(list[i],filter)) {
		// Create an image directory within dir2(results)
		  subdir = dir2+list[i]+File.separator;
		  File.makeDirectory(subdir);
			  if (!File.exists(subdir))
			      exit("Unable to create movie directory");	

//import image, get stack dimensions, make composite projection for identifying AVG locations     	
      	run("Bio-Formats Importer", "open="+dir1+list[i] +" view=Hyperstack stack_order=XYCZT");
      	setLocation(50,50);
	Stack.getDimensions(width, height, channels, slices, frames);
      	run("Z Project...", "start=1 stop=" +slices+" projection=[Max Intensity]");
     	rename("Image Map of "+list[i]);
     	setLocation(60,60);
      	run("Make Composite");
  	selectWindow("Image Map of "+list[i]);
	
  	setSlice(channel4);
  	run("Enhance Contrast", "saturated=0.4");
  	setSlice(channel2);
	run("Enhance Contrast", "saturated=0.4");
	selectWindow("Image Map of "+list[i]);
	getLocationAndSize(f,g,h,j);	

//identify cells to crop and count 
	setTool("elliptical");
	roiManager("reset");
	run("ROI Manager...");
	selectWindow("ROI Manager");	
	setLocation(f+h,g+(j/4));
	waitForUser("circle and \"Add (t)\" each nuclei to ROI Manager");
	
//show all cell selections and show dialog to identify celltype for each, continue by OK
	selectWindow("Image Map of "+list[i]);
	celltype=newArray("interphase","mitotic");
	selectWindow("Image Map of "+list[i]);
	setOption("Show All",true);
	Dialog.create("Identify Cell Type");
	
//get cell types from dialog box by iterating for each cellROI, close projection image
	for(count=0;count<roiManager("count");count++){
		Dialog.addChoice("Cell #"+count+1, celltype);
		}
	Dialog.show();
	selectWindow("Image Map of "+list[i]);
	close();
	
//place celltype value in each cellID array position, rename each cellROI, and save ROI manager for this HyperStackImage
	cellID=newArray(roiManager("count"));
	for(count=0;count < roiManager("count");count++){
		cellID[count]=Dialog.getChoice();
		roiManager("Select", count);
		roiManager("Rename","cell "+count+1+" "+cellID[count]);
		
	}
	roiManager("Save",subdir+"CellMap.zip");
	maxCell=roiManager("count");
//reopen ROI file if closed, select image, select cell by ROI, duplicate this cells' hyperstack (all channels), duplicate channel4 channel to regular stack (single channel)
//loop this for each cell in the image
//count = keep track of the cells ROI in ROI manager
	
	for(count=0;count < maxCell;count++){
						
		//duplicate each cropped cell hyperstack 
		roiManager("reset"); 
		roiManager("Open",subdir+"CellMap.zip");
		selectWindow(list[i]);
		roiManager("Select", count);
		run("Duplicate...", "title=Image:"+i+"_Cell:"+count+1+"_CellType:"+cellID[count]+" duplicate");

		//define this cropped cell hyperstack as "cellHyperStack"
		cellHyperStack="Image:"+i+"_Cell:"+count+1+"_CellType:"+cellID[count];

		//enlarge the hyperstack to prevent errors when measuring edge kinetochores
		//save the image for documentation later
		Stack.getDimensions(width, height, channels, slices, frames);
		run("Canvas Size...", "width="+width+10+" height="+height+10+" position=Center");
		selectWindow(cellHyperStack);
		saveAs("Tiff",subdir+"Cell#"+count+1+".tif");				
		cellHyperStack="Cell#"+count+1+".tif";

		//duplicate channel4 channel for kinetochore identification
		Stack.setChannel(channel4);
		reduceHyperStack(channel4);
		
		//find brightest pixel for this channel, place its value in the redults table, then change the pixel value to black, repeat for 'objects' times, then close the blacked out image
		kt=1;	
		max=resultNumber+objects;
		//resultNumber is initialized=0, then recalculated after adding all objects to results table before next cell iteration	
		for(resultNumber;resultNumber<max;resultNumber++){
			//find the highest intensity pixel and print its location and value to results table
			printStackMaxPixel(i+1,kt,count+1,resultNumber);
			//change this max value and a region () around it to black, preventing re-counting
			blackout(resultNumber);
			kt++;
			}
		close();
		
		
		//go back to hyperstack of this cell, duplicate channel4 channel stack, subtract background and gather pixel values 
		selectWindow(cellHyperStack);
		Stack.setChannel(channel4);
		reduceHyperStack(channel4);
		run("Subtract Background...", "rolling=50 stack");
		resultNumber=resultNumber-objects;
		for(resultNumber;resultNumber<max;resultNumber++){
			appendMax(getResult("x", resultNumber),getResult("y", resultNumber),getResult("z", resultNumber),resultNumber,"subtracted channel4");
			}
		close();
		
		//go back to hyperstack of this cell, duplicate the channel3 channel stack and gather pixel values 
		selectWindow(cellHyperStack);
		Stack.setChannel(channel3);
		reduceHyperStack(channel3);
		resultNumber=resultNumber-objects;
		for(resultNumber;resultNumber<max;resultNumber++){
			appendMax(getResult("x", resultNumber),getResult("y", resultNumber),getResult("z", resultNumber),resultNumber,"raw channel3");
			}

		//keeping channel3 channel open, subtract background and find subtracted values
		run("Subtract Background...", "rolling=50 stack");
		resultNumber=resultNumber-objects;
		for(resultNumber;resultNumber<max;resultNumber++){
			appendMax(getResult("x", resultNumber),getResult("y", resultNumber),getResult("z", resultNumber),resultNumber,"subtracted channel3");
			}
		
		//before closing, save an ROI for each kinetochore using coordinates on the Results table
		resultNumber=resultNumber-objects;
		roiManager("reset"); 
		for(resultNumber;resultNumber<max;resultNumber++){
			saveDocumentation(getResult("x", resultNumber),getResult("y", resultNumber),getResult("z", resultNumber),resultNumber);
			}
		roiManager("Save",subdir+"Cell#"+count+1+"KinetochoreROIs.zip");
		close();

		 selectWindow("Results");
		 saveAs("Measurements", dir2+"Results of Analysis.txt");

		//set resultNumber as the next available line in Results for next cell iteration		
		resultNumber=nResults;

		//close cellHyperStack and prepare to open another
		selectWindow(cellHyperStack);
		close();
		
		
		
		}  //loops each cell for one image
		selectWindow(list[i]);
		close();
	    }    //end of IF(filter) statement
	else
		print(list[i]+" was not included");
		
      }     //loops each movie in source folder
 
 selectWindow("Results");
 saveAs("Measurements", dir2+"Results of Analysis.txt");

 
 selectWindow("ROI Manager");
 run("Close");
 
 print("program ended properly");
}  //end main macro 


// Reduce HyperStack
//
// This macro function reduces the dimensionality of an hyperstack. It will create
// a new hyperstack with all the channels and time points at a given
// z position, or all the z slices for the current channel and time point, etc.

function reduceHyperStack(channel) {
    
     requires("1.40a");
     if (!Stack.isHyperStack) exit ("HyperStack required");
     setBatchMode(true);
     Stack.getDimensions(width, height, channels, slices, frames);
     Stack.getPosition(c1, z1, t1);
     Stack.getDisplayMode(mode);
     title = getTitle();
     b = bitDepth();
     id = getImageID();


     channels = 1;
     run("New HyperStack...", "title="+title+" channel-"+channel+" type="+b+"-bit display=Color width="+width+" height="+height+" channels="+channels+" slices="+slices+" frames="+frames+" ");
     id2 = getImageID();
     n = channels*slices*frames; 
     i = 0;

     for (c=1; c<=channels; c++) {
        if (channels==1) c=c1;
        selectImage(id);
        Stack.setPosition(c,1,1);
        getVoxelSize(vw, vh, vd, unit); 
         if (b!=24) getLut(reds, greens, blues);
        getMinAndMax(min, max);
        for (z=1; z<=slices; z++) {
           if (slices==1) z=z1;
           for (t=1; t<=frames; t++) {
              showProgress(i++, n);
              if (frames==1) t=t1;
              selectImage(id);
              Stack.setPosition(c,z,t);
              run("Copy");
              selectImage(id2);
              Stack.setPosition(c,z,t);
              run("Paste");
           }
        }
        selectImage(id2);
        Stack.setPosition(c,1,1);
        setVoxelSize(vw, vh, vd, unit);
        if (b!=24) setLut(reds, greens, blues); 
        setMinAndMax(min, max);
     }

     setBatchMode(false);
     selectImage(id);
     Stack.setPosition(c1, z1, t1);
     selectImage(id2);
     Stack.setPosition(1, 1, 1);
     if (is("composite")) Stack.setDisplayMode(mode);
     run("Select None");

  }



//this macro function searches through a stack to find the highest intensity pixel,
//once found it adds the location to the roi manager, 
//changes the selection to a 3x3 square, changes pixel value to 0,
//and then repeats for +/- slice


function printStackMaxPixel(movie,kt,cell,resultNumber) {

//determine which slice contains the hightest intensity pixel
Stack.getDimensions(width, height, channels, slices, frames);


currentmax=0;
goodslice=0;
for(i=1;i<=slices;i++){
	setSlice(i);
	getRawStatistics(nPixels, mean, min, slicemax, std, histogram);
	if(slicemax > currentmax){
		currentmax=slicemax;
		goodslice=i;
		}
	}

//go to that slice and find the coordinates of the highest intensity pixel
//append the intensity value and coordinates in results table
setSlice(goodslice);
	for(y=1;y<=height;y++){
		for(x=1;x<=width;x++){
			if (currentmax==getPixel(x,y)){
			setResult("Image#",resultNumber,movie);
			setResult("Cell #",resultNumber,cell);
			setResult("kt #",resultNumber,kt);
			setResult("x",resultNumber,x);
			setResult("y",resultNumber,y);
			setResult("z",resultNumber,goodslice);
			setResult("raw channel4 value",resultNumber,getPixel(x,y));
			updateResults();
			}
		}
	}
}

//ImageJ macro written to be used in Alex's Kinetochore Counter macro
//Dan Rozelle, 20090123
//
//draws a sphere with specified redius centered around
//pointx,y,z found in results table
//

function blackout(resultNumber) {

x=getResult("x", resultNumber);
y=getResult("y", resultNumber);
z=getResult("z", resultNumber);

slice=z-2;
run("Colors...", "foreground=black background=black");

//fill 5x5 square black on 5 slices, centered on ROI
for(slice;slice<=z+2;slice++){
	if(slice > 0 && slice <= nSlices){
		setSlice(slice);
		fillRect(x-2,y-2,5,5);
		}
	}

}




//this macro function scans through a specified ROI and appends the 
//coordinates and value of the highest intensity pixel to the results table

function appendMax(x,y,slice,line,category) {



//scan each pixel in a 5x5 ROI specified by given center point for the highest intensity pixel
//append its value to the given line in the results table under a new specified category

Stack.getDimensions(width, height, channels, slices, frames);

currentmax=0;
setSlice(slice);
y=y-2;
x=x-2;
ymax=y+5;
xmax=x+5;

if(y>=0 && x>=0){
	if(ymax<=height && xmax<=width){
		for(y;y<=ymax;y++){
			for(x;x<=xmax;x++){
				if(currentmax < getPixel(x,y)){
					currentmax=getPixel(x,y);
					}
				}
			}
		}
	}	
else{
	currentmax=getPixel(y+2,x+2);
	}	
	
	setResult(category,line,currentmax);
	updateResults();
}

function saveDocumentation(x,y,z,line){

	foo=getResult("x", line);
	bar=getResult("y", line);
	baz=getResult("z", line);
	run("Specify...", "width=3 height=3 x="+foo+" y="+bar+" slice="+baz);
	roiManager("add");
	
}
