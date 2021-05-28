//To read the information of a polygon from a mld file.
package read_mld;

import java.io.File;
import java.io.IOException;

public class readPolygon {
	
	private static File inFile;
	private static int nPoint;
	private static long skip;
	
	public readPolygon() {}
	
	//To define which file and which location to read.
	public static void setInFile(File InFile, long Skip) throws IOException {
		inFile = InFile;
		skip = Skip;
		System.out.println("ReadPolygon()");
	}

	//To print the number of points in polygon, which is a 4-byte integer.
	public static void print_num_point() throws IOException {
		read_an_int.setInFile(inFile, skip);
		System.out.print("#Point: ");
		read_an_int.println();
		nPoint = read_an_int.getValue();
		skip = skip + 4;
	}
	
	//To print the coordinates (x,y) for each point, in millimeters
	public static void print_cors() throws IOException {
		for (int k = 1; k <= nPoint; k++) {
			System.out.println("For point " + k + ":");
			System.out.print("(");
			read_a_float.setInFile(inFile, skip);
			read_a_float.print();
			skip = skip + 4;
			System.out.print(",");
			read_a_float.setInFile(inFile, skip);
			read_a_float.print();
			skip = skip + 4;
			System.out.print(")");
			System.out.println();
		}
	}
		
	//To return the number of the points in polygon.
	public static int get_num_point() {
		return nPoint;
	}

}
