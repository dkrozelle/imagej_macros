

macro "AutoScaleBrightestSlice"{

//get the image dimensions
getDimensions(width, height, channels, slices, frames);
c=channels;
favorite = 4; //choose the channel you want to autofocus on (first channel = 1)
displaymode = "0111"; //bool for each channel, "0111" means do not display first channel

//define which colors you want to use on each channel
if(channels>1){
lookuptable = newArray(4);
lookuptable[0] = "Grays";
lookuptable[1] = "Blue";
lookuptable[2] = "Green";
lookuptable[3] = "Red";
}
else {
lookuptable = newArray(1);
lookuptable[0] = "Grays";
}


//search each channel for the max slice containing the max intensity pixel
for(c;c>0;c--){
	Stack.setChannel(c);
	run(lookuptable[c-1]);

	//reset max counters for each channel
	slicemax=0;
	channelmax = 0;
		
	//get max value of each slice, remember it if it is the largest you have seen for this channel
	for(z=1;z<=slices;z++){
		Stack.setSlice(z);
		getStatistics(area, mean, min, max, std, histogram);
			
			if(max > channelmax){
				channelmax = max;
				slicemax = z;
				}
		}
	if(c == favorite) {
		bestslice = slicemax;
		}

	//move to the brightest intensity slice on this channel and use auto contrast
	Stack.setSlice(slicemax);
	resetMinAndMax();
	run("Enhance Contrast", "saturated=0.2");
}
	//now that you're done, set it to the best place EVER!
if(channels>1){
	Stack.setChannel(favorite);
	Stack.setSlice(bestslice);
	Stack.setActiveChannels(displaymode);
	}
}