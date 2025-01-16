// VESSEL DIAMETER ANALYSIS 

// Adapted from the "Vessel Analysis plugin" 
// Elfarnawany, Mai H., “Signal Processing Methods for Quantitative Power Doppler Microvascular Angiography” (2015). 
// Electronic Thesis and Dissertation Repository. 3106.

// PART 1

// Choose the folder in which all the images are
folder = getDirectory( "Choose a folder") 
filelist = getFileList(folder);

//loop to iterate through all the images in a folder and get the n file from the folder
for (i = 0; i < lengthOf(filelist); i++) {
		file = filelist[i];

// if the 'file' is tif file then open it, open the image filelist[i]
	if (endsWith(file, ".tif")) {
		open(folder + file);
		
		// OPEN IMAGE, MAKE STACK, COMPOSITE, SUBTRACT BACKGROUND AND BINARIZATION 
		
		run("Z Project...", "projection=[Max Intensity]"); //run images to stack
		imageName = getTitle(); //set “imageName” as the original name of each image
		run("Split Channels"); //split the four channels 
		selectWindow("C1-"+ imageName); //close channels I don't need: imagej has not memory enough
		close();
		selectWindow("C3-"+ imageName); //Select window of the channel number three (PDXL)
		close();	// closes the opened images 

		selectWindow("C2-"+ imageName); //Select window of the channel number four (pericytes)
		run("Subtract Background...", "rolling=50"); //subtract background
		run("Despeckle"); //remove little particle noise
		setAutoThreshold("Triangle dark no-reset");
		run("Analyze Particles...", "size=60-Infinity pixel show=Masks overlay");
		run("Convert to Mask");
		//dilate in order to close holes in the middle of the vessels, iterating 4 times
		run("Options...", "iterations=4 count=1 black do=Dilate"); 
		run("Options...", "iterations=4 count=1 black do=Erode"); //and erode back 4 times
		run("Duplicate...", " ");
		duplicate = getTitle();
		
		// Calculate EDM & colour pixels based on "Fire" look-up table
		run("Geometry to Distance Map", "threshold=1");
		processed = getTitle();
		
		// Skeletonize pre-EDM image
		selectWindow(duplicate);
		setOption("BlackBackground", true);
		run("Skeletonize");
		
		// Convert pixel values to 0 (black) or 1 (white)
		run("RGB Color");
		run("8-bit Color", "number=2");
		
		// Multiply pixels of both images to produce skeletonized image of coloured vessels
		imageCalculator("Multiply create 32-bit", duplicate, processed);
		run("Fire");
		intermediate = getTitle();
		
		// Double pixels values (radius values -> diameter values)
		imageCalculator("Add create 32-bit", intermediate, intermediate);
		
		// Final image produced; close previous images
		result = getTitle();
		saveAs("Tiff", folder + result);
		
		close(duplicate); 
		close(processed);
		close(intermediate);
	}
} 



// PART 2


// Choose the folder in which all the images are
folder = getDirectory( "Choose a folder") 
filelist = getFileList(folder);

Dialog.create("Enter dimensions");// Get image dimensions in pixels and mm
Dialog.addNumber("Distance in mm", 0);
Dialog.addNumber("Distance in pixels", 0);
Dialog.show();
mmDist = Dialog.getNumber();
pixelDist = Dialog.getNumber();
conversionFactor = mmDist/pixelDist;

// A for loop to iterate through all the images in a folder and get the nth file from the folder
for (i = 0; i < lengthOf(filelist); i++) {
		file = filelist[i];
		
// if the 'file' is tif file then open it, open the image filelist[i]
	if (endsWith(file, ".tif")) {
		open(folder + file);
		
		result = getTitle();
		// Calculate pixel/mm ratio & set scale based on input
		run("Set Scale...", "distance=" + pixelDist + " known=" + mmDist + " pixel=1 unit=mm");

		// Calculate average diameter of vessel ROI
		do {
	
			selectWindow(result);
	
			do { 
				// Prompt user to select region (default to rectangle selection tool)
				setTool(0);
				beep();
				waitForUser("Select ROI", "Select a vessel segment, then click OK.");
			} while(selectionType() != 0); 
	
	setBatchMode(true); 
	getSelectionCoordinates(x, y);
	startX = x[0];
	startY = y[0];
	endX = x[2];
	endY = y[2];

	var dist=0, count=0, total=0, average=0;

	// Loop through pixels in ROI
	for (v = startY; v <= endY; v++) {
		for (h = startX; h <= endX; h++) {
			dist = getPixel(h,v); 	
			
			// Account for non-black pixels only
			if (dist != 0) {
				count++; 
				total += dist; 
			}
		}
	}

	// Print average diameter 
 	average = (total/count) * conversionFactor;
	setSelectionName(average + "mm");
	
	// Overlay label for selected ROI
	run("Add Selection...");
	run("Labels...", "color=white font=10 show use bold");
	
	setBatchMode(false);

	// Ask user to select another region of interest
	cont = getBoolean("Would you like to calculate the average diameter of another region?");
	
} while(cont)

run("Save");
flatten = getBoolean("Would you like to save a copy of the flattened image?");
if (flatten) {
	setBatchMode(true);
	run("Flatten");
	name = getTitle();
	save(folder + name);
	close(name);
	setBatchMode(false);
}
}
}