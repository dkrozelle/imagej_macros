// 20130729 ciclistadan
// perform simple functions on all open images

macro "go"{

function batchFunction();

	if(isOpen("Results")){
		selectWindow("Results");
		run("Close");
		}
	if(isOpen("Log")){
		selectWindow("Log");
		run("Close");
		}

// functions for non-image windows
  // list = getList("window.titles");
  // if (list.length==0)
  //    print("No non-image windows are open");
  // else {
  //    print("Non-image windows:");
  //    for (i=0; i<list.length; i++)
  //       print("   "+list[i]);
  // }


showStatus("Running Batch Process on Open Images");
  if (nImages==0)
     print("No images are open");
  else {
     setBatchMode(false);
     for (i=1; i<=nImages; i++) {
        selectImage(i);
        batchFunction(i);
        showProgress(i/nImages);
     }
  }
 showStatus("Batch Processing Complete");
}



function batchFunction(title){

//functions that move the window only work with setBatchMode(false)
	getLocationAndSize(x,y,width,height);
	setLocation(x+500,y);

}