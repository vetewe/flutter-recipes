// Import library yang diperlukan
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app_recipes/homepage.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Widget StatefulWidget untuk menampilkan detail resep
class RecipesDetail extends StatefulWidget {
  final Map recipes;
  const RecipesDetail({Key? key, required this.recipes}) : super(key: key);

  @override
  _RecipesDetailState createState() => _RecipesDetailState();
}

// State untuk RecipesDetail
class _RecipesDetailState extends State<RecipesDetail> {
  // Variabel untuk menyimpan status penyimpanan resep
  bool isSaved = false;

  @override
  void initState() {
    // Inisialisasi state dan memuat status penyimpanan
    super.initState();
    _loadSavedStatus();
  }

  // Fungsi untuk memuat status penyimpanan resep dari SharedPreferences
  void _loadSavedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isSaved = prefs.getBool('recipe_${widget.recipes['id']}') ?? false;
    });
  }

  // Fungsi untuk mengubah status penyimpanan resep
  void _toggleSaved() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isSaved = !isSaved;
      prefs.setBool('recipe_${widget.recipes['id']}', isSaved);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Membangun UI untuk detail resep
    final Size size = MediaQuery.of(context).size;

    // Memisahkan string ingredients dan instructions menjadi list
    List<String> ingredients = widget.recipes['ingredients'].split('; ');
    List<String> instructions = widget.recipes['instructions'].split('; ');

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stack untuk menampilkan gambar resep, tombol kembali, dan tombol simpan
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Gambar resep
                Image.network(
                  urlm + '/img/' + widget.recipes['image'],
                ),
                // Tombol kembali dan tombol simpan
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 10,
                  right: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                        child: Tooltip(
                          message: 'Back',
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: Colors.black,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                        child: Tooltip(
                          message: 'Saved',
                          child: IconButton(
                            icon: Icon(
                              isSaved ? Icons.bookmark : Icons.bookmark_border,
                              color: isSaved ? Colors.black : Colors.white,
                            ),
                            onPressed: _toggleSaved,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Container informasi resep (nama, cuisine, rating, dll)
                Positioned(
                  bottom: -40,
                  right: 25,
                  left: 25,
                  child: Container(
                    height: 166,
                    width: size.width,
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          spreadRadius: 2,
                          blurRadius: 2,
                        )
                      ],
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.amber,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.recipes['name'],
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 15),
                              Row(
                                children: [
                                  Text(
                                    widget.recipes['cuisine'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Text(
                                    " • ",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    widget.recipes['mealType']
                                        .toString()
                                        .replaceAll(RegExp(r'[\[\]]'), '')
                                        .split(',')
                                        .join(' • '),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Container(
                          height: 40,
                          width: size.width,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 35,
                              ),
                              const Icon(
                                Icons.star,
                                color: Colors.orange,
                              ),
                              Text(widget.recipes['rating'].toString()),
                              const SizedBox(
                                width: 40,
                              ),
                              const Icon(
                                Icons.timer,
                                color: Colors.blueAccent,
                              ),
                              Text(
                                  "${widget.recipes['cookTimeMinutes'].toString()} min"),
                              const SizedBox(
                                width: 30,
                              ),
                              const Icon(
                                Icons.accessibility,
                                color: Colors.black,
                              ),
                              Text(
                                  "${widget.recipes['caloriesPerServing'].toString()} kcl"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Bagian untuk menampilkan ingredients dan instructions
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  // Bagian ingredients
                  const Text(
                    "Ingredients",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10, top: 10, right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(ingredients.length, (index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "• ",
                                style: TextStyle(
                                    color: Colors.amber, fontSize: 20),
                              ),
                              Expanded(
                                child: Text(
                                  ingredients[index],
                                  style: TextStyle(fontSize: 16, height: 1.5),
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Bagian instructions
                  const Text(
                    "Instructions",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10, top: 10, right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(instructions.length, (index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 25,
                                child: Text(
                                  "${index + 1}.",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  instructions[index],
                                  style: TextStyle(fontSize: 16, height: 1.5),
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
