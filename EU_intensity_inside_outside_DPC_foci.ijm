// EU_intensity_inside_outside_DPC v1-0
// EU signal quantification at DPC foci comparing to global levels 


minCellSize=700; //Min cell size in pixels
minDamageSize=40; //Min damage size in pixels
minNucleoliSize=70; //Min nucleoli size in pixels

print("\\Clear");
print("Minimum cell size = "+minCellSize+" pixels");
print("Minumum damage size = "+minDamageSize+" pixels");
print("Minumum nucleolus size = "+minNucleoliSize+" pixels");
print("Area = area averaged");
print("Mean = mean intensity of selected area");
print("StdDev = standard deviation of the intensity of the selected area");
print("Min, Max = min, max of measured area");
print("First measurement is foci area, second measurement is cell area outside foci and nucleoli");


//Apply basic settings
//run("Close All");
name=getTitle();
//setBatchMode(true);
run("Split Channels");
//run("Set Scale...", "distance=0 known=1 pixel=1 unit=micron global");
run("Set Measurements...", "area mean standard min max limit decimal=2");

//Generating nucleus masks
selectImage("C1-"+name);
run("Fire");
rename("DAPI");
run("Duplicate...", "title=[Temporary Nucleus Mask]");
run("Smooth");

//Nucleus Threshold a
setAutoThreshold("Default dark no-reset");
run("Convert to Mask");
rename("Temp Nucleus Mask");
run("Watershed");
run("Analyze Particles...", "size="+minCellSize+"-Infinity pixel show=Masks exclude");
run("Grays");
rename("Nucleus Mask");
run("Close-");


//Generating damage mask
selectImage("C2-"+name);
run("Duplicate...", "title=[Temporary Damage Mask]");
run("Smooth");

//Damage Threshold b
setAutoThreshold("Yen dark no-reset");
run("Convert to Mask");
run("Analyze Particles...", "size="+minDamageSize+"-Infinity pixel show=Masks exclude");
rename("Damage Mask");
run("Grays");
imageCalculator("Subtract create", "Nucleus Mask","Damage Mask");
rename("Non-Damaged Area");


//Generating nucleoli mask
selectImage("C3-"+name);
run("Duplicate...", "title=[Temporary Nucleoli Mask]");
run("Smooth");

//Nucleoli Threshold c
setAutoThreshold("Yen dark no-reset");
run("Convert to Mask");
run("Analyze Particles...", "size="+minNucleoliSize+"-Infinity pixel show=Masks exclude");
rename("Nucleoli Mask");
run("Grays");
run("Dilate"); 
imageCalculator("Subtract create", "Non-Damaged Area","Nucleoli Mask");
rename("Non-Damaged Area, excl nucleoli")


//remove foci overlapping with nucleoli
imageCalculator("Subtract create", "Damage Mask","Nucleoli Mask");
run("Analyze Particles...", "size="+minDamageSize+"-Infinity pixel show=Masks exclude");
run("Grays");
run("Erode");
run("Erode");
rename("Damaged Area, excl nucleoli")


//measure EU intensity at foci
imageCalculator("And create", "Damaged Area, excl nucleoli","C3-"+name);
rename("EU damage Areas");
setThreshold(1, 255);
run("Create Selection");
run("Measure");

//measure global EU intensity, excluding foci and nucleoli
imageCalculator("And create", "Non-Damaged Area, excl nucleoli","C3-"+name);
rename("EU Outside Areas");
setThreshold(1, 255);
run("Create Selection");
run("Measure");
