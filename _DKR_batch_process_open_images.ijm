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
     setBatchMode(true);
     for (i=1; i<=nImages; i++) {
        selectImage(i);
        batchFunction(
        	i);
        showProgress(i/nImages);
     }
  }
 showStatus("Batch Processing Complete");
}



function batchFunction(title){

// set to middle slice and pseudo-color RBG with autoscale
	setSlice( floor(nSlices/2));

	run("Make Composite");
	Stack.setChannel(1);
	run("Blue");
	run("Enhance Contrast", "saturated=0.35");
	Stack.setChannel(2);
	run("Green");
	run("Enhance Contrast", "saturated=0.35");
	Stack.setChannel(3);
	run("Red");
	run("Enhance Contrast", "saturated=0.35");


}