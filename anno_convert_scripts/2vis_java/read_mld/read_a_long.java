//To read a 8-byte long (/integer) from a mld file.
package read_mld;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

public class read_a_long {

	private static File inFile;
	private static byte[] inOutb;
	private static long l, skip;

	public read_a_long() {}
	
	//To define which file and which location to read.
	public static void setInFile(File InFile, long Skip) throws IOException {
		inFile = InFile;
		skip = Skip;
		FileInputStream loc = new FileInputStream(inFile);
		inOutb = new byte[8];
		loc.skip(skip);
		loc.read(inOutb);
		loc.close();
	}
	
	//To print the long (/integer).
	public static void println() {
		l = (inOutb[7] << 56)
				 + ((inOutb[6] & 0xFF) << 48)
				 + ((inOutb[5] & 0xFF) << 40)
				 + ((inOutb[4] & 0xFF) << 32)
				 + ((inOutb[3] & 0xFF) << 24)
				 + ((inOutb[2] & 0xFF) << 16)
				 + ((inOutb[1] & 0xFF) << 8) 
				 + (inOutb[0] & 0xFF);
	    System.out.println(l);
	}
	
	//To return the long itself.
	public static long getValue() {
		return l;
	}
	
}
