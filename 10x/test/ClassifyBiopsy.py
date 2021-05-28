# -*- coding: utf-8 -*-
"""
Created on Mon Apr  1 21:39:46 2019

@author: INSERM
Classify biopsies (2 classes)
Annotation: 1 class
"""
import openslide
from openslide import OpenSlide
import matplotlib.pyplot as plt
import numpy as np
from PIL import Image, ImageFilter
import os
from matplotlib import cm
import pandas as pd

#%%
#slide_name='R10_004_3- 2017-08-25 13.25.36.ndpi'
#slide_path=os.path.join("E:\\deeplearning\\Hepatocarcinomes\\Biopsy HCC", slide_name)
#out_path="E:\\deeplearning\\Hepatocarcinomes\\data\\5x\\biopsy_HCC"

slide_name='R10_004_2 - 2017-08-23 19.43.29.ndpi'
slide_path=os.path.join("E:\\deeplearning\\Hepatocarcinomes\\BiopsyHCC", slide_name)
if slide_name[:-5].split('- ')[0].endswith(' '):
    out_path=os.path.join("E:\\deeplearning\\Hepatocarcinomes\\BiopsiesClassification", slide_name[:-5].split(' - ')[0])
else:
    out_path=os.path.join("E:\\deeplearning\\Hepatocarcinomes\\BiopsiesClassification", slide_name[:-5].split('- ')[0])

patch_size=128
#attention! if use 1.0, the evalutaion script have to be the one with 64p.
stride = 0.25 #in % of patch width: 0.125(8), 0.25(16), 0.5(32), 0.75(48), 1.0(64)
stride_string = '_stride' + str(int(stride*patch_size)) + 'p'

#%% 
# =============================================================================
# load properties of slide
# =============================================================================

#open a file pointer
f=OpenSlide(slide_path)

#level counts : number of downsampled images
levels=f.level_count
#print("levels: "+str(levels))

#size of flull slide images
(width,height)=f.dimensions
#print("Width= "+str(width)+", Height= "+str(height))

#down sample
level_downsamples=f.level_downsamples

#levels dimensions
dims=f.level_dimensions

#for i in range(levels-1):
#    print("level "+str(i+1)+": (x,y)= "+str(dims[i+1])+"\tdownsampling= "+str(level_downsamples[i+1]))
#    #no original (0)

#Metadata    
properties=f.properties

#%%
# =============================================================================
# prepare for prediction
# =============================================================================

#print("Properties :")
print("\t"+openslide.PROPERTY_NAME_VENDOR+" : "+properties[openslide.PROPERTY_NAME_VENDOR])
#print("\t"+openslide.PROPERTY_NAME_QUICKHASH1+" : "+properties[openslide.PROPERTY_NAME_QUICKHASH1])
#print("\t"+openslide.PROPERTY_NAME_BACKGROUND_COLOR+" : "+str(properties[openslide.PROPERTY_NAME_BACKGROUND_COLOR]))
print("\t"+openslide.PROPERTY_NAME_OBJECTIVE_POWER+" : "+properties[openslide.PROPERTY_NAME_OBJECTIVE_POWER])
print("\t"+openslide.PROPERTY_NAME_MPP_X+" : "+properties[openslide.PROPERTY_NAME_MPP_X]) #um
print("\t"+openslide.PROPERTY_NAME_MPP_Y+" : "+properties[openslide.PROPERTY_NAME_MPP_Y])
#print("\t"+openslide.PROPERTY_NAME_BOUNDS_X+" : "+str(properties[openslide.PROPERTY_NAME_BOUNDS_X]))
#print("\t"+openslide.PROPERTY_NAME_BOUNDS_Y+" : "+properties[openslide.PROPERTY_NAME_BOUNDS_Y])
#print("\t"+openslide.PROPERTY_NAME_BOUNDS_WIDTH+" : "+properties[openslide.PROPERTY_NAME_BOUNDS_WIDTH])
#print("\t"+openslide.PROPERTY_NAME_BOUNDS_HEIGHT+" : "+properties[openslide.PROPERTY_NAME_BOUNDS_HEIGHT])


#Return the best level for displaying the given downsample. Here : 20x/5=4
mag=float(properties[openslide.PROPERTY_NAME_OBJECTIVE_POWER])
downsample=mag/10
best_level=f.get_best_level_for_downsample(downsample)
print("Best level for 5x :"+str(best_level))

#thumbnail image
#plt.figure(figsize=(10,10))
#thumb=f.get_thumbnail(dims[-1]) #maximum display size to smallest downsampled image downsample=128
#plt.imshow(thumb)
##plt.axis("off")
#plt.title("Macro image")
#plt. close()

#croped tile
#x=6000
#y=15000
#plt.figure(figsize=(10,10))

#crop=f.read_region((x,y),best_level,(patch_size,patch_size))
#plt.subplot(121)
#plt.imshow(crop)
##plt.axis('off')
#plt.title("Croped tile")
#plt.subplot(122)
#crop2=f.read_region((x+int(0.5*patch_size*int(downsample)),y),best_level,(patch_size,patch_size))
#plt.imshow(crop2)
##plt.axis('off')
#plt.title("Croped tile")
#
##Img_to_np.array
#img=list(crop2.getdata())
#img=np.array(img)
#img=img.reshape(128,128,4)
#img=img[:,:,0:3]
#img=img.reshape(1,128,128,3)
#img=img/255


#%%
# =============================================================================
# load model
# =============================================================================
from keras.models import load_model
from keras import models

#vgg16_dense_bn
model=load_model('E:\\deeplearning\\Hepatocarcinomes\\models\\10x\\vgg16_dense_bn_\\adam_64_lr3_weights.15-0.9289.hdf5')
model.summary()

#extract the outputs of the  layers
layer_outputs=[layer.output for layer in model.layers[:]]

#layer names
layer_names=[]
for layer in model.layers[:]:
    layer_names.append(layer.name)
     
#create a model that will return the last three outputs given the model input
# prendre layer 24  'dense2'
activation_model=models.Model(inputs=model.input, outputs=layer_outputs[26:29])


## =============================================================================
## predict for one image
## =============================================================================
##feed with one image
##will return a list of np arrays one per layer activation
#activations=activation_model.predict(img)
# 
##512 features layer
#features=activations[0]
#features=features.reshape(512)
# 
# #probabilities
#pb=activations[2]
#pb=pb.reshape(2)
# 
#plt.figure()
#plt.imshow(features.reshape(16,32),vmin=0,vmax=3.0)
#plt.title(str(pb[0]))
#plt.axis=('off')
#plt. close()

# =============================================================================
# predict full slide with OFFSET
# =============================================================================
(width,height)=dims[best_level]

cols=int(np.floor(width/patch_size/stride))
rows=int(np.floor(height/patch_size/stride))
dx=patch_size*downsample*stride
dy=dx
print("cols "+str(cols))
print("rows "+str(rows))
print("(dx, dy) = "+str(dx))
    
#features_map=np.zeros((cols,rows,512))
pb_map=np.zeros((cols,rows,2))

from tqdm import tqdm
pbar1=tqdm(total=rows,desc='row', miniters=1,position=0)
for j in range(rows):
    pbar1.update()
    for i in range (cols):
        #print(int(i*patch_size*downsample),int(j*patch_size*downsample))
        x=int(i*dx)
        y=int(j*dy)
        #print(x)
        #3 level: 
        #1- the original slide: here 40x, for set coordinates x, y
        #2- best_level: 5x, from which extract
        #3- the output heatmap: for calculate rows, cols
        #the final output heatmap will have a offset of 1/2*stride*patch_size on 5x
        #That is to say the heatmap have 1/2 pixel offset righter and lower than what it should be
        crop=f.read_region((x,y),best_level,(patch_size,patch_size))
        img=list(crop.getdata())
        img=np.array(img)
        img=img.reshape(128,128,4)
        img=img[:,:,0:3]
        img=img.reshape(1,128,128,3)
        img=img/255
        activations=activation_model.predict(img)
        #512 features layer
#        features=activations[0]
#        features=features.reshape(512)
#        features_map[i,j,:]=features
        #probabilities
        pb=activations[2]
        pb=pb.reshape(2)
        pb_map[i,j,:]=pb 
        
#fig=plt.subplot(rows,cols,n)
#plt.imshow(img)
#fig.axes.get_xaxis().set_visible(False)
#fig.axes.get_yaxis().set_visible(False)
#n=n+1

#plot pb maps
plt.figure(figsize=(15,10))
plt.subplot(221)#pb map for tumoral
plt.imshow(np.transpose(pb_map[:,:,0]),cmap='plasma',interpolation='gaussian')
plt.subplot(222)#pb map for non tumoral
plt.imshow(np.transpose(pb_map[:,:,1]),cmap='plasma',interpolation='gaussian')
plt.subplot(222)#features vector for y=100
#plt.matshow(np.transpose(features_map[:,100,:]))

#probability map (for tumoral tissue)
heatmap=np.transpose(pb_map[:,:,1])


#%%
# =============================================================================
# save results with OFFSET and close
# =============================================================================

#little tips:
#"img" above is a temporal variable to save a patch to be predicted,
#below it is the macro image.

#get macro image at smallest resolution available
#img=f.get_thumbnail(dims[-1]) 
thumb_level=f.get_best_level_for_downsample(patch_size*downsample*stride)
img=f.read_region((0,0),thumb_level,dims[thumb_level])
#save macro image
#img.save(out_path + "_macro.png")


#Transform heat map to PIL image
#8 bit probability map
heatmap_im = Image.fromarray(np.uint8(heatmap*255))
heatmap_im.save(out_path + '_PbMap8bit' + stride_string + '_10x.png')

#with colormap
heatmap_im = Image.fromarray(np.uint8(cm.plasma(heatmap)*255))
heatmap_im.save(out_path + '_PbMap8bit_plasma' + stride_string + '_10x.png')
#In fact, not precise. Should look back to the definition of "cols" and "rows". Resize by integer and possibly make padding.		
# Filter no that important for it is only for visualization.		
if (heatmap_im.size[0]<dims[thumb_level][0]):		
    heatmap_im = heatmap_im.resize((dims[thumb_level]), Image.BICUBIC)		
else:		
    heatmap_im = heatmap_im.resize((dims[thumb_level]))

#merge macro and heatmap
im=img.convert("RGBA")
heatmap_im=heatmap_im.convert("RGBA")
heatmap_im=heatmap_im.filter(ImageFilter.BLUR) #ou ImageFilter.GaussianBlur(radius=2)
blended = Image.blend(im, heatmap_im, alpha=0.4)
blended.save(out_path + '_blended' + stride_string + '_10x.png')

plt.figure(figsize=(10,10))
plt.imshow(blended)

# close the image
f.close()

#mean feature vector of the slide
#qq=features_map.reshape(rows*cols,512)
#qq=qq[heatmap.reshape((rows*cols))>0.5,:]
#qq=np.mean(qq,axis=0)
#plt.figure()
#plt.matshow(np.reshape(qq,(1,512)),aspect=50)
#plt.figure()
#plt.plot(qq)

#save np.arrays as npy files
#file= out_path + '_features' + stride_string + '_10x.npy'
#np.save(file,features_map)
#load
#zz=np.load(file)
file= out_path + '_pb' + stride_string + '_10x.npy'
np.save(file,pb_map)



