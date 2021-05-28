# -*- coding: utf-8 -*-
"""
Created on Thu Mar 19 10:37:06 2020

@author: visiopharm5
"""

import openslide
from openslide import OpenSlide
import matplotlib.pyplot as plt
import numpy as np
import os

slide_path="E:\\diagnostic_slides\\2f11aa57-0a3b-4d93-b33b-562027679a79"
out_path="X:\\DeepLearning\\ProjetHepatocarcinomes\\PythonCode\\SlideClassificationLympho"

#open a file pointer
slide_name="TCGA-2Y-A9H1-01Z-00-DX1.FE4D124E-AB92-4083-8D09-F025B0C637EB.svs"
slide_path=os.path.join(slide_path,slide_name)
f=OpenSlide(slide_path)

#level counts : number of downsampled images
levels=f.level_count
print("levels: "+str(levels))

#size of flull slide images
(width,height)=f.dimensions
print("Width= "+str(width)+", Height= "+str(height))

#down sample
level_downsamples=f.level_downsamples

#levels dimensions
dims=f.level_dimensions

for i in range(levels-1):
    print("level "+str(i+1)+": (x,y)= "+str(dims[i+1])+"\tdownsampling= "+str(level_downsamples[i+1])) #no original (0)

#Metadata    
properties=f.properties
print("Properties :")
print("\t"+openslide.PROPERTY_NAME_VENDOR+" : "+properties[openslide.PROPERTY_NAME_VENDOR])
print("\t"+openslide.PROPERTY_NAME_OBJECTIVE_POWER+" : "+properties[openslide.PROPERTY_NAME_OBJECTIVE_POWER])
print("\t"+openslide.PROPERTY_NAME_MPP_X+" : "+properties[openslide.PROPERTY_NAME_MPP_X]) #um
print("\t"+openslide.PROPERTY_NAME_MPP_Y+" : "+properties[openslide.PROPERTY_NAME_MPP_Y])