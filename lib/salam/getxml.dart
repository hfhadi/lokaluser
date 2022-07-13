import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

class GetXml extends StatefulWidget {
  const GetXml({Key? key}) : super(key: key);

  @override
  State<GetXml> createState() => _GetXmlState();
}

class _GetXmlState extends State<GetXml> {
  MyXml() {
    final bookshelfXml = 'images/zoomxml.xml';
    final document = XmlDocument.parse(bookshelfXml);
    //print(document);
    var element = document.findAllElements('coordinates');
    // print(element);
  }

  @override
  void initState() {
    MyXml();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}
