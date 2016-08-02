//
//macro created by CiclistaDan 20110726
//used to automate the Parallel Iterative Deconvolution for one filtered directory 
//  http://fiji.sc/Parallel_Iterative_Deconvolution
//using the WPL - Wiener Filter Preconditioned Landweber method
//
//Parallel Iterative Deconvolution is an ImageJ plugin for iterative image deblurring. 
//The code is derived from RestoreTools: An Object Oriented Matlab Package for Image Restoration written by James G. Nagy 
//and several of his students, including Julianne Chung, Katrina Palmer, Lisa Perrone, and Ryan Wright and also from 
//Iterative Deconvolve 3D written by Robert Dougherty.
//

macro "go"{

//vars
psfSize = 25;       //width/height of estimated PSF image
maxIters = "100";   //number of interations
nOfThreads = "16";  //number of parallel threads, use 2 for personal laptops, up to 16 for imaging core
//run("Monitor Memory...");
setBatchMode(true);

if(nImages>0) exit ("close all images before proceeding");
	if(isOpen("Results")){
		selectWindow("Results");
		run("Close");
		}
	if(isOpen("Log")){
		selectWindow("Log");
		run("Close");
		}


function deconvolve();
function PSF();
function getDateStamp();
function getTimeStamp();
filter_choices = newArray('zvi', 'tif', 'NO', 'dv', 'D3D.dv', 'R3D.dv');

//name of the lens, the pixel size created by this lense, and the refractive index of the medium it uses (i.e. oil vs. H2O)
lenses     = newArray("100X-oil", "63X-oil", "40X-air", "20X-air", "10X-air", "2.5X-air" );
pixellist  = newArray("0.0625",   "0.0990",  "0.1572",  "0.3121",  "0.6258",  "2.396"    );
nalist     = newArray("0.4",      "1.3",     "0.6",     "0.75",     "0.30",     "0.075"    ); // <---need to fix 100X NA
refractlist  = newArray("1.515",    "1.4",   "1.000",   "1.000",   "1.000",   "1.000"    );

//heres a good table http://www.olympusmicro.com/primer/techniques/fluorescence/fluorotable2.html
//these need to be in the same units as pixel size (e.g. we typically use um )
channellist = newArray("no_decon", "DAPI",  "FITC",  "TRITC",  "DeepRed", "empty");
wavelist    = newArray("0",        "0.470", "0.525", "0.576",  "0.647"  , "0");

/**********************************************************/
//create dialog box

Dialog.create("Configure");
Dialog.addChoice("Filter",filter_choices,".tif");
Dialog.addChoice("Lens",lenses,lenses[1]);
Dialog.addChoice("C1",channellist,channellist[1]);
Dialog.addChoice("C2",channellist,channellist[2]);
Dialog.addChoice("C3",channellist,channellist[3]);
Dialog.addChoice("C4",channellist,channellist[5]);
Dialog.addNumber("dz",0.300);


	Dialog.show();

/**********************************************************/
//gather inputs

filter=Dialog.getChoice();
lens  = Dialog.getChoice();
dz    = Dialog.getNumber();

//set the pixel size for this image
//from the lens we can get remaining variables
for (i=0; i<lenses.length; i++){
	if(lenses[i]==lens){
		refractive = refractlist[i]; 
		na         = nalist[i];
		dx         = pixellist[i];
		
		}
	}


	
//trim the array to remove empty channels
{ 
//populate a list of the channel names
prechannelname = newArray(4);
for(i=0; i<prechannelname.length; i++){
	prechannelname[i] = Dialog.getChoice();
	}

size=0;
	
//count each non-empty channels
for(place=0;place<prechannelname.length;place++){
	if(prechannelname[place] != "empty"){size++;}
	}
	
//create a new array and populate with filtered images
channelname = newArray(size);
position=0;
for(place=0;place<prechannelname.length;place++){
	if(prechannelname[place] != "empty"){
		channelname[position]=prechannelname[place];
		position++;
		}
	}
	
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
	  

PSFfolder = "PSF";
dir2 = dir1+PSFfolder+File.separator;
if(!File.exists(dir2)) File.makeDirectory(dir2);
	  
// Create a tmp directory within dir1 if it doesn't already exist
systemTempDir = getDirectory("temp");
tmpfolder = "dkr_decon_tmp";
tmp = systemTempDir+tmpfolder+File.separator;
if(!File.exists(tmp)) File.makeDirectory(tmp);

//filter the file list
{ 
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

//increment through each image in the filtered list
for(i=0; i<list.length; i++) {

  //use the LOCI importer if necessary	
	if(filter == 'dv' || filter == 'D3D.dv' || filter ==  'R3D.dv' || filter == 'zvi'){
		run("Bio-Formats Importer", "open="+dir1+list[i]+" view=Hyperstack stack_order=XYCZT");
		
		}
	else{
		open(dir1+list[i]);
		}
		
	//do the good stuff
	run("Set Scale...", "distance=1 known="+dx+" pixel=1 unit=micron");
	deconvolve(list[i]);

	}
	
time = getTimeStamp();
print("Deconvolution Finished at "+time);
print("My computation is done, feel free to restart computer or log-out as necessary");

}





function deconvolve(name){
	//get the image dimensions
	selectWindow(name);
	Stack.getDimensions(width, height, channels, slices, frames);
	
	if(endsWith(name,"tif") || endsWith(name,"zvi") ){
		noSuffix = substring(name,0,lengthOf(name)-4);
		}
	
	selectWindow(name);
	run("Split Channels");
	
	//save channels and decon
	for(i=0; i<channelname.length; i++){

			if(channelname[i] != "no_decon"){
				currentChannel = tmp+"C"+i+"-"+noSuffix;
				selectWindow("C"+i+1+"-"+name);			
				//save and close the duplicated channel since the decon needs to open the file itself
				saveAs("Tiff", currentChannel);		
				selectWindow("C"+i+"-"+noSuffix+".tif");	
				close();
				
				pathToBlurredImage = currentChannel+".tif";
				pathToPsf = PSF(channelname[i]);
				pathToDeblurredImage = tmp+"C"+i+"-"+noSuffix+"_d3d.tif";

				boundary = "REFLEXIVE"; //available options: REFLEXIVE, PERIODIC, ZERO
				resizing = "AUTO"; // available options: AUTO, MINIMAL, NEXT_POWER_OF_TWO
				output = "FLOAT"; // available options: SAME_AS_SOURCE, BYTE, SHORT, FLOAT  
				precision = "SINGLE"; //available options: SINGLE, DOUBLE
				threshold = "-1"; //if -1, then disabled
				//maxIters = "5"; //defined at top vars section
				//nOfThreads = "2";
				showIter = "true";
				gamma = "0";
				filterXY = "1.0";
				filterZ = "1.0";
				normalize = "false";
				logMean = "false";
				antiRing = "true";
				changeThreshPercent = "0.01";
				db = "false";
				detectDivergence = "true";

				call("edu.emory.mathcs.restoretools.iterative.ParallelIterativeDeconvolution3D.deconvolveWPL", pathToBlurredImage, pathToPsf, pathToDeblurredImage, boundary, resizing, output, precision, threshold, maxIters, nOfThreads, showIter, gamma, filterXY, filterZ, normalize, logMean, antiRing, changeThreshPercent, db, detectDivergence);
				selectWindow("C"+i+"-"+noSuffix+"_d3d.tif");
				close();
				}

			//even if you're not deconvolving the channel you need to resave it under a processed name
			else{
				currentChannel = tmp+"C"+i+"-"+noSuffix+"_d3d";
				selectWindow("C"+i+1+"-"+name);
		
				//save and close the duplicated channel since the decon needs to open the file itself
				saveAs("Tiff", currentChannel);	
				selectWindow("C"+i+"-"+noSuffix+"_d3d.tif");	
				close();
			}
		}

	//reopen the processed images
	for(i=0; i<channelname.length; i++){
		open(tmp+"C"+i+"-"+noSuffix+"_d3d.tif");
		rename("c"+i);
		}
	
	//put the channels back into a combined hyperstack, don't worry about the color names here, just keep the correct order...stupid plugin
	if(      channelname.length == 4){merge = "red=c0 green=c1     blue=c2     gray=c3     create";}
	else if( channelname.length == 3){merge = "red=c0 green=c1     blue=c2     gray=*None* create";}
	else if( channelname.length == 2){merge = "red=c0 green=c1     blue=*None* gray=*None* create";}
	else{                            merge = "red=c0 green=*None* blue=*None* gray=*None* create";}

	run("Merge Channels...", merge);

	run("Conversions...", " "); //this will leave the intensity values unchanged, otherwise it will always make the max=65535
	run("16-bit");
	saveAs("Tiff",dir1+noSuffix+"_d3d");
	close();
		
}

function PSF(psfName){
	location = dir1+"PSF"+File.separator+psfName+".tif";
	if(File.exists(dir1+psfName+".tif")){ return location;}
	else{



		run("Diffraction PSF 3D", "index="+refractive+" numerical="+na+" wavelength="+wave[i]+" longitudinal=0 image="+dx+" slice="+dz+" width,="+psfSize +" height,="+psfSize +" depth,="+slices+" normalization=[Sum of pixel values = 1] title="+psfName);
		saveAs("Tiff",location);		
		close();
		return location;
		}
	
}
	
	
function getDateStamp(){
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	
	year = toString(year);
	if(lengthOf(toString(month)) == 1){month = "0"+toString(month);}
		else{month = toString(month);}
	if(lengthOf(toString(dayOfMonth)) == 1){dayOfMonth = "0"+toString(dayOfMonth);}
		else{dayOfMonth = toString(dayOfMonth);}
	
	dateStamp = year+month+dayOfMonth;
	
	return dateStamp;
	}
function getTimeStamp(){
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	
	if(lengthOf(toString(hour)) == 1){hour = "0"+toString(hour);}
		else{hour = toString(hour);}
	if(lengthOf(toString(minute)) == 1){minute = "0"+toString(minute);}
		else{minute = toString(minute);}
	if(lengthOf(toString(second)) == 1){second = "0"+toString(second);}
		else{second = toString(second);}
	
	timeStamp = hour+":"+minute+":"+second;
	return timeStamp;
	}
