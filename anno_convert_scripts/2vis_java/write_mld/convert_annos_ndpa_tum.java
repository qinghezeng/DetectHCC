//This script is to convert the annotations in ndpa files (from ndpView) to mld file, by batch.
//Only to recognize annotations which is set to "T"(tumoral) class.
//Save the mld files to the correspondent directories in database.
//So if we set the filenames to "LayerData", it is possible to import database using Visiopharm.
//How to set the filenames to "LayerData"? In class "write_mld_roi_batch_ndpa_tum", comment line 34 and enable line 36.
package write_mld;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;

public class convert_annos_ndpa_tum {

	private static ArrayList<File> fileList = new ArrayList<File>();
	
	public static void main(String[] args) throws IOException {   
		//set the directory where the ndpa files are located.
	    String inPath = "W:\\HES HCC DL Projet\\";  
	    //read the names of all the 
	    getFiles(inPath);
	    for(int iii=0;iii<fileList.size();iii++)
	    { 
	    	String[] parts = fileList.get(iii).getName().split(".ndpi");
	    	String name = parts[0]; 
	    	name = name.replace(".","_");
//	    	write_mld_label_batch_ndpa_tum.ops(fileList.get(iii).getPath(), iii);
	    	write_mld_roi_batch_ndpa_tum.ops(fileList.get(iii).getPath(), name);
	    }
	}   
	
	public static void getFiles(String path) throws IOException {   

	    File file = new File(path);   
	    File[] array = file.listFiles(); //this function does not guarantee any order
	    Arrays.sort(array); //make files in the order as they are displayed in a folder
	    
	    for(int k=0;k<array.length;k++)
	    {   
	        if(array[k].getName().endsWith(".ndpa"))
	        {   
	            System.out.println(array[k].getName());   
	            System.out.println(array[k]);   
//	            System.out.println(array[i].getPath());   
	            fileList.add(array[k]);
	        }
	    }  
	}   
}
