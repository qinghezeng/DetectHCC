# -*- coding:Utf-8 -*-

#************ToDo**********************#
#Interface la dll hamamatsu NDPRead.dll#
#Gerer correctement les erreurs        #
#path de la DLL                        #
#Verifier types des variables          #
#**************************************#

#****Imports**************************
from ctypes import *
from PIL import Image
from matplotlib import pyplot as plt
#import win32clipboard
#*************************************

#****Variables globales
def LoadNDPRead():
  global NDPRead 
  NDPRead = WinDLL("C:\\Users\\visiopharm5.CICCDOM\\Downloads\\Hamamatsu-Imaging-master\\dll\\NDP.read 1.1.27\\redist\\x64\\NDPRead.dll")
  #print NDPRead                    #pour tester le chargement de la DLL
  #print NDPRead.GetImageWidth
  #print NDPRead.GetBitDepthWS


#****definitions de fonctions********

def GetImageWidth (filename):
  #Width in nm retourne sous forme long
  return NDPRead.GetImageWidthS(filename)
  
def GetImageHeight (filename):
  #Height in nm retourne sous forme long
  return NDPRead.GetImageHeightS(filename)
  
def GetBitDepth (filename) :
  #Bit Depth : 8,16,24 ne marche pas
  return NDPRead.GetBitDepthS(filename)
  
def GetNoChannels (filename) :
  #nmbre de canaux retourne sous forme de long
  return NDPRead.GetNoChannelsS(filename)
  
def GetChannelOrder (filename) :
  #codage des canaux 
  #0= Undefined (Error)
  #1=BGR
  #2=RGB
  #3=Y (greyscale)
  return NDPRead.GetChannelOrderS(filename)

def SetCameraResolution(x=512,y=512) :
  #taille camera entre en passant de variables de type ctype long
  #retourne 0 en cas d'echec
  x=c_long(x)
  y=c_long(y)
  res=NDPRead.SetCameraResolutionS(x,y)
  return res
  

def GetMap(filename):
  #get map retourne l'overview de la region scannee
  center_x = c_long(0)
  center_y = c_long(0)
  map_width = c_long(0)
  map_height = c_long(0)
  map_pwidth = c_long(0)
  map_pheight = c_long(0)
  
  #premier appel avec buffer a 0
  buff=create_string_buffer(0)
  buffer_size= c_long(0)
  a=NDPRead.GetMapS(filename,byref(center_x),byref(center_y),byref(map_width),
  byref(map_height),buff,byref(buffer_size),byref(map_pwidth),byref(map_pheight)) 
  
  #2 eme appel avec la bonne taille
  size=map_pwidth.value*map_pwidth.value*4
  buff=create_string_buffer(size)
  buffer_size= c_long(size)
  a=NDPRead.GetMapS(filename,byref(center_x),byref(center_y),byref(map_width),
  byref(map_height),buff,byref(buffer_size),byref(map_pwidth),byref(map_pheight)) 
  
  #if a==0 
  
  return [buff,center_x.value,center_y.value,map_width.value,map_height.value,
  map_pwidth.value,map_pheight.value]
  

def GetSlideImage(filename) :
  #GetSlideImage
  #[buff,center_x.value,center_y.value,center_y.value,map_height.value,
  #map_pwidth.value,map_pheight.value]
  center_x = c_long(0)
  center_y = c_long(0)
  slide_width = c_long(0)
  slide_height = c_long(0)
  slide_pwidth = c_long(0)
  slide_pheight = c_long(0)
  buff=create_string_buffer(0)
  buffer_size= c_long(0)
  
  #un premier appel permet deconnaitre la taille x y necessaire
  a=NDPRead.GetSlideImageS(filename,byref(center_x),byref(center_y),
  byref(slide_width),byref(slide_height),buff,byref(buffer_size),
  byref(slide_pwidth),byref(slide_pheight))
  
  #un deuxieme appel avec la bonne taille de buffer
  buff=create_string_buffer(slide_pwidth.value*slide_pheight.value*4)
  buffer_size= c_long(slide_pwidth.value*slide_pheight.value*4)
  a=NDPRead.GetSlideImageS(filename,byref(center_x),byref(center_y),
  byref(slide_width),byref(slide_height),buff,byref(buffer_size),
  byref(slide_pwidth),byref(slide_pheight))
  
  #if a==0 
  
  return [buff,center_x.value,center_y.value,slide_width.value,slide_height.value,
  slide_pwidth.value,slide_pheight.value]


def GetZRange(filename) :
  #ZRange retourne le nombre de plan Z presents dans le fichier
  #On doit lui fournir des pointeurs long par reference qu'il affecte ensuite
  zmin=c_long(0)
  zmax=c_long(0)
  zstep=c_long(0)
  res=NDPRead.GetZRangeS(filename,byref(zmin),byref(zmax),byref(zstep)) 
  if res == 0 :
    return [ -1,-1,-1]
  else :
    return [zmin.value,zmax.value,zstep.value]


def GetImageData(filename,x,y,z=0,lens=20.0):
  #GetImageDataS recupere un snapshot
  #long GetImageData(LPCTSTR i_strImageID,long i_nPhysicalXPos,long i_nPhysicalYPos
  #,long i_nPhysicalZPos, float i_fMag,long FAR* o_nPhysicalWidth,
  #long FAR* o_nPhysicalHeight,void *i_pBuffer,long *io_nBufferSize)
  posx=c_long(x)
  posy=c_long(y)
  posz=c_long(z)
  lens=c_float(lens)
  width=c_long(0)
  height=c_long(0)
  buff=create_string_buffer(0)
  buffer_size= c_long(0)
  a=NDPRead.GetImageDataS(filename,posx,posy,posz,lens,byref(width),
  byref(height),buff,byref(buffer_size) )        
  buff=create_string_buffer(buffer_size.value)
  a=NDPRead.GetImageDataS(filename,posx,posy,posz,lens,byref(width),
  byref(height),buff,byref(buffer_size) )
  
  return [buff,posx.value,posy.value,posz.value,lens.value,width.value,height.value]

def GetImageDataInSourceBitDepth():
  return -1
  #pas implementé

def GetSourceLens(filename) :
  #grossisement objectif retourné sous forme double
  return NDPRead.GetSourceLensS(filename)

def GetSourcePixelSize(filename) :
  #taille de l'image en pixels en passant par reference (adresse du pointeur)
  #les variables a modifier. Retourne 0 en cas d'echec
  x=c_long(0)
  y=c_long(0)
  a=NDPRead.GetSourcePixelSizeS(filename,byref(x), byref(y))
  return [x.value,y.value]
        
def GetReference(filename,length) :
  #Recupere la reference de la lame
  #on doit fournir un str* de taille connue (en nbre de char) et initiallise
  #retourne 0 en cas d'echec
  reference=c_wchar_p('a'*length)
  l=c_long(length)
  a=NDPRead.GetReferenceS(filename,reference,l)
  return reference.value

def CleanUp() :
  return -1
  #CleanUp vide la memoire
  #pas implementé

def GetLastErrorMessage() :
  #recuperer le dernier message d'erreur
  #retourne un pointeur ctyp c_char_p. Il faut le preciser avant...
  NDPRead.GetLastErrorMessageS.restype = c_char_p
  error=NDPRead.GetLastErrorMessageS()
  return error

def GetLowLevelParam (filename,parameter,length) :
  #                                     long GetLowLevelParam(         
  #filename                             LPCTSTR i_strImageID,
  #parameter:“ImageNames”,“FileNames”   LPCTSTR i_stParamID,
  liste=c_char_p('a'*length)            #LPTSTR o_strValue,
  l=c_long(length)                      #long i_nBufferLength)  
  a=NDPRead.GetLowLevelParamS(filename,parameter,liste,l)
  return liste.value

def SetLowLevelParam (filename,parameter,value):
  #long SetLowLevelParam(
  #LPCTSTR i_strImageID,
  #LPCTSTR i_stParamID,
  #LPCTSTR i_strValue)
  a=NDPRead.SetLowLevelParamS(filename,parameter,value)
  return a

def SetOption () :
  return -1