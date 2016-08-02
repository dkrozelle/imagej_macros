// created by Dan Rozelle 20091110
//used to quickly convert a folder of images in a microscope-specific format which requires import to the native Tiff format


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

/**********************************************************/

Dialog.create("Select Options");
 	Dialog.addString("Filter(suffix)","zvi");
	Dialog.addCheckbox("Project Stack", false)
	Dialog.show();

	filter=Dialog.getString();
	project=Dialog.getCheckbox();

/**********************************************************/

dir1 = getDirectory("Choose source directory");
if (dir1=="")
      exit("No directory available");

dir2 = getDirectory("Choose output directory");
if (dir2=="")
      exit("No directory available");

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

//process each image in the filtered list
for(i=0; i<list.length; i++) {

	if(filter == 'lsm' || filter == 'dv' || filter == 'D3D.dv' || filter ==  'R3D.dv' || filter == 'zvi'){
		run("Bio-Formats Importer", "open="+dir1+list[i]+" view=Hyperstack stack_order=XYCZT");
	}
	else{
		open(dir1+list[i]);
	}

	//insert additional functions here if desired

	if(project){
		selectWindow(list[i]);
		getDimensions(imageWidth, imageHeight, channels, slices, frames);
		run("Z Project...", "start=1 stop="+channels+" projection=[Max Intensity]");
		saveAs("Tiff", dir2+list[i]);
		close();
	}

	else{
		selectWindow(list[i]);
		saveAs("Tiff", dir2+list[i]);
		close();
	}
	while (nImages >0) close();
}

print(list.length+" Images Converted");

}


