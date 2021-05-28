guiscript=true

// Get QuPath & project
def qupath = getQuPath()
def project = qupath.getProject()

// Loop through images, setting the name
// (actually accessing a private field... therefore 'bad')
project.getImageList().each {
    def path = it.getServerPath()
    int ind = path.lastIndexOf(':')
    def scene = path[ind+1..-1]
    def name = new File(path[0..ind-2]).getName()
    it.putMetadataValue('Slide_ID', name)
    it.imageName = name + ' (' + scene + ')'
    print it.imageName
}

// Need to set to null first to force update
qupath.setProject(null)
qupath.setProject(project)

// Be very careful is you use this to write the project!
// The logic is a bit weird and it will probably overwrite 
// the existing project - so duplicate your .qpproj file to be safer
//qupath.lib.projects.ProjectIO.writeProject(project)

//HELP: run it and select the images to apply to.