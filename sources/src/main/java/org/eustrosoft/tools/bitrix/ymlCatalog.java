package org.eustrosoft.tools.bitrix;

import org.w3c.dom.Document;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import java.io.IOException;

public class ymlCatalog {
    public void xml2Ini() throws IOException, SAXException, ParserConfigurationException {
        DocumentBuilder documentBuilder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
        Document document = documentBuilder.parse("parsefile.xml");
        Node root = document.getDocumentElement();
        NodeList records = root.getChildNodes();
        for (int i = 0; i < records.getLength(); i++) {
            Node node = records.item(i);
            if (node.getNodeType() != Node.COMMENT_NODE) {
                NodeList nodeProps = node.getChildNodes();
                for (int j = 0; j < nodeProps.getLength(); j++) {
                    Node nodeProp = nodeProps.item(j);
                    if (nodeProp.getNodeType() != Node.COMMENT_NODE) {
                        NodeList insightNode = nodeProp.getChildNodes();
                        if (nodeProp.getNodeName().equals("offers")) {
                            for (int k = 0; k < insightNode.getLength(); k++) {
                                NamedNodeMap attributes = insightNode.item(k).getAttributes();
                                System.out.print(insightNode.item(k).getNodeName() + ": ");
                                if (attributes != null) {
                                    System.out.println(attributes.getNamedItem("id").getTextContent());
                                    System.out.println("type: " + attributes.getNamedItem("type").getTextContent());
                                }
                                Node list = insightNode.item(k);
                                if (list.getNodeType() != Node.COMMENT_NODE) {
                                    NodeList listNodes = list.getChildNodes();
                                    for (int f = 0; f < listNodes.getLength(); f++) {
                                        System.out.println(listNodes.item(f).getNodeName() + ": " + listNodes.item(f).getTextContent());
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

    }
}
