//To extract annotation from a ndpa file (xml format, created by ndpView) and print it.
package write_mld;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.DocumentBuilder;
import org.w3c.dom.Document;
import org.w3c.dom.NodeList;
import org.w3c.dom.Node;
import org.w3c.dom.Element;
import java.io.File;

public class read_xml_print {
	
	public static void main(String argv[]) {

	    try {

	    //To specify a ndpa file to extract annotation from.
		File fXmlFile = new File("Y:\\IMAGES\\CK\\JulienCalderaro\\Hepatocarcinomes\\HMNT0113 - 2017-07-24 14.44.57.ndpi.ndpa");
		DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
		DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
		Document doc = dBuilder.parse(fXmlFile);
				
		//optional, but recommended
		//read this - http://stackoverflow.com/questions/13786607/normalization-in-dom-parsing-with-java-how-does-it-work
		doc.getDocumentElement().normalize();

		//To print Root Element. Expect "annotations".
		System.out.println("Root Element: " + doc.getDocumentElement().getNodeName());
				
		NodeList nList = doc.getElementsByTagName("ndpviewstate");
				
		System.out.println("----------------------------");

		for (int temp = 0; temp < nList.getLength(); temp++) {

			Node nNode = nList.item(temp);
					
			//To print Current Element. Expect "ndpviewstate".
			System.out.println("\nCurrent Element: " + nNode.getNodeName());
					
			if (nNode.getNodeType() == Node.ELEMENT_NODE) {

				Element eElement = (Element) nNode;
				Element annotation = (Element)eElement.getElementsByTagName("annotation").item(0);
				//To print the index of annotation object.
				System.out.println("annotation id: " + eElement.getAttribute("id"));
				//To print the type of the annotation object.
				System.out.println("type: " + eElement.getElementsByTagName("title").item(0).getTextContent());
				//To print the shape of annotation object.
				System.out.println("shape: " + annotation.getAttribute("displayname"));
				//To print the unit of coordinates.
				System.out.println("coordformat: " + eElement.getElementsByTagName("coordformat").item(0).getTextContent());
				
				NodeList npoint = eElement.getElementsByTagName("point");

				System.out.println("\npointlist:");
				
				for (int n = 0; n < npoint.getLength(); n++) {

					//To print the index of the point in this annotation object.
					System.out.println("point id : " + n);
					//To print the coordinates of the point.
					System.out.println("point : " + eElement.getElementsByTagName("point").item(n).getTextContent());	
				}
			}
		}
		
	    } catch (Exception e) {
		e.printStackTrace();
	    }
	  }
}