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

public class read_xml_tum {
	
	private static int anno_num;
	private static int[] point_num, anno_shape;
	private static ArrayList<Float> point;
	private static ArrayList<Integer> lpoint_num, lanno_type, lanno_shape;
	private static ArrayList<String> anno_type_char, anno_shape_char;
	private static String coordformat;
	private static File fXmlFile;
	
	public read_xml_tum() {
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
		lpoint_num = new ArrayList<Integer>();
		lanno_type = new ArrayList<Integer>();
		lanno_shape = new ArrayList<Integer>();
		anno_type_char = new ArrayList<String>();
		anno_shape_char = new ArrayList<String>();
		
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
				anno_type_char.add(eElement.getElementsByTagName("title").item(0).getTextContent());
				if(anno_type_char.get(anno_type_char.size()-1).equals("T")) {
				
					//To exact the shape of the annotation object.
					anno_shape_char.add(annotation.getAttribute("displayname"));
					switch(anno_shape_char.get(anno_shape_char.size()-1)) {
					case "AnnotateFreehand":
						lanno_shape.add(0);
						break;
					case "AnnotateRectangle":
						lanno_shape.add(5);
						break;
					}	
	//				System.out.println("shape: " + anno_shape_char[temp]);
					
					//To exact the unit of the coordinates.
					coordformat = eElement.getElementsByTagName("coordformat").item(0).getTextContent();
	//				System.out.println("coordformat : " + coordformat);
					
					//To exact the number of points in the annotation object.
					NodeList npoint = eElement.getElementsByTagName("point");
					lpoint_num.add(npoint.getLength());
	
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
		}
		
		anno_num = lanno_shape.size();
		point_num = new int[anno_num];
		anno_shape = new int[anno_num];
		for(int a = 0; a < anno_num; a++) {
			point_num[a] = lpoint_num.get(a);
			anno_shape[a] = lanno_shape.get(a);
		}
		
		
    } catch (Exception e) {
    	e.printStackTrace();
    	}
	}
	
	//To return the number of annotation object.
	public static int get_anno_num() {
		return anno_num;
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