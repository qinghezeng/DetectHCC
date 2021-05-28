//To read a string (/multiple characters) with 0 terminated.
package read_mld;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;

public class read_chars_0ter {
	
	private static File inFile;
	private static long skip;
	private static String s;
	
	public read_chars_0ter() {	}
	
	//To define which file and which location to read.
	public static void setInFile(File InFile, long Skip) throws IOException {
		inFile = InFile;
		skip = Skip;
		FileReader loc = new FileReader(inFile);
		
		loc.skip(skip);
		StringBuilder sb = new StringBuilder();
		
		while (true) 
		{
		    int ch = loc.read();
		    if (ch == -1) throw new IOException();
		    if (ch == 0) break; // when read a NUL, stop
		    sb.append((char)ch);
		}
		
		loc.close();
		s = sb.toString();
				
	}	

	//To print the 0-terminated string (/multiple characters).
	public static void println() {
		System.out.println(s);
	}
	
	//To return the length of the 0-terminated string (/multiple characters).
	public static int getCharLength() {
		return s.length();
	}

	//To return the 0-terminated string.
	public static String getAsString() {
		return s;
	}
	
}
