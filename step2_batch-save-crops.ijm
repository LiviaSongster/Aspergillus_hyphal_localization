// TO RUN: select batch directory for analysis

// GOALS:
// 1) allow user to select ROIs and make crops from a big batch of movies quickly

mainDir = getDirectory("Choose a directory containing your files:"); 
mainList = getFileList(mainDir); 
//newDir = getDirectory("Choose a directory for output:"); 
newDir = mainDir+"Single-hyphae-crops"+File.separator;
File.makeDirectory(newDir);
roiDir = mainDir+"Crop-ROIs"+File.separator;
File.makeDirectory(roiDir);
Dialog.create("Define the image type");
Dialog.addString("Input Image Type:", ".tif"); //default is .tif

// next pull out the values from the dialog box and save them as variables
Dialog.show();
imageType = Dialog.getString();

for (m=0; m<mainList.length; m++) { //clunky, loops thru all items in folder looking for image
	if (endsWith(mainList[m], imageType)) { 
		open(mainDir+mainList[m]); //open image file on the list
		title = getTitle(); //save the title of the movie
		name = substring(title, 0, lengthOf(title)-4);
		checkcrop = roiDir+title+"-RoiSet.zip";
		
		// check if crop already exits
		// if it does not, then run code
		if(File.exists(checkcrop) == 0){
		
		// prompt user to select regions of interest and save them using t shortcut
		setTool("rectangle");
		waitForUser("Manually select ROI(s), press t to save, then click OK"); 

		if (roiManager("Count") > 0){
			// loop thru ROI list and duplicate and save each crop as a tiff, ready for analysis!
			for (n = 0; n < roiManager("count"); n++){
				selectWindow(title); // selects your movie
				roiManager("Select", n);
				run("Duplicate...", "duplicate");
				saveAs("tif", newDir+name+"-"+n+".tif");
        		}
        	
        	selectWindow("ROI Manager");
			run("Select All");
			roiManager("save selected", roiDir+name+"-RoiSet.zip"); // saves the roiset   		
		
			selectWindow("ROI Manager");
			run("Close"); //close ROI manager
		} }
		close("*"); // close all open images
	 }
}