macro "Mark Cell Location" {
	roiWidth=100;
	roiHeight=100;
	i=1;
    leftButton=16;
    rightButton=4;
    shift=1;
    ctrl=2; 
    alt=8;
    x2=-1; y2=-1; z2=-1; flags2=-1;
      logOpened = false;
	print("close this window when done");
	print(" zoom to reposition with +/-, do not attempt to drag the window");
	print(" remember to save the ROI set after closing this window");
      if (getVersion>="1.37r")
          setOption("DisablePopupMenu", true);
	getDimensions(imageWidth, imageHeight, channels, slices, frames);  
	//continue until log is closed	  
      while (!logOpened || isOpen("Log")) {
          getCursorLoc(x, y, z, flags);
		  
			//only perform one at this location
			if (x!=x2 || y!=y2 || z!=z2 || flags!=flags2) {
 
			if(flags==16||flags==2){
				if(x-roiWidth/2<0){left=0;}
				else if(x+roiWidth/2>imageWidth){left=imageWidth-roiWidth;}
				else{left=x-roiWidth/2;}
				
				if(y-roiHeight/2<0){top=0;}
				else if(y+roiHeight/2>imageHeight){top=imageHeight-roiHeight;}
				else{top=y-roiHeight/2;}				
				
				run("Specify...", "width="+roiWidth+" height="+roiHeight+" x="+left+" y="+top+" slice=5");
				//print("Specify...", "roiWidth="+roiWidth+" roiHeight="+roiHeight+" x="+left+" y="+top+" slice=5");
				//run("Draw");
				i++;

			}
            
              logOpened = true;
              startTime = getTime();
          }
          x2=x; y2=y; z2=z; flags2=flags;
          wait(100);
	}

     
      if (getVersion>="1.37r")
          setOption("DisablePopupMenu", false);

}