//To translate a mld file (binary code) into a txt format.
package read_mld;

import java.io.File;
import java.io.IOException;

//To read a mld file which is written in C.
public class read_print2txt {

	private static File inFile = null;
	private static long skip = 0;
	
	public read_print2txt() {}
	
	public static void main(String[] args) throws IOException {

		//To define which mld file to read.
		inFile = new File("Y:\\IMAGES\\CK\\JulienCalderaro\\Hepatocarcinomes\\annotation_from_qupath\\P591234-01-niv3-Scene-1-ScanRegion0.mld");
		
		System.out.println("ReadMLDFile(" + inFile +")");
		System.out.println("{");

		try {
			//4-char Magic. Should be "LDFF".
			read_chars.setInFile(inFile, skip, 4);
			System.out.print("Magic: ");
			read_chars.println();
			skip = skip + 4;
			
			//4-byte-integer Version. The current is "3".
			read_an_int.setInFile(inFile, skip);
			System.out.print("Version: ");
			read_an_int.println();
			skip = skip + 4;
			
			//4-byte-integer number of layers. Expect "3".
			read_an_int.setInFile(inFile, skip);
			System.out.print("#Layers: ");
			read_an_int.println();
			int nLayer = read_an_int.getValue();
			skip = skip + 4;
			
			System.out.println();
	
			//the information of each layer.
			for (int a = 1; a <= nLayer; a++) {
			
				System.out.println("For layer:");
				System.out.println("{");
				System.out.print("Name: ");
				//To read the name of layer. Should be ROI, Label or Annotation.
				read_chars.setInFile(inFile, skip, 64);
				read_chars.println();
				skip = skip + 64;
		
				//1-byte-bool InImageCoordinates. Expect false.
				read_a_bool.setInFile(inFile, skip);
				System.out.print("InImageCoordinates: ");
				read_a_bool.println();
				skip = skip + 1;
				
				//4-byte-integer. Number of the objects in this layer.
				read_an_int.setInFile(inFile, skip);
				System.out.print("#Objects: ");
				int nObj = read_an_int.getValue();
				read_an_int.println();
				skip = skip + 4;
				
				//If there is any object in this layer:
				if(nObj!=0)	{
					System.out.println();
					
					//4-byte-integer. Memory size of the buffer for all the objects in this layer.
					System.out.print("BufferSize: ");
					read_an_int.setInFile(inFile, skip);
					read_an_int.println();
					skip = skip + 4;
						
					//If there is any object in ROI layer, the first object will be the background object by default.
					
					//For each object in this layer:
					for (int j = 1; j <= nObj; j++) { 
						//cannot use "i" here, because there will be "i" in the sub-functions called.
						System.out.println("For Object " + j + ":");
						System.out.println("{");
						System.out.println("ReadObjectBuffer()");
						System.out.println("{");
						
						//1 byte. Object Shape ID.
						read_chars.setInFile(inFile, skip, 1);
						System.out.print("Shape: ");
						read_chars.println();
						int Shape = read_chars.getAsInt();
						skip = skip + 1;
				
						//1 byte. Object Type ID.
						read_chars.setInFile(inFile, skip, 1);
						System.out.print("Type: ");
						read_chars.println();
						skip = skip + 1;
						
						System.out.println();
						
						//Read the information of each object according to their shape.
						System.out.println("Switch(" + Shape + ")");
						switch(Shape) {
						
						//Polygon
						case 0: 
							readPolygon.setInFile(inFile, skip);
							readPolygon.print_num_point();
							int pnum = readPolygon.get_num_point();
							readPolygon.print_cors();
							skip = skip + 4 + 8 * pnum;
							break;
							
						//Ellipse
						case 1: 
							System.out.println("Ellipse is not supported.");
							break;
							
						//Circle
						case 2: 
							System.out.println("Circle is not supported.");
							break;
							
						//Polyline
						case 3: 
							System.out.println("Polyline is not supported.");
							break;
								
						//Line
						case 4: 
							System.out.println("Line is not supported.");
							break;
								
						//Rectangle
						case 5: 
							readRectangle.setInFile(inFile,skip);
							readRectangle.readGarbage();
							readRectangle.readOrigin();
							readRectangle.readWidth();
							readRectangle.readHeight();
							readRectangle.readAngle();
							skip = skip + 44;
							break;
								
						//Square
						case 6: 
							readSquare.setInFile(inFile,skip);
							readSquare.readGarbage();
							readSquare.readOrigin();
							readSquare.readWidth_Height();
							readSquare.readAngle();
							skip = skip + 36;
							break;
						
						//Text
						case 7: 
							System.out.println("Text is not supported.");
							break;
								
						}
						System.out.println();
						
						//Multiple-char Text, 0 terminated.
						read_chars_0ter.setInFile(inFile, skip);
						System.out.print("Text: ");
						read_chars_0ter.println();
						skip = skip + read_chars_0ter.getCharLength() + 1;
						
						//Multiple_char Additional, 0 terminated.
						read_chars_0ter.setInFile(inFile, skip);
						System.out.print("Additional: ");
						read_chars_0ter.println();
						skip = skip + read_chars_0ter.getCharLength() + 1;
						
						System.out.println("}");
						System.out.println("}");
						System.out.println();
					}
					
				} else {
					
					System.out.println("}");
					System.out.println();
				}
				
			}
			
			//print the current location in the mld file.
			System.out.print("(Location here: " + skip);
			System.out.println(")");
			System.out.println("");
			
			//read the information of other layers:
			read_chars_0ter.setInFile(inFile, skip);
			String LayerWhat = read_chars_0ter.getAsString();
			while(LayerWhat.equals("[LayerImage]") || LayerWhat.equals("[LayerAtlas]") || LayerWhat.equals("[LayerConfigs]")) {
				
				switch(LayerWhat) {
				//For each LayerImage:
				case "[LayerImage]":
					System.out.println("For Layer each LayerImage");
					System.out.println("{");
					System.out.println("ReadLayerImage()");
						
					//0 terminated "[LayerImage]" string to identify each LayerImage
					System.out.print("LayerImageMagic: ");
					read_chars_0ter.println();
					skip = skip + read_chars_0ter.getCharLength() + 1;
					
					//!!!The documentation of vis is misleading because it leave out the description of this argument.
					//0 terminated string. Name of each LayerImage.
					System.out.print("Name: ");
					read_chars_0ter.setInFile(inFile, skip);
					read_chars_0ter.println();
					skip = skip + read_chars_0ter.getCharLength() + 1;
					
					//8-byte-integer. Length of TIFF image stream.
					read_a_long.setInFile(inFile, skip);
					System.out.print("Length: ");
					read_a_long.println();
					long length = read_a_long.getValue();
					skip = skip + 8;
						
					//A buffer of Length bytes which can be read as a normal TIFF file.
					System.out.println("TIFF Image stream: ");
					System.out.print("[");
					write_tiff.setInFile(inFile, skip, (int)length);
					write_tiff.op(); //write the TIFF image
					skip = Math.addExact(skip, length);	//To throw exception if overflow (Java 8)
					System.out.println("]");
					System.out.println("}");
					System.out.println();
					
					read_chars_0ter.setInFile(inFile, skip);
					LayerWhat = read_chars_0ter.getAsString();
					break;
					
				//LayerAtlas overlays:
				case "[LayerAtlas]":
					System.out.println("ReadLayerAtlas()");
					//0 terminated "[LayerAtlas]" string.
					System.out.print("LayerAtlasMagic: ");
					read_chars_0ter.println();
					skip = skip + read_chars_0ter.getCharLength() + 1;
						
					//8-byte-integer. Length of XML stream.
					read_a_long.setInFile(inFile, skip);
					System.out.print("Length: ");
					read_a_long.println();
					length = read_a_long.getValue();
					skip = skip + 8;
						
					//A buffer of length chars which can be read as a normal XML stream.
					System.out.println("LayerAtlas XML: ");
					System.out.print("[");
					read_chars_long.setInFileLong(inFile, skip, length);
					read_chars_long.print();
					skip = Math.addExact(skip, length);	//To throw exception if overflow (Java 8). DO NOT FORGET to give the result back to "skip".
					System.out.println("]");
					System.out.println();
					read_chars_0ter.setInFile(inFile, skip);
					LayerWhat = read_chars_0ter.getAsString();
					break;
					
				//LayerConfig information:
				case "[LayerConfigs]":
					System.out.println("ReadLayerConfigs()");
					//0 terminated "[LayerConfigs]" string.
					System.out.print("LayerConfigsMagic: ");
					read_chars_0ter.println();
					skip = skip + read_chars_0ter.getCharLength() + 1;
						
					//8-byte-integer. Length of XML stream.
					read_a_long.setInFile(inFile, skip);
					System.out.print("Length: ");
					read_a_long.println();
					length = read_a_long.getValue();
					skip = skip + 8;
						
					//A buffer of Length chars which can be read as a normal XML stream.
					System.out.println("LayerConfigs XML: ");
					System.out.print("[");
					read_chars_long.setInFileLong(inFile, skip, length);
					read_chars_long.print();
					skip = Math.addExact(skip, length);	//To throw exception if overflow (Java 8)
					System.out.println("]");
					System.out.println();
					read_chars_0ter.setInFile(inFile, skip);
					LayerWhat = read_chars_0ter.getAsString();
				}
				
			}
				
			int nTotal = read_chars.getNTotal();
			//print the number of bytes, the number of bytes read, and the rest bytes of the mld file.
			System.out.println("Total Bytes= "+ nTotal);
			System.out.println("Read Bytes = " + skip);
			System.out.println("The rest bytes are: ");
			int zero = 0;
			long lTotal = (long)zero << 32 | nTotal & 0xFFFFFFFFL;
			long lRest = lTotal - skip;
			read_chars_long.setInFileLong(inFile, skip, lRest);
			read_chars_long.print();
		 }
		
        catch(IOException ex) {
            System.out.println(
                "Error reading to file '"
                + inFile + "'");
            // Or we could just do this:
            // ex.printStackTrace();
        }
		
	}
	
}