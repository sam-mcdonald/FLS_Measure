//FLS Measure for phenotyping frogeye leaf spot of soybean
//Requires Barcode_Codec (https://github.com/PCCV/Barcode_Codec/tree/v1.0.1)
//Requires ImageJ 1.45f or newer
//Quick installation: 
//	1. Save this script as "FLS Measure.ijm"
// 	2. Copy "FLS Measure.ijm" to the ImageJ/FIJI plugins folder
//	3. Restart ImageJ/FIJI
//	4. "FLS Measure" will appear in the ImageJ Plugins menu

  
function batch_nobarcode(input, output, filename){
	close("*");
	roiManager("reset");
	open(input + filename);
	print("Running " + filename);

	//Compress image
	run("Scale...", "x=- y=- width=1500 height= interpolation=Bilinear average create");
	rename("0.jpg");
	
	//Measure leaf area
	run("HSB Stack");
	setSlice(1);
	run("Delete Slice");
	setSlice(2);
	run("Delete Slice");
	setThreshold(85, 255);
	setOption("BlackBackground", true);
	run("Convert to Mask", "method=Default background=Light calculate black");
	run("Median...", "radius=4 slice");
	run("Options...", "iterations=9 count=1 black pad do=Open");
	setThreshold(1, 255);
	roiManager("reset");
	run("Create Selection");
	roiManager("add");
	if (roiManager("count") != 1) {
		exit("Failed to isolate leaf" + filename);
	}
	roiManager("Select", 0);
	run("Measure");
	selectWindow("Results");
	leafarea=(""+getResult("Area")+"");
	run("Close");
	selectWindow(filename);
	run("Scale...", "x=- y=- width=1500 height= interpolation=Bilinear average create");
	roiManager("Set Color", "red");
	roiManager("Show All without labels");
	run("Flatten");	
	saveAs("JPEG", output + filename);

	//Measure lesions
	open(input + filename );
	run("Scale...", "x=- y=- width=1500 height= interpolation=Bilinear average create");
	run("Duplicate...", "title=3.jpg");
	run("Lab Stack");
	run("Delete Slice");
	run("Next Slice [>]");
	run("Delete Slice");
	roiManager("Select", 0);
	run("Clear Outside", "slice");
	run("Enhance Contrast", "saturated=0.35");
	setAutoThreshold("Default dark stack");
	setThreshold(-8, 100); //origignally -8. May have to adjust for each set 
	run("Convert to Mask");
	roiManager("reset");
	run("Clear Results");
	run("Analyze Particles...", "size=16-Infinity circularity=0.30-Infinity show=[Count Masks] display clear include add slice");
	lesionarea=0;
	lesionnumber=0;
	for(i=0; i<nResults; i++) {
    	lesionarea += getResult("Area", i);
    	lesionnumber = i;
    }
    if (lesionarea != 0) {
		lesionnumber = lesionnumber+1;
	}
	if (roiManager("count") == 0) { //creates an empty results table to save if there are no lesions
		makeRectangle(1, 1, 2, 2);
		run("Measure");
		selectWindow("Results");
		Table.deleteRows(0, 0);
	}
	
	selectWindow("Results");
	saveAs("TXT", output + filename + "_lesion-results");

	//Save overlay image
	open(output + filename);
	roiManager("Set Color", "yellow");
	roiManager("Show All with labels");
	run("Flatten");

	//Print barcode on image
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	    TimeString ="";
	    if (dayOfMonth<10) {TimeString = TimeString+"0";}
	    TimeString = TimeString+dayOfMonth+"-"+MonthNames[month]+"-"+year+" ";
	    if (hour<10) {TimeString = TimeString+"0";}
	    TimeString = TimeString+hour+":";
	    if (minute<10) {TimeString = TimeString+"0";}
	    TimeString = TimeString+minute+":";
	    if (second<10) {TimeString = TimeString+"0";}
	    TimeString = TimeString+second;	
	fontSize = 15;
	x = 15;
	y = fontSize+5;
	setColor("Black");
	setFont("Monospaced", fontSize, "antialiased");
	Overlay.drawString(filename, x, y);
	y = y + fontSize + 5;
	Overlay.drawString(TimeString, x, y);//
	Overlay.show;//
	Overlay.show;
	
	saveAs("JPEG", output + filename);

	//add data to a next tow in combined data table
	selectWindow("combinedresults");
	percentlesionarea = d2s(parseInt(lesionarea)/parseInt(leafarea),8);
	Table.set("name", rownum, filename);
	Table.set("leafarea", rownum, leafarea);
	Table.set("lesionarea", rownum, lesionarea);
	Table.set("percentlesionarea", rownum, percentlesionarea);
	Table.set("lesionnumber", rownum, lesionnumber);
}

function batch_barcode(input, output, filename){
	close("*");
	
	////Rename file as barcode////
	open(input + filename);
	setBatchMode(false);
	run("Barcode Codec"); //requires Barcode Codec packaage from https://github.com/PCCV/Barcode_Codec
	selectWindow("Decoded Text");
	barcode = getInfo("window.contents");
	File.rename(input + filename, input + barcode + ".jpg");
	close("Decoded Text");
	setBatchMode(true);
	close("*");
	roiManager("reset");
	open(input + barcode + ".jpg");
	print("Running " + barcode);

	//Compress image
	run("Scale...", "x=- y=- width=1500 height= interpolation=Bilinear average create");
	rename("0.jpg");
	
	//Measure leaf area
	run("HSB Stack");
	setSlice(1);
	run("Delete Slice");
	setSlice(2);
	run("Delete Slice");
	setThreshold(85, 255);
	setOption("BlackBackground", true);
	run("Convert to Mask", "method=Default background=Light calculate black");
	run("Median...", "radius=4 slice");
	run("Options...", "iterations=9 count=1 black pad do=Open");
	setThreshold(1, 255);
	roiManager("reset");
	run("Create Selection");
	roiManager("add");
	if (roiManager("count") != 1) {
		exit("Failed to isolate leaf" + barcode);
	}
	roiManager("Select", 0);
	run("Measure");
	selectWindow("Results");
	leafarea=(""+getResult("Area")+"");
	run("Close");
	selectWindow(barcode + ".jpg");
	run("Scale...", "x=- y=- width=1500 height= interpolation=Bilinear average create");
	roiManager("Set Color", "red");
	roiManager("Show All without labels");
	run("Flatten");	
	saveAs("JPEG", output + barcode + ".jpg");

	//Measure lesions
	open(input + barcode + ".jpg");
	run("Scale...", "x=- y=- width=1500 height= interpolation=Bilinear average create");
	run("Duplicate...", "title=3.jpg");
	run("Lab Stack");
	run("Delete Slice");
	run("Next Slice [>]");
	run("Delete Slice");
	roiManager("Select", 0);
	run("Clear Outside", "slice");
	run("Enhance Contrast", "saturated=0.35");
	setAutoThreshold("Default dark stack");
	setThreshold(-8, 100); //origignally -8. May have to adjust for each set 
	run("Convert to Mask");
	roiManager("reset");
	run("Clear Results");
	run("Analyze Particles...", "size=16-Infinity circularity=0.30-Infinity show=[Count Masks] display clear include add slice");
	lesionarea=0;
	lesionnumber=0;
	for(i=0; i<nResults; i++) {
    	lesionarea += getResult("Area", i);
    	lesionnumber = i;
    }
    if (lesionarea != 0) {
		lesionnumber = lesionnumber+1;
	}
	if (roiManager("count") == 0) { //creates an empty results table to save if there are no lesions
		makeRectangle(1, 1, 2, 2);
		run("Measure");
		selectWindow("Results");
		Table.deleteRows(0, 0);
	}
	
	selectWindow("Results");
	saveAs("TXT", output + barcode + "_lesion-results");

	//Save overlay image
	open(output + barcode + ".jpg");
	roiManager("Set Color", "yellow");
	roiManager("Show All with labels");
	run("Flatten");

	//Print barcode and tiemstamp on image	
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	    TimeString ="";
	    if (dayOfMonth<10) {TimeString = TimeString+"0";}
	    TimeString = TimeString+dayOfMonth+"-"+MonthNames[month]+"-"+year+" ";
	    if (hour<10) {TimeString = TimeString+"0";}
	    TimeString = TimeString+hour+":";
	    if (minute<10) {TimeString = TimeString+"0";}
	    TimeString = TimeString+minute+":";
	    if (second<10) {TimeString = TimeString+"0";}
	    TimeString = TimeString+second;
	fontSize = 15;
	x = 15;
	y = fontSize+5;
	setColor("Black");
	setFont("Monospaced", fontSize, "antialiased");
	Overlay.drawString(barcode, x, y);
	Overlay.show;
	y = y + fontSize + 5;
	Overlay.drawString(TimeString, x, y);
	Overlay.show;
	saveAs("JPEG", output + barcode);

	//add data to a next tow in combined data table
	selectWindow("combinedresults");
	percentlesionarea = d2s(parseInt(lesionarea)/parseInt(leafarea),8);
	Table.set("name", rownum, barcode);
	Table.set("leafarea", rownum, leafarea);
	Table.set("lesionarea", rownum, lesionarea);
	Table.set("percentlesionarea", rownum, percentlesionarea);
	Table.set("lesionnumber", rownum, lesionnumber);
}

function single_nobarcode(){
	close("*");
	close("ROI Manager");
	close("Results");
	
	setBatchMode(false);
	path = File.openDialog("Select a File");
	open(path);
	
	filename = getTitle();
	
	roiManager("reset");
	run("Scale...", "x=- y=- width=1500 height= interpolation=Bilinear average create");
	rename("0.jpg");
		
	//Measure leaf area
	run("HSB Stack");
	setSlice(1);
	run("Delete Slice");
	setSlice(2);
	run("Delete Slice");
	Dialog.create("Leaf Segmentation");
	Dialog.addSlider("Threnshold value:", 0, 255, 85);
	Dialog.addSlider("Median filter radius:", 0, 20, 4);
	Dialog.addSlider("Petiole width:", 0, 40, 9);
	Dialog.show();
	leafminthreshold = Dialog.getNumber();
	medianradius = Dialog.getNumber();
	petiolesize = Dialog.getNumber();
	setThreshold(leafminthreshold, 255);
	setOption("BlackBackground", true);
	run("Convert to Mask", "method=Default background=Light calculate black");
	run("Median...", "radius=medianradius slice");
	run("Options...", "iterations=petiolesize count=1 black pad do=Open");
	setThreshold(1, 255);
	roiManager("reset");
	run("Create Selection");
	roiManager("add");
	run("Measure");
	selectWindow("Results");
	leafarea=(""+getResult("Area")+"");
	selectWindow("0.jpg");
	close();
	selectWindow(filename);
	run("Scale...", "x=- y=- width=1500 height= interpolation=Bilinear average create");
	roiManager("Set Color", "red");
	roiManager("Show All without labels");
	run("Flatten");
	rename("result-image");
	
	//Measure lesion area
	selectWindow(filename);
	run("Scale...", "x=- y=- width=1500 height= interpolation=Bilinear average create");
	run("Duplicate...", "title=3.jpg");
	run("Lab Stack");
	run("Delete Slice");
	selectWindow("3.jpg");
	run("Next Slice [>]");
	run("Delete Slice");
	roiManager("Select", 0);
	run("Clear Outside", "slice");
	Dialog.create("Lesion Segmentation");
	Dialog.addSlider("Threnshold value:", -100, 100, -8);
	Dialog.addSlider("Minimum size:", 0, 2000, 16);
	Dialog.addSlider("Minimum circularity:", 0.0, 1.0, 0.30);
	Dialog.show();
	minthreshold = Dialog.getNumber();
	minsize = Dialog.getNumber();
	mincircularity = Dialog.getNumber();
	run("Enhance Contrast", "saturated=0.35");
	setAutoThreshold("Default dark stack");
	setThreshold(minthreshold, 100);
	run("Convert to Mask");
	roiManager("reset");
	run("Clear Results");
	run("Analyze Particles...", "size=minsize-Infinity circularity=mincircularity-Infinity show=[Count Masks] display clear add slice");
	lesionarea=0;
		lesionnumber=0;
		for(i=0; i<nResults; i++) {
	    	lesionarea += getResult("Area", i);
	    	lesionnumber = i;
	    }
	    if (lesionarea != 0) {
			lesionnumber = lesionnumber+1;
		}
		if (roiManager("count") == 0) { //creates an empty results table to save if there are no lesions
			makeRectangle(1, 1, 2, 2);
			run("Measure");
			selectWindow("Results");
			Table.deleteRows(0, 0);
		}
	selectWindow("3.jpg");
	close();
	selectWindow("Count Masks of 3.jpg");
	close();
	selectWindow("result-image");
	roiManager("Set Color", "yellow");
	roiManager("Show All with labels");
	run("Flatten");
	
	percentlesionarea = d2s(parseInt(lesionarea)/parseInt(leafarea),8);
	print("name= "+filename + "	Leaf Area= "+leafarea+ "	Lesion Area= "+lesionarea +  "	Percent Lesion Area= "+percentlesionarea +"	Lesion Number= "+lesionnumber);
	selectWindow("result-image-1");
	close();
	selectWindow(substring(filename,0,lastIndexOf(filename, "."))+"-1.jpg");
	close();
	
	//Print barcode and tiemstamp on image
	selectWindow("result-image");
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	    TimeString ="";
	    if (dayOfMonth<10) {TimeString = TimeString+"0";}
	    TimeString = TimeString+dayOfMonth+"-"+MonthNames[month]+"-"+year+" ";
	    if (hour<10) {TimeString = TimeString+"0";}
	    TimeString = TimeString+hour+":";
	    if (minute<10) {TimeString = TimeString+"0";}
	    TimeString = TimeString+minute+":";
	    if (second<10) {TimeString = TimeString+"0";}
	    TimeString = TimeString+second;
	fontSize = 15;
	x = 15;
	y = fontSize+5;
	setColor("Black");
	setFont("Monospaced", fontSize, "antialiased");
	Overlay.drawString(filename, x, y);
	Overlay.show;
	y = y + fontSize + 5;
	Overlay.drawString(TimeString, x, y);
	Overlay.show;
	run("Flatten");
	selectWindow(substring(filename,0,lastIndexOf(filename, "."))+"-2.jpg");
	close();
	selectWindow("result-image-1");
	
	saveif = getBoolean("Would you like to save result image and lesion table?");
	if(saveif == 1){
		input=substring(path,0,lastIndexOf(path, "/"))+"/";
		File.makeDirectory(input + "results/");
		outputdir = input + "results/";
		selectWindow("result-image-1");
		saveAs("JPEG", outputdir + filename);
		selectWindow("Results");
		saveAs("TXT", outputdir + filename + "_lesion-results");
		selectWindow("Log");

		//create a new data table to store and save data from all images
		a=Array.getSequence(1);
		Table.create("combinedresults");
		Table.setColumn("numbers", a);
		Table.setColumn("name");
		Table.setColumn("leafarea");
		Table.setColumn("lesionarea");
		Table.setColumn("percentlesionarea");
		Table.setColumn("lesionnumber");
		Table.deleteColumn("numbers");

		selectWindow("combinedresults");
		Table.set("name", 0, filename);
		Table.set("leafarea", 0, leafarea);
		Table.set("lesionarea", 0, lesionarea);
		Table.set("percentlesionarea", 0, percentlesionarea);
		Table.set("lesionnumber", 0, lesionnumber);
		saveAs("combinedresults", outputdir + filename + "results.csv");
		
		print("Saved in "+ outputdir);
	}

	single_repeat = getBoolean("Would you like to analyze another imgae?");
	if(single_repeat == 1){
		single_nobarcode();
		}
		else {
			close("*");
			exit();
		}

}

function single_barcode(){
	close("*");
	close("ROI Manager");
	close("Results");
	
	setBatchMode(false);
	path = File.openDialog("Select a File");
	open(path);
	
	run("Barcode Codec");
	selectWindow("Decoded Text");
	barcode = getInfo("window.contents");
	rename(barcode + ".jpg");
	close("Decoded Text");
	filename = getTitle();
	
	roiManager("reset");
	run("Scale...", "x=- y=- width=1500 height= interpolation=Bilinear average create");
	rename("0.jpg");
		
	//Measure leaf area
	run("HSB Stack");
	setSlice(1);
	run("Delete Slice");
	setSlice(2);
	run("Delete Slice");
	Dialog.create("Leaf Segmentation");
	Dialog.addSlider("Threnshold value:", 0, 255, 85);
	Dialog.addSlider("Median filter radius:", 0, 20, 4);
	Dialog.addSlider("Petiole width:", 0, 40, 9);
	Dialog.show();
	leafminthreshold = Dialog.getNumber();
	medianradius = Dialog.getNumber();
	petiolesize = Dialog.getNumber();
	setThreshold(leafminthreshold, 255);
	setOption("BlackBackground", true);
	run("Convert to Mask", "method=Default background=Light calculate black");
	run("Median...", "radius=medianradius slice");
	run("Options...", "iterations=petiolesize count=1 black pad do=Open");
	setThreshold(1, 255);
	roiManager("reset");
	run("Create Selection");
	roiManager("add");
	run("Measure");
	selectWindow("Results");
	leafarea=(""+getResult("Area")+"");
	selectWindow("0.jpg");
	close();
	selectWindow(filename);
	run("Scale...", "x=- y=- width=1500 height= interpolation=Bilinear average create");
	roiManager("Set Color", "red");
	roiManager("Show All without labels");
	run("Flatten");
	rename("result-image");
	
	//Measure lesion area
	selectWindow(filename);
	run("Scale...", "x=- y=- width=1500 height= interpolation=Bilinear average create");
	run("Duplicate...", "title=3.jpg");
	run("Lab Stack");
	run("Delete Slice");
	selectWindow("3.jpg");
	run("Next Slice [>]");
	run("Delete Slice");
	roiManager("Select", 0);
	run("Clear Outside", "slice");
	Dialog.create("Lesion Segmentation");
	Dialog.addSlider("Threnshold value:", -100, 100, -8);
	Dialog.addSlider("Minimum size:", 0, 2000, 16);
	Dialog.addSlider("Minimum circularity:", 0.0, 1.0, 0.30);
	Dialog.show();
	minthreshold = Dialog.getNumber();
	minsize = Dialog.getNumber();
	mincircularity = Dialog.getNumber();
	run("Enhance Contrast", "saturated=0.35");
	setAutoThreshold("Default dark stack");
	setThreshold(minthreshold, 100);
	run("Convert to Mask");
	roiManager("reset");
	run("Clear Results");
	run("Analyze Particles...", "size=minsize-Infinity circularity=mincircularity-Infinity show=[Count Masks] display clear add slice");
	lesionarea=0;
		lesionnumber=0;
		for(i=0; i<nResults; i++) {
	    	lesionarea += getResult("Area", i);
	    	lesionnumber = i;
	    }
	    if (lesionarea != 0) {
			lesionnumber = lesionnumber+1;
		}
		if (roiManager("count") == 0) { //creates an empty results table to save if there are no lesions
			makeRectangle(1, 1, 2, 2);
			run("Measure");
			selectWindow("Results");
			Table.deleteRows(0, 0);
		}
	selectWindow("3.jpg");
	close();
	selectWindow("Count Masks of 3.jpg");
	close();
	selectWindow("result-image");
	roiManager("Set Color", "yellow");
	roiManager("Show All with labels");
	run("Flatten");
	
	percentlesionarea = d2s(parseInt(lesionarea)/parseInt(leafarea),8);
	print("name= "+barcode + "	Leaf Area= "+leafarea+ "	Lesion Area= "+lesionarea +  "	Percent Lesion Area= "+percentlesionarea +"	Lesion Number= "+lesionnumber);
	selectWindow("result-image-1");
	close();
	selectWindow(substring(filename,0,lastIndexOf(filename, "."))+"-1.jpg");
	close();
	
	//Print barcode and tiemstamp on image
	selectWindow("result-image");
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	    TimeString ="";
	    if (dayOfMonth<10) {TimeString = TimeString+"0";}
	    TimeString = TimeString+dayOfMonth+"-"+MonthNames[month]+"-"+year+" ";
	    if (hour<10) {TimeString = TimeString+"0";}
	    TimeString = TimeString+hour+":";
	    if (minute<10) {TimeString = TimeString+"0";}
	    TimeString = TimeString+minute+":";
	    if (second<10) {TimeString = TimeString+"0";}
	    TimeString = TimeString+second;
	fontSize = 15;
	x = 15;
	y = fontSize+5;
	setColor("Black");
	setFont("Monospaced", fontSize, "antialiased");
	Overlay.drawString(barcode, x, y);
	Overlay.show;
	y = y + fontSize + 5;
	Overlay.drawString(TimeString, x, y);
	Overlay.show;
	run("Flatten");
	selectWindow(substring(filename,0,lastIndexOf(filename, "."))+"-2.jpg");
	close();
	selectWindow("result-image-1");
	
	saveif = getBoolean("Would you like to save result image and lesion table?");
	if(saveif == 1){
		input=substring(path,0,lastIndexOf(path, "/"))+"/";
		File.makeDirectory(input + "results/");
		outputdir = input + "results/";
		selectWindow("result-image-1");
		saveAs("JPEG", outputdir + barcode);
		selectWindow("Results");
		saveAs("TXT", outputdir + barcode + "_lesion-results");
		selectWindow("Log");

		//create a new data table to store and save data from all images
		a=Array.getSequence(1);
		Table.create("combinedresults");
		Table.setColumn("numbers", a);
		Table.setColumn("name");
		Table.setColumn("leafarea");
		Table.setColumn("lesionarea");
		Table.setColumn("percentlesionarea");
		Table.setColumn("lesionnumber");
		Table.deleteColumn("numbers");

		selectWindow("combinedresults");
		Table.set("name", 0, barcode);
		Table.set("leafarea", 0, leafarea);
		Table.set("lesionarea", 0, lesionarea);
		Table.set("percentlesionarea", 0, percentlesionarea);
		Table.set("lesionnumber", 0, lesionnumber);
		saveAs("combinedresults", outputdir + barcode + "results.csv");
		
		print("Saved in "+ outputdir);
	}

	single_repeat = getBoolean("Would you like to analyze another imgae?");
	if(single_repeat == 1){
		single_barcode();
		}
		else {
			close("*");
			exit();
		}

}

MonthNames = newArray("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
DayNames = newArray("Sun", "Mon","Tue","Wed","Thu","Fri","Sat");

//User select single or batch process and w/o barcode
types = newArray("Batch Process Images", "Process Single Image");
Dialog.create("Frogeye Measure");
Dialog.addChoice("Type:", types);
Dialog.addCheckbox("Barcodes?", true);
Dialog.show();
type = Dialog.getChoice();
decode = Dialog.getCheckbox();
if (decode)
	if (type == "Batch Process Images"){
		input = getDirectory("Input Directory");
		starttime = getTime();
		list = getFileList(input);
		n = list.length;
		
		outputDir = input + "results/";
		File.makeDirectory(outputDir);
		output = input + "results/";
		
		setBatchMode(true);
		a=Array.getSequence(n); //sequence of numbers from 1:n
		
		run("Set Measurements...", "area redirect=None decimal=3");
		print("\\Clear");
		
		//create a new data table to store and save data from all images
		Table.create("combinedresults");
		Table.setColumn("numbers", a);
		Table.setColumn("name");
		Table.setColumn("leafarea");
		Table.setColumn("lesionarea");
		Table.setColumn("percentlesionarea");
		Table.setColumn("lesionnumber");
		Table.deleteColumn("numbers");
		rownum=0;
		
		print("Beginning analysis of " + n + " files");
		
		for (i = 0; i < list.length; i++){
			if (endsWith(list[i], ".jpg")) {
				rownum=rownum+1; //image number to save in correct row of combinedresults table
				batch_barcode(input, output, list[i]);
			}
		}
		
		//save table with all data
		selectWindow("combinedresults");
		Table.deleteRows(0, 0);
		saveAs("combinedresults", output + "combined_results.csv");
		run("Close");
		
		
		//information on analysis time
		deltatime = ((getTime() - starttime)/1000);
		print(n + " images processed" + 
		"\nTime to process: " + deltatime +" s" + 
		"\nTime per image: " + deltatime/(n) +" s");
		selectWindow("Log");
		saveAs("TXT", output + "image_analysis_analytics");
		waitForUser("Analysis complete. Results saved in " + output + "\n" + n + " images processed" + 
		"\nTime to process: " + deltatime +" s" + 
		"\nTime per image: " + deltatime/(n) +" s" + 
		"\nThis information saved with results.");
		
		selectWindow("Log");
		run("Close");
		selectWindow("Results");
		run("Close");
	}
	else{
		single_barcode();
		close("*");
	}
else
 if (type == "Batch Process Images"){
		input = getDirectory("Input Directory");
		starttime = getTime();
		list = getFileList(input);
		n = list.length;
		
		outputDir = input + "results/";
		File.makeDirectory(outputDir); //Turn this line on the first time running for a set
		output = input + "results/";
		
		setBatchMode(true);
		a=Array.getSequence(n); //sequence of numbers from 1:n
		
		run("Set Measurements...", "area redirect=None decimal=3");
		print("\\Clear");
		
		//create a new data table to store and save data from all images
		Table.create("combinedresults");
		Table.setColumn("numbers", a);
		Table.setColumn("name");
		Table.setColumn("leafarea");
		Table.setColumn("lesionarea");
		Table.setColumn("percentlesionarea");
		Table.setColumn("lesionnumber");
		Table.deleteColumn("numbers");
		rownum=0;
		
		print("Beginning analysis of " + n + " files");
		
		for (i = 0; i < list.length; i++){
			if (endsWith(list[i], ".jpg")) {
				rownum=rownum+1; //image number to save in correct row of combinedresults table
				batch_nobarcode(input, output, list[i]);
			}
		}
		
		//Save table with all data
		selectWindow("combinedresults");
		Table.deleteRows(0, 0);
		saveAs("combinedresults", output + "combined_results.csv");
		run("Close");
		
		
		//Information on analysis time
		deltatime = ((getTime() - starttime)/1000);
		print(n + " images processed" + 
		"\nTime to process: " + deltatime +" s" + 
		"\nTime per image: " + deltatime/(n) +" s");
		selectWindow("Log");
		saveAs("TXT", output + "image_analysis_analytics");
		waitForUser("Analysis complete. Results saved in " + output + "\n" + n + " images processed" + 
		"\nTime to process: " + deltatime +" s" + 
		"\nTime per image: " + deltatime/(n) +" s" + 
		"\nThis information saved with results.");
		
		selectWindow("Log");
		run("Close");
		selectWindow("Results");
		run("Close");
 	}
	else{
		single_nobarcode();
		close("*");
	}
  