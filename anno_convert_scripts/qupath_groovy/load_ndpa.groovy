// https://groups.google.com/forum/#!searchin/qupath-users/ndpa%7Csort:date/qupath-users/xhCx_nhbWQQ/QoUOQB24CQAJ

import qupath.lib.scripting.QP
import qupath.lib.gui.scripting.QPEx
import qupath.lib.geom.Point2
import qupath.lib.roi.*
//import qupath.lib.roi.PolylineROI

import qupath.lib.objects.PathAnnotationObject
import qupath.lib.images.servers.ImageServer
import qupath.lib.common.GeneralTools
import qupath.lib.gui.dialogs.Dialogs
import qupath.lib.objects.classes.PathClassFactory

import java.io.*; 

def server = QP.getCurrentImageData().getServer()

// We need the pixel size
def cal = server.getPixelCalibration()
if (!cal.hasPixelSizeMicrons()) {
	Dialogs.showMessageDialog("Metadata check", "No pixel information for this image!");
	return
}

// Here we get the pixel size
def md = server.getMetadata()
pixelsPerMicron_X = 1 / cal.getPixelWidthMicrons() //md["pixelWidthMicrons"]
pixelsPerMicron_Y = 1 / cal.getPixelHeightMicrons() //md["pixelHeightMicrons"]

//Aperio Image Scope displays images in a different orientation
//TODO Is this in the metadatata? Is this likely to be a problem?
//print(server.dumpMetadata())
def rotated = false


def h = server.getHeight()
def w = server.getWidth()
ImageCenter_X = (w/2)*1000/pixelsPerMicron_X
ImageCenter_Y = (h/2)*1000/pixelsPerMicron_Y 


// need to add annotations to hierarchy so qupath sees them
def hierarchy = QP.getCurrentHierarchy()

	
//***************Prompt user for NDPA annotation file
//Generic Method which prompts the user for a filename
//def NDPAfile = getQuPath().getDialogHelper().promptForFile('Select ndpa', null, 'Hamamatsu NDPA file', null)


//*********Get NDPA automatically based on naming scheme 
def path = GeneralTools.toPath(server.getURIs()[0]).toString()+".ndpa";

def NDPAfile = new File(path)
if (!NDPAfile.exists()) {
	print("No NDPA file for this image...")
	return
}

//Get X Reference from OPENSLIDE data
//The Open slide numbers are actually offset from IMAGE center (not physical slide center). 
//This is annoying, but you can calculate the value you need -- Offset from top left in Nanometers. 

def map = getCurrentImageData().getServer().osr.getProperties()
map.each { k, v ->
	if(k.equals("hamamatsu.XOffsetFromSlideCentre")){
		OffSet_From_Image_Center_X = v
		//print OffSet_From_Image_Center_X
		//print ImageCenter_X
		OffSet_From_Top_Left_X = ImageCenter_X.toDouble() - OffSet_From_Image_Center_X.toDouble()
		X_Reference =  OffSet_From_Top_Left_X
		//print X_Reference
		}
	if(k.equals("hamamatsu.YOffsetFromSlideCentre")){
		OffSet_From_Image_Center_Y = v
		//print    OffSet_From_Image_Center_Y
		//print ImageCenter_Y

		OffSet_From_Top_Left_Y = ImageCenter_Y.toDouble() - OffSet_From_Image_Center_Y.toDouble() 
		 Y_Reference =  OffSet_From_Top_Left_Y
		 //print Y_Reference
		}
}


//Read files
def text = NDPAfile.getText()

def list = new XmlSlurper().parseText(text)

def convertPointMicrons(point) {
	point.x = point.x /1000 * pixelsPerMicron_X  + X_Reference /1000 * pixelsPerMicron_X 
	point.y = point.y /1000 * pixelsPerMicron_Y + Y_Reference /1000 * pixelsPerMicron_Y 
}

//Here we attempt to recover some possible class names by which the annotations are called.
def convertName(details) {
	def ret = details.trim().toLowerCase()
	switch(ret) {
		case "tumour" : case "tumeur":
			ret = "tumor"
			break
		case "ignorer":
			ret = "ignore"
			break
		case "necrose":
			ret = "necrosis"
			break
		case "autre":
			ret = "other"
			break
	}
	return ret.capitalize()
}
	  
	

list.ndpviewstate.each { ndpviewstate ->
	def annotationName = ndpviewstate.title.toString().trim()
	def annotationClassName = convertName(annotationName)
	def annotationType = ndpviewstate.annotation.@type.toString().toUpperCase()
	def details = ndpviewstate.details.toString()
	print(annotationName+" ("+annotationType+") ("+annotationClassName+") "+details)
  
	roi = null
	
	if (annotationType == "CIRCLE") {
		//special case
		def X = ndpviewstate.annotation.x.toDouble()
		def Y = ndpviewstate.annotation.y.toDouble()
		def point = new Point2(X, Y)
		convertPointMicrons(point)

		def rx = ndpviewstate.annotation.radius.toDouble() / 1000 * pixelsPerMicron_X
		def ry = ndpviewstate.annotation.radius.toDouble() / 1000 * pixelsPerMicron_Y
		roi = new EllipseROI(point.x-rx,point.y-ry,rx*2,ry*2,null);
	}
	
	if (annotationType == "LINEARMEASURE") {
		//special case
		def X = ndpviewstate.annotation.x1.toDouble()
		def Y = ndpviewstate.annotation.y1.toDouble()
		def pt1 = new Point2(X, Y)
		convertPointMicrons(pt1)
		X = ndpviewstate.annotation.x2.toDouble()
		Y = ndpviewstate.annotation.y2.toDouble()
		def pt2 = new Point2(X, Y)
		convertPointMicrons(pt2)
		roi = new LineROI(pt1.x,pt1.y,pt2.x,pt2.y);
	}

	if (annotationType == "PIN") {
		def X = ndpviewstate.annotation.x.toDouble()
		def Y = ndpviewstate.annotation.y.toDouble()
		def point = new Point2(X, Y)
		convertPointMicrons(point)
		roi = new PointsROI(point.x,point.y);
	}
		
	// All that's left if FREEHAND which handles polygons, polylines, rectangles
	ndpviewstate.annotation.pointlist.each { pointlist ->


		def tmp_points_list = []

		 pointlist.point.each{ point ->

			if (rotated) {
				X = point.x.toDouble()
				Y = h - point.y.toDouble()
			}
			else {
				X = point.x.toDouble()
				Y =  point.y.toDouble()
				//print(X)
				//print(Y)
			}


			tmp_points_list.add(new Point2(X, Y))
		} 
		
 
		//Adjust each point relative to SLIDECENTER coordinates and adjust for pixelsPerMicron
		for ( point in tmp_points_list){
				//print("Original  : " + point)
				convertPointMicrons(point)
				//print("Corrected : " + point)
		}
		
		if (annotationType == "FREEHAND") {
			isClosed = ndpviewstate.annotation.closed.toBoolean()
			isRectangle = (ndpviewstate.annotation.specialtype.toString() == "rectangle")
			if (isRectangle) {
				x1 = tmp_points_list[0].x
				y1 = tmp_points_list[0].y
				x3 = tmp_points_list[2].x
				y3 = tmp_points_list[2].y
				roi = new RectangleROI(x1,y1,x3-x1,y3-y1);
			}
			else if (isClosed)
				roi = new PolygonROI(tmp_points_list);
			else
				roi = new PolylineROI(tmp_points_list, null);
		}
		
	}
	
	if (roi != null)
	{
		def annotation = new PathAnnotationObject(roi)

		annotation.setName(annotationName)        
		
		if (annotationClassName)
		{
			//TODO (validate) and add the new class if it doesn't already exist:
			//if (!PathClassFactory.classExists(annotationClassName))
			
			annotation.setPathClass(PathClassFactory.getPathClass(annotationClassName))
		}
		
		if (details) {          
			annotation.setDescription(details)
		}
		hierarchy.addPathObject(annotation) //, false)
	}

}