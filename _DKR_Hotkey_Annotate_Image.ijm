// 20140905 ciclistadan
// annotate an image, record counts of each marker in results table, ability to save roi/crop of each  
// 
//   This macro makes use of lettered hotkeys, and therefore assumes that "Require control key for shortcuts"
//    in Edit▷Options▷Misc…↓ is checked.
// 
// a = infected + granules (AVG)
// s = uninfected + granules (SG)
// d = uninfected cell without granules
// f = infected cells (with factory)

// 1/2/3 toggle channels

// r = refresh annotations on display
// p = print results to Results window
// o = output results and roi

function mark();


macro "initialize" {

	// if(nImages>1) exit ("close all but one image before proceeding");
	// getDimensions(imageWidth, imageHeight, channels, slices, frames);  
// if(slices>1) exit ("this image has "+slices+"slices'n"+"this macro requires a single flat image (no z-stacks)");

name=getTitle();
basename = substring(name,0,lengthOf(name)-4);

roiManager("Reset");
roiManager("Show All with labels");
run("Labels...", "color=white font=12 show use draw bold");

}


function mark(x,y,cat){	

	roiManager("Add");
	j=roiManager("count");
	roiManager("Select", j-1);

	// concatenate the name
	padded = toString(j/10000,4);
	padded = substring(padded,2);

	label = padded+"-"+cat;
	roiManager("Rename", label);
	run("Labels...", "color=white font=12 show use draw bold");

}

macro "Refresh [r]" {
	run("Labels...", "color=white font=12 show use draw bold");
}


macro "Mark AVG [a]" {
	cat = "AVG";
	getCursorLoc(x, y, z, flags);
	makePoint(x, y)
	mark(x,y,cat);
}

macro "Mark SG [s]" {
	cat = "SG";
	getCursorLoc(x, y, z, flags);
	makePoint(x, y)
	mark(x,y,cat);
}

macro "Mark UnInf [d]" {
	cat = "UnInf";
	getCursorLoc(x, y, z, flags);
	makePoint(x, y)
	mark(x,y,cat);
}

macro "Mark Factory [f]" {
	cat = "Factory";
	getCursorLoc(x, y, z, flags);
	makePoint(x, y)
	mark(x,y,cat);
}

macro "toggle1 [1]" {
	Stack.getActiveChannels(channels);
	if (substring(channels,0,1)==1){
		Stack.setActiveChannels("0"+substring(channels,1));
	}
	else {
		Stack.setActiveChannels("1"+substring(channels,1));
	}
}

macro "toggle2 [2]" {
	Stack.getActiveChannels(channels);
	if (substring(channels,1,2)==1){
		Stack.setActiveChannels(substring(channels,0,1)+"0"+substring(channels,2));
	}
	else {
		Stack.setActiveChannels(substring(channels,0,1)+"1"+substring(channels,2));
	}
}

macro "toggle2 [3]" {
	Stack.getActiveChannels(channels);
	if (substring(channels,2,3)==1){
		Stack.setActiveChannels(substring(channels,0,2)+"0"+substring(channels,3));
	}
	else {
		Stack.setActiveChannels(substring(channels,0,2)+"1"+substring(channels,3));
	}
}

macro "save roi and results [o]" {
	saveAs("Results", "/Users/danrozelle/Desktop/Results.xls");
	
	name=getTitle();
basename = substring(name,0,lengthOf(name)-4);
roiManager("Deselect");
	roiManager("Save", "/Users/danrozelle/Desktop/"+basename+"_RoiSet.zip");
}

macro "Print Results [p]" {
	setBatchMode(true);
	name=getTitle();
	basename = substring(name,0,lengthOf(name)-4);

	roiManager("Deselect");
	nROI = roiManager("count");
	
	// add a new row and label it with this image name
	setResult("image", nResults, basename)
	for(i=0 ;i<nROI ;i++){
		roiManager("Select", i);
		label = call("ij.plugin.frame.RoiManager.getName", i);
		cat = substring(label,5);
		
		prev = getResult(cat, nResults-1);
		if(prev>0){value = prev+1;}
		else{value=1;}

		setResult(cat, nResults-1, value);
		}

	if( getResult("AVG", nResults-1)>0 ){
		AVGs = getResult("AVG", nResults-1);}
	else {
		setResult("AVG", nResults-1, 0);
		AVGs = 0; }

	if( getResult("SGs", nResults-1)>0 ){
		AVGs = getResult("SG", nResults-1);}
	else {
		setResult("SG", nResults-1, 0);
		SGs = 0; }

	if( getResult("Factory", nResults-1)>0 ){
		Factories = getResult("Factory", nResults-1);}
	else {
		setResult("Factory", nResults-1, 0);
		Factories = 0; }

	if( getResult("UnInf", nResults-1)>0 ){
		Uninfected = getResult("UnInf", nResults-1);}
	else {
		setResult("UnInf", nResults-1, 0);
		Uninfected = 0; }


	// calculate %AVGs
	setResult("n", nResults-1, AVGs+Factories+SGs+Uninfected);
	setResult("Proportion AVGs", nResults-1, AVGs/(Factories+AVGs));

	setResult("Proportion Infected Cells", nResults-1, (AVGs+Factories)/(AVGs+Factories+SGs+Uninfected) );
	setBatchMode(false);

}
