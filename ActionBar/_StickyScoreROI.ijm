run("Action Bar","/plugins/ActionBar/_StickyScoreROI.ijm");
exit();

<sticky>
<line>

<button>
label=Save ROI
icon=_StickyBarDemo1/viewmag+.png
arg=<macro>
	roiManager("Add");
	i = roiManager("count");
	roiManager("select",i-1);
	roiManager("Rename", "cell"+i);
	
	setResult("Label", nResults, "cell"+i);
	updateResults();
	setTool("freehand");
</macro>
</line>

<line>
<button>
label=Draw
icon=_DanBar/none
arg=<macro>
	setTool("freehand");
</macro>
<button>
label=Hand
icon=_DanBar/none
arg=<macro>
	setTool("hand");
</macro>
</line>

<line>
<button>
label=zoom -
icon=_DanBar/none
arg=<macro>
	run("Out [-]");
</macro>
<button>
label=zoom +
icon=_DanBar/none
arg=<macro>
	run("In [+]");
</macro>
</line>

<line>
<button>
label=1
icon=_DanBar/none
arg=<macro>
	Stack.getActiveChannels(string);
	first = substring(string,0,1);
	second = substring(string,1,2);
	third = substring(string,2,3);

	if (first=="0")
		first="1";
	else if (first=="1")
		first="0";

	Stack.setActiveChannels(first+second+third);
</macro>

<button>
label=2
icon=_DanBar/none
arg=<macro>
	Stack.getActiveChannels(string);
	first = substring(string,0,1);
	second = substring(string,1,2);
	third = substring(string,2,3);

	if (second=="0")
		second="1";
	else if (second=="1")
		second="0";

	Stack.setActiveChannels(first+second+third);
</macro>

<button>
label=3
icon=_DanBar/none
arg=<macro>
	Stack.getActiveChannels(string);
	first = substring(string,0,1);
	second = substring(string,1,2);
	third = substring(string,2,3);

	if (third=="0")
		third="1";
	else if (third=="1")
		third="0";

	Stack.setActiveChannels(first+second+third);
</macro>

</line>






<line>
<button>
label=Prev ROI
icon=_AnimationBar/previous.png
arg=<macro>
	i = roiManager("index");
	if(i>0){roiManager("select", i-1);}
</macro>

<button>
label=Next ROI
icon=_AnimationBar/next.png
arg=<macro>
	i = roiManager("index");
	if(roiManager("count")>i+1){roiManager("select", i+1);}
</macro>
</line>
______________________________
<line>
<button>
label=AVG
icon=_DanBar/none
arg=<macro>
	category="AVG";
	i = roiManager("index");
	j = i+1;
	if(getResultLabel(i)=="cell"+j){
		oldvalue = getResult(category, i);
		if(oldvalue==0){
			setResult(category,i,1);
			updateResults();}
		else if(oldvalue==1){
			setResult(category,i,0);
			updateResults();}	
		else{setResult(category,i,1);updateResults();}
	}		
	else{showMessage("something is messed up");}
</macro>
<button>
label=SG
icon=_DanBar/none
arg=<macro>
	category="SG";
	i = roiManager("index");
	j = i+1;
	if(getResultLabel(i)=="cell"+j){
		oldvalue = getResult(category, i);
		if(oldvalue==0){
			setResult(category,i,1);
			updateResults();}
		else if(oldvalue==1){
			setResult(category,i,0);
			updateResults();}	
		else{setResult(category,i,1);updateResults();}
	}		
	else{showMessage("something is messed up");}
</macro>
</line>
______________________________
<line>
<button>
label=Factory
icon=_DanBar/none
arg=<macro>
	category="Factory";
	i = roiManager("index");
	j = i+1;
	if(getResultLabel(i)=="cell"+j){
		oldvalue = getResult(category, i);
		if(oldvalue==0){
			setResult(category,i,1);
			updateResults();}
		else if(oldvalue==1){
			setResult(category,i,0);
			updateResults();}	
		else{setResult(category,i,1);updateResults();}
	}		
	else{showMessage("something is messed up");}
</macro>
<button>
label=VACV Particle
icon=_DanBar/none
arg=<macro>
	category="VACV Particle";
	i = roiManager("index");
	j = i+1;
	if(getResultLabel(i)=="cell"+j){
		oldvalue = getResult(category, i);
		if(oldvalue==0){
			setResult(category,i,1);
			updateResults();}
		else if(oldvalue==1){
			setResult(category,i,0);
			updateResults();}	
		else{setResult(category,i,1);updateResults();}
	}		
	else{showMessage("something is messed up");}
</macro>
</line>
______________________________
<line>
<button>
label=Apoptotic
icon=_DanBar/none
arg=<macro>
	category="Apoptotic";
	i = roiManager("index");
	j = i+1;
	if(getResultLabel(i)=="cell"+j){
		oldvalue = getResult(category, i);
		if(oldvalue==0){
			setResult(category,i,1);
			updateResults();}
		else if(oldvalue==1){
			setResult(category,i,0);
			updateResults();}	
		else{setResult(category,i,1);updateResults();}
	}		
	else{showMessage("something is messed up");}
</macro>
<button>
label=Abnormal
icon=_DanBar/none
arg=<macro>
	category="Abnormal";
	i = roiManager("index");
	j = i+1;
	if(getResultLabel(i)=="cell"+j){
		oldvalue = getResult(category, i);
		if(oldvalue==0){
			setResult(category,i,1);
			updateResults();}
		else if(oldvalue==1){
			setResult(category,i,0);
			updateResults();}	
		else{setResult(category,i,1);updateResults();}
	}		
	else{showMessage("something is messed up");}
</macro>
</line>
______________________________
<line>
<button>
label=Mitotic
icon=_DanBar/none
arg=<macro>
	category="Mitotic";
	i = roiManager("index");
	j = i+1;
	if(getResultLabel(i)=="cell"+j){
		oldvalue = getResult(category, i);
		if(oldvalue==0){
			setResult(category,i,1);
			updateResults();}
		else if(oldvalue==1){
			setResult(category,i,0);
			updateResults();}	
		else{setResult(category,i,1);updateResults();}
	}		
	else{showMessage("something is messed up");}
</macro>
<button>
label=Nice Image
icon=_DanBar/none
arg=<macro>
	category="Nice Image";
	i = roiManager("index");
	j = i+1;
	if(getResultLabel(i)=="cell"+j){
		oldvalue = getResult(category, i);
		if(oldvalue==0){
			setResult(category,i,1);
			updateResults();}
		else if(oldvalue==1){
			setResult(category,i,0);
			updateResults();}	
		else{setResult(category,i,1);updateResults();}
	}		
	else{showMessage("something is messed up");}
</macro>
</line>
______________________________
<line>
<button>
label=Inspect
icon=_DanBar/none
arg=<macro>
	category="Needs Further Inspection";
	i = roiManager("index");
	j = i+1;
	if(getResultLabel(i)=="cell"+j){
		oldvalue = getResult(category, i);
		if(oldvalue==0){
			setResult(category,i,1);
			updateResults();}
		else if(oldvalue==1){
			setResult(category,i,0);
			updateResults();}	
		else{setResult(category,i,1);updateResults();}
	}		
	else{showMessage("something is messed up");}
</macro>
<button>
label=___
icon=_DanBar/none
arg=<macro>
	category="___";
	i = roiManager("index");
	j = i+1;
	if(getResultLabel(i)=="cell"+j){
		oldvalue = getResult(category, i);
		if(oldvalue==0){
			setResult(category,i,1);
			updateResults();}
		else if(oldvalue==1){
			setResult(category,i,0);
			updateResults();}	
		else{setResult(category,i,1);updateResults();}
	}		
	else{showMessage("something is messed up");}
</macro>
</line>

______________
<line>
<button>
label=initialize
icon=_DanBar/none
arg=<macro>
	bool = getBoolean("Are you sure you want to erase the ROI manager and results table");
	if(bool){
		run("ROI Manager...");
		roiManager("reset");
		run("Clear Results");
		run("Set Measurements...", "  AVG SG factory particle display redirect=None decimal=2");
		updateResults();}
	else{}	
	roiManager("Show All");
</macro>
</line>