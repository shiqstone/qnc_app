import 'package:flutter/material.dart';
import 'package:qnc_app/qnc.dart';
import 'package:qnc_app/tryon.dart';
import 'package:qnc_app/widgets/image_comparator/image_comparator.dart';

class DemoPage extends StatefulWidget {
  @override
  _DemoPageState createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xb019937b),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 60),
                Text(
                  'XP the magic of AI NOW!',
                  style: TextStyle(color: Colors.white, fontSize: 32),
                ),
                SizedBox(
                    child: ImageComparator(),
                    height: MediaQuery.of(context).size.height / 3 * 2,
                    width: double.infinity),
                SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    minimumSize: Size(MediaQuery.of(context).size.width / 3, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(context, new MaterialPageRoute(builder: (context) => new PrepareTryOnPage()));
                  },
                  child: Text(
                    'Try It Now!',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: Size(MediaQuery.of(context).size.width / 3, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(context, new MaterialPageRoute(builder: (context) => new PrepareQncPage()));
                  },
                  child: Text(
                    'More Fun',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
