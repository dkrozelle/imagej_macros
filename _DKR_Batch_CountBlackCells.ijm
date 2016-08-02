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
Dialog.addNumber("Min Cell Size",400);
Dialog.addNumber("Max Cell Size",1500);
Dialog.addCheckbox("Auto Threshold ?",false);
Dialog.addNumber("Manual Threshold",175);
Dialog.show();

/**********************************************************/

//gather inputs
filter        = Dialog.getString();
min_cell_size = Dialog.getNumber();
max_cell_size = Dialog.getNumber();
autothreshold = Dialog.getCheckbox();
manualthreshold = Dialog.getNumber();

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
	basename = replace(name,".tif","");

	//insert batch functions here
	selectWindow(name);
	run("Duplicate...", "title=copy");
	selectWindow("copy");
	run("8-bit");

	if(autothreshold){
		run("Threshold...");
		waitForUser("Verify Threshold, Apply, and Click OK to Proceed");
	}
	else{
		setOption("BlackBackground", false);
		setAutoThreshold("Default");
		setThreshold(0, manualthreshold);
		run("Convert to Mask");
	}
	run("Fill Holes");
	run("Watershed");
	roiManager("Reset");
	run("Analyze Particles...", "size="+min_cell_size+"-"+max_cell_size+" circularity=0.00-1.00 show=Nothing clear add");
	roiManager("Show All with labels");
	roiManager("Show All");
	roiManager("Deselect");
	roiManager("Save", dir2+File.separator+basename+".zip");

	if(isOpen("Results")){
		selectWindow("Results");
		run("Close");
	}

	selectWindow(name);
	run("Invert");
	
	 rois = roiManager("count");
  	for (j=0; j<rois; j++) {
      roiManager("select", j);
      getStatistics(area, mean, min, max);
      setResult("Area",  j, area);
      setResult("Mean", j, mean);
      setResult("Min", j, min);
      setResult("Max", j, max);
 	}


	//roiManager("Multi Measure");
	saveAs("Results", dir2+File.separator+basename+".xls");
	//close results ?

	roiManager("Reset");
	while (nImages >0) close();
}

print('done');
}


