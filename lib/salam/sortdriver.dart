import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SortDriver extends StatefulWidget {
  const SortDriver({Key? key}) : super(key: key);

  @override
  State<SortDriver> createState() => _SortDriverState();
}

class _SortDriverState extends State<SortDriver> {
  var ref = FirebaseDatabase.instance.ref().child("activeDrivers");
  var dtList = [];
  String driverId = '';
  var dList = [];

  getDriver() {
    var newMap = {};
    var d = {};
    ref.onValue.listen((event) {
      //  print(event.snapshot.value);

      d = event.snapshot.value as Map<String, dynamic>;
      print(d);
      print('--start---');
    });

    newMap = Map.fromEntries(
      d.entries.toList()
        ..sort(
          (e1, e2) => DateTime.parse(e1.value["time"]!).compareTo(
            DateTime.parse(e2.value["time"]!),
          ),
        ),
    );

    print('newMap: $newMap');
    print('newMap: ${newMap.entries.toList()[4]}');
    print('--end---');
  }

  getData() async {
    var d = await ref.get();
    var f = d.value as Map;
    print(f);

    var newMap = Map.fromEntries(
      f.entries.toList()
        ..sort(
          (e1, e2) => DateTime.parse(e1.value["time"]!).compareTo(
            DateTime.parse(e2.value["time"]!),
          ),
        ),
    );
    dList = [];
    newMap.forEach((key, value) {
      dList.add([key, value]);
    });
    print(dList);
    print('----------------------------');
    print(dList.firstWhere((element) => element[1]['zone'] == 'التحدي')[0]);

    print('-------------end---------------');
    driverId = dList.firstWhere((element) => element[1]['zone'] == 'التحدي')[0];
    setState(() {});
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: dList.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        '${dList[index][1]['time']} ${dList[index][1]['zone']} ${dList[index][0]}',
                        style: TextStyle(fontSize: 22.0),
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () => getData(),
              child: Text('click'),
            ),
            Text(driverId),
          ],
        ),
      ),
    );
  }
}
