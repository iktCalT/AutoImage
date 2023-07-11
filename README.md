## It will delete the images without large enough identified regions. So, please BACK UP the images when you want to test the codes!

# AutoImage
Automatic image analysis
An ImageJ micro to identify sample thickness with optical images. But you need to adjust the parameters with images of your own samples.

10th Jul. 2023 
  1. Added the function to read parameters from a CSV file to use different sets of parameters for different cases.
  2. Added some examples.

11th Jul. 2023 
  * Added a parameter called "remove_undesired_images", default as "N".  
  If it is "Y", then the micro will delete all undesired images (without large enough flakes). If it is "N", all undesired images will be stored in an isolated folder.
