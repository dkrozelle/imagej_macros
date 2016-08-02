//ciclistadan 20110516 adapted from spindle measurer
//opens images from dir and writes measurements to a results table


macro "go"{

filter = "tif";
setBatchMode(true);

if(nImages>0) exit ("close all images before proceeding");

run("Clear Results");

//get directory and filter 
{
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
	//you now have list[] with all desired files
	}
}


for(i=0;i<list.length;i++){
	
	open(list[i]);
	getDimensions(width, height, channels, slices, frames);
	name = replace(list[i],".tif","");
	setResult("Label",nResults,name);


	for(c=1 ; c<=channels ; c++){
		setSlice(c);
		getRawStatistics(nPixels, mean, min, max, std, histogram);
		setResult("ch"+c+"mean",nResults-1,floor(mean));
		setResult("ch"+c+"max", nResults-1,floor(max) );
		setResult("ch"+c+"min", nResults-1,floor(min) );
		}
	selectWindow(list[i]);
	close();
	}

updateResults();

}
