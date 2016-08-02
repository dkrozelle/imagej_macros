macro "Mark Cell Location" {

setTool("point");

    leftButton=16;
    x2=-1; y2=-1; z2=-1; flags2=-1;

    done=0;

    if (getVersion>="1.37r")
        setOption("DisablePopupMenu", true);

	//continue until leftButton is clicked
    while (done==0) {
        getCursorLoc(x, y, z, flags);

		//capture location on left click	
		if(flags==16){
			return(x,y);
			done=1;
			}
		}
}