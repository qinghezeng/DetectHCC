//To add chars as specific bytes (with zero padding) to a ArrayList<Byte>.
package write_mld;

import java.util.ArrayList;

public class ByteList_add_chars {
	
	public ByteList_add_chars() {}
	
	public static ArrayList<Byte> op(String s, int nChar, ArrayList<Byte> LByte) {
		byte[] byteInv = s.getBytes();
		byte[] bytenull = "\0".getBytes() ;
		for(int i=0; i<byteInv.length; i++) {
			LByte.add(byteInv[i]);}
		//if the string is shorter than the length we want, fill the string with "0" to the end.
		for(int i=byteInv.length; i<nChar; i++) {
			LByte.add(bytenull[0]);
		}
        return LByte;
	}

}