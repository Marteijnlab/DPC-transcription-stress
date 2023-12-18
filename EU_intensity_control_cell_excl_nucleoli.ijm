// EU_intensity_control_cell_excluding_nucleoli
// EU signal quantification outside nucleoli

minCellSize=1000; //Min cell size in pixels
minNucleoliSize=70; //Min damage size in pixels

print("\\Clear");
print("Minimum cell size = "+minCellSize+" pixels");
print("Minumum nucleolus size = "+minNucleoliSize+" pixels");
print("Area = pixel size of area averaged");
print("Mean = mean intensity of selected area");
print("StdDev = standard deviation of the mean intensity of nucleus without damage");
print("Min, Max = min, max of measured area");


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


//Generating nucleoli mask
selectImage("C3-"+name);
run("Duplicate...", "title=[Temporary Nucleoli Mask]");
run("Smooth");

//Nucleoli Threshold b
setAutoThreshold("Yen dark no-reset");
run("Convert to Mask");
run("Analyze Particles...", "size="+minNucleoliSize+"-Infinity pixel show=Masks exclude");
rename("Nucleoli Mask");
run("Grays");
run("Dilate");
imageCalculator("Subtract create", "Nucleus Mask","Nucleoli Mask");
rename("Outside nucleoli")

//measure global EU intensity
imageCalculator("And create", "Outside nucleoli","C3-"+name);
rename("EU outside nucleoli");
setThreshold(1, 255);
run("Create Selection");
run("Measure");
