// Import paket-paket yang diperlukan
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_recipes/recipesDetail.dart';
import 'package:app_recipes/homepage.dart';

// Widget StatefulWidget untuk halaman resep yang disimpan
class SavedRecipePage extends StatefulWidget {
  const SavedRecipePage({Key? key}) : super(key: key);

  @override
  _SavedRecipePageState createState() => _SavedRecipePageState();
}

// State untuk SavedRecipePage
class _SavedRecipePageState extends State<SavedRecipePage> {
  // Daftar untuk menyimpan resep-resep yang disimpan
  List<dynamic> _savedRecipes = [];

  // Inisialisasi state
  @override
  void initState() {
    super.initState();
    _loadSavedRecipes();
  }

  // Fungsi untuk memuat resep-resep yang disimpan
  void _loadSavedRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final allRecipes = await fetchRecipes();
    final savedRecipes = allRecipes.where((recipe) {
      return prefs.getBool('recipe_${recipe['id']}') ?? false;
    }).toList();
    setState(() {
      _savedRecipes = savedRecipes;
    });
  }

  // Membangun tampilan UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text('Saved Recipes', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: _savedRecipes.isEmpty
          ? Center(child: Text('No saved recipes yet'))
          : ListView.builder(
              itemCount: _savedRecipes.length,
              itemBuilder: (context, index) {
                return _buildRecipeCard(_savedRecipes[index]);
              },
            ),
    );
  }

  // Fungsi untuk membangun kartu resep
  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipesDetail(recipes: recipe),
          ),
        ).then((_) => _loadSavedRecipes());
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
