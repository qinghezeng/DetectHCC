/**
 * Script to export image tiles (can be customized in various ways).
 */

import qupath.lib.images.servers.LabeledImageServer

// Set all the annotations to Class Tumor
getAnnotationObjects() each {annotation -> annotation.setPathClass(getPathClass('Tumor'))}

// Get the current image (supports 'Run for project')
def imageData = getCurrentImageData()

// Define output path (here, relative to project)
def name = GeneralTools.getNameWithoutExtension(imageData.getServer().getMetadata().getName())
// def pathOutput = buildFilePath(PROJECT_BASE_DIR, 'tiles', name)
def pathOutput = buildFilePath("/media/visiopharm5/WDRed(backup)/qupath/", 'tiles', name)
mkdirs(pathOutput)

// Define output resolution in calibrated units (e.g. µm if available)
// double requestedPixelSize = 0.5

// Convert output resolution to a downsample factor
double pixelSize = imageData.getServer().getPixelCalibration().getAveragedPixelSize() // Attention! It couldn't get the right size for some (not all) 20x svs! Should be 0.5 but got 1.0 instead. 
// double downsample = requestedPixelSize / pixelSize // DO NOT use it with QuPath 0.2.3!!!
double downsample // Variables can be assigned but not declared inside the conditional statement:

print pixelSize

if (pixelSize > 0.35) { // 20x pixelsize ~= 0.5 or 1.0 (not correctly recognized)
    downsample = 1.0
} else { // 40x pixelsize ~= 0.25
    downsample = 2.0
}

print downsample

// Create an ImageServer where the pixels are derived from annotations
def labelServer = new LabeledImageServer.Builder(imageData)
    .backgroundLabel(0, ColorTools.WHITE) // Specify background label (usually 0 or 255)
    .downsample(downsample)    // Choose server resolution; this should match the resolution at which tiles are exported
    .addLabel('Tumor', 1)      // Choose output labels (the order matters!)
    .multichannelOutput(false)  // If true, each label is a different channel (required for multiclass probability)
    .build()

// Create an exporter that requests corresponding tiles from the original & labelled image servers
new TileExporter(imageData)
    .downsample(downsample)   // Define export resolution
    .imageExtension('.tif')   // Define file extension for original pixels (often .tif, .jpg, '.png' or '.ome.tif')
    .tileSize(256)            // Define size of each tile, in pixels
    .labeledServer(labelServer) // Define the labeled image server to use (i.e. the one we just built)
    .annotatedTilesOnly(true) // If true, only export tiles if there is a (classified) annotation present
    .overlap(0)              // Define overlap, in pixel units at the export resolution
    .writeTiles(pathOutput)   // Write tiles to the specified directory

print 'Done!'