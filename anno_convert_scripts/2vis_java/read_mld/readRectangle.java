//To read the information of a rectangle from a mld file.
package read_mld;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

public class readRectangle {
	
	private static File inFile;
	private static long skip;
	private static byte[] inOutb1 = new byte[4];
	private static byte[] inOutb2 = new byte[40];
	
	public readRectangle() {}
	
	//To define which file and which location to read.
	public static void setInFile(File InFile, long Skip) throws IOException {
		inFile = InFile;
		skip = Skip;
		FileInputStream loc = new FileInputStream(inFile);
		loc.skip(skip+4);
		loc.read(inOutb2);
		loc.close();
		System.out.println("ReadRectangle()");
	}
	
	//To print the 4-byte garbage.
	public static void readGarbage() throws IOException {
		FileInputStream loc1 = new FileInputStream(inFile);
		loc1.skip(skip);
		loc1.read(inOutb1);
		String s = new String(inOutb1);
		System.out.println("Garbage: " + s);
		loc1.close();
	}
	
	//To print the coordinates (x,y) of the origin of the rectangle, in millimeters.
	public static void readOrigin() {
		long l;
	    l=inOutb2[0];
	    l&=0xff;
	    l|=((long)inOutb2[1]<<8);
	    l&=0xffff;
	    l|=((long)inOutb2[2]<<16);
	    l&=0xffffff;
	    l|=((long)inOutb2[3]<<24);
	    l&=0xffffffffl;
	    l|=((long)inOutb2[4]<<32);
	    l&=0xffffffffffl;
	    l|=((long)inOutb2[5]<<40);
	    l&=0xffffffffffffl;
	    l|=((long)inOutb2[6]<<48);
	    l&=0xffffffffffffffl;
	    l|=((long)inOutb2[7]<<56);
		System.out.print("Origin: (" + Double.longBitsToDouble(l));
	
	    l=inOutb2[8];
	    l&=0xff;
	    l|=((long)inOutb2[9]<<8);
	    l&=0xffff;
	    l|=((long)inOutb2[10]<<16);
	    l&=0xffffff;
	    l|=((long)inOutb2[11]<<24);
	    l&=0xffffffffl;
	    l|=((long)inOutb2[12]<<32);
	    l&=0xffffffffffl;
	    l|=((long)inOutb2[13]<<40);
	    l&=0xffffffffffffl;
	    l|=((long)inOutb2[14]<<48);
	    l&=0xffffffffffffffl;
	    l|=((long)inOutb2[15]<<56);
		System.out.print("," + Double.longBitsToDouble(l)+")");
		System.out.println();
	}
	
	//To print the 8-byte-double width/2 of the rectangle, in millimeters.
	public static void readWidth() {
		long l;
	    l=inOutb2[16];
	    l&=0xff;
	    l|=((long)inOutb2[17]<<8);
	    l&=0xffff;
	    l|=((long)inOutb2[18]<<16);
	    l&=0xffffff;
	    l|=((long)inOutb2[19]<<24);
	    l&=0xffffffffl;
	    l|=((long)inOutb2[20]<<32);
	    l&=0xffffffffffl;
	    l|=((long)inOutb2[21]<<40);
	    l&=0xffffffffffffl;
	    l|=((long)inOutb2[22]<<48);
	    l&=0xffffffffffffffl;
	    l|=((long)inOutb2[23]<<56);
		System.out.println("Width: "+ Double.longBitsToDouble(l));
	}
	
	//To print the 8-byte-double height/2 of the rectangle, in millimeters.
	public static void readHeight() {
		long l;
	    l=inOutb2[24];
	    l&=0xff;
	    l|=((long)inOutb2[25]<<8);
	    l&=0xffff;
	    l|=((long)inOutb2[26]<<16);
	    l&=0xffffff;
	    l|=((long)inOutb2[27]<<24);
	    l&=0xffffffffl;
	    l|=((long)inOutb2[28]<<32);
	    l&=0xffffffffffl;
	    l|=((long)inOutb2[29]<<40);
	    l&=0xffffffffffffl;
	    l|=((long)inOutb2[30]<<48);
	    l&=0xffffffffffffffl;
	    l|=((long)inOutb2[31]<<56);
		System.out.println("Height: " + Double.longBitsToDouble(l));
	}
	
	//To print the 8-byte-double angle of the rectangle, in radians.
	public static void readAngle() {
		long l;
	    l=inOutb2[32];
	    l&=0xff;
	    l|=((long)inOutb2[33]<<8);
	    l&=0xffff;
	    l|=((long)inOutb2[34]<<16);
	    l&=0xffffff;
	    l|=((long)inOutb2[35]<<24);
	    l&=0xffffffffl;
	    l|=((long)inOutb2[36]<<32);
	    l&=0xffffffffffl;
	    l|=((long)inOutb2[37]<<40);
	    l&=0xffffffffffffl;
	    l|=((long)inOutb2[38]<<48);
	    l&=0xffffffffffffffl;
	    l|=((long)inOutb2[39]<<56);
		System.out.println("Angle: " + Double.longBitsToDouble(l));
	}
	
}
