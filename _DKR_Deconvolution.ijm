


macro {

//vars
batch = false;
setBatchMode(batch);
run("Monitor Memory...");


//name of the lens, the pixel size created by this lense, and the refractive index of the medium it uses (i.e. oil vs. H2O)
lenses     = newArray("100X-oil", "63X-oil", "40X-air", "20X-air", "10X-air", "2.5X-air" );
pixellist  = newArray("0.0625",   "0.0990",  "0.1572",  "0.3121",  "0.6258",  "2.396"    );
nalist     = newArray("0.4",      "0.4",     "0.4",     "0.4",     "0.4",     "0.4"    ); // <---need to fix these
refractlist  = newArray("1.515",    "1.515",   "1.000",   "1.000",   "1.000",   "1.000"    );

//heres a good table http://www.olympusmicro.com/primer/techniques/fluorescence/fluorotable2.html
//these need to be in the same units as pixel size (e.g. we typically use um )
channellist = newArray("none", "DAPI",  "FITC",  "TRITC",  "DeepRed");
wavelist    = newArray("0",    "0.470", "0.525", "0.576",  "0.647"  );

Dialog.create("Configure");
Dialog.addChoice("Lens",lenses,lenses[1]);
Dialog.addChoice("C1",channellist,channellist[1]);
Dialog.addChoice("C2",channellist,channellist[2]);
Dialog.addChoice("C3",channellist,channellist[3]);
Dialog.addChoice("C4",channellist,channellist[0]);
Dialog.addNumber("dz",0.350);

Dialog.show();

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
		run("Merge Channels...", "red="+channelname[0]+"_d3d green="+channelname[1]+"_d3d blue="+channelname[2]+"_d3d gray=*None* create keep");

		for(i=0; i<channelname.length; i++){
			if(channelname[i] != "none"){
				selectWindow(channelname[i]+"_d3d");
				close();
				}
		}
	}
}