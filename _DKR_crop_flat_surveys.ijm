//20110428 ciclistadan
//  crops individual cells images and allows you to specify ROIs, 
//  from which it makes duplicates and saves each
//  originally used for AVG examples but can be used for any ROI
//  later you can go through these saves crops and get stats from them

dir2="";
macro "go"{

//make sure only one image is open
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

//list auto functions here, adjust mode as necessary

function batchfunction();
function autoScaleBrightestSlice();
function getLocation();
function cropAndSave();


//where to save cropped images

dir1 = getDirectory("Choose source directory");
if (dir1=="")
      exit("No directory available");
  // Create a results directory in dir1

dir2 = dir1+"results"+File.separator;
  File.makeDirectory(dir2);
  if (!File.exists(dir2))
      exit("Unable to create directory");

name = "survey";
id = getImageID();	  
rename(name);
selectWindow(name);

batchfunction(name);


}


function batchfunction(name){

serial=1;
print("Mark Crop Areas \n close all windows when done \n remember to save your ROIManager");
check=1;
while(check==1){
	coords = newArray(2);
	getLocation(name, coords);
	cropAndSave(name,100,100,coords,serial);

//	check = getBoolean("more AVGs here?");
	serial++;
	}
	selectWindow("Log");
	run("Close");
}



function getLocation(name, coords){

	setTool("point");
    leftButton=16;
    x2=-1; y2=-1; z2=-1; flags2=-1;
    done=0;
	selectWindow(name);
    if (getVersion>="1.37r")
        setOption("DisablePopupMenu", true);

	//continue until leftButton is clicked
    while (done==0) {
        getCursorLoc(x, y, z, flags);

		//capture location on left click	
		if(flags==16){
			coords[0] = x;
			coords[1] = y;
			done=1;
			}
		}
}

function cropAndSave(name, roiWidth, roiHeight, coords, serial){
	selectWindow(name);
	getDimensions(imageWidth, imageHeight, channels, slices, frames);  

	if(coords[0]-(roiWidth/2)<0){left=0;}
		else if(coords[0]+(roiWidth/2)>imageWidth){left=imageWidth-roiWidth;}
		else{left=coords[0]-(roiWidth/2);}
		
	if(coords[1]-(roiHeight/2)<0){top=0;}
		else if(coords[1]+(roiHeight/2)>imageHeight){top=imageHeight-roiHeight;}
		else{top=coords[1]-(roiHeight/2);}				
		
		run("Specify...", "width="+roiWidth+" height="+roiHeight+" x="+left+" y="+top);//might need to specify slice

		//duplicate, this will extract the ROI 
		run("Duplicate...", "title=dup duplicate");

		//append the new file with crop number
		newname = name;
		newname = replace(newname,"survey","cell#"+serial+".tif");
		rename(newname);
		saveAs("Tiff", dir2+newname);
		close();
		
		selectWindow(name);
		roiManager("Add");





}
