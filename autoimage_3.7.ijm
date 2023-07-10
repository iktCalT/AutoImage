// Version 2.0 Added wait time
// Version 3.0 Can read parameters from csv file


//setBatchMode(true);  // If you set BatchMode as true, then it won't have so many windows pop-ups

// Initial parameter
input_path = "D:/LibrariesInD/Desktop/Test/ThorCam/G_230118_2_2/";
original_extension = "tif"; // Original_extension of original image. "tif","png", etc..     DO NOT add "." to it !! I added that in the following codes
save_extension = "tif"; // DO NOT add ".", too! Acceptable extension list: 'tif', 'gif', 'jpg', 'txt', 'zip', 'raw', 'bmp', 'png', 'pnm', and 'roi'
background_file_name = "background_100x"  // Name of background file without extension. This file should be stored in the subfolder under input_path, that is input_path/background/background_file_name+oroginal_extension
min_size = 15; // Only the flacks larger than this size (unit is defined in variable "unit" in "Set scale & scale bar" part) will be counted, and included in result file. If this number is too small, background will have huge influence
max_size = "Infinity" // ("Infinity", 1, 10, 500, etc.)
min_circularity = 0;  // Set minimun and maximum circularity for particles
max_circularity = 1;
wait_time =  500; // Waittime (ms)
wait_loop = 20; // If there is no new images in wait_time*wait_loop, the program will stop
max_flake_no = 10; // If there is more flakes than max_flake_no, a warning code will occur
max_area = 10000; // If there a flake with area larger than max_area, a warning code will occur
columns = 4; // How many data will a flake have. For example: name, flake No., flake size, warning code
max_samename = 5; // If there are more than max_samename images have existed in one folder, the program will end to avoid infinite loop
roi_width = 5; // Set ROI stroke width
roi_color = "red"; // Set ROI stroke color  ("red", "66ccff", etc.)

// Set threshold for "H", "S", and "B"(also known s "V")
H_min = 140;
H_max = 193;
S_min = 35;
S_max = 80;
B_min = 160;
B_max = 190;

// Other parameters
BrgtCtrst_low = 104;  // Brightness/Contrast
BrgtCtrst_high = 134;
gaussian_radius = 2;  // Radius of gaussian fliter, default: 2
mean_radius = 2;  // Radius of mean fliter, default: 2
erosion_radius = 10;  // Radius of erosion, default: 10

// Set scale & scale bar 
real_distance = 14.26;
unit = "um";  // Unit of real_distance
pixel_distance = 195.7436;  // How many pixels does this distance correspond to
scale_bar_length = 20;  // Set the length of scale bar, unit is same as real_distance

// Pathes
background_path = input_path + "background/"
background_file = background_path + background_file_name + "." + original_extension

result_path = input_path + "Result/";
result_file = result_path + "Results.csv";

backup_path = input_path + "Finished/"
save_path = input_path + "Processed/";

// Create the folder if it doesn't exist
if (! File.isDirectory(background_path)) File.makeDirectory(background_path);
if (! File.isDirectory(result_path)) File.makeDirectory(result_path);
if (! File.isDirectory(backup_path)) File.makeDirectory(backup_path);
if (! File.isDirectory(save_path)) File.makeDirectory(save_path);

// Save format
save_format = "Tiff"; // Default save format
if (save_extension == "tif") save_format = "Tiff";
else if (save_extension == "tiff") save_format = "Tiff";
else if (save_extension == "gif") save_format = "Gif";
else if (save_extension == "jpg") save_format = "Jpeg";
else if (save_extension == "txt") save_format = "Text Image";
else if (save_extension == "zip") save_format = "ZIP";
else if (save_extension == "raw") save_format = "Raw Data";
else if (save_extension == "bmp") save_format = "BMP";
else if (save_extension == "png") save_format = "PNG";
else if (save_extension == "pnm") save_format = "PGM";
else if (save_extension == "roi") save_format = "Selection";
else {
    print("Please check your save extension, only 'tif', 'gif', 'jpg', 'txt', 'zip', 'raw', 'bmp', 'png', 'pnm', and 'roi' are acceptable");
    exit;
}

//file = File.open(save_path + result_file, "w");
result_csv = File.open(result_file);
write(result_csv, "Filename,Flake No.,Area(um2),Notice\n\n");
File.close(result_csv);

loop_count = 0;
while (true) {
    file_list = getFileList(input_path);
    image_count = 0; // Reset image_count, image_count is the number of images in input_path for now
    for (i = 0; i < file_list.length; i++) {
        //print(file_list[i]);
        //open(input_path+file_list[i]);
        if (endsWith(file_list[i], "." + original_extension)) {
            image_count++;
            run("Clear Results"); // Reset the results
            results = newArray(max_flake_no * columns); // Reset the array to store the results
            
            // Read the files one by one
            if(!File.exists(input_path + file_list[i])){
                print("File " + input_path + file_list[i] + " doesn't exist.");
            }
            else{  // When the file exists
                // Open files
                filename = file_list[i];
                open(input_path + filename);
                //print(filename);
                
                filename_without_extension = substring(filename, 0, lengthOf(filename)-4);
                
                // Correct background
                rename("image."+original_extension);
                open(background_file);
                rename("background." + original_extension);
                run("Calculator Plus", "i1=image."+original_extension+" i2=background."+original_extension+" operation=[Divide: i2 = (i1/i2) x k1 + k2] k1=128 k2=0 create");
                
                // Image processing
                run("Brightness/Contrast...");
                setMinAndMax(BrgtCtrst_low, BrgtCtrst_high);
                call("ij.ImagePlus.setDefault16bitRange", 16);
                run("Close");
                run("Gaussian Blur...", "sigma=" + gaussian_radius);
                run("Mean", "radius=" + mean_radius);
                run("HSB Stack");
                //saveAs(save_format, save_path + filename_without_extension + "_before_threshold." + save_extension);  // For debugging or parameter adjusting
                run("Stack Splitter", "number=3");

            
                //----------------Set Threshold Here------------------
                selectWindow("Hue");
                setAutoThreshold("Default dark no-reset");
                setThreshold(H_min, H_max,"black & white");
                setOption("BlackBackground", true);
                run("Convert to Mask");
                selectWindow("Saturation");
                setAutoThreshold("Default dark no-reset");
                setThreshold(S_min, S_max,"black & white");
                setOption("BlackBackground", true);
                run("Convert to Mask");
                selectWindow("Brightness");
                setAutoThreshold("Default dark no-reset");
                setThreshold(B_min, B_max,"black & white");
                setOption("BlackBackground", true);
                run("Convert to Mask");
                imageCalculator("AND create", "Saturation","Hue");
                selectWindow("Result of Saturation");
                imageCalculator("AND create", "Brightness","Result of Saturation");
                selectWindow("Result of Brightness");
                //----------------------------------------------------
                

                //saveAs(save_format, save_path + filename_without_extension + "_before_erosion." + save_extension);  // For debugging or parameter adjusting
                run("Minimum...", "radius=" + erosion_radius + " stack");
                run("Maximum...", "radius=" + erosion_radius + " stack");
                //saveAs(save_format, save_path + filename_without_extension + "." + save_extension);  // For debugging or parameter adjusting
                run("Set Measurements...", "area mean min limit redirect=None decimal=3");
                
                // Process image one by one
                run("Set Scale...", "distance=" + pixel_distance + " known=" + real_distance + " unit=" + unit);
                roiManager("reset");
                
                run("Analyze Particles...", "size=" + min_size + "-" + max_size + " circularity=" + min_circularity + "-" + max_circularity + " add stack");
                roinum = roiManager("count");
                if(roinum != 0) {
                    selectWindow("Result of Brightness"); 
                    run("Scale Bar...", "width=" + scale_bar_length + " height=" + scale_bar_length + " thickness=5 font=24 color=White background=None location=[Upper Left] horizontal bold"); 
                    roiManager("Select All");
                    roiManager("Set Color", roi_color);
                    roiManager("Select All");
                    roiManager("Set Line Width", roi_width);
                    roiManager("Select All");
                    run("Flatten");
                    saveAs(save_format, save_path + filename_without_extension + "_processed." + save_extension);
                    for (j = 1; j <= roinum; j++) {
                        if (j>max_flake_no) break;
                        roiManager("Select", j-1);
                        run("Measure");
                        //area_value = getResult("Area", j-1);
                        //mean_value = getResult("Mean", j-1);
                        area_value = getResult("Area", j-1);
                        //mean_value = getResult("Mean", j-1);
                        results[(j-1)*columns + 0] = filename_without_extension;
                        results[(j-1)*columns + 1] = j;
                        results[(j-1)*columns + 2] = area_value;
                        if (roinum >= max_flake_no) results[(j-1)*columns + 3] = max_flake_no; // Too many flakes on the image, that's strange
                        if (area_value >= max_area) results[(j-1)*columns + 3] = max_area; // Very large flake, that's strange
                    }
                    run("Clear Results");
                    rename("finalresult." + save_extension);
                    run("RGB Color"); 
                    selectWindow("image." + original_extension);  // Show ROI on the original image
                    run("Set Scale...", "distance=" + pixel_distance + " known=" + real_distance + " unit=" + unit);
                    run("Scale Bar...", "width=" + scale_bar_length + " height=" + scale_bar_length + " thickness=5 font=24 color=White background=None location=[Upper Left] horizontal bold");
                    roiManager("Select All");
                    roiManager("Set Color", roi_color);
                    roiManager("Select All");
                    roiManager("Set Line Width", roi_width);
                    roiManager("Select All");
                    run("Flatten");
                    if (! File.exists(backup_path + filename_without_extension + "." + save_extension)) {
                        saveAs(save_format, backup_path + filename_without_extension + "." + save_extension);
                    }
                    
                    
                    else {
                        for (numbering = 1; numbering < max_samename; numbering++) {
                            if (! File.exists(backup_path + filename_without_extension +"("+ numbering + ")." + save_extension)) {
                                saveAs(save_format, backup_path + filename_without_extension + "(" + numbering + ")." + save_extension);
                                break;
                            }
                        }
                        if (numbering >= max_samename) {
                            print("Too many images with same name in the input folder!! \nPlease check");
                            exit();
                        }
                    }
                    rename("image." + save_extension);    
                    run("Combine...", "stack1=image." + save_extension + " stack2=finalresult." + save_extension);
                    run("8-bit Color", "number=256");
                    saveAs(save_format, save_path + filename_without_extension + "_compare." + save_extension); 
                    
                }
                else {
                    results[0] = filename_without_extension;
                    results[1] = 0;
                    results[2] = 0;
                    results[3] = -1;     // No flake larger than threshold
                }

                close("*");
                
                // Append information to the csv file
                for (row = 0; row < max_flake_no; row++) {
                    if (results[row*columns + 0] != 0) {
                        File.append(results[row*columns + 0] + "," + results[row*columns + 1] + "," + results[row*columns + 2] 
                                    + ',' +  results[row*columns + 3] , result_file);
                    }
                } 
                File.append("", result_file);  // empty line between different images
                
                File.delete(input_path + filename); // satisfied images have already benn saved, we just need to delete the original one
            }
        } 
        
    
    }  // end for (i = 0; i < file_list.length; i++) {}
    
    
    // If there is no new images in wait_time*wait_loop, the end the loop
    if (image_count == 0) loop_count++;
    else loop_count = 0;
    
    if (loop_count>wait_loop) {
        break;
    }
    
    // Wait for the new images
    wait(wait_time);
    
// end while (true) {}
}

print("Process finished!");

//setBatchMode(false);
