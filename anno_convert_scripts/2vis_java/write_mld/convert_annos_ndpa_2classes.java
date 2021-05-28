//This script is to convert the annotation in ndpa files (from ndpView) to mld file, by batch.
//It will create a csv file to save the relationship between index and names of slides.
package write_mld;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;

public class convert_annos_ndpa_2classes {

	private static ArrayList<File> fileList = new ArrayList<File>();
	
	public static void main(String[] args) throws IOException {   
		//set the directory where the ndpa files are located.
	    String inPath = "W:\\HES HCC DL Projet\\";  
	    //read the names of all the 
	    getFiles(inPath);
	    String outPath = "W:\\HES HCC DL Projet\\annotation_vis\\test\\contenu.csv";  
	    writeIndex(outPath);
	    for(int iii=0;iii<fileList.size();iii++)
	    { 
	    	write_mld_label_batch_ndpa_2classes.ops(fileList.get(iii).getPath(), iii);
//	    	write_mld_roi_batch.ops(fileList.get(iii).getPath(), iii);
	    }
	}   

	public static void writeIndex(String path) {
		 try {  
		      File csv = new File(path);
		      
		      BufferedWriter bw = new BufferedWriter(new FileWriter(csv, true)); // true to apprend
		      for(int j=0;j<fileList.size();j++)
			    {
			      bw.write(j + "," + fileList.get(j));  
			      bw.newLine(); 
			    }
		      bw.close();  
		    } catch (FileNotFoundException e) {  
		      e.printStackTrace();  
		    } catch (IOException e) {  
		      e.printStackTrace();  
		    }  
		 }
	
	public static void getFiles(String path) throws IOException {   

	    File file = new File(path);   
	    File[] array = file.listFiles(); //this function does not guarantee any order
	    
	    for(int k=0;k<array.length;k++)
	    {   
	        if(array[k].getName().endsWith(".ndpa"))
	        {   
	            System.out.println(array[k].getName()); //print the name of the ndpa file
	            System.out.println(array[k]);   //print the path and the name of the ndpa file
//	            System.out.println(array[i].getPath());   //the same as the above command
	            fileList.add(array[k]);
	        }
	    }  
	}   
}
