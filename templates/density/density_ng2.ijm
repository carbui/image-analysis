
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
		selectWindow("C3-"+ imageName);
		close();
		selectWindow(file);
		close();

		
		selectWindow("C4-"+ imageName); //CD13+ cells -- obtain the binary image 
		//close(); //Uncomment if measuring only NG2 total area
		run("Subtract Background...", "rolling=10"); //subtract background
		run("Despeckle"); //remove little particle noise
		resetThreshold();
		setAutoThreshold("Otsu dark no-reset"); //set threshold
		run("Convert to Mask");
		C4 = getTitle();
		
		selectWindow("C2-"+ imageName); //NG2+ cells -- obtain the binary image
		run("Subtract Background...", "rolling=10"); //subtract background
		run("Despeckle"); //remove little particle noise
		resetThreshold();
		setAutoThreshold("Triangle dark no-reset");
		setOption("BlackBackground", true);
		run("Convert to Mask");
		C2 = getTitle();

		run("Set Measurements...", "area_fraction display redirect=None decimal=3");
		imageCalculator("AND create", C4, C2); //UNCOMMENT IF MEASURING COLOCALIZATION
		//selectWindow("Result of C2-MAX_2022dec07_27_48.lif - stroke_t2d_empa_27_slice2_left_1.tif");
		run("Measure"); //measure (limited to thresholded particles)
		close();
		close(C4);
		close(C2);
		
} } 

saveAs("Results_NG2_TOTAL_APRIL", "/Users/ca0207bu/Desktop/HALF TIME/Stockholm/Staning 1 images/STROKE vs SHAM/Results/Results_NG2_TOTAL_APRIL.txt"); //Save the results in text file

