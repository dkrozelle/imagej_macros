function cropROI(){	

	roiWidth=50;
	roiHeight=50;
	getDimensions(imageWidth, imageHeight, channels, slices, frames);  

	if(x-roiWidth/2<0){left=0;}
				else if(x+roiWidth/2>imageWidth){left=imageWidth-roiWidth;}
				else{left=x-roiWidth/2;}
				
				if(y-roiHeight/2<0){top=0;}
				else if(y+roiHeight/2>imageHeight){top=imageHeight-roiHeight;}
				else{top=y-roiHeight/2;}				
				
				run("Specify...", "width="+roiWidth+" height="+roiHeight+" x="+left+" y="+top+" slice=5");
}