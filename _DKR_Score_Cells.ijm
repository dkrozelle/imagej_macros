//20120809 ciclistadan
// adapter from _DKR_Batch_categorize 
// updates: scales exposure for each images, keep ordered columns and cell names in results table
//used to quickly open each image, select applicable categories, write results to table and close



macro "go"{

//vars
function preptable();
function batchfunction();
function scale();

mode = "CHECKBOX"; //alternative mode "MANUAL"
filter = "tif";
choices = newArray(
	"SG",
	"AVG",
	"Small Viral Factory",
	"Large Viral Factory",
	"small VACV Particles",
	"Apoptotic",
	"Binucleate",
	"Mitotic",
	"abnormal",
	"Niice",
	"further inspection needed"
	);

//prep environment
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
		
preptable();
}

//get exposure scaling values
{
/**********************************************************/
Dialog.create("Select Options");
 	Dialog.addString("Filter","tif");
	Dialog.addString("Channel 1", "Blue");
	Dialog.addNumber("Min", 450);
	Dialog.addNumber("Max", 2200);
	Dialog.addString("Channel 2", "Green");
	Dialog.addNumber("Min", 400);
	Dialog.addNumber("Max", 1450);
	Dialog.addString("Channel 3", "Red");
	Dialog.addNumber("Min", 400);
	Dialog.addNumber("Max", 1200);
	Dialog.addString("Channel 4", "empty");
	Dialog.addNumber("Min", -1);
	Dialog.addNumber("Max", -1);
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
}

//Directory info, filter and sort files
{
dir1 = getDirectory("Choose source directory");
if (dir1=="")
      exit("No directory available");

if(filter == "NO"){
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
	midList=newArray(size);
	position=0;
	for(place=0;place<preList.length;place++){
		if(endsWith(preList[place],filter)){
			midList[position]=preList[place];
			position++;
		}
	}

	//sort the list, this onl works if the numbers are zero padded
	//list = Array.sort(midList);
	list = midList;
	}
}


Dialog.create("Movie Identifiers");
	Dialog.addMessage(dir1);
 	Dialog.addMessage(list[0]);

 	Dialog.addString("Experiment#","000");
 	 	
	Dialog.show();
	
	expname= Dialog.getString();
	
//open each image, sacle it, and perform the batch function
for(i=0; i<list.length; i++) {
	//open a two color image in separate channel stacks

	
	if(filter == 'dv' || filter == 'D3D.dv' || filter ==  'R3D.dv'){
		run("Bio-Formats Importer", "open="+dir1+list[i]+" view=Hyperstack stack_order=XYCZT");
		}
	else{
		open(dir1+list[i]);
		}
	selectWindow(list[i]);
	run("Set... ", "zoom=200");	
	setLocation(100,100);
	
	//perform the exposure and scale exposure function
	selectWindow(list[i]);
	scale(list[i]);
	batchfunction(list[i]);

	//close the window after dialog box is closed
	selectWindow(list[i]);
	close();
	}
}

function preptable()
{

setResult("Label",nResults,"blank line");
setResult("Exp",nResults-1,0);

for(j=0 ; j<choices.length ; j++){
	setResult(choices[j],nResults-1,0);}
	}	

updateResults();

}

function batchfunction(name)
{

setResult("Label",nResults,name);
setResult("Exp",nResults-1,expname);
	
Dialog.create("Select Categories");

for(i=0 ; i<choices.length ; i++){
	Dialog.addCheckbox(choices[i],false);
	}
	Dialog.show();

for(j=0 ; j<choices.length ; j++){
	foo = Dialog.getCheckbox();
		if(foo){setResult(choices[j],nResults-1,1);}
	}	
	
	updateResults();

}


function scale(name){
selectWindow(name);

//repeat loop for each channel j
getDimensions(width, height, channels, slices, frames);
stop = channels;

for(j=0;j<stop;j++){
setSlice(j+1);
	if(color[j] != "empty"){
		run(color[j]);
		//print(j+" = "+color[j]+",min="+min[j]+", max="+max[j]);
		if(min[j] != -1){
			setMinAndMax(min[j], max[j]);
			call("ij.ImagePlus.setDefault16bitRange", 16);
			
			}
		else{
			run("Enhance Contrast", "saturated=0.35");
			}
		}
	}
}