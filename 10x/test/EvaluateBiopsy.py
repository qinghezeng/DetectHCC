# -*- coding: utf-8 -*-
"""
Created on Mon Apr  1 21:39:46 2019

@author: INSERM
Classify biopsies (2 classes)
Evaluate results (1 class)
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

slide_name='R10_004_20- 2017-08-25 16.30.19.ndpi'
slide_path=os.path.join("E:\\deeplearning\\Hepatocarcinomes\\BiopsyHCC", slide_name)
if slide_name[:-5].split('- ')[0].endswith(' '):
    out_path=os.path.join("E:\\deeplearning\\Hepatocarcinomes\\BiopsiesClassification", slide_name[:-5].split(' - ')[0])
else:
    out_path=os.path.join("E:\\deeplearning\\Hepatocarcinomes\\BiopsiesClassification", slide_name[:-5].split('- ')[0])
    
patch_size=128
#attention! stride cannot be 1. The following codes assume there is a shift in the predicton
stride = 0.25 #in % of patch width: 0.125(8), 0.25(16), 0.5(32), 0.75(48)
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
#from keras.models import load_model
#from keras import models
#
##vgg16_dense_bn
#model=load_model('E:\\deeplearning\\Hepatocarcinomes\\models\\5x\\vgg16_dense_bn\\best_model')
#model.summary()
#
##extract the outputs of the  layers
#layer_outputs=[layer.output for layer in model.layers[:]]
#
##layer names
#layer_names=[]
#for layer in model.layers[:]:
#    layer_names.append(layer.name)
#     
##create a model that will return the last three outputs given the model input
## prendre layer 24  'dense2'
#activation_model=models.Model(inputs=model.input, outputs=layer_outputs[26:29])


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
#pb_map=np.zeros((cols,rows,2))
#
#from tqdm import tqdm
#pbar1=tqdm(total=rows,desc='row', miniters=1,position=0)
#for j in range(rows):
#    pbar1.update()
#    for i in range (cols):
#        #print(int(i*patch_size*downsample),int(j*patch_size*downsample))
#        x=int(i*dx)
#        y=int(j*dy)
#        #print(x)
#        #3 level: 
#        #1- the original slide: here 40x, for set coordinates x, y
#        #2- best_level: 5x, from which extract
#        #3- the output heatmap: for calculate rows, cols
#        #the final output heatmap will have a offset of 1/2*stride*patch_size on 5x
#        #That is to say the heatmap have 1/2 pixel offset righter and lower than what it should be
#        crop=f.read_region((x,y),best_level,(patch_size,patch_size))
#        img=list(crop.getdata())
#        img=np.array(img)
#        img=img.reshape(128,128,4)
#        img=img[:,:,0:3]
#        img=img.reshape(1,128,128,3)
#        img=img/255
#        activations=activation_model.predict(img)
#        #512 features layer
#        features=activations[0]
#        features=features.reshape(512)
#        features_map[i,j,:]=features
#        #probabilities
#        pb=activations[2]
#        pb=pb.reshape(2)
#        pb_map[i,j,:]=pb
#        
#fig=plt.subplot(rows,cols,n)
#plt.imshow(img)
#fig.axes.get_xaxis().set_visible(False)
#fig.axes.get_yaxis().set_visible(False)
#n=n+1

#plot pb maps
#plt.figure(figsize=(15,10))
#plt.subplot(221)#pb map for tumoral
#plt.imshow(np.transpose(pb_map[:,:,0]),cmap='plasma',interpolation='gaussian')
#plt.subplot(222)#pb map for non tumoral
#plt.imshow(np.transpose(pb_map[:,:,1]),cmap='plasma',interpolation='gaussian')
#plt.subplot(222)#features vector for y=100
#plt.matshow(np.transpose(features_map[:,100,:]))
#
##probability map (for tumoral tissue)
#heatmap=np.transpose(pb_map[:,:,0])


#%%
# =============================================================================
# save results with OFFSET and close
# =============================================================================

#little tips:
#"img" above is a temporal variable to save a patch to be predicted,
#below it is the macro image.

##get macro image at smallest resolution available
##img=f.get_thumbnail(dims[-1]) 
#thumb_level=f.get_best_level_for_downsample(patch_size*downsample*stride)
#img=f.read_region((0,0),thumb_level,dims[thumb_level])
##save macro image
#img.save(out_path + "_macro.png")


##Transform heat map to PIL image
##8 bit probability map
#heatmap_im = Image.fromarray(np.uint8(heatmap*255))
#heatmap_im.save(out_path + "_PbMap8bit_10x.png")
#
##with colormap
#heatmap_im = Image.fromarray(np.uint8(cm.plasma(heatmap)*255))
#heatmap_im.save(out_path + "_PbMap8bit_plasma_10x.png")
##In fact, not precise. Should look back to the definition of "cols" and "rows". Resize by integer and possibly make padding.		
## Filter no that important for it is only for visualization.		
#if (heatmap_im.size[0]<dims[thumb_level][0]):		
#    heatmap_im = heatmap_im.resize((dims[thumb_level]), Image.BICUBIC)		
#else:		
#    heatmap_im = heatmap_im.resize((dims[thumb_level]))
#
##merge macro and heatmap
#im=img.convert("RGBA")
#heatmap_im=heatmap_im.convert("RGBA")
#heatmap_im=heatmap_im.filter(ImageFilter.BLUR) #ou ImageFilter.GaussianBlur(radius=2)
#blended = Image.blend(im, heatmap_im, alpha=0.4)
#blended.save(out_path + "_blended_10x.png")
#
#plt.figure(figsize=(10,10))
#plt.imshow(blended)
#
## close the image
#f.close()
#
##mean feature vector of the slide
#qq=features_map.reshape(rows*cols,512)
#qq=qq[heatmap.reshape((rows*cols))>0.5,:]
#qq=np.mean(qq,axis=0)
#plt.figure()
#plt.matshow(np.reshape(qq,(1,512)),aspect=50)
#plt.figure()
##plt.plot(qq)
#
##save np.arrays as npy files
#file= out_path + "_features_10x.npy"
#np.save(file,features_map)
##load
##zz=np.load(file)
#file= out_path + "_pb_10x.npy"
#np.save(file,pb_map)

#%%
# =============================================================================
# reload proababilities and build map without OFFSET (2 times larger than real map)
# =============================================================================
pb_map=np.load(out_path+'_pb' + stride_string + '_10x.npy')

#build a probability map
heatmap=np.transpose(pb_map[:,:,1]) #1 is tum
heatmap_im = Image.fromarray(np.uint8(heatmap*255))

#build a true probability without offset nor padding
import copy

[w, h] = copy.copy(heatmap_im.size)
[w, h] = [w * 2, h * 2]
heatmap_img = heatmap_im.resize((w, h), Image.ANTIALIAS)
heatmap_im_ajusted = Image.new('L', (w, h))
crop = heatmap_img.crop((0, 0, w-1, h-1))
heatmap_im_ajusted.paste(crop, (1, 1, w, h))
#save a probability map for Visiopharm
#res = 1/float(properties[openslide.PROPERTY_NAME_MPP_Y])/8/16*2*25400
#heatmap_im_ajusted.save(out_path+"_PbMap8bit_vis_10x.tiff", dpi=(res, res))

heatmap = np.asarray(heatmap_im_ajusted) / 255

# find the smalllest dimension for annotations without rounding error
import math

index=-1

# 1 smallest integer rescale factor. 2 not smaller than prob map
while math.modf(level_downsamples[index])[0]!=0 or dims[index][0] < heatmap.shape[1]:
    index = index - 1
(w, h) = dims[index]

# calculate how many times should rescale the annotations to match the prob map
#could be .5 if stride is 0.75
if math.modf(w/heatmap.shape[1])[0]>0.4 and math.modf(w/heatmap.shape[1])[0]<0.6:
    times = w // heatmap.shape[1] + 0.5
else:
    times = w // heatmap.shape[1]

#%%
# =============================================================================
# load annotation
# =============================================================================
from PIL import ImageDraw

# read annotations from csv
df = pd.read_csv(slide_path[:-5].split('- ')[0] + '_anno_df.csv')

# properties to translate coordinates of annotations
offsetx = int(properties['hamamatsu.XOffsetFromSlideCentre'])
offsety = int(properties['hamamatsu.YOffsetFromSlideCentre'])
mppx = float(properties[openslide.PROPERTY_NAME_MPP_X])
mppy = float(properties[openslide.PROPERTY_NAME_MPP_Y])

#translate annotations
list_point = []
types = []
shapes = []
anno = 0
list_point.append([])

for i in range(len(df)):
    if (df['id'][i] != anno):
        list_point.append([])
        types.append(df['type'][i-1])
        shapes.append(df['shape'][i-1])
        anno = anno + 1
    xcor = df['x'][i]
    xcor = xcor - offsetx
    xcor = xcor /1000 / mppx / downsample / patch_size * times / stride * 2 + w/2
    ycor = df['y'][i]
    ycor = ycor - offsety
    ycor = ycor /1000 / mppy / downsample / patch_size * times / stride * 2 + h/2
    list_point[anno].append((xcor, ycor))

types.append(df['type'][len(df)-1])
shapes.append(df['shape'][len(df)-1])
    
mask_anno = Image.new('L', (w, h))
draw = ImageDraw.Draw(mask_anno)
for i in range((anno+1)):
    if shapes[i] == 'freehand':
        if types[i] == 'T':
            draw.polygon(list_point[i], outline=255, fill=255)
        else:
            raise ValueError('Annotation error: unknown class.')
    else:
        raise ValueError('Annotation error: not polygon.')
#mask_anno.save(out_path + '_grayscale_annotation_.png')

# resize the annotation to match the prob map
crop = mask_anno.crop((0, 0, int(heatmap.shape[1]*times), int(heatmap.shape[0]*times)))
# default "resample" is set to Image.NEAREST. 
# NEAREST is the best here (downsampling) on all overall indicators with fine annotation. 
# The AUC and accuracy could be very different. Also depends on your PIL version.
annotations_im = crop.resize((heatmap.shape[1], heatmap.shape[0]))
annotations_im.save(out_path + '_annotation.png')
annotations = np.asanyarray(annotations_im)

#%%
## =============================================================================
## draw annotations on probability map
## =============================================================================
##some colormap may need a inversion first   
#from PIL import ImageOps  
#
##heatmap_im_ajusted = ImageOps.invert(heatmap_im_ajusted)
##from matplotlib import colors
##cmap = colors.LinearSegmentedColormap.from_list("", ["green","yellow","red"]) #jet
##cm_hot = cm.get_cmap(cmap)
#cm_hot = cm.get_cmap(cm.plasma)
#heatmap_data = cm_hot(heatmap)
#heatmap_im_color = Image.fromarray(np.uint8(heatmap_data*255)) #heatmap with color
#
##thumb image    
#downsampling = int(width/w) #(width,height) is of 5x level
#thumb_level=f.get_best_level_for_downsample(patch_size*downsample*stride/2)
#image=f.read_region((0,0),thumb_level,dims[thumb_level])
#image=image.convert("RGBA")
#
##blended image
#heatmap_im_rgba=heatmap_im_color.convert("RGBA")
#heatmap_im_rgba=heatmap_im_rgba.filter(ImageFilter.BLUR) #ou ImageFilter.GaussianBlur(radius=2)
#blended = Image.blend(image, heatmap_im_rgba, alpha=0.5)
#draw = ImageDraw.Draw(blended)
#for i in range((anno+1)):
#    draw.polygon(list_point[i], outline="black")
#blended.show()
#
##draw annotation
#draw = ImageDraw.Draw(blended)
#for i in range((anno+1)):
##    draw annotations in a fine polygon
##    draw.polygon(list_point[i], outline="red")
##    a trick to draw a thick polygon, but sometimes not complete
#    draw.line(list_point[i], fill="red", width=1)
#    for point in list_point[i]:
#        draw.ellipse((point[0] - 4, point[1] - 4, point[0]  + 4, point[1] + 4), fill="red")
#blended.show()

#%%
# =============================================================================
# draw ROC curve and save
# =============================================================================
from sklearn.metrics import roc_curve, auc

fpr, tpr, thresholds  =  roc_curve(annotations.flatten(), heatmap.flatten(), pos_label=255)
roc_auc = auc(fpr, tpr)

# calculate the optimal threshold
best_threshold = np.argmax(tpr - fpr)

# plt.plot(fpr,tpr) to draw. 'roc_auc' records the value of auc, which can be calculated by the auc() function.
plt.plot(fpr, tpr, lw=1, label='auc = %0.3f, tpr = %0.3f, tnr = %0.3f, thres = %0.3f' % ( roc_auc, tpr[best_threshold], 1-fpr[best_threshold], thresholds[best_threshold]))
# Draw diagonal
plt.plot([0, 1], [0, 1], '--', color=(0.6, 0.6, 0.6))
# Draw perfect preformance
# plt.plot([0, 0, 1], [0, 1, 1],
#          linestyle = ':',
#          color = 'black')

plt.xlim([-0.05, 1.05])
plt.ylim([-0.05, 1.05])
plt.xlabel('False Positive Rate (1 - Specificity)')
plt.ylabel('True Positive Rate (Sensitivity)')
plt.title('ROC curve: VGG16 on '+slide_name[:-5].split('- ')[0] + ' ' + stride_string[1:]+' 10x')
plt.legend(loc="lower right")
plt.savefig(out_path + '_vgg16_roc' + stride_string + '_10x.jpg')
plt.show()

#%%
# =============================================================================
# calculate performance using optimal threshold and save
# =============================================================================
TP = 0
TN = 0 
FP = 0
FN = 0

# sometimes meet with OpenSlideError when extract some regions
FPError = []
FNError = []

for i in range(annotations.shape[0]):
    for j in range(annotations.shape[1]):
        if annotations[i, j] == 255: #tum
            if heatmap[i, j] > thresholds[best_threshold]: #tum
                TP = TP + 1
            else :
#                try:
                # the heatmap for comparation is 2 times larger that the acutal one, so the size is half of the patch size predicted
#                    crop=f.read_region((int(j*dx/2), int(i*dy/2)),best_level,(int(patch_size*stride/2), int(patch_size*stride/2)))
#                except: #catch the OpenSlideError 
#                    FNError.append([i, j])
#                else:
#                    crop.save('E:\\deeplearning\\Hepatocarcinomes\\BiopsiesClassification\\FalseSample\\TestSet\\FN_10x\\'+ stride_string + '\\' + slide_name[:-5].split('- ')[0]+'_'+str(FN).zfill(5)+'.tif')
                FN = FN + 1
        else:
            if heatmap[i, j] > thresholds[best_threshold]:
#                try:
#                    crop=f.read_region((int(j*dx/2), int(i*dy/2)),best_level,(int(patch_size*stride/2), int(patch_size*stride/2)))
#                except:
#                   FPError.append([i, j])
#                else:
#                    crop.save('E:\\deeplearning\\Hepatocarcinomes\\BiopsiesClassification\\FalseSample\\TestSet\\FP_10x\\' + stride_string + '\\' +slide_name[:-5].split('- ')[0]+'_'+str(FP).zfill(5)+'.tif')
                FP = FP + 1
            else :
                TN = TN + 1
                
if len(FNError)!=0 or len(FPError)!=0: 
    with open(out_path+'_OpenSlideError.txt', 'w') as doc:
        doc.write('OpenSlideError when try to extract FN patch correspondent to annotations:' +'\n')
        doc.write(str(FNError))
        doc.write('\n\n '+ 'OpenSlideError when try to extract FP patch correspondent to annotations:' + '\n')
        doc.write(str(FPError))
    print(slide_name + ' met with OpenSlideError when extract patches.')
del(FNError, FPError)

sensitivity = TP / (TP + FN)
specificity = TN / (TN + FP)
precision = TP / (TP + FP)
fall_out = FP / (FP + TN)

accuracy = (TP + TN) / (TP + TN + FP + FN)
F1 = 2 * TP / (2*TP + FP + FN)

iou = TP / (TP + FN + FP) #tum_IoU = overlap / (positive_prediction + positive_anno - overlap) = TP / ((TP + FP) + (TP + FN) -TP)

performance = pd.DataFrame(np.array([[slide_name, thresholds[best_threshold], TP, TN, FP, FN, sensitivity, specificity, precision, 
                                     fall_out, roc_auc, accuracy, F1, iou]]),
                    columns=['Slide Name', 'Optimal Threshold', 'True Positive', 'True Negative', 'False Positive', 'False Negative',
                                'Sensitivity (TPR)', 'Specificity (TNR)', 'Precision (PPV)', 'Fall-Out (FPR)', 'Area under ROC (AUC)', 
                                'Accuracy (ACC)', 'F1-Score', 'Intersection over Union (IoU)'])

# save all the indicators from dataframe to csv
if os.path.isfile(out_path.split('R')[0]+'vgg16_performance_training' + stride_string + '_10x.csv'):
    performance.to_csv(out_path.split('R')[0]+'vgg16_performance_training' + stride_string + '_10x.csv', index=False, header=False, mode='a')
else:
    performance.to_csv(out_path.split('R')[0]+'vgg16_performance_training' + stride_string + '_10x.csv', index=False, header=True, mode='a')

#%%
# =============================================================================
# draw a normalized confusion matrix and save
# =============================================================================
labels = ['Tumor', 'Normal']

tick_marks = np.array(range(len(labels))) + 0.5

def plot_confusion_matrix(ConMat, title='Confusion Matrix', cmap=plt.cm.binary):
    plt.imshow(ConMat, interpolation='nearest', cmap=cmap)
    plt.title(title)
    plt.colorbar()
    xlocations = np.array(range(2))
    plt.xticks(xlocations, labels)
    plt.yticks(xlocations, labels)
    plt.ylabel('Prediction')
    plt.xlabel('Annotation')

ConMat = np.array([[TP, FP], [FN, TN]])
np.set_printoptions(precision=2)
cm_normalized = ConMat.astype('float') / ConMat.sum(axis=0)[np.newaxis, :]
print('cm_normalized')
plt.figure(figsize=(12, 8), dpi=120)

ind_array = np.arange(len(labels))
x, y = np.meshgrid(ind_array, ind_array)

for x_val, y_val in zip(x.flatten(), y.flatten()):
    c = cm_normalized[y_val][x_val]
    if c > 0.01:
        plt.text(x_val, y_val, "%0.2f" % (c,), color='red', fontsize=7, va='center', ha='center')

# offset the tick
plt.gca().set_xticks(tick_marks, minor=True)
plt.gca().set_yticks(tick_marks, minor=True)
plt.gca().xaxis.set_ticks_position('none')
plt.gca().yaxis.set_ticks_position('none')
plt.grid(True, which='minor', linestyle='-')
plt.gcf().subplots_adjust(bottom=0.15)

plot_confusion_matrix(cm_normalized, title='Normalized confusion matrix on '+slide_name[:-5].split('- ')[0]+' '+stride_string[1:]+' 10x')
# show confusion matrix
plt.savefig(out_path+'_confusion_matrix' + stride_string + '_10x.png', format='png')
#plt.show()
plt.close()



