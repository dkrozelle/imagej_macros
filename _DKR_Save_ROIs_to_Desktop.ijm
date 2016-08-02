//_DKR_Save_ROIs_to_Desktop.ijm

macro "go"{

dir1 = getDirectory("home");

dir2 = dir1+File.separator+"Desktop"+File.separator+"ROIs"+File.separator;
File.makeDirectory(dir2);
if (!File.exists(dir2))
	exit("Unable to create directory");	

	name=getTitle;
	name = replace(name,"C3-","");
	name = replace(name,"tif","zip");
	roiManager("Deselect");
	roiManager("Save",dir2+name);
	roiManager("Reset");
}