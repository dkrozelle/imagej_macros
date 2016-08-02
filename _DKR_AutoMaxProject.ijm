//20090703 ciclistadan
//quick way to max project 2um of an image
// updated, 20130716

macro "go [q]"{

dir1 = getDirectory("home")+"/Desktop";

// Create an output directory within dir1
dir2 = dir1+File.separator+"crop";

if (File.exists(dir2)){}
	else{
		File.makeDirectory(dir2);
		if (!File.exists(dir2))
			exit("Unable to create directory");
	}



//set the total um you want projected
depth=1.5;
//assume each slice is 500nm apart
slicedepth=depth/0.5;

Stack.getPosition(channel,slice,frame);
getDimensions(width, height, channels, slices, frames);

if(slice-1<=0) bottom=0;
else bottom = slice-1;

if(slice+1>=slices) top=slices;
else top = slice+1;

name = getTitle();
//duplicate, this will crop an ROI if present, otherwise do the whole image
run("Duplicate...", "title=dup duplicate");

run("Z Project...", "start="+bottom+" stop="+top+" projection=[Max Intensity]");

//append the new file with prj
newname = name;
newname = replace(newname,".tif","-prj.tif");
selectWindow("MAX_dup");
rename(newname);

saveAs("Tiff", dir2+File.separator+newname);
close();

selectWindow("dup");
close();


}