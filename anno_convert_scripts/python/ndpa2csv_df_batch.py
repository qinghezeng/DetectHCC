# -*- coding: utf-8 -*-
"""
Created on Fri May 24 18:48:24 2019

To read a ndpa file as dataframe and save it into a csv file.
Extracted info: type, shape, points.

@author: visiopharm5
"""

#%%
import xml.etree.ElementTree as ET
import pandas as pd
import os
import re

#%%
def ndpa2csv(name):
    path = "E:\\deeplearning\\Hepatocarcinomes\\slides_annotations_hammamatsu"
    file = os.path.join(path, name)
    
    tree = ET.parse(file)  
    roots = tree.getroot()
    
    points = [] #list to save info for each point
    
    for i in range(len(roots)):
        type = roots[i][0].text
        # many slides are labelled in a NT1-like format
        if type!='T' and type!='NT':
            if type.startswith(('N', 'n')):
                type = 'NT'
            elif type.startswith(('T', 't')):
                type = 'T'
            # other format or non-labelled
            else:
                return 0
        shape = roots[i][10].attrib['type']
        for point in roots[i][10][2]:
            x = int(point[0].text)
            y = int(point[1].text)
            points.append([i, type, shape, x, y])
    
    df = []        
            
    df = pd.DataFrame(points, columns=['id', 'type','shape', 'x', 'y'])
    
    # export to csv
    df.to_csv(os.path.join(path, re.split(' |- ', name[:-10])[0]+'_anno_df.csv'))
    
    # read from csv
    #df = pd.read_csv(os.path.join(path, name[:-10]+'_df.csv'))

    return 1
    
#%%
path = "E:\\deeplearning\\Hepatocarcinomes\\slides_annotations_hammamatsu"

names = []
for root, dirs, files in os.walk(path):
    for f in files:
        if f.endswith('.ndpa'):
            names.append(f)
        
#name = 'R10_004_2 - 2017-08-23 19.43.29.ndpi.ndpa'
#path = "E:\\deeplearning\\Hepatocarcinomes\\Biopsy HCC"
#name = 'HMNT0001.ndpi.ndpa'

from tqdm import tqdm
pbar1=tqdm(total=len(names),desc='slides', miniters=1,position=0)
for i in names:
    pbar1.update()
    if not ndpa2csv(i):
        print(re.split(' |- ', i[:-10])[0] +  ' Annotation error: unexpected class format.')


