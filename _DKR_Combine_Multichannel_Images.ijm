// created by Dan Rozelle 20091110
//used to quickly open each  movie, select the category, write results to table and close



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
setBatchMode(true);
//run("Monitor Memory...");

/**********************************************************/
//create dialog box

Dialog.create("Configure");
Dialog.addString("Filter","TIF");
Dialog.addNumber("# Channels",3);

Dialog.show();

/**********************************************************/

//gather inputs
filter=Dialog.getString();
channels = Dialog.getNumber();


/**********************************************************/
//select directories and filter image list
dir1 = getDirectory("Choose source directory");
if (dir1=="")
	exit("No directory available");
parent = File.getParent(dir1);

dir2 = parent+File.separator+"output"+File.separator;
File.makeDirectory(dir2);
if (!File.exists(dir2))
	exit("Unable to create directory");	

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
/**********************************************************/
//Increment through each set of images
for(i=0; i<list.length; i=i+channels) {
	//open a two color image in separate channel stacks

		open(dir1+list[i]);
		open(dir1+list[i+1]);
		open(dir1+list[i+2]);
	
	//insert batch function here
	run("Merge Channels...", "c1=["+list[i]+"] c2=["+list[i+1]+"] c3=["+list[i+2]+"] create");

	selectWindow("Composite");
	setSlice(1);
	run("Blue");
	run("Enhance Contrast", "saturated=0.35");

	setSlice(2);
	run("Green");
	run("Enhance Contrast", "saturated=0.35");

	setSlice(3);
	run("Red");
	run("Enhance Contrast", "saturated=0.35");

	saveAs("Tiff", dir2+list[i]);
	//close the window after dialog box is closed
	close();
}

print('done');
}


