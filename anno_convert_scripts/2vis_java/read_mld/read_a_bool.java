//To read a 1-byte boolean from a mld file.

package read_mld;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

public class read_a_bool {

	private static File inFile;
	private static int i;
	private static long skip;

	public read_a_bool() {}
	
	//To define which file and which location to read.
	public static void setInFile(File InFile, long Skip) throws IOException {
		inFile = InFile;
		skip = Skip;
		FileInputStream loc = new FileInputStream(inFile);
		loc.skip(skip);
		i = loc.read();
		loc.close();
	}
	
	//To print the boolean.
	public static void println() {
		if (i==0) {
			boolean b = false;
			System.out.println(b);}
		else {
			boolean b = true;
			System.out.println(b);
		}
	}

}
