import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Manager',
      theme: ThemeData(
        primaryColor: Colors.brown,  // ใช้สีน้ำตาลเข้มเป็นสีหลัก
        brightness: Brightness.light,  // โหมดสว่างเพื่อให้เหมาะกับการอ่าน
        scaffoldBackgroundColor: Colors.yellow[50],  // พื้นหลังสีครีมอ่อน
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.brown[700],  // AppBar สีเข้มเพื่อให้เด่น
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        textTheme: TextTheme(
          headlineSmall: TextStyle(
            fontFamily: 'Georgia', fontSize: 16, color: Colors.black87),  // เปลี่ยน headline6 เป็น headlineSmall
          bodyLarge: TextStyle(
            fontFamily: 'Georgia', fontSize: 14, color: Colors.black54),
        ),
        cardTheme: CardTheme(
          elevation: 5,
          color: Colors.brown[50],  // สีพื้นหลังของ Card เป็นสีน้ำตาลอ่อน
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.brown[700],  // สีของปุ่มลอย
        ),
      ),
      home: BookListScreen(),
    );
  }
}

class BookListScreen extends StatefulWidget {
  @override
  _BookListScreenState createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  final CollectionReference books = FirebaseFirestore.instance.collection('Books');

  void _addBook() {
    TextEditingController titleController = TextEditingController();
    TextEditingController authorController = TextEditingController();
    TextEditingController categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Book', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: InputDecoration(labelText: 'Title')),
              TextField(controller: authorController, decoration: InputDecoration(labelText: 'Author')),
              TextField(controller: categoryController, decoration: InputDecoration(labelText: 'Category')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                books.add({
                  'title': titleController.text,
                  'author': authorController.text,
                  'category': categoryController.text,
                });
                Navigator.pop(context);
              },
              child: Text('Add', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  void _editBook(DocumentSnapshot book) {
    TextEditingController titleController = TextEditingController(text: book['title']);
    TextEditingController authorController = TextEditingController(text: book['author']);
    TextEditingController categoryController = TextEditingController(text: book['category']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Book', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: InputDecoration(labelText: 'Title')),
              TextField(controller: authorController, decoration: InputDecoration(labelText: 'Author')),
              TextField(controller: categoryController, decoration: InputDecoration(labelText: 'Category')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                books.doc(book.id).update({
                  'title': titleController.text,
                  'author': authorController.text,
                  'category': categoryController.text,
                });
                Navigator.pop(context);
              },
              child: Text('Update', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  void _deleteBook(String bookId) {
    books.doc(bookId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book List'),
      ),
      body: StreamBuilder(
        stream: books.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          return ListView(
            padding: EdgeInsets.all(10),
            children: snapshot.data!.docs.map((book) {
              return Card(
                child: ListTile(
                  contentPadding: EdgeInsets.all(15),
                  title: Text(book['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text('by ${book['author']}', style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.brown),
                        onPressed: () => _editBook(book),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteBook(book.id),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.white),
        onPressed: _addBook,
      ),
    );
  }
}






