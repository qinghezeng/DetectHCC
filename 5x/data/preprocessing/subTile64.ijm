//*******************Variables***********************************************
//path="/media/noname/LaCie/CK_DOC/00_HepatoCarcinomes/test";
path="X:\DeepLearning\ProjetHepatocarcinomes\00_HepatoCarcinomesDataSet\test";

tileSize=512;
tileWidth=tileSize;
tileHeight=tileSize;

subTileSize=64;
subTileWidth=subTileSize;
subTileHeight=subTileSize;

//subtile stride
stride=64;
//label to detect 
label=2;

//****************************************************************************
//For image J batch mode means (when true) it doesn't display the images it open 
batchMode=true;
setBatchMode(batchMode);

//Read the list of file names corresponding to tiles and corresponding label exported from visiopherm
list = getFileList(path);
nTiles=0;
for (i=0; i<list.length;i++){
	if(endsWith(list[i],".tif")&& startsWith(list[i],"img")){
		//print(list[i]);
		nTiles++;
	}
}

//Print a few informations about what it's to be done
print(nTiles + " tiles to process");
nExemples=nTiles*tileWidth/subTileWidth*tileHeight/subTileHeight;// to modify and use for 0 padding output file names
nPosExemples=0;
nNegExemples=0;
nMixedExemples=0;

//---for each tile In the list --------------//
for(n=0;n<nTiles;n++){
	//open image
	filename=list[n];
	open(path+"//"+filename);
	image=getImageID();
	//open mask, that is the label image 
	maskname="label"+substring(filename,indexOf(filename,"_"));
	open(path+"//"+maskname);
	mask=getImageID();
	print(n+1+"/"+nTiles+" "+filename);
	
	run("Clear Results");
	getDimensions(width, height, channels, slices, frames);
	tileWidth=width;
	tileHeight=height;
	
//------for each subtile---------//
	for(j=0;j<=tileHeight-subTileHeight;j+=stride){
		for(i=0;i<=tileWidth-subTileWidth;i+=stride){

		//create the sub-tile
		selectImage(mask);		
		run("Specify...", "width=&subTileWidth height=&subTileHeight x=&i y=&j"); //draws a ROI on the image
		run("Duplicate...", "title=subTileMask"); //copy this part of the label image as a new image 
		subTileMask=getImageID();
		selectImage(image);
		run("Specify...", "width=&subTileWidth height=&subTileHeight x=&i y=&j");
		run("Duplicate...", "title=subTile"); //copy this part of the RGB image as a new image 
		subTile=getImageID();

		//treshold sub-tile mask
		selectImage(subTileMask);
		setThreshold(label,label);
		run("Measure");
		ratio=getResult("%Area"); //measure the % of the image area which as positive label
		//close sub-tile mask
		selectImage(subTileMask);
		close();
		
		//save sub-tile in appropriate location / sorting folder , depending on the % of area of the  image  covered by positive label 
		selectImage(subTile);
		if(ratio<=25){
			//save as neg
			nNegExemples++;
			save(path+"//split64//Neg//neg_"+nNegExemples+".tif");
			//close subtile
			close();
			}
		else if(ratio>=75){
			//save as pos
			nPosExemples++;
			save(path+"//split64//Pos//pos_"+nPosExemples+".tif");
			//close subtile
			close();
			}
		else{
			//save as mixed
			nMixedExemples++;
			save(path+"//split64//Mixed//mix_"+nMixedExemples+".tif");
			//close subtile
			close();
			}
	}
}

//---close image & mask----------//
selectImage(mask);		
close();	
selectImage(image);
close();

}//end of list

//print infos about what was done
nExemples=nPosExemples+nNegExemples+nMixedExemples;

print("************************************");
print("Number of exemples : "+nExemples+ " ("+subTileWidth+"x"+subTileHeight+")");
print("Number of positive exemples : "+nPosExemples+" ("+nPosExemples/nExemples*100+"%)");
print("Number of negative exemples : "+nNegExemples+" ("+nNegExemples/nExemples*100+"%)");
print("Number of mixed exemples : "+nMixedExemples+" ("+nMixedExemples/nExemples*100+"%)");