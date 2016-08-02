macro "go [q]"{

	String.resetBuffer;
	Stack.getDimensions(width, height, channels, slices, frames);

	for(i=1; i <= channels; i++){
		Stack.setChannel(i);
		getMinAndMax(min, max);
		String.append("Ch"+i+": "+floor(min)+"-"+floor(max)+"\n");
		}
	
	String.copy(String.buffer);
	
	}


