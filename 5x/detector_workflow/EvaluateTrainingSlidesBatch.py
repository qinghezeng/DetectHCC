# -*- coding: utf-8 -*-
"""
Created on Mon Apr  1 21:39:46 2019

@author: INSERM
"""
import openslide
from openslide import OpenSlide
import matplotlib.pyplot as plt
import numpy as np
from PIL import Image
import os
from sklearn.metrics import roc_curve, auc
import pandas as pd
from PIL import ImageDraw

#%%
def ClassifySlide(slide_name):

    #slide_name='R10_004_3- 2017-08-25 13.25.36.ndpi'
    #slide_path=os.path.join("E:\\deeplearning\\Hepatocarcinomes\\Biopsy HCC", slide_name)
    #out_path="E:\\deeplearning\\Hepatocarcinomes\\data\\5x\\biopsy_HCC"
    
    slide_path=os.path.join("E:\\deeplearning\\Hepatocarcinomes\\slides_annotations_hammamatsu", slide_name)
    out_path=os.path.join("E:\\deeplearning\\Hepatocarcinomes\\SlidesClassification", slide_name[:-5].split(' ')[0])
    
    # =============================================================================
    # load properties of slide
    # =============================================================================
    
    #open a file pointer
    f=OpenSlide(slide_path)
    
    #level counts : number of downsampled images
#    levels=f.level_count
#    print("levels: "+str(levels))
    
    #size of flull slide images
    (width,height)=f.dimensions
#    print("Width= "+str(width)+", Height= "+str(height))
    
    #down sample
    level_downsamples=f.level_downsamples
    
    #levels dimensions
    dims=f.level_dimensions
    
#    for i in range(levels-1):
#        print("level "+str(i+1)+": (x,y)= "+str(dims[i+1])+"\tdownsampling= "+str(level_downsamples[i+1])) #no original (0)
    
    #Metadata    
    properties=f.properties

    # =============================================================================
    # prepare for prediction
    # =============================================================================
    
#    print("Properties :")
#    print("\t"+openslide.PROPERTY_NAME_VENDOR+" : "+properties[openslide.PROPERTY_NAME_VENDOR])
    #print("\t"+openslide.PROPERTY_NAME_QUICKHASH1+" : "+properties[openslide.PROPERTY_NAME_QUICKHASH1])
    #print("\t"+openslide.PROPERTY_NAME_BACKGROUND_COLOR+" : "+str(properties[openslide.PROPERTY_NAME_BACKGROUND_COLOR]))
#    print("\t"+openslide.PROPERTY_NAME_OBJECTIVE_POWER+" : "+properties[openslide.PROPERTY_NAME_OBJECTIVE_POWER])
#    print("\t"+openslide.PROPERTY_NAME_MPP_X+" : "+properties[openslide.PROPERTY_NAME_MPP_X]) #um
#    print("\t"+openslide.PROPERTY_NAME_MPP_Y+" : "+properties[openslide.PROPERTY_NAME_MPP_Y])
    #print("\t"+openslide.PROPERTY_NAME_BOUNDS_X+" : "+str(properties[openslide.PROPERTY_NAME_BOUNDS_X]))
    #print("\t"+openslide.PROPERTY_NAME_BOUNDS_Y+" : "+properties[openslide.PROPERTY_NAME_BOUNDS_Y])
    #print("\t"+openslide.PROPERTY_NAME_BOUNDS_WIDTH+" : "+properties[openslide.PROPERTY_NAME_BOUNDS_WIDTH])
    #print("\t"+openslide.PROPERTY_NAME_BOUNDS_HEIGHT+" : "+properties[openslide.PROPERTY_NAME_BOUNDS_HEIGHT])
    
    
    #Return the best level for displaying the given downsample. Here : 20x/5=4
    mag=float(properties[openslide.PROPERTY_NAME_OBJECTIVE_POWER])
    downsample=mag/5
    best_level=f.get_best_level_for_downsample(downsample)
#    print("Best level for 5x :"+str(best_level))
     
    #thumbnail image
#    plt.figure(figsize=(10,10))
#    thumb=f.get_thumbnail(dims[-1]) #maximum display size to smallest downsampled image downsample=128
#    plt.imshow(thumb)
#    #plt.axis("off")
#    plt.title("Macro image")
#    plt.close()
    
    #croped tile
    #x=6000
    #y=15000
    #plt.figure(figsize=(10,10))
    patch_size=64
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
    #img=img.reshape(64,64,4)
    #img=img[:,:,0:3]
    #img=img.reshape(1,64,64,3)
    #img=img/255

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
    ##extract the outputs of the layers
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
    
    
    # =============================================================================
    # predict full slide
    # =============================================================================  
    (width,height)=dims[best_level]
#    cols=int(np.floor(width/patch_size))
#    rows=int(np.floor(height/patch_size))
    dx=patch_size*downsample
    dy=dx
    #print("cols "+str(cols))
    #print("rows "+str(rows))
    #print("(dx, dy) = "+str(dx))
    #    
    #features_map=np.zeros((cols,rows,512))
    #pb_map=np.zeros((cols,rows,2))
    #
    #from tqdm import tqdm
    #pbar1=tqdm(total=rows,desc='row', miniters=1,position=0)
    ##n=1
    #for j in range(rows):
    #    pbar1.update()
    #    for i in range (cols):
    #        #print(int(i*patch_size*downsample),int(j*patch_size*downsample))
    #        x=int(i*dx)
    #        y=int(j*dy)
    #        #print(x)
    #        crop=f.read_region((x,y),best_level,(patch_size,patch_size)) #location is upper left of level 0
    #        img=list(crop.getdata())
    #        img=np.array(img)
    #        img=img.reshape(64,64,4)
    #        img=img[:,:,0:3]
    #        img=img.reshape(1,64,64,3)
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
    ##fig=plt.subplot(rows,cols,n)
    ##plt.imshow(img)
    ##fig.axes.get_xaxis().set_visible(False)
    ##fig.axes.get_yaxis().set_visible(False)
    ##n=n+1
    #
    ##plot pb maps
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
    

    # =============================================================================
    # save results and close
    # =============================================================================
    
    ##little tips:
    ##"img" above is a temporal variable to save a patch to be predicted,
    ##below it is the macro image.
    #
    ##get macro image at smallest resolution available
    ##img=f.get_thumbnail(dims[-1])
    #thumb_level=f.get_best_level_for_downsample(patch_size*downsample)
    #img=f.read_region((0,0),thumb_level,dims[thumb_level])
    ##save macro image
    #img.save(out_path+"macro.png")
    #
    #
    ##Transform heat map to PIL image
    ##8 bit probability map
    #heatmap_im = Image.fromarray(np.uint8((heatmap)*255))
    #heatmap_im.save(out_path+"_PbMap8bit.png")
    #
    ##with colormap
    #heatmap_im = Image.fromarray(np.uint8(cm.plasma(heatmap)*255))#plasma
    #heatmap_im.save(out_path+"_PbMap8bit_plasma.png")
    ##The sample not precise.
    ##In fact, not precise. Should look back to the definition of "cols" and "rows". Resize by integer and possibly make padding.
    ## Filter no that important for it is only for visualization.
    #if (heatmap_im.size[0]<dims[thumb_level][0]):
    #    heatmap_im = heatmap_im.resize((dims[thumb_level]), Image.BICUBIC)
    #else:
    #    heatmap_im = heatmap_im.resize((dims[thumb_level]))
    #
    ##merge macro and heatmap
    #img=img.convert("RGBA")
    #heatmap_im=heatmap_im.convert("RGBA")
    #heatmap_im=heatmap_im.filter(ImageFilter.BLUR) #ou ImageFilter.GaussianBlur(radius=2)
    #blended = Image.blend(img, heatmap_im, alpha=0.25)
    #blended.save(out_path+"blended.png")
    #
    #plt.figure(figsize=(10,10))
    #plt.imshow(blended)
    #
    ## close the image
    #f.close()
    
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
    #file=out_path+"features.npy"
    #np.save(file,features_map)
    ##load
    ##zz=np.load(file)
    #file=out_path+"pb.npy"
    #np.save(file,pb_map)

    # =============================================================================
    # reload proababilities and build map
    # =============================================================================
    pb_map=np.load(out_path+"_pb.npy")
    
    #build a probability map
    heatmap=np.transpose(pb_map[:,:,0])
#    heatmap_im = Image.fromarray(np.uint8(heatmap*255))
    
    # find the smalllest dimension for annotations without rounding error
    import math
    
    index=-1
    
    # 1 smallest integer rescale factor. 2 not smaller than prob map
    while math.modf(level_downsamples[index])[0]!=0 or dims[index][0] < heatmap.shape[1]:
        index = index - 1
    (w, h) = dims[index]
    
    # calculate how many times should rescale the annotations to match the prob map
    times = w // heatmap.shape[1]

    # =============================================================================
    # load annotation
    # =============================================================================
    
    # read annotations from csv
    df = pd.read_csv(slide_path[:-5].split(' ')[0] + '_anno_df.csv')
    
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
        xcor = xcor /1000 / mppx / downsample / patch_size * times +w/2
        ycor = df['y'][i]
        ycor = ycor - offsety
        ycor = ycor /1000 / mppy / downsample / patch_size * times +h/2
        list_point[anno].append((xcor, ycor))
        
    types.append(df['type'][len(df)-1])
    shapes.append(df['shape'][len(df)-1])
        
    if all(type == 'T' for type in types) or all(type == 'NT' for type in types):
        return False
    
    mask_anno = Image.new('L', (w, h))
    draw = ImageDraw.Draw(mask_anno)
    for i in range((anno+1)):
        if shapes[i] == 'freehand':
            if types[i] == 'T':
                draw.polygon(list_point[i], outline=255, fill=255)
            elif types[i] == 'NT':
                draw.polygon(list_point[i], outline=100, fill=100)
            else:
                raise ValueError('Annotation error: unknown class.')
        else:
            raise ValueError('Annotation error: not polygon.')
    #mask_anno.save(out_path + '_grayscale_annotation_.png')
    
    # resize the annotation to match the prob map
    crop = mask_anno.crop((0, 0, heatmap.shape[1]*times, heatmap.shape[0]*times))
    # default "resample" is set to Image.NEAREST. 
    # NEAREST is the best here (downsampling) on all overall indicators with fine annotation. 
    # The AUC and accuracy could be very different. Also depends on your PIL version.
    annotations_im = crop.resize((heatmap.shape[1], heatmap.shape[0]))
    annotations_im.save(out_path + '_annotation.png')
    annotations = np.asanyarray(annotations_im)

    # =============================================================================
    # draw ROC curve and save
    # =============================================================================
    
    annotated = annotations.flatten()!=0
    
    fpr, tpr, thresholds  =  roc_curve(annotations.flatten()[annotated], heatmap.flatten()[annotated], pos_label=255)
    roc_auc = auc(fpr, tpr)
    
    # calculate the optimal threshold
    # Normally, we use Youden's J statistic.
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
    plt.title('ROC curve: VGG16 on '+slide_name[:-5].split(' ')[0])
    plt.legend(loc="lower right")
    plt.savefig(out_path + '_vgg16_roc.jpg')
#    plt.show()
    plt.close()

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
            if annotations[i, j] == 255:
                if heatmap[i, j] > thresholds[best_threshold]:
                    TP = TP + 1
                else :
                    try:
                        crop=f.read_region((int(j*dx), int(i*dy)),best_level,(patch_size,patch_size))
                    except: #catch the OpenSlideError 
                        FNError.append([i, j])
                    else:
                        crop.save('E:\\deeplearning\\Hepatocarcinomes\\SlidesClassification\\FalseSample\\TrainingSet\\FN_5x\\'+slide_name[:-5].split(' ')[0]+'_'+str(FN).zfill(5)+'.tif')
                    FN = FN + 1
            elif annotations[i, j] == 100:
                if heatmap[i, j] > thresholds[best_threshold]:
                    try:
                        crop=f.read_region((int(j*dx), int(i*dy)),best_level,(patch_size,patch_size))
                    except:
                       FPError.append([i, j])
                    else:
                        crop.save('E:\\deeplearning\\Hepatocarcinomes\\SlidesClassification\\FalseSample\\TrainingSet\\FP_5x\\'+slide_name[:-5].split(' ')[0]+'_'+str(FP).zfill(5)+'.tif')
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
    
    accuracy = (TP + TN) / sum(annotated)
    F1 = 2 * TP / (2*TP + FP + FN)
    
    #tum_IoU = overlap / (positive_prediction + positive_anno - overlap) = TP / ((TP + FP) + (TP + FN) -TP)
    iou = TP / (TP + FN + FP)
    
    performance = pd.DataFrame(np.array([[slide_name, thresholds[best_threshold], TP, TN, FP, FN, sensitivity, specificity, precision, 
                                         fall_out, roc_auc, accuracy, F1, iou]]),
                       columns=['Slide Name', 'Optimal Threshold', 'True Positive', 'True Negative', 'False Positive', 'False Negative',
                                'Sensitivity (TPR)', 'Specificity (TNR)', 'Precision (PPV)', 'Fall-Out (FPR)', 'Area under ROC (AUC)', 
                                'Accuracy (ACC)', 'F1-Score', 'Intersection over Union (IoU)'])
    
    # save all the indicators from dataframe to csv
    if os.path.isfile(out_path.split('HMNT')[0]+'vgg16_performance_training.csv'):
        performance.to_csv(out_path.split('HMNT')[0]+'vgg16_performance_training.csv', index=False, header=False, mode='a')
    else:
        performance.to_csv(out_path.split('HMNT')[0]+'vgg16_performance_training.csv', index=False, header=True, mode='a')

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
#    print('cm_normalized')
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
    
    plot_confusion_matrix(cm_normalized, title='Normalized confusion matrix on '+slide_name[:-5].split('- ')[0])
    # show confusion matrix
    plt.savefig(out_path+'_confusion_matrix.png', format='png')
#    plt.show()
    plt.close()
    
    return True
    
    
#%%
path = "E:\\deeplearning\\Hepatocarcinomes\\slides_annotations_hammamatsu"

names = []
for root, dirs, files in os.walk(path):
    for f in files:
        if f.endswith('.ndpa'):
            #training slides
            #first remove: 4 test slide + 1 OpenSlideError 
            if not f.startswith(('HMNT0113 -', 'HMNT0132_bis -', 'HMNT0264 -', 'HMNT0478_bis ', 'HMNT0069_bis ')): 
                if f.startswith('HMNT0783_bis -'):
                    break
                else:
                    names.append(f[:-5])
                    
skipped = 0    
#slide_name='HMNT0001.ndpi'

from tqdm import tqdm
pbar1=tqdm(total=len(names),desc='slides', miniters=1,position=0)
for i in names:
    pbar1.update()
    if not ClassifySlide(i):
        print(i[:-5].split(' ')[0] + ' skipped: only have 1-class annotations.')
        skipped = skipped + 1

print(str(len(names)-skipped) + ' slides evaluated.')

