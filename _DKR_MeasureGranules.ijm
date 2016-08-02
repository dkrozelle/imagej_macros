//ciclistadan 20110517 adapted from spindle measurer
//opens images from dir, create mask for measuring stress granules, checkbox categorize, writes measurements to a results table
//
//buglist
//need to verify windows opening before relying on their existance, give a chance to recover
//possibly define starting cell?
macro "go"{

batch = false;
setBatchMode(batch);
//prep the environment and create some results logs
{
//define some variables
granule=1;

if(nImages>0) exit ("close all images before proceeding");

run("Clear Results");

//make some custom results window
	title1 = "WholeCellResults";
	title2 = "["+title1+"]";
	f = title2;
	if (isOpen(title1)){
		print(f, "\\Update:"); // clears the window
		}
	else{
		run("Text Window...", "name="+title2+" width=72 height=8 menu");
		}
	print(f, "exp,well,cell,ch1_mean,ch1_max,ch1_min,ch1_dif1,ch2_mean,ch2_max,ch2_min,ch2_dif1,ch3_mean,ch3_max,ch3_min,ch3_dif1,factories");

		
	title3 = "IndividualGranuleResults";
	title4 = "["+title3+"]";
	g = title4;
	if (isOpen(title3)){
		print(g, "\\Update:"); // clears the window
		}
	else{
		run("Text Window...", "name="+title4+" width=72 height=8 menu");
		}
	print(g,"experiment,well,cell,granule,mean,max,min");
}

//Dialog to get experiment details
{
experiment  = "0022";
well = "0001";

//define channels
DAPI = 1;
GFP = 2;
TRITC = 3;
}

//Dialog to get the source image and ROI
{
completefilename = File.openDialog("Please select the source image");
dir1 = File.getParent(completefilename)+File.separator;
name = File.getName(completefilename);

if (dir1=="")
      exit("No dir1 available");
	  
dir2 = dir1+"Results for dkr"+experiment+"_well#"+well+File.separator;
File.makeDirectory(dir2);
  if (!File.exists(dir2))
      exit("Unable to create directory");
	  
open(dir1+name);
getDimensions(imageWidth, imageHeight, channels, slices, frames);  
 
//make sure we have an ROI manager file 
roifilename = "MasterRoiSet.zip";
if(File.exists(dir1+roifilename)){
	
	}
else{
	completeroiname = File.openDialog("Please select the ROI file");
	roifilename = File.getName(completeroiname);
	}
	roiManager("Reset");
	roiManager("Open",dir1+roifilename);
	cells = roiManager("count")-1;	  
}


//iterate through each cell
for(cell=1; cell<cells; cell++){
	roiManager("Reset");
	roiManager("Open",dir1+roifilename);
	
	//pull out the cell and name it
	cellname=experiment+"-"+well+"-"+cell;
	roiManager("Select", cell-1);
	roiManager("Rename", cellname);
	run("Duplicate...", "title="+cellname+" duplicate channels=1-"+channels);
	//remove all intensities from outside this cell
	run("Clear Outside");
	
	//start a new results line for this cell
	print(f,"\n"+experiment+","+well+","+cell+",");

	//get measurements for whole cell fluorescence for each channel	
	for(c=1 ; c<=channels ; c++){
		selectWindow(cellname);
		setSlice(c);
		getRawStatistics(nPixels, mean, min, max, std, histogram);
		print(f, floor(mean)+","+max+","+min+","+floor(max-mean)+",");
		}
		
	//identify nucleus and viral factories
	//duplicate the DAPI channel, define foci and then go back to original image
	setSlice(DAPI);
	run("Duplicate...", "title=binary channels=1-3");
	
	//identify granules and add to ROIManager
	selectWindow("binary");	
	roiManager("Reset");
	roiManager("Add");

	roiManager("Save",dir1+"tmp.zip");
	roiManager("Reset");

	run("Smooth");
	setAutoThreshold("Otsu dark");


	run("Convert to Mask");
	run("Watershed");

	roiManager("Open",dir1+"tmp.zip");
	roiManager("Select",0);
	roiManager("Reset");
	run("Analyze Particles...", "size=10-5000 circularity=0.30-1.00 show=[Overlay Outlines] exclude add");
	selectWindow("binary");
	close();
	
	//manually add and remove ROIs as necessary
	Stack.setActiveChannels("100");
	run("Enhance Contrast", "saturated=0.35");
	setTool("oval");
	roiManager("Show All");
	
	//move window so you can see everything
	selectWindow(cellname);
	run("Set... ", "zoom=200");
	setLocation(100,100);
	getLocationAndSize(x1,y1,w1,h1);
	if(!batch){	waitForUser("Manually add and remove ROIs as necessary"); }
	

	objects = roiManager("count");
	
	if(objects>1){factories = objects-1;}
	else{factories = 0;} //the nucleus doesn't count
	
	if(objects>0){
		//save factories to the roiManager if there is something to save
		roiManager("Deselect");
		roiManager("Save", dir2+cellname+"_factories.zip");
		roiManager("Reset");
		}

	print(f,factories);
	
	//calculate what type of cell this most likely is
	selectWindow(cellname);
	setSlice(GFP);
	getRawStatistics(nPixels, mean, min, max, std, histogram);
	//clear MasterRoiList from manager
	roiManager("Reset");
	signal = floor(max-mean);
	if(signal < 150){
		//this cell does not have significant intensity
		}
	else{
		//this cell has a decent signal now lets get intensities for specific stress granules
			
		//duplicate the GFP channel, define stress granule ROIs and then go back to original image
		setSlice(GFP);
		run("Duplicate...", "title=binary channels=1-3");
		
		//identify granules and add to ROIManager
		selectWindow("binary");	
		run("Smooth");
		setAutoThreshold("RenyiEntropy dark");
		run("Convert to Mask");
		run("Watershed");
		run("Analyze Particles...", "size=5-200 circularity=0.00-1.00 show=[Overlay Outlines] add");
		selectWindow("binary");
		close();
		}
		
	//move window so you can see everything
	selectWindow(cellname);
	run("Set... ", "zoom=200");
	setLocation(100,100);
	getLocationAndSize(x1,y1,w1,h1);
	roiManager("Show All");

	//manually add and remove ROIs as necessary
	Stack.setActiveChannels("010");
	setTool("oval");
	if(!batch){	waitForUser("the intensity for this image is "+signal+"\nmanually add and remove ROIs as necessary");}

	//only count SGs if there are some
	sgCount = roiManager("count");
	
	if(sgCount > 0){
		for(j=0;j<sgCount;j++){
			//print("cell"+cell+":"+sgCount);
			roiManager("Select", j);
			roiManager("Rename", "granule"+granule);
			selectWindow(cellname);
			getRawStatistics(nPixels, mean, min, max, std, histogram);
			print(g, "\n"+experiment+","+well+","+cell+","+granule+","+floor(mean)+","+floor(max)+","+floor(min));
			granule++;		
			}
			
		//save the roiManager if there is something to save
		roiManager("Deselect");
		roiManager("Save", dir2+cellname+"_granules.zip");
		roiManager("Reset");
		}
	
	//save this cropped cell image
	selectWindow(cellname);
	saveAs("Tiff", dir2+cellname);
	run("Close");

	}
run("Clear Results");
selectWindow(title1);
saveAs("Text",dir1+title1+".xls");
selectWindow(title3);
saveAs("Text",dir1+title3+".xls");
if (File.exists(dir1+title1+".xls")){print(title1+" saved");}
if (File.exists(dir1+title3+".xls")){print(title3+" saved");}

}