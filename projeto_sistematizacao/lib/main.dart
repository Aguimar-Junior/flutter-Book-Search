import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CEUB Book Search',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  List<Book> _books = [];
  bool _isLoading = false;

  Future<void> _searchBooks() async {
    final query = _controller.text;
    final url = 'https://www.googleapis.com/books/v1/volumes?q=$query';

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _books = (data['items'] as List)
              .map((item) => Book.fromJson(item))
              .toList();
        });
      } else {
        print('Failed to load books');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CEUB Book Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Digite o nome do livro',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _searchBooks,
              child: Text('Pesquisar'),
            ),
            SizedBox(height: 16),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
              child: ListView.builder(
                itemCount: _books.length,
                itemBuilder: (context, index) {
                  final book = _books[index];
                  return ListTile(
                    title: Text(book.title ?? 'Título não disponível'),
                    subtitle: Text(
                      '${book.author ?? 'Autor não disponível'} - '
                          '${book.publisher ?? 'Editora não disponível'} - '
                          '${book.publishedDate ?? 'Ano não disponível'}',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Book {
  final String? title;
  final String? author;
  final String? publisher;
  final String? publishedDate;

  Book({this.title, this.author, this.publisher, this.publishedDate});

  factory Book.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] ?? {};
    final authors = (volumeInfo['authors'] as List?)?.join(', ');

    return Book(
      title: volumeInfo['title'],
      author: authors,
      publisher: volumeInfo['publisher'],
      publishedDate: volumeInfo['publishedDate'],
    );
  }
}
