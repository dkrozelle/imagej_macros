//this macro uses previously defined ROIs from _DKR_FRAP_ROI.ijm to find the min/max values of the I_FRAP region 

macro "go"{

roiManager("Reset");
run("Set Measurements...", "  min redirect=None decimal=2");

run("Bio-Formats Importer", "view=Hyperstack stack_order=XYCZT merge_channels autoscale");

title = File.name;
dir1  = File.directory;
run("Grays");
getDimensions(width, height, channels, slices, frames);

if(channels > 1){
run("Split Channels");
selectWindow("C1-"+title);
rename(title);
}

open(dir1+title+"-roiset.zip");
selectWindow(title);
roiManager("Select", 0);


roiManager("Multi Measure");
saveAs("Results", dir1+title+"-minmax.xls");

selectWindow(title);
close();

while (nImages >0) close();
}
