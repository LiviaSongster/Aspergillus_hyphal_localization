// TO RUN: select batch directory for analysis

// GOALS:
// 1) trace from TIP inwards using segmented line tool, width 20 to 25.
// 2) save intensity measurements from two fluorescent channels

// input must be a single tif with at least 2 channels
// when prompted, change the channel order below.

mainDir = getDirectory("Choose a directory containing your files:"); 
mainList = getFileList(mainDir); 
gfpDir = mainDir+"GFP-Linescan-Results"+File.separator;
File.makeDirectory(gfpDir);
rfpDir = mainDir+"RFP-Linescan-Results"+File.separator;
File.makeDirectory(rfpDir);
roiDir = mainDir+"Linescan-ROIs"+File.separator;
File.makeDirectory(roiDir);

Dialog.create("Define the image type");
Dialog.addString("Input Image Type:", ".tif"); //default is .tif
Dialog.addString("GFP/488 Channel number", "2"); //default is 1
Dialog.addString("RFP/561 Channel number", "3"); //default is 2

// next pull out the values from the dialog box and save them as variables
Dialog.show();
imageType = Dialog.getString();
greenChannel = Dialog.getString();
redChannel = Dialog.getString();

for (m=0; m<mainList.length; m++) { //clunky, loops thru all items in folder looking for image
	if (endsWith(mainList[m], imageType)) { 
		open(mainDir+mainList[m]); //open image file on the list
		title = getTitle(); //save the title of the movie
		run("Enhance Contrast", "saturated=0.35 process_all"); // adjust brightness
		run("Split Channels");
		red_title = "C"+redChannel+"-"+title;
		green_title = "C"+greenChannel+"-"+title;
		name = substring(title, 0, lengthOf(title)-4); // extract name of file without suffix
		
		// prompt user to select regions of interest and save them using t shortcut
		setTool("polyline");
		run("Line Width...", "line=20");
		waitForUser("Start your trace from the hyphal tip, press t to save, then click OK"); 
			
		if (roiManager("Count") > 0){
				selectWindow(green_title); // selects your movie
				// green line first
				roiManager("Select", 0);
				run("Plot Profile");
				Plot.getValues(x, y);
				for (i=0; i<x.length; i++){
     				print(x[i], y[i]);
  				}
				selectWindow("Log");
				saveAs("Text", gfpDir+name+"_gfp_linescan.txt");
				selectWindow("Log");
				run("Close"); //close Log
				
				// red line second from channel 4
				selectWindow(red_title); // selects your movie
				roiManager("Select", 0);
				run("Plot Profile");
				Plot.getValues(x, y);
				for (i=0; i<x.length; i++){
     				print(x[i], y[i]);
  				}
				selectWindow("Log");
				saveAs("Text", rfpDir+name+"_rfp_linescan.txt");
				selectWindow("Log");
				run("Close"); //close Log
				roiManager("Save", roiDir+name+"_line.roi"); // saves the roiset
				   		
        		}
					
			selectWindow("ROI Manager");
			run("Close"); //close ROI manager
		}
		close("*"); // close all open images
	}