//To add the information of a rectangle to the ArrayList<Byte>.
package write_mld;

import java.nio.ByteBuffer;
import java.util.ArrayList;

public class ByteList_addRectangle {

	public ByteList_addRectangle() {}
	
	//To add a rectangle
	public static ArrayList<Byte> op(ArrayList<Float> fpoint, int ptemp, ArrayList<Byte> LByte) {
		
		byte[] bytes = new byte[8];
		
		//To calculate the x coordinate of the origin of the rectangle and add it to the ArrayList<Byte>. 
		//8 byte real in millimeters.
		double ox = (fpoint.get(ptemp) / 2 /1000000 + fpoint.get(ptemp+6) / 2 /1000000);
	    ByteBuffer.wrap(bytes).putDouble(ox);
	    for(int i=bytes.length-1; i>-1; i--) { //have to make the byte[] inverse
	    	LByte.add(bytes[i]); }
	    
	    //To add the y coordinate of the origin of the rectangle. 8 byte real in millimeters.
		double oy = -(fpoint.get(ptemp+1) / 2 /1000000 + fpoint.get(ptemp+3) / 2 /1000000);
	    ByteBuffer.wrap(bytes).putDouble(oy);
	    for(int i=bytes.length-1; i>-1; i--) { //have to make the byte[] inverse
	    	LByte.add(bytes[i]); }
	    
	    //To add the width/2 of the rectangle. 8 byte real in millimeters.
		double w = (fpoint.get(ptemp+6) /1000000 - fpoint.get(ptemp) /1000000) / 2 ;
	    ByteBuffer.wrap(bytes).putDouble(w);
	    for(int i=bytes.length-1; i>-1; i--) { //have to make the byte[] inverse
	    	LByte.add(bytes[i]); }
	    
	    //To add the height/2 of the rectangle. 8 byte real in millimeters.
		double h = (fpoint.get(ptemp+3) /1000000 - fpoint.get(ptemp+1) /1000000) / 2 ;
	    ByteBuffer.wrap(bytes).putDouble(h);
	    for(int i=bytes.length-1; i>-1; i--) { //have to make the byte[] inverse
	    	LByte.add(bytes[i]); }
	    
	    //To add the angle of the rectangle. 8 byte real in radians.
		double a = 0;
	    ByteBuffer.wrap(bytes).putDouble(a);
	    for(int i=bytes.length-1; i>-1; i--) { //have to make the byte[] inverse
	    	LByte.add(bytes[i]); }
 
        return LByte;
	}
	
}
