run("Action Bar","/plugins/ActionBar/_DanBar.ijm");
exit();

<noGrid> //this sizes buttons to each text, erase to have spacefilling buttons

-------------- 1 --------------
<line>


<button>
label=LOCI
arg=<macro>
	run("Bio-Formats Importer", "view=Hyperstack stack_order=XYCZT merge_channels autoscale");
</macro>


<button>
label=Rec
arg=run("Record...");

<button>
label=Copy
arg=run("Copy to System");

<button>
label=Sync
arg=run("Sync Windows");

<button>
label=ScaleBar
arg=<macro>
	filename = "_DKR_Calibrate_and_ScaleBar.ijm";
	path = getDirectory("macros");
	run("Install...", "install="+path+"dkr"+File.separator+filename);
	run("go");
</macro>

<button>
label=8 
arg=run("8-bit");

<button>
label=16
arg=run("16-bit");

<button>
label=RGB 
arg=run("RGB Color");	

<button>
label=Rotate
arg=<macro>
	filename = "_DKR_RotateCell.txt";
	path = getDirectory("macros");
	run("Install...", "install="+path+"dkr"+File.separator+filename);
	run("rotate cell");
</macro>

<button>
label=DanBar Info
arg=<macro>
	Dialog.create("DanBar");
	Dialog.addMessage("DanBar was created by Dan Rozelle PhD. drozelle@bu.edu");
	//Dialog.addMessage("   click the \"Help\" button for more information");
	Dialog.addHelp("http://connorlab.com/");
	Dialog.show();
</macro>

<button>
label=Edit
arg=<macro>
	prog = "subl ";
	file = "ActionBar/_DanBar.ijm";
	path = getDirectory("plugins");
	full_name = prog+path+"dkr"+File.separator+file;
	exec(full_name);
</macro>

<button>
label=Reset
arg=<macro>
	filename = "_DKR_ResetDanBar.ijm";
	path = getDirectory("macros");
	run("Install...", "install="+path+"dkr"+File.separator+filename);
	run("go");
</macro>

<button>
label=SetSlices
arg=<macro>
	filename = "_DKR_set_middle_slice.ijm";
	path = getDirectory("macros");
	run("Install...", "install="+path+"dkr"+File.separator+filename);
	run("go");
</macro>

<button>
label=SaveOpen
arg=<macro>
	filename = "_DKR_SaveOpenImages.ijm";
	path = getDirectory("macros");
	run("Install...", "install="+path+"dkr"+File.separator+filename);
	run("go");
</macro>

<button>
label=close all 
arg=while (nImages >0) close();


</line> 
-------------- 2 --------------
<line>


<button>
label=3x5
arg=run("Specify...", "width=300 height=500 x=0 y=0 ");

<button>
label=5x3
arg=run("Specify...", "width=500 height=300 x=0 y=0 ");

<button>
label=R-100
arg=run("Specify...", "width=100 height=100 x=0 y=0 ");

<button>
label=R-500
arg=run("Specify...", "width=500 height=500 x=0 y=0 ");

<button>
label=R-1000
arg=run("Specify...", "width=1000 height=1000 x=0 y=0 ");

<button>
label=Project
arg=<macro>
	filename = "_DKR_ZProject.ijm";
	path = getDirectory("macros");
	run("Install...", "install="+path+"dkr"+File.separator+filename);
	run("go [z]");
</macro>

<button>
label=B
arg=run("Blue");

<button>
label=G
arg=run("Green");

<button>
label=R
arg=run("Red");

<button>
label=Y
arg=run("Yellow");

<button>
label=Gry
arg=run("Grays");

<button>
label=WGR
arg=<macro>
	Stack.setChannel(1);
	run("Grays");
	run("Enhance Contrast", "saturated=0.35");
	Stack.setChannel(2);
	run("Green");
	run("Enhance Contrast", "saturated=0.35");
	Stack.setChannel(3);
	run("Red");
	run("Enhance Contrast", "saturated=0.35");
	Stack.setChannel(1);
</macro>

<button>
label=GRMB
arg=<macro>
	Stack.setChannel(1);
	run("Green");
	run("Enhance Contrast", "saturated=0.35");
	Stack.setChannel(2);
	run("Red");
	run("Enhance Contrast", "saturated=0.35");
	Stack.setChannel(3);
	run("Magenta");
	run("Enhance Contrast", "saturated=0.35");
	Stack.setChannel(4);	
	run("Blue");
	run("Enhance Contrast", "saturated=0.35");
	Stack.setChannel(1);
</macro>

<button>
label=BRG
arg=<macro>
	Stack.setChannel(1);
	run("Blue");
	run("Enhance Contrast", "saturated=0.35");
	Stack.setChannel(2);
	run("Red");
	run("Enhance Contrast", "saturated=0.35");
	Stack.setChannel(3);
	run("Green");
	run("Enhance Contrast", "saturated=0.35");
	Stack.setChannel(1);
</macro>

<button>
label=BGR
arg=<macro>
	Stack.setChannel(1);
	run("Blue");
	run("Enhance Contrast", "saturated=0.35");
	Stack.setChannel(2);
	run("Green");
	run("Enhance Contrast", "saturated=0.35");
	Stack.setChannel(3);
	run("Red");
	run("Enhance Contrast", "saturated=0.35");
	Stack.setChannel(1);
</macro>

<button>
label=RBG
arg=<macro>
	run("Make Composite");
	Stack.setChannel(1);
	run("Red");
	run("Enhance Contrast", "saturated=0.35");
	Stack.setChannel(2);
	run("Blue");
	run("Enhance Contrast", "saturated=0.35");
	Stack.setChannel(3);
	run("Green");
	run("Enhance Contrast", "saturated=0.35");
</macro>

<button>
label=RGB
arg=<macro>
	run("Make Composite");
	Stack.setChannel(1);
	run("Red");
	run("Enhance Contrast", "saturated=0.35");
	Stack.setChannel(2);
	run("Green");
	run("Enhance Contrast", "saturated=0.35");
	Stack.setChannel(3);
	run("Blue");
	run("Enhance Contrast", "saturated=0.35");
</macro>

<button>
label=GRB
arg=<macro>
	run("Make Composite");
	Stack.setChannel(1);
	run("Green");
	run("Enhance Contrast", "saturated=0.35");
	Stack.setChannel(2);
	run("Red");
	run("Enhance Contrast", "saturated=0.35");
	Stack.setChannel(3);
	run("Blue");
	run("Enhance Contrast", "saturated=0.35");
</macro>

<button>
label=SaveAsTif
arg=<macro>
	filename = "_DKR_SaveFolderAsTiff.ijm";
	path = getDirectory("macros");
	run("Install...", "install="+path+"dkr"+File.separator+filename);
	run("go");
</macro>




</line> 
-------------- 3 --------------
<line>


<button>
label=S&C
arg=<macro>
	filename = "_DKR_PositionWindows.txt";
	path = getDirectory("macros");
	run("Install...", "install="+path+"dkr"+File.separator+filename);
	run("go");
</macro>

<button>
label=PrjCrop
arg=<macro>
	filename = "_DKR_AutoMaxProject.ijm";
	path = getDirectory("macros");
	run("Install...", "install="+path+"dkr"+File.separator+filename);
	run("go [q]");
</macro>

<button>
label=StickyScore
arg=<macro>
	run("Action Bar","plugins"+File.separator+"ActionBar"+File.separator+"_StickyScoreROI.ijm");
</macro>

<button>
label=Combine Stacks
arg=<macro>
	filename = "_DKR_CombineStacks.ijm";
	path = getDirectory("macros");
	run("Install...", "install="+path+"dkr"+File.separator+filename);
	run("go");
</macro>

<button>
label=Montage.bat
arg=<macro>
	filename = "_DKR_Scale&Montage_Batch.ijm";
	path = getDirectory("macros");
	run("Install...", "install="+path+"dkr"+File.separator+filename);
	run("go [q]");
</macro>

<button>
label=RGB.bat
arg=<macro>
	filename = "_DKR_Scale&RGB_Batch.ijm";
	path = getDirectory("macros");
	run("Install...", "install="+path+"dkr"+File.separator+filename);
	run("go [q]");
</macro>

<button>
label=crop factory
arg=<macro>
	filename = "_DKR_Click_to_Crop.ijm";
	path = getDirectory("macros");
	run("Install...", "install="+path+"dkr"+File.separator+filename);
	run("go");
</macro>

<button>
label=SaveROIs
arg=<macro>
	filename = "_DKR_Batch_Save_Existing_ROI.ijm";
	path = getDirectory("macros");
	run("Install...", "install="+path+"dkr"+File.separator+filename);
	run("go");
</macro>

<button>
label=Annotate
arg=<macro>
	filename = "_DKR_Hotkey_Annotate_Image.ijm";
	path = getDirectory("macros");
	run("Install...", "install="+path+"dkr"+File.separator+filename);
	run("initialize");
</macro>


</line>
