// Import library yang diperlukan
import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:app_recipes/recipesDetail.dart';
import 'package:app_recipes/savedRecipes.dart';

// URL untuk API resep
const url = "http://localhost:8080/recipesapi";
const urlm = "http://localhost:8080/";

// Fungsi untuk mengambil data resep dari API
Future<List<dynamic>> fetchRecipes() async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final recipes = data['data'] as List<dynamic>;
    // Mengacak urutan resep
    final random = Random();
    recipes.shuffle(random);
    return recipes;
  } else {
    throw Exception('Failed to load data');
  }
}

// Widget utama HomePage
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

// State untuk HomePage
class _HomePageState extends State<HomePage> {
  List<dynamic> _allRecipes = [];
  List<dynamic> _filteredRecipes = [];
  TextEditingController _searchController = TextEditingController();
  Offset _floatingButtonPosition = Offset(300, 500);

  @override
  Widget build(BuildContext context) {
    // Membangun struktur utama halaman
    return Scaffold(
      appBar: AppBar(
        // Konfigurasi AppBar
        backgroundColor: Colors.amber,
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restaurant, color: Colors.black),
              SizedBox(width: 8),
              Text('Food Recipes', style: TextStyle(color: Colors.black)),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildSearchBar(),
              _buildPopularRecipes(),
            ],
          ),
          DraggableFloatingActionButton(
            // Konfigurasi tombol floating yang bisa digeser
            child: FloatingActionButton(
              backgroundColor: Colors.amber,
              child: Icon(Icons.bookmark, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SavedRecipePage()),
                );
              },
            ),
            offset: _floatingButtonPosition,
            onPressed: () {},
            onPanUpdate: (Offset offset) {
              setState(() {
                _floatingButtonPosition = offset;
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  // Fungsi untuk memuat resep saat inisialisasi
  Future<void> _loadRecipes() async {
    final recipes = await fetchRecipes();
    setState(() {
      _allRecipes = recipes;
      _filteredRecipes = recipes;
    });
  }

  // Widget untuk membangun bar pencarian
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search any recipe',
                  prefixIcon: Icon(Icons.search, color: Colors.amber[800]),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                onChanged: _filterRecipes,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk memfilter resep berdasarkan query pencarian
  void _filterRecipes(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredRecipes = _allRecipes;
      } else {
        _filteredRecipes = _allRecipes.where((recipe) {
          final name = recipe['name'].toString().toLowerCase();
          final cuisine = recipe['cuisine'].toString().toLowerCase();
          final mealType = recipe['mealType'].toString().toLowerCase();
          final searchLower = query.toLowerCase();

          return name.contains(searchLower) ||
              cuisine.contains(searchLower) ||
              mealType.contains(searchLower);
        }).toList();
      }
    });
  }

  // Widget untuk menampilkan daftar resep populer
  Widget _buildPopularRecipes() {
    return Expanded(
      child: _allRecipes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _filteredRecipes.isEmpty
              ? const Center(child: Text('No matching recipes found'))
              : ListView.builder(
                  itemCount: _filteredRecipes.length,
                  itemBuilder: (context, index) {
                    return _buildRecipeCard(_filteredRecipes[index]);
                  },
                ),
    );
  }

  // Widget untuk membangun kartu resep individual
  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipesDetail(recipes: recipe),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  urlm + '/img/' + recipe['image'],
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe['name'],
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                            child: Text(recipe['cuisine'],
                                maxLines: 1, overflow: TextOverflow.ellipsis)),
                        Text(' • '),
                        Flexible(
                          child: Text(
                            recipe['mealType']
                                .toString()
                                .replaceAll(RegExp(r'[\[\]]'), '')
                                .split(',')
                                .join(' • '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text(recipe['rating'].toString()),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget untuk tombol floating yang bisa digeser
class DraggableFloatingActionButton extends StatelessWidget {
  final Widget child;
  final Offset offset;
  final VoidCallback onPressed;
  final Function(Offset) onPanUpdate;

  const DraggableFloatingActionButton({
    Key? key,
    required this.child,
    required this.offset,
    required this.onPressed,
    required this.onPanUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: Draggable(
        feedback: child,
        child: child,
        onDragEnd: (details) {
          onPanUpdate(details.offset);
        },
      ),
    );
  }
}
