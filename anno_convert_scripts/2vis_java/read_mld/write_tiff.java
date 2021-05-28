//To exact a TIFF image from a mld file.
//Require to install the referenced libraries of TwelveMonkeys ImageIO plugin.
package read_mld;

import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

import javax.imageio.ImageIO;

public class write_tiff {

	private static File inFile;
	private static byte[] inOutb;
	private static long skip;

	public write_tiff() {}

	//To define which file and which location to read.
	public static void setInFile(File InFile, long Skip, int nl) throws IOException {
		inFile = InFile;
		skip = Skip;
		inOutb = new byte[nl];
		FileInputStream loc = new FileInputStream(inFile);
		loc.skip(skip);
		loc.read(inOutb);
		loc.close();	
	}
	
	//To exact and write the TIFF image.
	public static void op() throws IOException {
		InputStream tiff = new ByteArrayInputStream(inOutb);
		BufferedImage bImageFromConvert = ImageIO.read(tiff);
		ImageIO.write(bImageFromConvert, "TIFF", new File("D:\\vis_db\\img\\heatmap.tiff"));
	}
	
}
