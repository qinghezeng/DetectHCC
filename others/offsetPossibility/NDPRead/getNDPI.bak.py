# -*- coding:Utf-8 -*-

#***********************GetNDPI*************************
#Recup�re les images ou les infos dans le fichier NDPI
#Et les passe dans le clipboard de windows
#Ou les sauve dans un fichier TIFF ou un fichier text 
#*******************************************************

from NDPRead import *
from io import StringIO
import win32clipboard as w

def getNDPI_init():
  """Charge la DLL NDPRead de Hmamatsu"""
  LoadNDPRead()
    
def getSlide(NDPIfilename):
  """R�cup�re l'image de la lame enti�re avec �tiquette
  et la retourne sous forme d'image PIL
  """
  slide=GetSlideImage(NDPIfilename)
  size=(slide[5]+1,slide[6])     #pourquoi +1??
  slideImage =  Image.frombuffer('RGB', size, slide[0],'raw', 'RGB', 0,1)
  return slideImage
  
def getMap(NDPIfilename,camera_x,camera_y):
  """R�cup�re l'image map (overview de la r�gion scann�e)
  � la r�solution demand�e et la retourne sous forme d'image
  PIL
  """
  SetCameraResolution(camera_x,camera_y)
  Map=GetMap(NDPIfilename)
  size=(Map[5],Map[6])
  mapImage =  Image.frombuffer('RGB', size, Map[0],'raw', 'RGB', 0,1)
  return mapImage
  
def getSnapshotFixedPix(NDPIfilename,pos_x,pos_y,pos_z,pix_width,pix_height,lens):
  """R�cup�re une r�gion du scan avec une taiile de pisel fixee
  et la retourne sous forme d'une image PIL + calibration en �m/pix
  """
  SetCameraResolution(pix_width,pix_height)
  data=GetImageData(NDPIfilename,pos_x,pos_y,pos_z,lens)
  size=(pix_width,pix_height)
  snapshotImage =  Image.frombuffer('RGB', size, data[0],'raw', 'RGB', 0,1)
  scale = data[5]/pix_width*1e-3
  return (snapshotImage,scale)
  
def getInfo(NDPIfilename):
  """R�cup�re les infos du fichier et les retourne sous forme
  de string"""
  info=""
  info+="Ref : "+GetReference(NDPIfilename,128)
  info+="\nWidth (nm) = "+str(GetImageWidth(NDPIfilename))
  info+="\nHeight (nm) = "+str(GetImageHeight(NDPIfilename))
  imsize=GetSourcePixelSize(NDPIfilename)
  info+="\nWidth (pix) = "+str(imsize[0])
  info+="\nHeight (pix) = "+str(imsize[1])
  zr=GetZRange(NDPIfilename)
  info+="\nZmin = "+str(zr[0])
  info+="\nZmax = "+str(zr[1])
  info+="\nZstep = "+str(zr[2])
  info+="\nn Channels = "+str(GetNoChannels(NDPIfilename))
  co=GetChannelOrder(NDPIfilename)
  if co==1:
    info+="\nChannels order = BGR"
  elif co==2:
    info+="\nChannels order = RGB"
  elif co==3:
    info+="\nChannels order = GREY"
  #info+="\nSource lens = "+str(GetSourceLens(NDPIfilename))
  return info
  
  
 
  
def image2Clipboard(imagePIL) :
  """Transf�re une image PIL dans le clipboard de windows"""
  w.OpenClipboard()
  w.EmptyClipboard()
  output = StringIO()   
  bgr2rgb=(
        0.0, 0.0, 1.0, 0,
        0.0, 1.0, 0.0, 0,
        1.0, 0.0, 0.0, 0 )                        #permet de remmetre les couleurs dans le bon ordre
  imagePIL.convert("RGB",bgr2rgb).save(output, "BMP")    #????
  data = output.getvalue()[14:]                     #????
  output.close()
  w.SetClipboardData( w.CF_DIB,data )
  w.CloseClipboard()
  
def imageSave(imagePIL,filename) :
  """Sauve une image PIL en TIFF"""
  
def info2Clipboard(text_info) :
  """Transf�re les infos dans le clip board"""
  
def infoSave(text_info,filename) :
  """Sauvegarde les infos dans un fichier texte"""
  

  