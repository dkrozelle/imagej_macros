// created by ciclistadan 20110413
//used to combine hyperstacks for determining scaling levels 

//TODO
// add support for 5D images
// fix ugly labeling function, use overlay or roi definitions?
// add montage definition for greater flexibility

//20140711 - automatic determination of panel width fixed

macro "go"{

setBatchMode(true);
//choose the directory
dir1 = getDirectory("Choose source directory");
if (dir1=="")
      exit("No directory available");

//get a list of all the files in this folder 
preList = getFileList(dir1);
size=0;

// change this value to bypass dialog window and go with defaults 
if(false){
//determine which filetypes to include
	filter="tif";
	panelsWide="";
	Dialog.create("File Types");
	Dialog.addString("Suffix Filter :", filter);
        Dialog.addCheckbox("Meander", true);
	Dialog.addCheckbox("Labels", false);
	Dialog.addString("Panels/row (leave blank for auto) :", panelsWide);
	
	Dialog.show();
	filter=Dialog.getString();
//"meander" method reverses even rows (2,4,6) , this is commonly used when you are recreating a mosaiX that was captured by scrolling L-R, R-L, L-R...
    meander=Dialog.getCheckbox();
	labels=Dialog.getCheckbox();
	panelsWide=Dialog.getString();
}
else{
	filter='tif';
	meander = true;
	labels  = false;
	panelsWide="";
}


//count only '*filter*' files
for(place=0;place<preList.length;place++){
	if(endsWith(preList[place],filter)){
		size++;
	}
}
//create a new array and populate with filtered images
midList=newArray(size);
position=0;
for(place=0;place<preList.length;place++){
	if(endsWith(preList[place],filter)){
		midList[position]=preList[place];
		position++;
	}
}

//sort the list
list = Array.sort(midList);

//calculate dimensions for the sheet, the mosaiX will be square unless you define "panelsWide" in the dialog


// dimensions not defined
if(panelsWide==""){
	//panels make a perfect square
	if(sqrt(size)%1==0){
		panelsWide = sqrt(size);
		panelsHigh = panelsWide;
	}
	//panels make an imperfect square
	else{
		panelsWide = floor(sqrt(size))+1;
		panelsHigh = panelsWide;
	}
}
//width defined
else if (panelsWide > 0){
	//panels make a perfect square
	if(size%panelsWide==0){
		panelsHigh = size/panelsWide;
	}
	else{
	//panels make an imperfect square or a rectangle
		panelsHigh = floor(size/panelsWide)+1;
	}
}
setFont("SansSerif", 24, " antialiased");
run("Line Width...", "line=3");
image=0;

//I need a loop for each row
for(row=1;row<=panelsHigh;row++){
	//now I need a loop to fill each position
	for(position=1;position<=panelsWide;position++){
		//only combine if there is another image
		if(image<list.length){
			//open the first image if this is the first in the row
			if(position==1){
				
				open(dir1+list[image]);
				if(labels){label(list[image]);}
				rename("row"+row);
				}
			else{
				open(dir1+list[image]);
				if(labels){label(list[image]);}
				if(meander && row%2==0){
					run("Combine...", "stack1=["+list[image]+"] stack2=[row"+row+"]");
					}
				else{	
					run("Combine...", "stack1=[row"+row+"] stack2=["+list[image]+"]");
					}
				rename("row"+row);
				}
			
			print(list[image]);
			image++;
			}
		}
	}

//now lets combine the rows
for(row=1;row<=panelsHigh;row++){
	if(isOpen("row"+row+1)){
		run("Combine...", "stack1=[row"+row+"] stack2=[row"+row+1+"] combine");
		rename("row"+row+1);
		}
	}
setBatchMode(false);
rename("Combined Image");
run("Make Composite", "display=Composite");

//optional, auto scale each channel
run("Specify...", "width=200 height=200 x=10 y=10 slice=1");
Stack.setChannel(1);
run("Green");
run("Enhance Contrast", "saturated=0.35");
Stack.setChannel(2);
run("Red");
run("Enhance Contrast", "saturated=0.35");
Stack.setChannel(3);
run("Blue");
run("Enhance Contrast", "saturated=0.35");

saveAs('tif');
close();
}

function label(name) {
			run("Colors...", "foreground=white background=white selection=yellow");
			makeRectangle(98, 54, 631, 52); 
			run("Fill", "slice");
			run("Colors...", "foreground=black background=white selection=yellow");
			drawString(name, 100, 100);
			}