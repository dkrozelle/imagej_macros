//20110711 ciclistadan
//quick way to crop and save an image

macro "go"{
getSelectionBounds(x, y, width, height);

//find the source images
dir1 = getDirectory("home") 
	  
// Create an output directory within dir1
dir2 = dir1+File.separator+"Desktop"+File.separator+"crop";

if (File.exists(dir2)){}
else{
	File.makeDirectory(dir2);
	if (!File.exists(dir2))
      exit("Unable to create directory");
	 }


//get the name of the active window
name = getTitle();
getDimensions(width, height, channels, slices, frames);

//make a copy of the cropped region
run("Duplicate...", "title="+name+" duplicate channels=1-"+channels+" slices=1-"+slices);

//figure out how many other crops you've already saved
serial=1;
do{
		newname = replace(name,".tif","_crop"+serial+".tif");
		serial++;
		} while(File.exists(dir2+File.separator+newname));

saveAs("Tiff", dir2+File.separator+newname);
close();


}