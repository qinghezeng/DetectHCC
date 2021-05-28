from getNDPI import *

#initialisation : load DLL
getNDPI_init()

#test getInfo
filename=('E:\\deeplearning\\Hepatocarcinomes\\Biopsy HCC\\R10_004_3- 2017-08-25 13.25.36.ndpi')
#filename=("c:/qq.ndpis") 
text=getInfo(filename)
print(text)

#test getSlide
slide=getSlide(filename)
plt.imshow(slide)
plt.show()

#test getMap
Map=getMap(filename,512,512 )
plt.imshow(Map)
plt.show()

#test getSnapshotFixedPix
 
posx=10000000
posy=2950000
posz=0
x=y=512
lens =10
snap=getRGBSnapshotFixedPix(filename,posx,posy,posz,x,y,lens)
im=snap[0]
plt.imshow(im)
plt.show()
print("\nsnapshot scale = %.3f um/pix" %snap[1])

#test getSnapshotFixedPix
image2Clipboard(im)
#image2Clipboard(Map)