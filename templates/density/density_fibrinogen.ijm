
// Choose the folder in which all the images are
folder = getDirectory( "Choose a folder") 
filelist = getFileList(folder);

// A for loop to iterate through all the images in a folder and get the nth file from the folder
for (i = 0; i < lengthOf(filelist); i++) {
		file = filelist[i];


// if the 'file' is tif file then open it, open the image filelist[i]
	if (endsWith(file, ".tif")) {
		open(folder + file);
		run("Z Project...", "projection=[Max Intensity]"); //run images to stack
		run("Subtract Background...", "rolling=50 stack");
		run("Despeckle", "stack");
		imageName = getTitle(); //set “imageName” as the original name of each image
		run("Split Channels"); //split the four channels 
		selectWindow("C3-"+ imageName); //close the channels I don't need cause imagej has not memory enough
		close();
		
		selectWindow("C1-"+ imageName); //fibrin
		resetThreshold();
		setAutoThreshold("RenyiEntropy dark");
		run("Convert to Mask");
		C1 = getTitle();
		
		selectWindow("C2-"+ imageName); //pdxl
		resetThreshold();
		setAutoThreshold("Otsu dark");
		run("Convert to Mask");
		C2 = getTitle();
		
		run("Set Measurements...", "area_fraction limit display redirect=None decimal=3");
		imageCalculator("Subtract create", C1,C2);
		run("Measure"); //measure (limited to thresholded particles)
		//close();
		close(C1);
		close(C2);
		
		
} } 

saveAs("Results_fibrin", "/Users/ca0207bu/Desktop/projects/Stockholm_2/Analysis_20240202/Results_fibrin_vh.txt"); //Save the results in text file
