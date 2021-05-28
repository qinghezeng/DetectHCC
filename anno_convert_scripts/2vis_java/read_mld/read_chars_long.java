//To read multiple characters whose length is a long, from a mld file.
package read_mld;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

public class read_chars_long {
	
	private static File inFile;
	private static int L, l;
	private static String s;
	private static long skip_;
	
	public read_chars_long() {}
	
	//To define which file and which location to read.
	public static void setInFileLong(File InFile, long Skip, long nChar) throws IOException {
	s = null;
	inFile = InFile;
	skip_ = Skip;
	L = (int)(nChar >> 32);
	l = (int)nChar;
}
	
	//To print the multiple characters.
	public static byte[] print() throws IOException {
		for(int u = 1; u <= L;u++) {
			FileInputStream loc = new FileInputStream(inFile);
			byte[] inOutb = new byte[Integer.MAX_VALUE-8]; 
			//the maximum "safe" number would be 2,147,483,639. Some VMs reserve some header words in an array. 
			//So the -8 is due to the bytes the reserved header words would occupy.
			loc.skip(skip_);
			loc.read(inOutb);
			s = new String(inOutb);
			System.out.print(s);
			loc.close();
			long intMax = Integer.MAX_VALUE-8;
			skip_ = Math.addExact(skip_, intMax);	//To throw exception if overflow (Java 8)
			}
		FileInputStream loc = new FileInputStream(inFile);
		byte[] inOutb = new byte[l];
		loc.skip(skip_);
		loc.read(inOutb);
		s = new String(inOutb);
		System.out.print(s);
		loc.close();
		long ll = l;
		skip_ = Math.addExact(skip_, ll);	//To throw exception if overflow (Java 8)
		return inOutb;
		}

}
