//General instructions after you have saved all the images in TIFF from the previous script. 

//Create one folder: IPSI. Save all the ipsilateral brains in this folder.
//Create another folder: CONTRA. Save all the contralateral brains in this folder. 
//Analyze folders separately
//Every time you run the analysis to the next folder, REMEMBER TO CHANGE PATH at line 42, otherwise the result will be replaced!!!!!!!!!!!!!!
//Open results in Excel. 
//Calculate the percentage of the Ipsi from the corresponding Contra ventral or dorsal striatum.

// Choose the folder in which all the images are
folder = getDirectory( "Choose a folder") 
filelist = getFileList(folder);

// A for loop to iterate through all the images in a folder and get the nth file from the folder
for (i = 0; i < lengthOf(filelist); i++) {
		file = filelist[i];


// if the 'file' is tif file then open it, open the image filelist[i]
	if (endsWith(file, ".tif")) {
		open(folder + file);
		//imageName = getTitle(); //set “imageName” as the original name of each image
		run("Set Measurements...", "mean limit display redirect=None decimal=3");
		waitForUser("NORMALIZE TO BACKGROUND 1", "Select an ROI form Corpus Callosum, then click OK.");
		run("Measure");
		waitForUser("NORMALIZE TO BACKGROUND 2", "Unselect ROI. \nGo to Process --> Math --> Subtract \nWrite the bakground value obtained from the Measure, then click OK.");
		
		waitForUser("VENTRAL STRIATUM", "Select as a ROI Ventral Striatum, then click OK.");
		run("Duplicate..."); //Duplicate the ROI selected. Then press ok.
		rename("Ventral"); 
		run("Measure");
		close();//close ventral image
		
		waitForUser("DORSAL STRIATUM", "Select as a ROI Dorsal Striatum, then click OK.");
		run("Duplicate..."); //Duplicate the ROI selected. Then press ok.
		rename("Dorsal");
		run("Measure");
		close("*"); //close all images
} } 

//REMEMBER TO CHANGE PATH at line 42, otherwise the result will be replaced. !!!!!!!!!!!!!!!!!!!
saveAs("Results_TH", "/copy/the/path/to/ipsi/or/contra/folder/Results_TH.txt"); //Save the results in TEXT file