//To read a 4-byte float (/real) from a mld file.
package read_mld;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

public class read_a_float {
	
	private static File inFile;
	private static long skip;
	private static byte[] inOutb;
	
	public read_a_float() {}
	
	//To define which file and which location to read.
	public static void setInFile(File InFile, long Skip) throws IOException {
		inFile = InFile;
		skip = Skip;
		FileInputStream loc = new FileInputStream(inFile);
		inOutb = new byte[4];
		loc.skip(skip);
		loc.read(inOutb);
		loc.close();
	}
	
	//To print the float (/real).
	public static void print() {
	    int l;  
	    l = inOutb[0];  
	    l &= 0xff;  
	    l |= ((long) inOutb[1] << 8);  
	    l &= 0xffff;  
	    l |= ((long) inOutb[2] << 16);  
	    l &= 0xffffff;  
	    l |= ((long) inOutb[3] << 24);  
	    System.out.print(Float.intBitsToFloat(l));  
	}
}
