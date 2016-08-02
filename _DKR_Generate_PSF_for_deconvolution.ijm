//
//macro created by CiclistaDan 20140404
// used to manually generate a theoretocal PSF image using known image capture parameters.
// This is necessary for most deconvolution plugins

// I have built this step into the parallel iteaative macro

macro "go"{

//name of the lens, the pixel size created by this lense, and the refractive index of the medium it uses (i.e. oil vs. H2O)
lenses     = newArray("100X-oil", "63X-oil", "40X-air", "20X-air", "10X-air", "2.5X-air" );
pixellist  = newArray("0.0625",   "0.0990",  "0.1572",  "0.3121",  "0.6258",  "2.396"    );
nalist     = newArray("0.4",      "1.3",     "0.6",     "0.75",     "0.30",     "0.075"    ); // <---need to fix 100X NA
refractlist  = newArray("1.515",    "1.4",   "1.000",   "1.000",   "1.000",   "1.000"    );

//heres a good table http://www.olympusmicro.com/primer/techniques/fluorescence/fluorotable2.html
//these need to be in the same units as pixel size (e.g. we typically use um )
channellist = newArray("no_decon", "DAPI",  "FITC",  "TRITC",  "FarRed", "empty");
wavelist    = newArray("0",        "0.470", "0.525", "0.576",  "0.647"  , "0");

/**********************************************************/
//create dialog box

Dialog.create("Configure");

Dialog.addChoice("Lens",lenses,lenses[1]);
Dialog.addChoice("C1",channellist,channellist[1]);
Dialog.addChoice("C2",channellist,channellist[2]);
Dialog.addChoice("C3",channellist,channellist[3]);
Dialog.addChoice("C4",channellist,channellist[5]);
Dialog.addNumber("dz",0.500);
Dialog.addNumber("slices",12);
Dialog.addNumber("PSF Size",256);

	Dialog.show();

/**********************************************************/
//gather inputs


lens  = Dialog.getChoice();
dz    = Dialog.getNumber();
slices= Dialog.getNumber();
psfSize= Dialog.getNumber();
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


//lookup wavelengths using channelname list
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

for(i=0; i<channelname.length; i++){
	run("Diffraction PSF 3D", "index="+refractive+" numerical="+na+" wavelength="+wave[i]+" longitudinal=0 image="+dx+" slice="+dz+" width,="+psfSize +" height,="+psfSize +" depth,="+slices+" normalization=[Sum of pixel values = 1] title="+channelname[i]);

}
}
