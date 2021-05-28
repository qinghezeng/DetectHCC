//To add a bool as 1 byte to a ArrayList<Byte>. 
package write_mld;

import java.util.ArrayList;

public class ByteList_add_a_bool {
	
	public ByteList_add_a_bool() {}
	
	public static ArrayList<Byte> op(boolean b, ArrayList<Byte> LByte) {
		byte bb = (byte)(b?1:0);
		LByte.add(bb);
		return LByte;	
	}
}
