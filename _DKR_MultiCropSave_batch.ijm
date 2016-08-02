//20110428 ciclistadan
//  goes through a folder of images and allows you to specify ROIs, 
//  from which it makes duplicates and saves each
//  originally used for AVG examples but can be used for any ROI
//  later you can go through these saves crops and get stats from them
dir1="";
dir2="";
macro "go"{

//clean up the environment
{
if(nImages>0) exit ("close all images before proceeding");

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


filter_choices = newArray('tif', 'zvi', 'dv', 'D3D.dv', 'R3D.dv', 'NO');
filter = "tif";
setBatchMode(false);

//get a list of all files in the source directory and filter out the ones you want
{
dir1 = getDirectory("Choose source directory");
if (dir1=="")
      exit("No directory available");

// Create a results directory within dir1 if it doesn't already exist
resultsfolder = "cropped";
dir2 = dir1+resultsfolder+File.separator;
if(!File.exists(dir2)) File.makeDirectory(dir2);

//ensure it was able to create dir2
if(!File.exists(dir2))
      exit("Unable to create directory");
	  
//get a list of all the files in this folder 
	preList = getFileList(dir1);
	size=0;
	
	//count each '*filter*' files
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
	
}

//starting with the first image, we increment through each image
  for(i=0; i<list.length; i++) {
	//open a two color image in separate channel stacks

	//import if necessary, else just open
	if(filter == 'dv' || filter == 'D3D.dv' || filter ==  'R3D.dv' || filter == 'zvi'){
		run("Bio-Formats Importer", "open="+dir1+list[i]+" view=Hyperstack stack_order=XYCZT");

		}
	else{
		open(dir1+list[i]);
		}
	selectWindow(list[i]);
	
	//all specific tasks are done in the batchfunction
	batchfunction(list[i]);
	
	//close the window after dialog box is closed
	if(isOpen(list[i])){ close(); }
}


function batchfunction(name){

autoScaleBrightestSlice();
serial=1;
print("Mark Crop Areas");
check=1;
while(check==1){
	coords = newArray(2);
	getLocation(name, coords);
	cropAndSave(name,100,100,coords,serial);
	check = getBoolean("more AVGs here?");
	serial++;
	}
	selectWindow("Log");
	run("Close");
}


function autoScaleBrightestSlice(){

//get the image dimensions
getDimensions(width, height, channels, slices, frames);
c=channels;
favorite = 2; //choose the channel you want to autofocus on (first channel = 1)
displaymode = "0111"; //bool for each channel, "0111" means do not display first channel

//define which colors you want to use on each channel
if(channels>1){
lookuptable = newArray(4);
lookuptable[0] = "Red";
lookuptable[1] = "Green";
lookuptable[2] = "Green";
lookuptable[3] = "Red";
}
else {
lookuptable = newArray(1);
lookuptable[0] = "Grays";
}


//search each channel for the max slice containing the max intensity pixel
for(c;c>0;c--){
	Stack.setChannel(c);
	run(lookuptable[c-1]);

	//reset max counters for each channel
	slicemax=0;
	channelmax = 0;
		
	//get max value of each slice, remember it if it is the largest you have seen for this channel
	for(z=1;z<=slices;z++){
		Stack.setSlice(z);
		getStatistics(area, mean, min, max, std, histogram);
			
			if(max > channelmax){
				channelmax = max;
				slicemax = z;
				}
		}
	if(c == favorite) {
		bestslice = slicemax;
		}

	//move to the brightest intensity slice on this channel and use auto contrast
	Stack.setSlice(slicemax);
	resetMinAndMax();
	run("Enhance Contrast", "saturated=0.5");
}
	//now that you're done, set it to the best place EVER!
if(channels>1){
	Stack.setChannel(favorite);
	Stack.setSlice(bestslice);
	Stack.setActiveChannels(displaymode);
	}
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
		newname = replace(newname,".tif","-crop"+serial+".tif");
		rename(newname);
		saveAs("Tiff", dir2+newname);
		close();
		
		selectWindow(name);
run("Specify...", "width=0 height=0 x=0 y=0");//deselect ROI





}
