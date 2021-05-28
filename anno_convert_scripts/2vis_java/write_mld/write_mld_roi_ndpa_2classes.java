//To write annotation exacted from a ndpa file into a mld file as ROIs. 
package write_mld;

import java.util.ArrayList;
import java.io.*;
import java.nio.ByteBuffer;

public class write_mld_roi_ndpa_2classes {
	
	public static void main(String argv[]) throws IOException {
		
		int nlabel, sumpoint = 0, pointTemp = 0;
		int[] shape, type;
		int[] npoint;
		ArrayList<Float> point;
		double[] Rec; 
		
		//To specify a ndpa file to extract annotation from.
		String f = "Y:\\IMAGES\\CK\\JulienCalderaro\\Hepatocarcinomes\\better_annotation\\HMNT0113 - 2017-07-24 14.44.57.ndpi.ndpa";		
		read_xml_2classes.set_file(f);
		//To get all the information about annotation objects from the ndpa file
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
		
		//To specify a name for the mld file to create.
		File outFile = new File("D:\\vis_db\\\\ndpview_test\\better_roi.mld");

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
			listByte = ByteList_add_an_int.op(nlabel+1, listByte);	

			//Import all the annotation as ROIs.
			//When there is any object in ROI layer, there is always a background object as the first object.
			//So we create a background object in ROI layer by default.
			//BufferSize of ROI layer.
			int ROIBufferSize = 0;
			//Calculate the BufferSize except the background object.
			for(int lt = 0; lt <nlabel; lt++) {
				switch(shape[lt]) {
				case 0:
					ROIBufferSize = ROIBufferSize + 4 + 4 + npoint[lt] * 8;
					break;
				case 5:
					ROIBufferSize = ROIBufferSize + 48;
				}
			}
			
			//BufferSize.
			listByte = ByteList_add_an_int.op(ROIBufferSize+48, listByte);
			
			//Background object.
			listByte = ByteList_add_an_int.as1byte(5, listByte);
			listByte = ByteList_add_an_int.as1byte(0,listByte);
			listByte = ByteList_add_chars.op("GARB", 4, listByte);
			byte[] bytes = new byte[8];
			for(double db : Rec) {
			    ByteBuffer.wrap(bytes).putDouble(db);
			    for(int i=bytes.length-1; i>-1; i--) { //have to make the byte[] inverse
			    	listByte.add(bytes[i]); }
			}
			listByte = ByteList_add_chars.op("", 0, listByte);
			listByte = ByteList_add_an_int.as1byte(0, listByte);
			listByte = ByteList_add_chars.op("", 0, listByte);
			listByte = ByteList_add_an_int.as1byte(0, listByte);
			
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
			
			//Label layer.
			listByte = ByteList_add_chars.op("Label", 64, listByte);
			//InImageCoordinates.
			listByte = ByteList_add_a_bool.op(false, listByte);
			//Number of objects in layer.
			listByte = ByteList_add_an_int.op(0, listByte);
			
			//Annotation layer.
			listByte = ByteList_add_chars.op("Annotation", 64, listByte);
			//InImageCoordinates.
			listByte = ByteList_add_a_bool.op(false, listByte);
			//Number of objects in layer.
			listByte = ByteList_add_an_int.op(0, listByte);
			
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