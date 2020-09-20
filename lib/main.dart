import 'dart:math';
import 'package:flutter/material.dart';
import './app_screen/databasehelper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> queryRows = [];
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  getData() async {
    setState(() => loader = true);
    queryRows = await DatabaseHelper.instance.queryAll();
    print(queryRows);
    setState(() => loader = false);
  }

  bool loader = false;
  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    final safepadding = MediaQuery.of(context).padding.top;
    return Scaffold(
      appBar: AppBar(
        title: Text('SqfLite Example'),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height - safepadding,
        child: Center(
          child: loader
              ? CircularProgressIndicator()
              : AnimatedList(
                  initialItemCount: queryRows.length,
                  itemBuilder:
                      (BuildContext context, int index, Animation animation) {
                    Map<String, dynamic> row = queryRows[index];
                    return GestureDetector(
                      onTap: () async {
                        nameController.value =
                            TextEditingValue(text: row['name']);
                        emailController.value =
                            TextEditingValue(text: row['email']);
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          child: SimpleDialog(
                            contentPadding: EdgeInsets.only(
                                left: 15.0,
                                right: 25.0,
                                top: 10.0,
                                bottom: 15.0),
                            title: Text('Add New Data'),
                            children: [
                              Container(
                                child: TextFormField(
                                  validator: (value) {
                                    if (value.length < 3) {
                                      return "Name must be atleast 3 characters";
                                    }
                                    return null;
                                  },
                                  autovalidate: true,
                                  controller: nameController,
                                  style: TextStyle(fontSize: 18.0),
                                  decoration: InputDecoration(
                                      labelText: 'Name',
                                      labelStyle: TextStyle(fontSize: 18.0)),
                                ),
                              ),
                              Container(
                                child: TextFormField(
                                  validator: (value) {
                                    Pattern emailpattern =
                                        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                    RegExp regexemail =
                                        new RegExp(emailpattern);
                                    if (!regexemail.hasMatch(value)) {
                                      return 'Invalid Email';
                                    }
                                    return null;
                                  },
                                  autovalidate: true,
                                  controller: emailController,
                                  style: TextStyle(fontSize: 18.0),
                                  decoration: InputDecoration(
                                      labelText: 'Email',
                                      labelStyle: TextStyle(fontSize: 18.0)),
                                ),
                              ),
                              Row(children: [
                                FlatButton(
                                  onPressed: () async {
                                    setState(() => loader = true);
                                    Navigator.pop(context);
                                    int i =
                                        await DatabaseHelper.instance.update({
                                      DatabaseHelper.columnId: row['_id'],
                                      DatabaseHelper.columnName:
                                          nameController.text,
                                      DatabaseHelper.columnEmail:
                                          emailController.text,
                                    });
                                    print(i);
                                    queryRows = await DatabaseHelper.instance
                                        .queryAll();
                                    setState(() => loader = false);
                                  },
                                  child: Text('Update'),
                                ),
                                FlatButton(
                                  color: Colors.red,
                                  onPressed: () async {
                                    setState(() => loader = true);
                                    Navigator.pop(context);
                                    setState(() => loader = false);
                                  },
                                  child: Text('Cancel'),
                                ),
                              ])
                            ],
                          ),
                        );
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 400),
                        curve: Curves.elasticIn,
                        height: 100,
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            color: Color(
                                    (Random().nextDouble() * 0xFFFFFF).toInt())
                                .withOpacity(0.5)),
                        margin: EdgeInsets.only(
                            top: 5.0, left: 15.0, right: 15.0, bottom: 5.0),
                        child: Row(
                          children: [
                            Icon(Icons.account_circle),
                            Container(
                              padding: EdgeInsets.only(left: 5),
                              width: MediaQuery.of(context).size.width / 4,
                              child: Text(
                                '${row['name']}',
                                // maxLines: 1,
                                style: TextStyle(
                                  // color: Colors.white70,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 10),
                              width: MediaQuery.of(context).size.width / 2.8,
                              child: Text(
                                '${row['email']}',
                                // maxLines: 1,
                                style: TextStyle(
                                  // color: Colors.white70,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            RawMaterialButton(
                              shape: CircleBorder(),
                              splashColor: Colors.transparent,
                              onPressed: () async {
                                setState(() => loader = true);
                                int rowsEffected = await DatabaseHelper.instance
                                    .delete(row['_id']);
                                print(rowsEffected);
                                queryRows =
                                    await DatabaseHelper.instance.queryAll();
                                setState(() => loader = false);
                              },
                              child: Icon(
                                Icons.delete_forever,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
          onPressed: addData, child: Icon(Icons.add, color: Colors.white)),
    );
  }

  addData() async {
    showDialog(
      context: context,
      child: SimpleDialog(
        contentPadding:
            EdgeInsets.only(left: 15.0, right: 25.0, top: 10.0, bottom: 15.0),
        title: Text('Add New Data'),
        children: [
          Container(
            child: TextFormField(
              validator: (value) {
                if (value.length < 3) {
                  return "Name must be atleast 3 characters";
                }
              },
              autovalidate: true,
              controller: nameController,
              style: TextStyle(fontSize: 18.0),
              decoration: InputDecoration(
                  labelText: 'Name', labelStyle: TextStyle(fontSize: 18.0)),
            ),
          ),
          Container(
            child: TextFormField(
              validator: (value) {
                Pattern emailpattern =
                    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                RegExp regexemail = new RegExp(emailpattern);
                if (!regexemail.hasMatch(value)) {
                  return 'Invalid Email';
                }
                return null;
              },
              autovalidate: true,
              controller: emailController,
              style: TextStyle(fontSize: 18.0),
              decoration: InputDecoration(
                  labelText: 'Email', labelStyle: TextStyle(fontSize: 18.0)),
            ),
          ),
          FlatButton(
            onPressed: () async {
              setState(() => loader = true);
              Navigator.pop(context);
              int i = await DatabaseHelper.instance.insert({
                DatabaseHelper.columnName: nameController.text,
                DatabaseHelper.columnEmail: emailController.text,
              });
              print(i);
              queryRows = await DatabaseHelper.instance.queryAll();
              setState(() => loader = false);
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }
}
