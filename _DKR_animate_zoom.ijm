
macro "go" { 

//get initial values
name = getTitle();
getDimensions(width, height, channels, slices, frames);
getSelectionBounds(roi_x, roi_y, roi_width, roi_height);
roi_set = selectionType();
steps = 10;   // zoom by this many pixels each step, must be even number

//make sure proper image is open with an area selected, it will accept selectionTypes 0=rectangle, 1=oval, 2=polygon, 3=freehand
if(roi_set < 0 || roi_set > 3 || slices>1){exit("You must specify a ROI");}

//calculate cropped large image dimensions
proportion_width  = width-roi_width/(roi_height/roi_width);
proportion_height = (height-roi_height)/1;

if(proportion_width >= proportion_height){
	step_width  = (width - roi_width)/steps;
	step_height = (step_width/(roi_height/roi_width));
	}
else{
	step_height = (height - roi_height)/steps;
	step_width  = (step_height(roi_height/roi_width));
	}
	
//make a place for the new stack
newImage("zoom", "RGB White", roi_width, roi_height, 1);

//define placeholders for intermediate rois
current_width  = roi_width;
current_height = roi_height;
current_x      = roi_x;
current_y      = roi_y;


for(i=0;i<steps;i++){

	selectWindow(name);
	run("Specify...", "width="+current_width+" height="+current_height+" x="+current_x+" y="+current_y);
	run("Duplicate...", "title=next");
	run("Size...", "width="+roi_width+" height="+roi_height+"  constrain average interpolation=Bilinear");

	run("Concatenator ", "stack1=next stack2=[zoom] title=[zoom]");

//expand current_x based on collisions with sides 	
//there is still room on both sides to expand each by half a step_width	
	if(current_x + current_width + step_width <= width){
		current_x = current_x - (step_width/2);
		}
//if we will go past the left side set that side as 0 and expand to the right
	else if(current_x - step_width/2 <= 0){
		current_x = 0;
		}
//if we will go past the right side, expand to the left by the full expansion amount
	else{
		current_x = current_x - (step_width);
		}
		
//do the same with current_y 	
//there is still room on both sides to expand each by half a step_width	
	if(current_y + current_height + step_height <= height){
		current_y = current_y - (step_height/2);
		}
//if we will go past the top side set that side as 0 and expand to the bottom
	else if(current_y - step_height/2 <= 0){
		current_y = 0;
		}
//if we will go past the bottom side, expand to the top by the full expansion amount
	else{
		current_y = current_y - (step_height);
		}		
		
//now expand the roi dimensions to the next size		
	current_width  = current_width  + step_width;
	current_height = current_height + step_height;
		
	} //end for loop
}//close macro