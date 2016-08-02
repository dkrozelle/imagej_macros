// ****************************
// this macro uses the very advanced stitching pluging developed by Stephan Preibisch
// please cite:
// 	S. Preibisch, S. Saalfeld, P. Tomancak (2009) "Globally optimal stitching of tiled 3D microscopic image acquisitions", Bioinformatics, 25(11):1463-1465.

// 20131211 by ciclistadan
// ("mosaix" folder of zvi encoded mosaiX images) -> stitched folder of tif images

// this has only been tested with multi-channel 2D images but should work as well with higher dimensions (z-stack + time)
// ****************************


macro "go [q]"{

setBatchMode(true);

//prepare env
if(nImages>0) exit ("close all images before proceeding");
if(isOpen("Results")){
	selectWindow("Results");
	run("Close");
	}
if(isOpen("Log")){
	selectWindow("Log");
	run("Close");
	}

// get params
Dialog.create("Set Options");
 	Dialog.addString("# panels wide",4);
 	Dialog.addString("# panels tall",4);
 	Dialog.addString("% overlap",13);
 	Dialog.show();
	
panels_x       = Dialog.getString();
panels_y       = Dialog.getString();
panels_overlap = Dialog.getString();

// get source mosaix.zvi folder
dir1 = getDirectory("Choose source directory");
if (dir1=="")
      exit("No directory available");
parent = File.getParent(dir1);
	  
// Create an output directory sibling to dir1
  dir2 = parent+File.separator+"stitched"+File.separator;
  File.makeDirectory(dir2);
  if (!File.exists(dir2))
      exit("Unable to create directory");	

// get list of images
list = getFileList(dir1);
	
//starting with the first image, import image as separate panels, we increment through each image
for(i=0; i<list.length; i++){
	showProgress(i+1/list.length);
	showStatus("importing "+list[i]);
	if(endsWith(list[i],"zvi")){
		run("Bio-Formats Importer", "open="+dir1+list[i]+" color_mode=Composite open_all_series view=Hyperstack stack_order=XYCZT");
		}
	else{
		exit ("this macro only works on Zeiss .zvi mosaiX files");
		}

//save tiles to tmp folder
	// find tmp folder
	tmp = getDirectory("temp");
	if(tmp=="") tmp = getDirectory("Choose a Temp Directory"); 
	if(tmp=="") exit("No tmp directory specified");
	
	// make a subfolder in tmp
	tmp = tmp+File.separator+"imagej"+File.separator;
	File.makeDirectory(tmp);
	if (!File.exists(tmp)) exit("Unable to create tmp directory");
	
	while(nImages>0){
		name=getTitle;
		saveAs("Tif",tmp+nImages);
		print("name:"+name+" ID:"+getImageID());
		close();
		}

	showStatus("stitching image");
	// perform stitching plugin...and for some reason you need to keep these spaces  v v v v v v v v   ?
	run("Grid/Collection stitching", "type=[Grid: snake by rows] order=[Right & Down                ] grid_size_x="+panels_x+" grid_size_y="+panels_y+" tile_overlap="+panels_overlap+" first_file_index_i=1 directory="+tmp+" file_names={i}.tif output_textfile_name=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 compute_overlap subpixel_accuracy computation_parameters=[Save computation time (but use more RAM)] image_output=[Fuse and display]");
	
	// save fused image output
	// "fuse and display" option merges channels back together, write to disk does not, so we go ahead and fuse followed by save
	saveAs("Tif",dir2+list[i]);
	close();
	}
print('Finished with all Stitches');

}
