
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
		selectWindow("C1-"+ imageName); //close the channels I don't need cause imagej has not memory enough
		close();
		selectWindow("C2-"+ imageName);
		close();
		selectWindow("C4-"+ imageName); //Select window of the channel number four (pericytes)
		close();
		
		selectWindow("C3-"+ imageName); //Select window of the channel number three (PDXL)
		run("Subtract Background...", "rolling=10"); //subtract background
		resetThreshold();
		setAutoThreshold("Otsu dark no-reset");
		run("Convert to Mask");
		run("Analyze Particles...", "size=20.00-Infinity show=Masks");
		run("Invert");
		setOption("BlackBackground", true);
		run("Options...", "iterations=4 count=1 black do=Dilate"); //dilate in order to close holes in the middle of the vessels, iterating 4 times
		run("Options...", "iterations=4 count=1 black do=Erode"); //and erode back 4 times
		run("Skeletonize"); //skeletonize
		//run("Measure Skeleton Length Tool (1)"); //skeleton lenght
		run("Analyze Skeleton (2D/3D)", "prune=none show");
		selectWindow(file);
		close();
		
} } 

saveAs("Results_PDXL_skeleton_lenght", "/Users/ca0207bu/Desktop/HALF TIME/Stockholm/Staning 1 images/Results/Results_skeleton_branches.txt"); //Save the results in  file


