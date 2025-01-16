
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
		imageName = getTitle(); //set “imageName” as the original name of each image
		run("Split Channels"); //split the four channels 
		//selectWindow("C1-"+ imageName); //close the channels I don't need cause imagej has not memory enough
		//close();
		selectWindow("C1-"+ imageName);
		close(); 
		selectWindow("C2-"+ imageName); //Select window of the channel number three (PDXL)
		close();	// closes the opened images 

		selectWindow("C3-"+ imageName); //Select window of the channel number four (pericytes)
		run("Subtract Background...", "rolling=50"); //subtract background
		run("Despeckle"); //remove little particle noise
		resetThreshold();
		setAutoThreshold("Otsu dark no-reset"); //set threshold
		run("Options...", "iterations=4 count=1 black do=Dilate"); 
		run("Options...", "iterations=4 count=1 black do=Erode"); //and erode back 4 times
		run("Analyze Particles...", "size=30-Infinity pixel show=Masks overlay");
		run("Measure"); //measure (limited to thresholded particles)
		//close();	
		
		selectWindow(file);
		close();

} } 

saveAs("Results_CD13_nitrate", "/Users/ca0207bu/Desktop/projects/Stockholm_2/Analysis_20240202/CD13_density/CD13_density_vehicle.txt"); //Save the results in excel file


