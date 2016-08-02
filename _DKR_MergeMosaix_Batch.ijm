// created by Dan Rozelle 20121018
//used to merge exported channels for a Zeiss MosaiX tiled image
//after aligning images on AxioVision, export images as tif
// settings use initially: Create Project Folder; Displayed Image Mode; Generate Merged Image; Merged Images only; Gray Scale, Apply display mappings


macro "go [q]"{
setBatchMode(true);
if(nImages>0) exit ("close all images before proceeding");

showMessageWithCancel("Make sure your image names will sort in the desired channel order");

//find the source images
dir1 = getDirectory("Choose project folder");
if (dir1=="")
      exit("No directory available");
	  
//get a list of all the folders in the project folder 
	list = getFileList(dir1);
	size=0;
	
// Create an output directory within the project directory AFTER you have generated a folder list
  dir2 = dir1+File.separator+"merged"+File.separator;
  File.makeDirectory(dir2);
  if (!File.exists(dir2))
      exit("Unable to create directory");	


//starting with the folder, we increment through each, merging images within each
  for(i=0; i<list.length; i++){
		channellist = getFileList(dir1+list[i]);
		
		channelstring="";
		
		for(j=0; j<channellist.length; j++){
			open(dir1+list[i]+channellist[j]);
			run("16-bit");
			append = "c"+j+1+"="+channellist[j]+" ";
			channelstring += append; 

			}
	
		run("Merge Channels...", channelstring+" create");
		len = lengthOf(list[i])-1;
		filename = substring(list[i],0,len);
		//print(list[i]+" "+len+" "+filename);
		saveAs("Tiff", dir2+filename+"_merge.tif");
		close();
	
	}

print("done");
}




