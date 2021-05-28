package write_mld;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.ArrayList;

public class write_mld_roi_qupath_czi {
	
	public static void main(String argv[]) throws IOException {
		
		String iname;
		int nlabel, sumpoint = 0, pointTemp = 0;
		int[] type;
		int[] npoint;
		ArrayList<Float> point;
		float pixel_width, pixel_height, image_width, image_height;
		double[] Rec; 
		
		File f = new File("D:\\qupath_ws\\polygons2.txt");		
		read_txt.set_file(f);
		read_txt.read_data();
		iname = read_txt.get_imageName();
		nlabel = read_txt.get_anno_num();
		type = read_txt.get_type();
		npoint = read_txt.get_point_num();
		image_width = read_txt.get_image_width();
		image_height = read_txt.get_image_height();
		pixel_width = read_txt.get_pixel_width();
		pixel_height = read_txt.get_pixel_height();
		for(int i=0; i<npoint.length; i++) {
			sumpoint = sumpoint + npoint[i];
		}
		point = read_txt.get_point();
		Rec= new double[] {0.0, 0.0, 3.4028234663852886E38, 3.4028234663852886E38, 0.0};
		
		File outFile = new File("Y:\\IMAGES\\CK\\JulienCalderaro\\Hepatocarcinomes\\annotation_from_qupath\\"+ iname + ".mld");
//		File outFile = new File("D:\\vis_db\\ndpview_test\\0001.mld");
//		File outFile = new File("D:\\vis_db\\ndpview_test\\LayerData_cp1252.mld");
		ArrayList<Byte> listByte = new ArrayList<Byte>();
		byte[] buffer;
		
		try {

			listByte = ByteList_add_chars.op("LDFF", 4, listByte);
			listByte = ByteList_add_an_int.op(3, listByte);
			listByte = ByteList_add_an_int.op(3, listByte);
			
			listByte = ByteList_add_chars.op("ROI", 64, listByte);
			listByte = ByteList_add_a_bool.op(false, listByte);
			listByte = ByteList_add_an_int.op(nlabel+1, listByte);	

			int labelBufferSize = 0;
			for(int lt = 0; lt <nlabel; lt++) {
				labelBufferSize = labelBufferSize + 4 + 4 + npoint[lt] * 8;
			}
			
			listByte = ByteList_add_an_int.op(labelBufferSize+48, listByte);
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
			
			for(int i=0; i<nlabel; i++) {
				listByte = ByteList_add_an_int.as1byte(0, listByte);
				listByte = ByteList_add_an_int.as1byte(type[i],listByte);
				
				listByte = ByteList_add_an_int.op(npoint[i], listByte);
				for(int j=0; j<npoint[i]; j++) {
					listByte = ByteList_add_a_float.op(((point.get(pointTemp)-image_width/2)*pixel_width)/1000F, listByte);
					pointTemp++;	
					listByte = ByteList_add_a_float.op((-((point.get(pointTemp))-image_height/2)*pixel_height)/1000F, listByte);
					pointTemp++;
				}
					
				listByte = ByteList_add_chars.op("", 0, listByte);
				listByte = ByteList_add_an_int.as1byte(0, listByte);
//				listByte = ByteList_add_chars.op("\0", 1, listByte);
				listByte = ByteList_add_chars.op("", 0, listByte);
				listByte = ByteList_add_chars.op("\0", 1, listByte);
			}
			
			listByte = ByteList_add_chars.op("Label", 64, listByte);
			listByte = ByteList_add_a_bool.op(false, listByte);
			listByte = ByteList_add_an_int.op(0, listByte);
			
			listByte = ByteList_add_chars.op("Annotation", 64, listByte);
			listByte = ByteList_add_a_bool.op(false, listByte);
			listByte = ByteList_add_an_int.op(0, listByte);
			
			listByte = ByteList_add_chars.op("[LayerConfigs]", 14, listByte);
//			listByte = ByteList_add_an_int.as1byte(0, listByte);
			listByte = ByteList_add_chars.op("\0", 1, listByte);
			listByte = ByteList_add_a_long.op(0L, listByte);
			
			listByte = ByteList_add_chars.op("LDFF 4.0", 9, listByte);
			
			
			buffer = new byte[listByte.size()];
			for (int ii = 0; ii < listByte.size(); ii++) {
			    buffer[ii] = (byte) listByte.get(ii);
			}

	        FileOutputStream outputStream = new FileOutputStream(outFile);
	
	        // write() writes as many bytes from the buffer
	        // as the length of the buffer. You can also
	        // use
	        // write(buffer, offset, length)
	        // if you want to write a specific number of
	        // bytes, or only part of the buffer.
	        outputStream.write(buffer);
	        // Always close files.
	        outputStream.close();  
	        
//	        char[] cbuf = new char[buffer.length];
//	        for(int i=0; i<buffer.length; i++) {
//	        	cbuf[i] = (char)buffer[i];
//	        }
//	        
//	        BufferedWriter writer = null;
//	        writer = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(outFile), "Cp1252"));
//	        writer.write(cbuf, 0, buffer.length);
//	        writer.close();     
			
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
