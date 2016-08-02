// created by Dan Rozelle 20100824
//batch open each  movie in a folder, measure spindle length and midzone length, write results to table and close



macro "_DKR_Batch_measureSpindleMidzone"{

if(nImages>0) exit ("close all images before proceeding");

	if(isOpen("Results")){
		selectWindow("Results");
		run("Close");
		}
	if(isOpen("Log")){
		selectWindow("Log");
		run("Close");
		}

//list BATCH functions here, adjust mode as necessary
function batchfunction();
mode           = newArray("BATCH", "MANUAL", "BOTH");
filter_choices = newArray('NO', '.dv', 'D3D.dv', 'R3D.dv', '.tif');

/**********************************************************/

Dialog.create("Select Options");
 	Dialog.addChoice("Method",mode,"BATCH");
 	Dialog.addChoice("Filter",filter_choices,".tif");
	
	Dialog.show();

	mode=Dialog.getChoice();
	filter=Dialog.getChoice();
	
/**********************************************************/




dir1 = getDirectory("Choose source directory");
if (dir1=="")
      exit("No directory available");

if(filter == "NO"){
	list = getFileList(dir1);
	}
else{
	
//get a list of all the files in this folder 
	preList = getFileList(dir1);
	size=0;
	
	//count each '*filter*' files
	for(place=0;place<preList.length;place++){
		if(endsWith(preList[place],filter)){
			size++;
		}
	}
	//create a new array and populate with filtered images
	list=newArray(size);
	position=0;
	for(place=0;place<preList.length;place++){
		if(endsWith(preList[place],filter)){
			list[position]=preList[place];
			position++;
			}
		}
	}


/********************************************************************/
/* allows the user to type in the appropriate experiment identifiers*/

Dialog.create("Movie Identifiers");
	Dialog.addMessage(dir1);
 	Dialog.addMessage(list[0]);

 	Dialog.addString("Experiment","48.01");
 	 	
	Dialog.show();
	
	expname= Dialog.getString();

/*******************************************************************/

	

//starting with the first image, we increment through each image until finish our list
  for(i=0; i<list.length; i++) {
	//open a two color image in separate channel stacks

	
	if(filter == 'dv' || filter == 'D3D.dv' || filter ==  'R3D.dv'){
		run("Bio-Formats Importer", "open="+dir1+list[i]+" view=Hyperstack stack_order=XYCZT");
		}
	else{
		open(dir1+list[i]);
		}
		
	run("Set... ", "zoom=800");	
	run("Subtract Background...", "rolling=50");
	run("Enhance Contrast", "saturated=0.70");
		
	if(mode == "MANUAL"){
		wait(100);
		waitForUser("click OK \nto proceed"); 
		}
	
	else if(mode == "BATCH"){
		selectWindow(list[i]);
		repeat = batchfunction(list[i]);
		
		}

	
	
	//close the window after dialog box is closed
	selectWindow(list[i]);
	close();
	if(repeat == 1){ 
		i--; //repeat this image
		}
	repeat=0;
	}
}


function batchfunction(name)
{
	run("Set Measurements...", " display decimal=2");
	setResult("Label",nResults,name);
		
	setTool("polyline");
	//waitForUser("measure spindle length");
	
	while(isKeyDown('space') == 0){}
	
	
	//get selection information
	type = selectionType();
	if(type == 6){
		getSelectionCoordinates(x, y);
		getDimensions(width, height, channels, slices, frames);
		getPixelSize(unit, pixelWidth, pixelHeight);
		
		//calculate segment lengths
		//entire spindle overlap zone
		if(x.length == 2){
			total_len = sqrt(  (x[1]-x[0])*(x[1]-x[0])   +   (y[1]-y[0])*(y[1]-y[0])  )*pixelWidth;
			midzone_len = total_len;
			midzone_pos = (midzone_len/2) / total_len;	
			midzone_pct = midzone_len / total_len;
			

			}
		//normal midzone
		else if(x.length == 4){
			s1 = sqrt(  (x[1]-x[0])*(x[1]-x[0])   +   (y[1]-y[0])*(y[1]-y[0])  )*pixelWidth;
			s2 = sqrt(  (x[2]-x[1])*(x[2]-x[1])   +   (y[2]-y[1])*(y[2]-y[1])  )*pixelWidth;
			s3 = sqrt(  (x[3]-x[2])*(x[3]-x[2])   +   (y[3]-y[2])*(y[3]-y[2])  )*pixelWidth;
			midzone_len = s2;
			total_len   = s1 + s2 + s3;	
			midzone_pct = s2/total_len;
			midzone_pos = ((s2/2)+s1)/total_len;
			

			}
		//mistaken selection, reopen this image to allow another selection
		else{		
			waitForUser("you need to draw a line");
			return 1;
			} 

	//print data 
	setResult("midzone_len", nResults-1, d2s(midzone_len,2) );
	setResult("total_len",   nResults-1, d2s(total_len,2)   );
	setResult("midzone_pct", nResults-1, d2s(midzone_pct,2));
	setResult("midzone_pos", nResults-1, d2s(midzone_pos,2));
		


	
	/*
	Dialog.create("Select Categories");
	choices = newArray("enriched","diffuse","bipolar");

 	Dialog.addChoice("This localization is:",choices,"diffuse");
	
	Dialog.show();
	
	choice = Dialog.getChoice();	
	
	if(choice == "enriched")    {setResult("enriched",nResults-1,1);}
	else if(choice == "diffuse"){setResult("diffuse" ,nResults-1,1);}
	else if(choice == "bipolar"){setResult("bipolar" ,nResults-1,1);}
	else{};
		
	*/
				
	updateResults();
	return 0;
		}
		
	//no selection was made, reopen this image to allow another selection
	else{
		waitForUser("you need to draw a line");
		return 1;
		}


}


