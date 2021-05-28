//To read a 4-byte integer from a mld file.
package read_mld;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

public class read_an_int {

		private static File inFile;
		private static int i;
		private static long skip;
		private static byte[] inOutb;

		public read_an_int() {}
		
		//To define which file and which location to read.
		public static void setInFile(File InFile, long Skip) throws IOException {
			inFile = InFile;
			skip = Skip;
			FileInputStream loc = new FileInputStream(inFile);
//			FileReader fonction get wrong with large integer like buffer size, but with small ones it works well. Very strange!
//			FileReader loc = new FileReader(inFile);
			loc.skip(skip);
			inOutb = new byte[4];
			loc.read(inOutb);
			loc.close();
	        i = (inOutb[3] << 24)
					 + ((inOutb[2] & 0xFF) << 16)
					 + ((inOutb[1] & 0xFF) << 8)
					 + (inOutb[0] & 0xFF);
		}
		
		//To print the integer.
		public static void println() {
		System.out.println(i);
		}

		//To return the integer.
		public static int getValue() {
			return i;
		}
}
