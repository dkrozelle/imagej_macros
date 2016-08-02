

macro "go"{

getDimensions(width, height, channels, slices, frames);
ROIsize=10;
wide=width;
high=height;

x=(wide/2)-(50);
y=(high/2)-(50);
run("Specify...", "width=100 height=100 x="+x+" y="+y+" oval");
run("To Selection");
run("Select None");

x=(wide/2)-(ROIsize/2);
y=(high/2)-(ROIsize/2);
run("Specify...", "width="+ROIsize+" height="+ROIsize+" x="+x+" y="+y+" oval");
 
}