// TO RUN: select batch directory for analysis

// GOALS:
// 1) automatically split long stacks into hyperstacks with 3 channels and 1 z plane
// 2) allow user to select ROIs and make crops from a big batch of movies quickly

mainDir = getDirectory("Choose a directory containing your files:"); 
mainList = getFileList(mainDir); 
newDir = getDirectory("Choose a directory for output:"); 
roiDir = getDirectory("Choose a directory for roisets:"); 

Dialog.create("Define the image type");
Dialog.addString("Input Image Type:", ".tif"); //default is .tif

// next pull out the values from the dialog box and save them as variables
Dialog.show();
imageType = Dialog.getString();

for (m=0; m<mainList.length; m++) { //clunky, loops thru all items in folder looking for image
	if (endsWith(mainList[m], imageType)) { 
		open(mainDir+mainList[m]); //open image file on the list
		title = getTitle(); //save the title of the movie

		if (File.exists(roiDir+mainList[m]+"-RoiSet.zip")) {
			roiManager("Open", roiDir+mainList[m]+"-RoiSet.zip");
		}

		if (roiManager("Count") > 0){
			// loop thru ROI list and duplicate and save each crop as a tiff, ready for analysis!
			for (n = 0; n < roiManager("count"); n++){
				selectWindow(title); // selects your movie
				roiManager("Select", n);
				run("Duplicate...", "duplicate");
				newName = getTitle();
				saveAs("tif", newDir+newName);
        		}
        	
			selectWindow("ROI Manager");
			run("Close"); //close ROI manager
		}
		close("*"); // close all open images
	}
}