//To extract annotation from a ndpa file (xml format) created by ndpView.
package write_mld;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.DocumentBuilder;
import org.w3c.dom.Document;
import org.w3c.dom.NodeList;
import org.w3c.dom.Node;
import org.w3c.dom.Element;
import java.io.File;
import java.util.ArrayList;

public class read_xml_2classes {
	
	private static int anno_num;
	private static int[] point_num, anno_type, anno_shape;
	private static String[] anno_type_char, anno_shape_char;
	private static ArrayList<Float> point;
	private static String coordformat;
	private static File fXmlFile;
	
	public read_xml_2classes() {
	}
	
	public static void set_file(String fname) {
		fXmlFile = new File(fname);
	}
	
	public static void read_data() {

	    try {
	    	
		DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
		DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
		Document doc = dBuilder.parse(fXmlFile);
				
		//optional, but recommended
		//read this - http://stackoverflow.com/questions/13786607/normalization-in-dom-parsing-with-java-how-does-it-work
		doc.getDocumentElement().normalize();

		//To print Root Element. Expect "annotations".
//		System.out.println("Root element: " + doc.getDocumentElement().getNodeName());
				
		NodeList nList = doc.getElementsByTagName("ndpviewstate");
				
//		System.out.println("----------------------------");
		
		point = new ArrayList<Float>(); //if we create it in the declaration, when we convert mutipule .ndpa, it will be accumulated and finally include the former ones every time.
		anno_num = nList.getLength();
		point_num = new int[anno_num];
		anno_type_char = new String[anno_num];
		anno_shape_char = new String[anno_num];
		anno_type = new int[anno_num];
		anno_shape = new int[anno_num];

		for (int temp = 0; temp < nList.getLength(); temp++) {

			Node nNode = nList.item(temp);
					
			//To print Current Element. Expect "ndpviewstate"
//			System.out.println("\nCurrent Element: " + nNode.getNodeName());
					
			if (nNode.getNodeType() == Node.ELEMENT_NODE) {

				Element eElement = (Element) nNode;
				Element annotation = (Element)eElement.getElementsByTagName("annotation").item(0);
				
				//To print the index of annotation object.
//				System.out.println("annotation id: " + eElement.getAttribute("id"));
				
				//To exact the type of the annotation object.
				anno_type_char[temp] = eElement.getElementsByTagName("title").item(0).getTextContent();
				switch(anno_type_char[temp]) {
				case "NT":
					anno_type[temp] = 2;
					break;
				case "T":
					anno_type[temp] = 3;
					break;
				}	
//				System.out.println("type: " + anno_type_char[temp]);
				
				//To exact the shape of the annotation object.
				anno_shape_char[temp] = annotation.getAttribute("displayname");
				switch(anno_shape_char[temp]) {
				case "AnnotateFreehand":
					anno_shape[temp] = 0;
					break;
				case "AnnotateRectangle":
					anno_shape[temp] = 5;
					break;
				}	
//				System.out.println("shape: " + anno_shape_char[temp]);
				
				//To exact the unit of the coordinates.
				coordformat = eElement.getElementsByTagName("coordformat").item(0).getTextContent();
//				System.out.println("coordformat : " + coordformat);
				
				//To exact the number of points in the annotation object.
				NodeList npoint = eElement.getElementsByTagName("point");
				point_num[temp]= npoint.getLength();

//				System.out.println("\npointlist:");
				
				for (int n = 0; n < npoint.getLength(); n++) {

					//To print the index of the point in this annotation object.
//					System.out.println("point id : " + n);
					
					//To exact the coordinates of point
					String xCor = annotation.getElementsByTagName("x").item(n).getTextContent();
					String yCor = annotation.getElementsByTagName("y").item(n).getTextContent();
//					System.out.println("x : " + xCor);	
//					System.out.println("y : " + yCor);	
					float x = Float.parseFloat(xCor); 
					float y = Float.parseFloat(yCor);;
					point.add(x);
					point.add(y);
				}
			}
		}
		
	    } catch (Exception e) {
		e.printStackTrace();
	    }
	  }
	
	//To return the number of annotation object.
	public static int get_anno_num() {
		return anno_num;
	}
	
	//To return the type list of annotation objects.
	public static int[] get_anno_type() {
		return anno_type;
	}
	
	//To return the shape list of annotation objects.
	public static int[] get_anno_shape() {
		return anno_shape;
	}
	
	//To return the numbers of points in each annotation object.
	public static int[] get_point_num() {
		return point_num;
	}
	
	//To return the unit of coordinates.
	public static String get_coordformat() {
		return coordformat;
	}
	
	//To return the coordinates of points in each annotation object.
	public static ArrayList<Float> get_point() {
		return point;
	}
}