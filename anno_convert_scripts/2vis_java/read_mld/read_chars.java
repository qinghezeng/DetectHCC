//To read a string (/multiple characters) with its length known.
package read_mld;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

public class read_chars {

	private static File inFile;
	private static int i, nTotal=0;
	private static String s;
	private static long skip;

	public read_chars() {}
	
	//To define which file and which location to read.
	public static void setInFile(File InFile, long Skip, int nChar) throws IOException {
		s = null;
		inFile = InFile;
		skip = Skip;
		FileInputStream loc = new FileInputStream(inFile);
		nTotal = loc.available();
		// It's strange that loc.read(char[i]) doesn't read anything.
		if (nChar==1) {
			loc.skip(skip);
			i = loc.read();
		} else {
			byte[] inOutb = new byte[nChar];
			loc.skip(skip);
			loc.read(inOutb);
			s = new String(inOutb);
		}
		loc.close();
	}
	
	//To print the string (multiple characters).
	public static void println() {
		if(s==null) {
			System.out.println(i);
		}
		else {
			System.out.println(s);
		}
	}
	
	//To return the string as a integer.
	public static int getAsInt() {
		if(s==null) {
			return i;
		}
		else {
			return Integer.parseInt(s);
		}
	}
	
	//To return the string.
	public static String getAsString() {
		return s;
	}
	
	//To return the length (in byte) of the mld file.
	public static int getNTotal() {
		return nTotal;
	}
}
