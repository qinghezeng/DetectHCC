//To add an integer as 4 bytes or 1 byte to a ArrayList<Byte>.
package write_mld;

import java.nio.ByteBuffer;
import java.util.ArrayList;

public class ByteList_add_an_int {
	
	public ByteList_add_an_int() {}
	
	//as 4 bytes
	public static ArrayList<Byte> op(int i, ArrayList<Byte> LByte) {
		byte[] byteInv = ByteBuffer.allocate(4).putInt(i).array();
        LByte.add(byteInv[3]);
        LByte.add(byteInv[2]);
        LByte.add(byteInv[1]);
        LByte.add(byteInv[0]);
        return LByte;
	}

	//as 1 byte
	public static ArrayList<Byte> as1byte(int j, ArrayList<Byte> LByte) {
        LByte.add((byte)j);
        return LByte;
	}
}
