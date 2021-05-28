package write_mld;

import java.io.File;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.nio.ByteBuffer;
import java.nio.file.Files;

public class write_layerimage_ndpa {
	
	public write_layerimage_ndpa() {}
	
	public static void op(File fname, int whereToInsert, File fImage) throws IOException {
		RandomAccessFile f = new RandomAccessFile(fname, "rw");
		System.out.println("Old length:" + f.length());
	    long aPositionWhereIWantToGo = (long)whereToInsert;
	    f.seek(aPositionWhereIWantToGo); // this basically reads n bytes in the file
	    byte[] oldEnd = new byte[(int)f.length()-whereToInsert];
	    f.readFully(oldEnd);
	    f.seek(aPositionWhereIWantToGo); 
	    byte[] byte1 = "[LayerImage]\0Probability map\0".getBytes();
	    f.write(byte1);
	    byte[] bytesImage = Files.readAllBytes(fImage.toPath());
	    System.out.println("tiff length:" + bytesImage.length);
	    byte[] byte2 = ByteBuffer.allocate(8).putLong((long)bytesImage.length).array();
	    byte[] byte3 = new byte[byte2.length];
	    for(int i=byte2.length-1; i>-1; i--) { //have to make the byte[] inverse
	    	byte3[byte2.length-1-i]=(byte2[i]); }
	    f.write(byte3);
	    f.write(bytesImage);
	    f.write(oldEnd);
	    System.out.println("New length:" + f.length());
	    f.close();
	}
	
	public static void main(String[] args) throws IOException {
		File file = new File("D:\\vis_db\\i.mld");
		int location = 44183;
		File tiffImage = new File("D:\\vis_db\\img" ,"heatmap_old.tiff");
		op(file, location, tiffImage);
	}

}
