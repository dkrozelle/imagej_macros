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
batch = false;
setBatchMode(batch);
run("Monitor Memory...");

function deconvolve();
filter_choices = newArray('zvi', 'tif', 'NO', 'dv', 'D3D.dv', 'R3D.dv');

//name of the lens, the pixel size created by this lense, and the refractive index of the medium it uses (i.e. oil vs. H2O)
lenses     = newArray("100X-oil", "63X-oil", "40X-air", "20X-air", "10X-air", "2.5X-air" );
pixellist  = newArray("0.0625",   "0.0990",  "0.1572",  "0.3121",  "0.6258",  "2.396"    );
nalist     = newArray("0.4",      "0.4",     "0.4",     "0.4",     "0.4",     "0.4"    ); // <---need to fix these
refractlist  = newArray("1.515",    "1.515",   "1.000",   "1.000",   "1.000",   "1.000"    );

//heres a good table http://www.olympusmicro.com/primer/techniques/fluorescence/fluorotable2.html
//these need to be in the same units as pixel size (e.g. we typically use um )
channellist = newArray("none", "DAPI",  "FITC",  "TRITC",  "DeepRed");
wavelist    = newArray("0",    "0.470", "0.525", "0.576",  "0.647"  );

/**********************************************************/
//create dialog box

Dialog.create("Configure");
Dialog.addChoice("Filter",filter_choices,".zvi");
Dialog.addChoice("Lens",lenses,lenses[1]);
Dialog.addChoice("C1",channellist,channellist[1]);
Dialog.addChoice("C2",channellist,channellist[2]);
Dialog.addChoice("C3",channellist,channellist[3]);
Dialog.addChoice("C4",channellist,channellist[0]);
Dialog.addNumber("dz",0.350);


	Dialog.show();

/**********************************************************/
//gather inputs

filter=Dialog.getChoice();
lens  = Dialog.getChoice();
dz    = Dialog.getNumber();

//set the pixel size for this image
//from the lens we can get these variables
for (i=0; i<lenses.length; i++){
	if(lenses[i]==lens){
		refractive = refractlist[i]; 
		na         = nalist[i];
		dx         = pixellist[i];
		run("Set Scale...", "distance=1 known="+dx+" pixel=1 unit=micron");
		}
	}

//get a list of the channel names
channelname = newArray(4);
for(i=0; i<channelname.length; i++){
	channelname[i] = Dialog.getChoice();
	}

//get a list of channel wavelengths
wave     = newArray(4);
//look at each channel name
for(j=0; j<channelname.length; j++){
	//and sort through all possible wavelengths until you find the one that matches
	for(i=0; i<wavelist.length; i++){
		if(channellist[i] == channelname[j]){
			wave[j] = wavelist[i];
			}
		}
	}
/**********************************************************/

//select directories and filter image list
{
dir1 = getDirectory("Choose source directory");
if (dir1=="")
      exit("No directory available");
dir2 = getDirectory("Choose source directory");
if (dir2=="")
      exit("Directory not available");
	  	  
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
}

//starting with the first image, we increment through each image until we have done 6, or finish our list, whichever comes first
  for(i=0; i<list.length; i++) {
	//open a two color image in separate channel stacks

	
	if(filter == 'dv' || filter == 'D3D.dv' || filter ==  'R3D.dv' || filter == 'zvi'){
		run("Bio-Formats Importer", "open="+dir1+list[i]+" view=Hyperstack stack_order=XYCZT");

		}
	else{
		open(dir1+list[i]);
		}
	
	deconvolve(list[i]);
		
	}

	//close the window after dialog box is closed
	close();
	}
}


function deconvolve(name){
	//get the image dimensions
	selectWindow(name);
	Stack.getDimensions(width, height, channels, slices, frames);

	//generate PSFs, duplicate each channel, and decon
	for(i=0; i<channelname.length; i++){
			if(channelname[i] != "none"){
				run("Diffraction PSF 3D", "index="+refractive+" numerical="+na+" wavelength="+wave[i]+" longitudinal=0 image="+dx+" slice="+dz+" width,="+width+" height,="+height+" depth,="+slices+" normalization=[Sum of pixel values = 1] title="+channelname[i]+"_PSF");
				selectWindow(name);
				run("Duplicate...", "title="+channelname[i]+" duplicate channels="+i+1+" slices=1-"+slices);
			
				run("Iterative Deconvolve 3D", "image="+channelname[i]+" point="+channelname[i]+"_PSF output="+channelname[i]+"_d3d normalize show log perform detect wiener=0.000 low=0.1 z_direction=0.3 maximum=10 terminate=0.010"); 

				rename(channelname[i]+"_d3d");
				
				selectWindow(channelname[i]);
				close();
				selectWindow(channelname[i]+"_PSF");
				close();
				}
		}

		
		//put the channels back into a combined hyperstack, don't worry about the color names here, just keep the correct order...stupid plugin
		run("Merge Channels...", "red="+channelname[0]+"_d3d green="+channelname[1]+"_d3d blue="+channelname[2]+"_d3d gray=*None* create");
		selectWindow("Composite");
		saveAs("Tiff", dir2+File.separator+channelname[i]+"_d3d");
		
		//this closes individual channels if they are still open
		for(i=0; i<channelname.length; i++){
			if(channelname[i] != "none"){
				selectWindow(channelname[i]+"_d3d");
				close();
				}
		}
	}


