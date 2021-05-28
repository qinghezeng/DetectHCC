path=getDirectory("Choose directory containing original tiles");
//path="/media/noname/LaCie/CK_DOC/00_HepatoCarcinomes/test";
run("Set Measurements...", "area mean center area_fraction redirect=None decimal=2");

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

threshold=200;

batchMode=true;
setBatchMode(batchMode);

list = getFileList(path);
nTiles=0;
for (i=0; i<list.length;i++){
	if(endsWith(list[i],".tif")&& startsWith(list[i],"img")){
		//print(list[i]);
		nTiles++;
	}
}
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
	//open mask
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

		//create sub-tile
		selectImage(mask);		
		run("Specify...", "width=&subTileWidth height=&subTileHeight x=&i y=&j");
		run("Duplicate...", "title=subTileMask");
		subTileMask=getImageID();
		selectImage(image);
		run("Specify...", "width=&subTileWidth height=&subTileHeight x=&i y=&j");
		run("Duplicate...", "title=subTile");
		subTile=getImageID();

		//treshold sub-tile mask
		selectImage(subTileMask);
		setThreshold(label,label);
		run("Measure");
		ratio=getResult("%Area");
		//close sub-tile mask
		close();
		//measure intensity of subtile image
		selectImage(subTile);
		run("Measure");
		mean=getResult("Mean");
		
		
		//save sub-tile in appropriate location / sorting folder
		selectImage(subTile);
		if(ratio<=25 && mean<= threshold){
			//save as neg
			nNegExemples++;
			save(path+"//split64//Neg//neg_"+nNegExemples+".tif");
			//close subtile
			close();
			}
		else if(ratio>=75 && mean<=threshold){
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

nExemples=nPosExemples+nNegExemples+nMixedExemples;

print("************************************");
print("Number of exemples : "+nExemples+ " ("+subTileWidth+"x"+subTileHeight+")");
print("Number of positive exemples : "+nPosExemples+" ("+nPosExemples/nExemples*100+"%)");
print("Number of negative exemples : "+nNegExemples+" ("+nNegExemples/nExemples*100+"%)");
print("Number of mixed exemples : "+nMixedExemples+" ("+nMixedExemples/nExemples*100+"%)");