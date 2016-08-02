//renumbers the labels for an ROI list

macro "go"{	

	roiManager("Deselect");
	nROI = roiManager("count");
	i=0;
	
	for(i;i<nROI;i++){
		roiManager("Select", i);
		roiManager("Rename", i+1);
	}
	


}