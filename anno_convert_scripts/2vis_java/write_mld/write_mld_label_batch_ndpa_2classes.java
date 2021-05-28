//A sub-fonction to make a batch processing.
//To write annotation exacted from ndpa files into mld files as labels by batch. 
package write_mld;

import java.util.ArrayList;
import java.io.*;
import java.nio.ByteBuffer;

public class write_mld_label_batch_ndpa_2classes {
	
	public write_mld_label_batch_ndpa_2classes() {}
	
	public static void ops(String fin, int index) throws IOException {
		
		int nlabel, sumpoint = 0, pointTemp = 0;
		int[] shape, type;
		int[] npoint;
		ArrayList<Float> point;
		double[] Rec; 
		
		//To pass name of a ndpa file to extract annotation from.	
		read_xml_2classes.set_file(fin);
		read_xml_2classes.read_data();
		nlabel = read_xml_2classes.get_anno_num();
		shape = read_xml_2classes.get_anno_shape();
		type = read_xml_2classes.get_anno_type();
		npoint = read_xml_2classes.get_point_num();
		for(int i=0; i<npoint.length; i++) {
			sumpoint = sumpoint + npoint[i];
		}
		point = read_xml_2classes.get_point();
		Rec= new double[] {0.0, 0.0, 3.4028234663852886E38, 3.4028234663852886E38, 0.0};
		
		//To create a mld file to write annotation into.
		File outFile = new File("W:\\HES HCC DL Projet\\annotation_vis\\test\\" + index + "_label.mld");
		
		//To create a Byte list for saving all the information to be written.
		ArrayList<Byte> listByte = new ArrayList<Byte>();
		byte[] buffer;
		
		try {

			//Magic. 
			listByte = ByteList_add_chars.op("LDFF", 4, listByte);
			//Version.
			listByte = ByteList_add_an_int.op(3, listByte);
			//Number of layer.
			listByte = ByteList_add_an_int.op(3, listByte);
			
			//ROI layer.
			listByte = ByteList_add_chars.op("ROI", 64, listByte);
			//InImageCoordinates.
			listByte = ByteList_add_a_bool.op(false, listByte);
			//Number of objects in ROI layer.
			listByte = ByteList_add_an_int.op(1, listByte);
			
			//Import all the annotation as labels.
			//Here we create a background object in the ROI layer, not necessary.
			//If only create labels in Visiopharm, there will not be the background object in the mld file exported.
			//BufferSize of ROI layer.
			listByte = ByteList_add_an_int.op(48, listByte);
			//Shape: Rectangle.
			listByte = ByteList_add_an_int.as1byte(5, listByte);
			//Type: default.
			listByte = ByteList_add_an_int.as1byte(1,listByte);
			//Garbage.
			listByte = ByteList_add_chars.op("GARB", 4, listByte);
			//Origin, Width, Height, Angle.
			byte[] bytes = new byte[8];
			for(double db : Rec) {
			    ByteBuffer.wrap(bytes).putDouble(db);
			    for(int i=bytes.length-1; i>-1; i--) { //have to make the byte[] inverse
			    	listByte.add(bytes[i]); }
			}
			//Text.
			listByte = ByteList_add_chars.op("", 0, listByte);
			listByte = ByteList_add_an_int.as1byte(0, listByte);
			//Additional.
			listByte = ByteList_add_chars.op("", 0, listByte);
			listByte = ByteList_add_an_int.as1byte(0, listByte);
			
			//If there is any object in Label layer, calculate the BufferSize.
			if(nlabel!=0) {
				int labelBufferSize = 0;
				for(int lt = 0; lt <nlabel; lt++) {
					switch(shape[lt]) {
					case 0:
						labelBufferSize = labelBufferSize + 4 + 4 + npoint[lt] * 8;
						break;
					case 5:
						labelBufferSize = labelBufferSize + 48;
					}
				}
				listByte = ByteList_add_an_int.op(labelBufferSize, listByte);
			}
			//Objects.
			for(int i=0; i<nlabel; i++) {
				//Shape.
				listByte = ByteList_add_an_int.as1byte(shape[i], listByte);
				//Type.
				listByte = ByteList_add_an_int.as1byte(type[i],listByte);
				
				switch(shape[i]) {
				//Polygon.
				case 0:
					//Number of points in polygon.
					listByte = ByteList_add_an_int.op(npoint[i], listByte);
					//Coordinates of each point. (x, y) in mm.
					for(int j=0; j<npoint[i]; j++) {
						listByte = ByteList_add_a_float.op(point.get(pointTemp)/1000000, listByte);
						pointTemp++;	
						listByte = ByteList_add_a_float.op(-point.get(pointTemp)/1000000, listByte);
						pointTemp++;
					}
					break;
					
				//Rectangle.
				case 5:
					//Garbage.
					listByte = ByteList_add_chars.op("GARB", 4, listByte);
					//Origin, Width, Height, Angle.
					listByte = ByteList_addRectangle.op(point, pointTemp, listByte);
					break;
				
				}
				//Text.
				listByte = ByteList_add_chars.op("", 0, listByte);
				listByte = ByteList_add_an_int.as1byte(0, listByte);
				//The second expression:
//				listByte = ByteList_add_chars.op("\0", 1, listByte);
				//Additional.
				listByte = ByteList_add_chars.op("", 0, listByte);
				listByte = ByteList_add_chars.op("\0", 1, listByte);
			
			}
			
			//Annotation layer.
			listByte = ByteList_add_chars.op("Annotation", 64, listByte);
			//InImageCoordinates.
			listByte = ByteList_add_a_bool.op(false, listByte);
			//Number of objects in layer.
			listByte = ByteList_add_an_int.op(0, listByte);
			
			//A default mld file always contains a LayerConfigs.
			listByte = ByteList_add_chars.op("[LayerConfigs]", 14, listByte);
//			listByte = ByteList_add_an_int.as1byte(0, listByte);
			listByte = ByteList_add_chars.op("\0", 1, listByte);
			//Length of XML stream.
			listByte = ByteList_add_a_long.op(0L, listByte);
			
			//A default mld file always contains the strings "LDFF 4.0" at the end.
			listByte = ByteList_add_chars.op("LDFF 4.0", 9, listByte);
			
			//To copy the Byte list to array of byte.
			buffer = new byte[listByte.size()];
			for (int i = 0; i < listByte.size(); i++) {
			    buffer[i] = (byte) listByte.get(i);
			}

	        FileOutputStream outputStream = new FileOutputStream(outFile);
	
	        //write() writes as many bytes from the buffer as the length of the buffer. 
	        //You can also use write(buffer, offset, length), 
	        //if you want to write a specific number of bytes, or only part of the buffer.
	        outputStream.write(buffer);
	        // Always close files.
	        outputStream.close();     

		 }
        catch(IOException ex) {
            System.out.println(
                "Error writing to file '"
                + outFile + "'");
            // Or we could just do this:
            // ex.printStackTrace();
        }
	}
}
