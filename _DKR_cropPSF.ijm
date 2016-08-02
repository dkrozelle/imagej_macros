macro "go"{	

if(selectionType() == 10){ 
	roiSize=250;
	getDimensions(imageWidth, imageHeight, channels, slices, frames);  
	getSelectionBounds(x, y, width, height);
	if(x-roiSize/2<0)
		{waitForUser("not enough room on the left for this PSF");}
	else if(x+roiSize/2>imageWidth)
		{waitForUser("not enough room on the right for this PSF");}
	else{left=x-roiSize/2;}
				
	if(y-roiSize/2<0)
		{waitForUser("not enough room on the top for this PSF");}
	else if(y+roiSize/2>imageHeight)
		{waitForUser("not enough room on the bottom for this PSF");}
	else{top=y-roiSize/2;}				
				
	run("Specify...", "width="+roiSize+" height="+roiSize+" x="+left+" y="+top);
	run("Duplicate...");
	}
else{waitForUser("you need to place a point selection on the PSF");}
}