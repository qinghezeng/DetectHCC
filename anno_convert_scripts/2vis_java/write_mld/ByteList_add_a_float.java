//To add a float as 4 bytes to a ArrayList<Byte>.
package write_mld;

import java.nio.ByteBuffer;
import java.util.ArrayList;

public class ByteList_add_a_float {

	public ByteList_add_a_float() {}
	
	public static ArrayList<Byte> op(float i, ArrayList<Byte> LByte) {
		byte[] byteInv = ByteBuffer.allocate(4).putFloat(i).array();
        LByte.add(byteInv[3]);
        LByte.add(byteInv[2]);
        LByte.add(byteInv[1]);
        LByte.add(byteInv[0]);
        return LByte;
	}
	
}
