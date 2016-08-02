run("Action Bar","/plugins/ActionBar/_AVG_Quant_Bar.ijm");
exit();


<line>

<button>
label=Edit AVG Bar
icon=_DanBar/none
arg=<macro>
	prog = "subl "
	file = "ActionBar/_AVG_Quant_Bar.ijm""
	path = getDirectory("plugins");
	full_name = prog+path+file
	exec(full_name);
</macro>

</line>
<line>

<button>
label=Project
icon=_DanBar/none
arg=<macro>
	filename = "_DKR_ZProject.ijm";
	path = getDirectory("macros");
	run("Install...", "install="+path+filename);
	run("go [z]");
</macro>

</line>
<line>

<button>
label=RBG
icon=_DanBar/none
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

</line>
<line>

<button>
label=Crop and Save
icon=_DanBar/none
arg=<macro>
	filename = "_DKR_CropAndSave.ijm";
	path = getDirectory("macros");
	run("Install...", "install="+path+filename);
	run("go");
</macro>

</line>
<line>

<button>
label=Save Cell ROI
icon=_DanBar/none
arg=<macro>
	filename = "_DKR_Batch_Save_Existing_ROI.ijm";
	path = getDirectory("macros");
	run("Install...", "install="+path+filename);
	run("go");
</macro>

</line>
<line>

<button>
label=Clear Outside
icon=_DanBar/none
arg=run("Clear Outside");

</line>
<line>

<button>
label=Split
icon=_DanBar/none
arg=run("Split Channels");

</line>
<line>

<button>
label=Threshold
icon=_DanBar/none
arg=run("Threshold...");

</line>
<line>

<button>
label=Analyze Particles
icon=_DanBar/none
arg=run("Analyze Particles...", "size=0-Infinity circularity=0.00-1.00 show=Nothing clear add");


</line>
<line>

<button>
label=Renumber ROIs
icon=_DanBar/none
arg=<macro>
	filename = "_DKR_renumber_ROI.ijm";
	path = getDirectory("macros");
	run("Install...", "install="+path+filename);
	run("go");
</macro>

</line>
<line>

<button>
label=Save ROIs
icon=_DanBar/none
arg=<macro>
	filename = "_DKR_Save_ROIs_to_Desktop.ijm";
	path = getDirectory("macros");
	run("Install...", "install="+path+filename);
	run("go");
</macro>

</line>
<line>

<button>
label=AutoROI
icon=_DanBar/none
arg=<macro>
	filename = "_DKR_Batch_Count_ROI.ijm";
	path = getDirectory("macros");
	run("Install...", "install="+path+filename);
	run("go");
</macro>

</line>
<line>

<button>
label=Combine ROI and Measure
icon=_DanBar/none
arg=<macro>
	filename = "_DKR_Batch_ROI_combining.ijm";
	path = getDirectory("macros");
	run("Install...", "install="+path+filename);
	run("go");
</macro>

</line>