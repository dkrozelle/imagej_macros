// created by Dan Rozelle 20110324
//used to create a similarly scaled montage for each image in a file
//this will only work with flat composite images (multi channel, single slice)


macro "go [q]"{
setBatchMode(false);
if(nImages>0) exit ("close all images before proceeding");

	if(isOpen("Results")){
		selectWindow("Results");
		run("Close");
		}
	if(isOpen("Log")){
		selectWindow("Log");
		run("Close");
		}

//list auto functions here, adjust mode as necessary
function batchfunction();

/**********************************************************/
Dialog.create("Select Options");
 	Dialog.addString("Filter","tif");
	Dialog.addString("Channel 1", "Red");
	Dialog.addNumber("Min", 450);
	Dialog.addNumber("Max", 3300);
	Dialog.addString("Channel 2", "Blue");
	Dialog.addNumber("Min", 610);
	Dialog.addNumber("Max", 2100);
	Dialog.addString("Channel 3", "Green");
	Dialog.addNumber("Min", 225);
	Dialog.addNumber("Max", 2600);
	Dialog.addString("Channel 4", "empty");
	Dialog.addNumber("Min", 853);
	Dialog.addNumber("Max", 1308);
	Dialog.addMessage("specify 'empty' for fewer channels, use -1 for channels that you want autoscaled");
	Dialog.show();
	
filter=Dialog.getString();

//make 3 arrays for the color and settings of each channel 
color = newArray("empty","empty","empty","empty");	
min   = Array.copy(color);
max   = Array.copy(color);

//loop through the input dialog and capture their values
	for(i=0;i<4;i++){
		color[i]=Dialog.getString();
		min[i]  = Dialog.getNumber();
		max[i]  = Dialog.getNumber();
		}

/**********************************************************/


//find the source images
dir1 = getDirectory("Choose source directory");
if (dir1=="")
      exit("No directory available");
parent = File.getParent(dir1);
	  
// Create an output directory within dir1
  dir2 = dir1+File.separator+"montages"+File.separator;
  File.makeDirectory(dir2);
  if (!File.exists(dir2))
      exit("Unable to create directory");	  
	  
// print("dir1 = "+dir1);
// print("parent = "+parent);
// print("dir2 = "+dir2);
	  
//filter files necessary	  
if(filter == ""){
	list = getFileList(dir1);
	}
else{
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
	
//starting with the first image, we increment through each image, performing the batch function
  for(i=0; i<list.length; i++){
  showProgress(i+1/list.length);
	//this will not work if this is still a stack, however a single plane SNAP will work fine	
	if(filter != 'tif'){
		run("Bio-Formats Importer", "open="+dir1+list[i]+" view=Hyperstack stack_order=XYCZT");
		}
	else{
		open(dir1+list[i]);
		}
	selectWindow(list[i]);
	
	//perform the batch function
	batchfunction(list[i]);
	
	//close the window after returning from function
	selectWindow(list[i]);
	close();
	
	}


}



function batchfunction(name){

selectWindow(name);

for(j=0;j<4;j++){
Stack.setChannel(j+1);
	if(color[j] != "empty"){
		
		run(color[j]);
		if(min[j] != -1){
			setMinAndMax(min[j], max[j]);
			call("ij.ImagePlus.setDefault16bitRange", 0);
			}
		else{
			run("Enhance Contrast", "saturated=0.35");
			}
		}
	}

selectWindow(name);
getDimensions(width, height, channels, slices, frames);
run("Make Montage...", "columns="+channels+" rows=1 scale=1 first=1 last="+channels+" increment=1 border=0 font=12");
selectWindow("Montage");
saveAs("Tiff", dir2+name);
close();

}


