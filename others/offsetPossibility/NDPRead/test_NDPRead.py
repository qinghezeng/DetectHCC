from NDPRead import *

LoadNDPRead()
f= "E:\\deeplearning\\Hepatocarcinomes\\Biopsy HCC\\R10_004_3- 2017-08-25 13.25.36.ndpi"
SetLowLevelParam (f,"EnableImage0","0.0")

p="ImageNames"
#p="FileNames"
print("parameters =\n", GetLowLevelParam (f,p,5000))


w=GetImageWidth(f)
print('Width (nm) =',w)

h=GetImageHeight(f)
print('Height (nm) =',h)

#bd=GetBitDepth(f)
#print('Bit Depth=',bd)

n_channels=GetNoChannels(f)
print('Number of channels =',n_channels)

co=GetChannelOrder(f)
print('Channels Order =',co)

res=SetCameraResolution(512,512)
print('Set Camera Resolution =',res)

zr=GetZRange(f)
print('Z min = ' ,zr[0])
print('Z max = ' ,zr[1])
print('Z step = ',zr[2])

slide=GetSlideImage(f)
#[buff,center_x.value,center_y.value,center_y.value,map_height.value,
#  map_pwidth.value,map_pheight.value]
print("\n****Slide****")
print("Center x (nm) =",slide[1])
print("Center y (nm) =",slide[2])
print("Slide width (nm) = %2.3f" %(slide[3] /1e6))
print("Slide height (nm) = %2.3f" %(slide[4] /1e6))
print("Slide width (pix) =",slide[5])
print("Slide height (pix) =",slide[6])
print("Slide octet =", sizeof(slide[0]))
#creation d'une image PIL a partir du buffer "L", "RGRBX", "RGBA", and "CMYK"
size=(slide[5]+1,slide[6])     #pourquoi +1??
im2 =  Image.frombuffer('RGB', size, slide[0],'raw', 'RGB', 0,1)
plt.imshow(im2)
plt.show()

#x=2048
#y=1536
x=512
y=512
SetCameraResolution(x,y)
map=GetMap(f)
print("\n****Map****")
print("Center x (mm) = %2.3f" %(map[1] /1e6))
print("Center y (mm) = %2.3f" %(map[2] /1e6))
print("Map width (mm) = %2.3f" %(map[3] /1e6))
print("Map height (mm) = %2.3f" %(map[4] /1e6))
print("Map width (pix) =",map[5])
print("Map height (pix) =",map[6])
print("Map octets =" ,sizeof(map[0]))
#creation d'une image PIL a partir du buffer "L", "RGRBX", "RGBA", and "CMYK"
size=(map[5],map[6])
im =  Image.frombuffer('RGB', size, map[0],'raw', 'RGB', 0,1)
plt.imshow(im)
plt.show()

x=512
y=512
SetCameraResolution(x,y)
data=GetImageData(f,12000000,2500000,0,20.0)
print("\n****Snapshot****")
print("pos x (mm) = %2.3f" %(data[1]/1e6))
print("pos y ((mm) = %2.3f" %(data[2]/1e6))
print("pos z (mm) = %2.3f" %(data[3] /1e6))
print("lens = ",data[4])
print("width (mm) = %2.3f" %(data[5]/1e6))
print("height (mm) = %2.3f" %(data[6]/1e6))
print('')
size=(x,y)
im3 =  Image.frombuffer('RGB', size, data[0],'raw', 'RGB', 0,1)
plt.imshow(im3)
plt.show()

print('Source Lens = %.2f' %GetSourceLens(f))
 
imsize=GetSourcePixelSize(f)
print("Width (pixels) = ", imsize[0])
print("Height (pixels) = ",imsize[1])

print("Reference =", GetReference(f,10))

print("Get last error = ", GetLastErrorMessage())
#avec une erreur
filename=c_char_p('E:\\deeplearning\\Hepatocarcinomes\\Biopsy HCC\\R10_004_3- 2017-08-25 13.25.36.ndpi')
GetImageWidth(filename)
print("Get last error = ", GetLastErrorMessage()))


from io import StringIO
import win32clipboard as w

w.OpenClipboard()
w.EmptyClipboard()
output = StringIO()   
bgr2rgb=(
        0.0, 0.0, 1.0, 0,
        0.0, 1.0, 0.0, 0,
        1.0, 0.0, 0.0, 0 )                        #permet de remmetre les couleurs dans le bon ordre
im3.convert("RGB",bgr2rgb).save(output, "BMP")    #????
data = output.getvalue()[14:]                     #????
output.close()
w.SetClipboardData( w.CF_DIB,data )
w.CloseClipboard()



