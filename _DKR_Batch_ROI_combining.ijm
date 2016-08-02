//created by Dan Rozelle 20140110
//requires several folders:
//		



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
Dialog.addMessage("Select the folder Cropped Cells")
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

AVG_ROIs_folder = parent+File.separator+"5-AVG_ROIs"+File.separator;
single_cell_ROIs_folder = parent+File.separator+"4-single_cell_ROIs"+File.separator;

dir2 = parent+File.separator+"6-combined_ROIs"+File.separator;
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
	basename = replace(name,".tif","");

	//combine all individual AVG ROIs into a single one
	roiManager("Open", AVG_ROIs_folder+basename+".zip");
	roiManager("Deselect");
	roiManager("Combine");
	roiManager("Deselect");
	roiManager("Delete");
	roiManager("Add");
	roiManager("Select", 0);
	roiManager("Rename", "all AVGs");

	//create a new ROI from the non-AVG cytoplasm
	roiManager("Open", single_cell_ROIs_folder+basename+".zip");
	roiManager("Select", 1);
	roiManager("Rename", "cytoplasm");
	roiManager("Select", newArray(0,1));
	roiManager("XOR");
	roiManager("Deselect");
	roiManager("Add");
	roiManager("Select", 2);
	roiManager("Rename", "non_AVG_cytoplasm");

	//save the new combined ROIs
	roiManager("Deselect");
	roiManager("Save", dir2+basename+".zip");

	//measure all channels for each ROI 
	run("Set Measurements...", "area mean standard min shape integrated display redirect=None decimal=3");
	roiManager("Multi Measure append");
	
	

	//close remaining windows and reset ROIManager
	roiManager("Reset");
	while (nImages >0) close();
}

print('done');
}


