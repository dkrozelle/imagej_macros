// 20121108 ciclistadan
// this was originally developed to crop viral factory regions from cell images 
// 
// requires flat single or multichannel image to already be open
// click on a region and an roi duplicates the region and saves it to the output folder

function cropROI();


macro "go" {

if(nImages>1) exit ("close all but one image before proceeding");
getDimensions(imageWidth, imageHeight, channels, slices, frames);  
if(slices>1) exit ("this image has "+slices+"slices'n"+"this macro requires a single flat image (no z-stacks)");

//where to save cropped images
 dir1 = getDirectory("Choose where to save cropped images");
 if (dir1=="") exit("No directory available");

//dir1="C:\\Users\\drozelle\\Desktop\\factory_crops\\";

name=getTitle();
basename = substring(name,0,lengthOf(name)-4);
//cropped ROI size
ROIsize=100;
//image numbering starts at
i=1;

leftButton=16; rightButton=4; shift=1; ctrl=2; alt=8;
x2=-1; y2=-1; z2=-1; flags2=-1;

	logOpened = false;
	print("close this window after you're done counting");
	print(" zoom to reposition with +/-, do not attempt to drag the window");
	print("\n currently saving crops to "+dir1);
	//continue until log is closed	  
      while (!logOpened || isOpen("Log")) {
          getCursorLoc(x, y, z, flags);
		
		//only recalculate if the cursor or button is pressed has changed position
		if (x!=x2 || y!=y2 || z!=z2 || flags!=flags2) {

			//crop an ROI when a click is detected
			if(flags==16||flags==2){
				cropROI(x,y,ROIsize,basename,i);
				i++;

			}
            
              logOpened = true;
              startTime = getTime();
          }
          x2=x; y2=y; z2=z; flags2=flags;
          wait(100);
	}

     

}


function cropROI(x,y,size,basename,i){	

	roiWidth=size;
	roiHeight=size;
	getDimensions(imageWidth, imageHeight, channels, slices, frames);  
	
	
	if(x-roiWidth/2<0){left=0;}
	else if(x+roiWidth/2>imageWidth){left=imageWidth-roiWidth;}
	else{left=x-roiWidth/2;}
	
	if(y-roiHeight/2<0){top=0;}
	else if(y+roiHeight/2>imageHeight){top=imageHeight-roiHeight;}
	else{top=y-roiHeight/2;}				
	
	run("Specify...", "width="+roiWidth+" height="+roiHeight+" x="+left+" y="+top+" slice=5");
	run("Duplicate...", "title=crop duplicate channels=1-"+channels);
	selectWindow("crop");
	
	saveAs("Tiff", dir1+basename+"-crop"+i+".tif");
	selectWindow(basename+"-crop"+i+".tif");
	close();
}