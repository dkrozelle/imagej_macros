macro "Mark Cell Location" {

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
		  
	//continue until log is closed	  
      while (!logOpened || isOpen("Log")) {
          getCursorLoc(x, y, z, flags);
		  
			//only recalculate if the cursor or button is pressed has changed position
			if (x!=x2 || y!=y2 || z!=z2 || flags!=flags2) {
 
			if(flags==16||flags==2){
				makePoint(x,y);
				print("point "+i+":"+x+", "+y)
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