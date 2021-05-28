//To add a long as 8 bytes to a ArrayList<Byte>.
package write_mld;

import java.nio.ByteBuffer;
import java.util.ArrayList;

public class ByteList_add_a_long {
	
	public ByteList_add_a_long() {}
	
	public static ArrayList<Byte> op(long l, ArrayList<Byte> LByte) {
		byte[] byteInv = ByteBuffer.allocate(8).putLong(l).array();
	    for(int i=byteInv.length-1; i>-1; i--) { //have to make the byte[] inverse
	    	LByte.add(byteInv[i]); }
        return LByte;
	}

}
