// TO RUN: select batch directory for analysis

// GOALS:
// 1) take nd2 or tif image and z project it
// 2) save bmp for easy browsing

mainDir = getDirectory("Choose a directory containing your files:"); 
mainList = getFileList(mainDir); 

Dialog.create("Define the image type");
Dialog.addString("Input Image Type:", ".nd2"); //default is .tif

// next pull out the values from the dialog box and save them as variables
Dialog.show();
imageType = Dialog.getString();

// make sub directory for the analysis
newDir = mainDir+"Output-SumZ"+File.separator;
File.makeDirectory(newDir);

newDir2 = mainDir+"Output-MaxZ"+File.separator;
File.makeDirectory(newDir2);

newDirBMP = mainDir+"Output-MaxZ-RGBbmp"+File.separator;
File.makeDirectory(newDirBMP);

for (m=0; m<mainList.length; m++) { //clunky, loops thru all items in folder looking for image
	if (endsWith(mainList[m], imageType)) { 
		open(mainDir+mainList[m]); //open image file on the list
		
		//run("Slice Keeper", "first=20 last=42 increment=2");
		
		title2 = getTitle(); 
		name = substring(title2, 0, lengthOf(title2)-4);
		// find dimensions of the movie
		getDimensions(width, height, channels, slices, frames);
		// change the micron scale
		Stack.setXUnit("micron");
		// microns per pixel hard coded below, 100X = 0.11
		run("Properties...", "channels=1 slices=1 frames=&slices pixel_width=0.11 pixel_height=0.11 voxel_depth=0.11 frame=[&fps sec]");
		// use number of slices and divide by 2 for number of z slices
		newSlices = slices / 4;
		nchannels = 4;
		run("Stack to Hyperstack...", "order=xyczt(default) channels=&nchannels slices=&newSlices frames=1 display=Grayscale");
		rename(title2);
		run("Duplicate...", "duplicate");
		title = getTitle();
		
		// Z project all channels
		run("Z Project...", "projection=[Sum Slices]");
			
		// save tiff of projection
		saveAs("Tiff", newDir+"SumZ-"+name+".tif");

		selectWindow(title2);
		run("Z Project...", "projection=[Max Intensity]");
		saveAs("Tiff", newDir2+"MaxZ-"+name+".tif");
		title = getTitle();
		
		// also make merged rgb and save as bmp
		selectWindow(title);
		run("Split Channels");
		
		red_title = "C3-"+title;
		selectWindow(red_title);
		run("Grays");
		setMinAndMax(100, 300);
		
		green_title = "C2-"+title;
		selectWindow(green_title);
		run("Grays");
		setMinAndMax(125, 500);
		
		blue_title = "C4-"+title;
		selectWindow(blue_title);
		run("Grays");
		setMinAndMax(200, 3000);
		
		run("Merge Channels...", "c2="+green_title+" c5="+blue_title+" c6="+red_title+" create");
		//run("Merge Channels...", "c2="+green_title+" create");
		run("RGB Color", "frames");
		//run("RGB Color");
		saveAs("bmp", newDirBMP+title+"_maxZ.bmp");
		
		close("*");
	}
}