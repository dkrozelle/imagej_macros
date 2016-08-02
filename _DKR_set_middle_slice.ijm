// 20140407 ciclistadan
// setslice to middle of stack for all open images

macro "go"{

setBatchMode(true);
  if (nImages==0)
     print("No images are open");
  else {
     for (i=1; i<=nImages; i++) {
        selectImage(i);

        // set to middle slice
		setSlice( floor(nSlices/2));
     }
  }

}

