// created by Dan Rozelle 20110324
//used to scale a single color from a composite image, used when you need to compensate for changes exposure times


macro "go"{

name = getTitle();
run("Split Channels");
selectWindow("C4-"+name);
run("Multiply...", "value=2.500");
run("Merge Channels...", "red=C1-"+name+" green=C2-"+name+" blue=C3-"+name+" gray=C4-"+name+" create");
//saveAs("Tiff","C:\Users\dkr\Desktop\J2");
}


