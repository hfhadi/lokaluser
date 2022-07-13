import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MarkerUpdate extends StatefulWidget {
  const MarkerUpdate({Key? key}) : super(key: key);

  @override
  State<MarkerUpdate> createState() => _MarkerUpdateState();
}

class _MarkerUpdateState extends State<MarkerUpdate> {
  DatabaseReference ref = FirebaseDatabase.instance.ref().child("activeDrivers"); //markers for google map
  List<int> alreadyAddedIndices = [3, 4, 5, 6, 7];

  var courseid = 0;
  var coursename = "default";

  changeFun() {
    final lists = [];

    Stream<DatabaseEvent> stream = ref.onValue;
    stream.listen((DatabaseEvent event) {
      if (lists.isNotEmpty) {
        lists.clear();
      }

      Map keyd = event.snapshot.value as Map;

      //print(keyd);

      keyd.forEach((keyf, value) {
        Map myposition = value as Map;
        // print(myposition);
        // myposition.update(value)
        myposition.forEach((keyg, value) {
          //List mmyposition.removeWhere((key, value) => value != myposition.values); = value as List;

          if (value is List) {
            lists.add(value);

            // var d = value.where((element) => element != value);

          }
        });
      });
      print(lists);
    });
  }

  @override
  void initState() {
    changeFun();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(("GridView Demo")),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GridView.builder(
              itemCount: 5,
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: (MediaQuery.of(context).orientation == Orientation.portrait) ? 3 : 5),
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        // change as per your code
                        courseid = index;
                        coursename = index.toString();
                        // add index in list if not available
                        // tapping again, remove index from list
                        alreadyAddedIndices.contains(index)
                            ? alreadyAddedIndices.remove(index)
                            : alreadyAddedIndices.add(index);
                      });
                    },
                    child: Column(
                      children: <Widget>[
                        Text((alreadyAddedIndices.contains(index)) ? "Added" : ""),
                        Icon(
                          index.isEven ? Icons.school : Icons.book_outlined,
                          size: MediaQuery.of(context).orientation == Orientation.portrait ? 30 : 30,
                          color: index.isOdd ? Colors.amber[800] : Colors.green[800],
                        ),
                        // course name text
                        const Text("course Name"),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
