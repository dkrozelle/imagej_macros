//this macro is used to quickly define the four ROIs and extract mean pixel intensities for further processing in R/MatLab

macro "go"{

roiManager("Reset");
run("Set Measurements...", "  mean redirect=None decimal=2");
setTool("polygon");

run("Bio-Formats Importer", "view=Hyperstack stack_order=XYCZT merge_channels autoscale");

title = File.name;
dir1  = File.directory;
run("Grays");
run("Specify...", "width=75 height=75 x=0 y=0 oval");
getDimensions(width, height, channels, slices, frames);

if(channels > 1){
run("Split Channels");
selectWindow("C1-"+title);
rename(title);

}

run("Specify...", "width=75 height=75 x=0 y=0 oval");
selectWindow(title);
waitForUser("define ROIS");
selectWindow(title);


roiManager("Select", 0);
roiManager("Rename", "I-frap");
roiManager("Select", 1);
roiManager("Rename", "I_ref");
roiManager("Select", 2);
roiManager("Rename", "I-base");
roiManager("Select", 3);
roiManager("Rename", "I_whole");
roiManager("Deselect");
selectWindow(title);
roiManager("Multi Measure");
roiManager("Deselect");
roiManager("Save", dir1+title+"-roiset.zip");
roiManager("Delete");
saveAs("Results", dir1+title+".xls");

selectWindow(title);
close();

}
