//This script is to export the image name, image width, image height, pixel width, pixel height and coordinates of annotations.
//Annotataion shape: polygon only.

// Create an empty text file
def path = buildFilePath(PROJECT_BASE_DIR, 'polygons2.txt')
def file = new File(path)
file.text = ''

def imageData = getCurrentImageData()
def server = imageData.getServer()
String imagePath = server.getPath()
//export the name of the slide
file << imagePath[imagePath.lastIndexOf('\\')+1..-1] << System.lineSeparator()
//export infos image size
file << 'Image width:' << server.getWidth() << System.lineSeparator()
file << 'Image height:' << server.getHeight() << System.lineSeparator()
file << 'Pixel width:' << server.getPixelWidthMicrons() << System.lineSeparator()
file << 'Pixel height:' << server.getPixelHeightMicrons() << System.lineSeparator()


// Loop through all objects & write the points to the file
for (pathObject in getAllObjects()) {
    // Check for interrupt (Run -> Kill running script)
    if (Thread.interrupted())
        break
    // Get the ROI
    def roi = pathObject.getROI()
    if (roi == null)
        continue
    // Write the point coordinates;
    file << roi.getPolygonPoints()
    file << pathObject.getPathClass() << System.lineSeparator()
}
print 'Done!'