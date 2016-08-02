// created by Dan Rozelle 20080701
//used to extract a binary image from the first frame of a movie
//and compile them into a montage 
//this enables easy marking and reference 


function markCellLocation() 

macro "MapMaker"{


dir1 = getDirectory("Choose source directory");
if (dir1=="")
      exit("No directory available");

//get a list of all the files in this folder 
preList = getFileList(dir1);
size=0;

//determine which filetypes to include in your maps
	filter="D3D.dv";
	expname=preList[0];

	Dialog.create("File Types");
	Dialog.addString("Exp :", expname);
	Dialog.addString("Suffix Filter :", filter);
	
	Dialog.show();
	expname=Dialog.getString();
	filter=Dialog.getString();
	

//count only '*filter*' files
for(place=0;place<preList.length;place++){
	if(endsWith(preList[place],filter)){
		size++;
	}
}
//create a new array and populate with filtered images
list=newArray(size);
position=0;
for(place=0;place<preList.length;place++){
	if(endsWith(preList[place],filter)){
		list[position]=preList[place];
		position++;
	}
}

//calculate how many sheets will be created if there are 6 images per sheet
map=0;
maps=round(list.length/6);
//we start with the first image
i=0;

//repeat processing for groups of 6 images
for(map=1;map<=maps;map++){
	//determine how many images will be processed for this sheet, default is 6 unless there are less than that
	if(i+6<=list.length) 
		max=i+6;
	else 
		max=list.length;
		group=max-i;
	//starting with the first image, we increment through each image until we have done 6, or finish our list, whichever comes first
	  for(i; i<max; i++) {
		//open a two color image in separate channel stacks
		run("Bio-Formats Importer", "open="+dir1+list[i]+" view=Hyperstack stack_order=XYCZT split_channels");
		
		//copy first frame of series
		selectWindow(list[i]+" - C=0");
		run("Copy");
		run("Internal Clipboard");
		selectWindow(list[i]+" - C=0");
		close();
	
		//copy second frame of series
		selectWindow(list[i]+" - C=1");
		run("Copy");
		run("Internal Clipboard");
		selectWindow(list[i]+" - C=1");
		close();

		//combine colors into one composite image
		run("Images to Stack");
		run("Make Composite", "display=Composite");
		selectWindow("Stack");
		rename(list[i]);

		//prepare binary image from composite
		run("RGB Color");
		run("8-bit");
		run("Invert");
		run("Enhance Contrast", "saturated=0.5");
	
		//save binary image and close all images
		selectWindow(list[i]+" (RGB)");
		saveAs("Tiff",dir1+list[i]+".dv");
		while (nImages >0) close();
			
		}

		//now that we have processed the images for this current sheet, we will reopen those images and compile the sheet
		//reset our increment counter "i" and open all images
		i=i-group;
		//reopen each processed image
		for (i;i<max;i++)
			{
			print(dir1+list[i]+".tif");
			open(dir1+list[i]+".tif");
			}
		
		run("Images to Stack");
		Stack.getDimensions(width, height, channels, slices, frames);
		foo=slices;
		run("Colors...", "foreground=black background=black selection=yellow");
		run("Make Montage...", "columns=3 rows=2 scale=0.25 first=1 last="+foo+" increment=1 border=2 label use");
		saveAs("Tiff",dir1+expname+"-map#"+map+".tif");
		close();
		selectWindow("Stack");
		close();
}

mark = false;
if(list.length>0) mark = getBoolean("Do you want to mark cells now?");
else print("there are no images of this type, try again");
	if (mark==true) {
	mapsList = getFileList(dir1);
	j=0;
		for(j;j<mapsList.length;j++){
			if(startsWith(mapsList[j],"MovieMap")){
				open(dir1+mapsList[j]);
				markCellLocation();
				selectWindow(mapsList[j]);
				saveAs("Tiff",dir1+mapsList[j]);
				close();
			}			

		}
	}


}


function markCellLocation() {

	roiManager("reset");
      leftButton=16;
      rightButton=4;
      shift=1;
      ctrl=2; 
      alt=8;
      x2=-1; y2=-1; z2=-1; flags2=-1;
      logOpened = false;
	print("close this window when done");
      if (getVersion>="1.37r")
          setOption("DisablePopupMenu", true);
      while (!logOpened || isOpen("Log")) {
          getCursorLoc(x, y, z, flags);
		//only recalculate if the cursor has changed one position
          if (x!=x2 || y!=y2 || z!=z2 || flags!=flags2) {
 
		if(flags==16||flags==2){
			run("Specify...", "width=3 height=3 x="+x+" y="+y);
			roiManager("add");
			roiManager("Label");
			
			}
            
              logOpened = true;
              startTime = getTime();
          }
          x2=x; y2=y; z2=z; flags2=flags;
          wait(100);
      }
      if (getVersion>="1.37r")
          setOption("DisablePopupMenu", false);





}