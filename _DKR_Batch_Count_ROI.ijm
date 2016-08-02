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
setBatchMode(false);
//run("Monitor Memory...");

/**********************************************************/
//create dialog box

Dialog.create("Configure");
Dialog.addString("Filter","tif");

Dialog.show();

/**********************************************************/

//gather inputs
filter=Dialog.getString();


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
//Increment through each image
for(i=0; i<list.length; i++) {
	//open a two color image in separate channel stacks

	if(filter != 'tif'){
		run("Bio-Formats Importer", "open="+dir1+list[i]+" view=Hyperstack stack_order=XYCZT");
	}
	else{
		open(dir1+list[i]);
	}
	name = list[i];
	print(name);
	//insert batch functions here
	selectWindow(name);
	run("Clear Outside");
	run("Split Channels");
	//if the channel you want to threshold is not the last channel you'll need to selectWindow("C1-"+name) here
	run("Threshold...");
	waitForUser("Verify Threshold and Click OK to Proceed");
	run("Analyze Particles...", "size=0-Infinity circularity=0.00-1.00 show=Nothing clear add");

	// renumber the ROIs
	filename = "_DKR_renumber_ROI.ijm";
	path = getDirectory("macros");
	run("Install...", "install="+path+filename);
	run("go");

	//save the ROI set to dir2 (this is also a separate macro "_DKR_Save_ROIs_to_Desktop.ijm")
	name = replace(name,"C3-","");
	name = replace(name,"tif","zip");
	roiManager("Deselect");
	roiManager("Save",dir2+name);
	roiManager("Reset");

	//close remaining windows
	while (nImages >0) close();
}

print('done');
}


