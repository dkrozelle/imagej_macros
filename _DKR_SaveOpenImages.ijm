macro "go"{

dir1 = getDirectory("where to save");

while(nImages>0){
	name=getTitle;
	saveAs("Tif",dir1+name);
	//print("nImages: "+nImages);
	//print("next image ID: "+getImageID());
	close();
}


//count = nImages;
//
//for(i=1;i<count;i++){
//	selectImage(i);
//	
//	
//	
//	}


}