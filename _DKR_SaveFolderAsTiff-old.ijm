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

//list auto functions here, adjust mode as necessary
function batchfunction();
mode           = newArray("AUTOFUNCTION", "MANUAL", "BOTH");
filter_choices = newArray('lsm', 'zvi', 'tif', 'NO', 'dv', 'D3D.dv', 'R3D.dv');
setBatchMode(true);
/**********************************************************/

Dialog.create("Select Options");
 	Dialog.addChoice("Method",mode,"AUTOFUNCTION");
 	Dialog.addChoice("Filter",filter_choices,".zvi");
	
	Dialog.show();

	mode=Dialog.getChoice();
	filter=Dialog.getChoice();
	
/**********************************************************/




dir1 = getDirectory("Choose source directory");
if (dir1=="")
      exit("No directory available");

dir2 = getDirectory("Choose output directory");
// Create an output directory within dir2
  dir2 = dir2+File.separator+"Images"+File.separator;
  File.makeDirectory(dir2);
  if (!File.exists(dir2))
      exit("Unable to create directory");		  
	  
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
	list=newArray(size);
	position=0;
	for(place=0;place<preList.length;place++){
		if(endsWith(preList[place],filter)){
			list[position]=preList[place];
			position++;
			}
		}
	}
	

//starting with the first image, we increment through each image until we have done 6, or finish our list, whichever comes first
  for(i=0; i<list.length; i++) {
	//open a two color image in separate channel stacks

	
	if(filter == 'lsm' || filter == 'dv' || filter == 'D3D.dv' || filter ==  'R3D.dv' || filter == 'zvi'){
		run("Bio-Formats Importer", "open="+dir1+list[i]+" view=Hyperstack stack_order=XYCZT");

		}
	else{
		open(dir1+list[i]);
		}
	selectWindow(list[i]);
	
		
	if(mode == "MANUAL"){
		wait(100);
		run("Install...", "install=C:\\ImageJ\\macros\\_DKR_AutoScaleBrightestSlice.txt");
		waitForUser("click OK \nto proceed"); 
		}
	
	else if(mode == "AUTOFUNCTION"){
		//selectWindow(list[i]);
		batchfunction(list[i]);
		
		}

	
	
	//close the window after dialog box is closed
	close();
	}
	print(list.length+" Images Converted");
}


function batchfunction(name)
{
	//selectWindow(name);
	run("16-bit");
	saveAs("Tiff", dir2+name);

}


