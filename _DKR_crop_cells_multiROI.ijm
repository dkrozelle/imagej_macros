//used to create sub-images of regularized size for a single image with multiple ROIs

macro "go"{	

	roiManager("Deselect");
	nROI = roiManager("count");
	i=0;
	
	for(i;i<nROI;i++){
		roiManager("Select", i);
		roiManager("Rename", i+1);
	}
	


}