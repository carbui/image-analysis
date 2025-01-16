
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
		selectWindow("C3-"+ imageName); //Select window of the channel number four (pericytes)
		close();
		
		selectWindow("C2-"+ imageName); //Select window of the channel number four (pericytes)
		run("Subtract Background...", "rolling=50"); //subtract background
		run("Despeckle"); //remove little particle noise
		setAutoThreshold("Default dark");
		resetThreshold();
		setAutoThreshold("Otsu dark");
		run("Convert to Mask");
		//dilate in order to close holes in the middle of the vessels, iterating 4 times
		run("Options...", "iterations=4 count=1 black do=Dilate"); 
		run("Options...", "iterations=4 count=1 black do=Erode"); //and erode back 4 times
		setOption("BlackBackground", true);
		run("Skeletonize");
		run("Measure Skeleton Length Tool (1)"); //calculate skeleton lenght
		//run("Analyze Skeleton (2D/3D)", "prune=none show"); //for some reason it doesn´t work, unless the skeletonized
															//images are first saved, closed and reopened. So this macro
															//ends by saving the skeletonized images; use the next macro
															//to run the Analyze Skeleton plugin!
		//selectWindow(file);
		//close();
		
} } 

saveAs("Results_PDXL_skeleton_lenght", "/Users/ca0207bu/Desktop/projects/Stockholm_2/Analysis_20240202/Skeleton/Results_skeleton_lenght_nitrate.txt"); //Save the results in  file


