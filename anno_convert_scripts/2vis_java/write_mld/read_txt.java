//To exact and return information from a txt file created by QuPath.
package write_mld;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;

public class read_txt {
	
	private static File f;
	private static int anno_num=0;
	private static int[] type, point_num;
	private static ArrayList<Integer> typeList = new ArrayList<Integer>(), np = new ArrayList<Integer>();
	private static ArrayList<Float> point = new ArrayList<Float>();
	private static float pixelWidth, pixelHeight, width, height;
	private static String imageName, line = null;
	
	public read_txt() {}
	
	//To specify an annotation file created by QuPath.
	public static void set_file(File file) {
		f = file;
	}
			
	//To exact the information.
	public static void read_data() throws IOException {
	
		BufferedReader br = new BufferedReader(new FileReader(f));
		
		//To read each line:
		while((line = br.readLine())!= null){
			//To read the name of the ndpi/czi slide.
			if(line.endsWith(".ndpi") || line.endsWith(".czi")) {
				String[] tmp1 = line.split("\\.");
				imageName = tmp1[0];} 
			
			//!!!ATTENTION! In QuPath, all the coordinates are aligned with the image center (centre d'image) as origin, 
			//but not whole slide image center (centre de la lame) like in ndpView.
			
			//To read the width of the image. Integer in pixels. Transfer it to float for calculation.
			else if(line.startsWith("Image width:")) {
				String[] tmp1 = line.split(":");
				width = (float)Integer.parseInt(tmp1[1]);} 
			
			//To read the height of the image. Integer in pixels. Transfer it to float for calculation.
			else if(line.startsWith("Image height:")) {
				String[] tmp1 = line.split(":");
				height = (float)Integer.parseInt(tmp1[1]);}
			
			//To read the width of a pixel in micrometers. Transfer it to float for calculation.
			else if(line.startsWith("Pixel width:")) {
				String[] tmp1 = line.split(":");
				pixelWidth = Float.parseFloat(tmp1[1]);}
			
			//To read the height of a pixel in micrometers. Transfer it to float for calculation.
			else if(line.startsWith("Pixel height:")) {
				String[] tmp1 = line.split(":");
				pixelHeight = Float.parseFloat(tmp1[1]);}
			
			//To read each annotation objects.
			else if(line.charAt(0) == '[') { //each annotation object starts with a "[".
				anno_num ++;
				String[] tmp2 = line.split(":");
				for(int j=0; j<tmp2.length; j++) {
					System.out.println(tmp2[j]);
					}
				for(int i=0; i<tmp2.length; i++){
					if(tmp2[i].indexOf(",")!=-1) {
						String[] tmp3 = tmp2[i].split(",|\\]");
						point.add(Float.parseFloat(tmp3[0]));
						point.add(Float.parseFloat(tmp3[1]));
						if(tmp3[2].equals(" Point")) {}
						//In QuPath, it repeats the last point of polygon to identify the end.
						else {
							point.remove(point.size()-1);
							point.remove(point.size()-1);
							np.add(tmp2.length-2);
							if(tmp3[2].equals("Tumor")) { //the class of this annotation object.
								typeList.add(2);
							} else if(tmp3[2].equals("null")) {
								typeList.add(3);
							}
						}
					}
				}
				System.out.println();
			} else {
				System.out.println("Error: Unexpected info.");
				System.out.println();
			}
		}
	
		//a list to describe the number of points in each annotation object.
		point_num = new int[anno_num];
		for(int i=0; i<anno_num; i++) {
			point_num[i] = np.get(i);
		}
		
		//a list to describe the types of each annotation object.
		type = new int[anno_num];
		for(int i=0; i<anno_num; i++) {
			type[i] = typeList.get(i);
		}
		
		//print the number of annotation objects, the number of points in each annotation objects,
		//and the coordinates of each point.
		System.out.println(anno_num);
		for(int j=0; j<point_num.length; j++) {
			System.out.println(point_num[j]);}
		for(int j=0; j<point.size(); j++) {
			System.out.println(point.get(j));}
	}
	
	//return the name of the slide.
	public static String get_imageName() {
		return imageName;
	}
	
	
	//return the number of annotation objects.
	public static int get_anno_num() {
		return anno_num;
	}
	
	//return the type list of annotation objects.
	public static int[] get_type() {
		return type;
	}
	
	//return the number of points in each annotation object.
	public static int[] get_point_num() {
		return point_num;
	}
	
	//return the coordinates of points in each annotation object.
	public static ArrayList<Float> get_point() {
		return point;
	}
	
	//return the width of image in pixel.
	public static float get_image_width() {
		return width;
	}
	
	//return the height of image in pixel.
	public static float get_image_height() {
		return height;
	}
	
	//return the width of each pixel in um.
	public static float get_pixel_width() {
		return pixelWidth;
	}
	
	//return the height of each pixel in um.
	public static float get_pixel_height() {
		return pixelHeight;
	}
	
}