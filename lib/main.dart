import 'package:flutter/material.dart';
import 'package:todolist_sqlite/data/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final database = MyDatabase();
  TextEditingController titleTEC = new TextEditingController();
  TextEditingController detailTEC = new TextEditingController();

  Future insert(String title, String detail) async {
    await database.into(database.todos).insert(TodosCompanion.insert(title: title, detail: detail));
  }

  Future<List<Todo>> getAll() {
    return database.select(database.todos).get();
  }

  Future update(Todo todo, String newTitle, String newDetail) async {
    await database.update(database.todos).replace(Todo(id: todo.id, title: newTitle, detail: newDetail));
  }

  Future delete(Todo todo) async {
    await database.delete(database.todos).delete(todo);
  }


  void todoDialog(Todo? todo) {
    if (todo != null) {
      titleTEC.text = todo.title;
      detailTEC.text = todo.detail;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Text(
                  (todo != null ? 'Edit' : 'Tambah') + " Catatan",
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(
                  height: 15
                ),
                TextFormField(
                  controller: titleTEC,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Judul',
                  ),
                ),
                SizedBox(
                  height: 10
                ),
                TextFormField(
                  controller: detailTEC,
                  maxLines: 5,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Detail',
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop('dialog');
                      },
                      child: Text('Batal', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey
                      ),
                    ),
                    SizedBox(
                      width: 10
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (todo != null) {
                          update(todo, titleTEC.text, detailTEC.text);
                        } else {
                        insert(titleTEC.text, detailTEC.text);
                        }
                        setState(() {});
                        Navigator.of(context, rootNavigator: true).pop('dialog'); 
                        titleTEC.clear();
                        detailTEC.clear();
                      },
                      child: Text('Simpan', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue
                      ),
                    ),
                  ]
                )
              ],
            ),
          ),
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text(
          'Todo-list App',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
        ),
      body: SafeArea(
        child: FutureBuilder<List<Todo>>(
          future: getAll(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if(snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                   return  Card(
                      child: ListTile(
                        onTap: () {
                          todoDialog(snapshot.data![index]);
                        },
                        title: Text(
                          snapshot.data![index].title,
                        ),
                        subtitle: Text(snapshot.data![index].detail),
                        trailing: ElevatedButton(
                          child: Icon(
                            Icons.delete,
                            color: Colors.white
                          ),
                          onPressed: () {
                            delete(snapshot.data![index]);
                            setState(() {});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: CircleBorder()
                          ),
                        ),
                      ),
                    );
                  }
                );
              } else {
                return Center(
                  child: Text('Tidak ada data.'),
                );
              }
            } 
          }
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          titleTEC.clear();
          detailTEC.clear();
          todoDialog(null);
        },
        backgroundColor: Colors.blue,
        shape: CircleBorder(),
        child: Icon(
          Icons.add,
          color: Colors.white
        ),
      ),
    );
  }
}