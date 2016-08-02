// created by ciclistadan 20111110
//used to quickly open each movie in a filtered directory and measure the min-max from a predefined roi 
//this macro uses previously defined ROIs from _DKR_FRAP_ROI.ijm to find the min/max values of the I_FRAP region 

macro "go"{

if(nImages>0) exit ("close all images before proceeding");

	if(isOpen("Results")){
		selectWindow("Results");
		run("Close");
		}
	if(isOpen("Log")){
		selectWindow("Log");
		run("Close");
		}

//vars
batch = false;
setBatchMode(batch);
run("Set Measurements...", "  min redirect=None decimal=2");

/**********************************************************/
//create dialog box

Dialog.create("Configure");
Dialog.addString("Filter",".lsm");
Dialog.show();
filter=Dialog.getString();
/**********************************************************/

//select directories and filter image list
{
dir1 = getDirectory("Choose source directory");
if (dir1=="")
      exit("No directory available");

//get a list of all the files in this folder 	  
if(filter == ""){
	list = getFileList(dir1);
	}
else{
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
}

//open each image
for(i=0; i<list.length; i++){
	//open a two color image in separate channel stacks
	if(filter != ''){
		run("Bio-Formats Importer", "open="+dir1+list[i]+" view=Hyperstack stack_order=XYCZT");
		}
	else{
		open(dir1+list[i]);
		}
	
	//make the measurements
	selectWindow(list[i]);
	title = File.name;
	run("Grays");
	getDimensions(width, height, channels, slices, frames);

	//break apart multichannel images before measurements, this macro assumes you want the first channel	
	if(channels > 1){
		run("Split Channels");
		selectWindow("C1-"+title);
		rename(title);
		}
	
	//open the corresponding ROI list if one exists, skip measurements if it does not
	if(File.exists(dir1+title+"-roiset.zip")){	
		
		open(dir1+title+"-roiset.zip");
		selectWindow(title);
		roiManager("Select", 0);
		roiManager("Multi Measure");
		saveAs("Results", dir1+title+"-minmax.xls");
		}
	//close the results window if there is one	
	if(nResults > 0){
		selectWindow("Results");
		run("Close");	
		}
		
	//close all the remaining images and clear the roi manager
	while (nImages >0) close();
	roiManager("Reset");
	}
}


	

	