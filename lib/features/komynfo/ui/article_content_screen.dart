import 'package:flutter/material.dart';
import 'package:komfy/themes/typography.dart';
import 'package:komfy/themes/colors.dart';
import 'package:komfy/shared/widgets/komynfo_grid_card.dart';

class ArticleContentScreen extends StatefulWidget {
  const ArticleContentScreen({super.key});

  @override
  State<ArticleContentScreen> createState() => _ArticleContentScreenState();
}

class _ArticleContentScreenState extends State<ArticleContentScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredItems = [];

  final List<Map<String, dynamic>> articleCards = [
    {
      'title': "Familiar?\nInilah istilah mental health yang sering digunakan!",
      'type': "Bacaan",
      'image': 'assets/images/kesehatan_mental.png',
      'isVideo': false,
    },
    {
      'title': "Merasa emosional?\nItu tandanya kamu adalah manusia",
      'type': "Bacaan",
      'image': 'assets/images/emosional.png',
      'isVideo': false,
    },
  ];

  List<Map<String, dynamic>> repeatItems(List<Map<String, dynamic>> items, int targetLength) {
    return List.generate(targetLength, (index) => items[index % items.length]);
  }

  @override
  void initState() {
    super.initState();
    filteredItems = List.from(articleCards);
    _searchController.addListener(_filterItems);
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredItems = articleCards.where((item) {
        return item['title'].toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final iconSize = screenWidth * 0.08;
    final paddingHorizontal = screenWidth * 0.05;

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                paddingHorizontal,
                screenHeight * 0.03,
                paddingHorizontal,
                screenHeight * 0.015,
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: iconSize),
                        const SizedBox(width: 4),
                        Text("Kembali", style: AppTypography.subtitle3.copyWith(color: Colors.white)),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // optional, to wrap content tightly
                      children: [
                        Text("Komynfo", style: AppTypography.title1.copyWith(color: Colors.white, height: 1)),
                        Text("Komfy Information", style: AppTypography.subtitle4.copyWith(color: Colors.white)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 30, 20, 90),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Cari informasi",
                          prefixIcon: Icon(Icons.search),
                          contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            borderSide: BorderSide(color: AppColors.darkBlue3),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: RichText(
                          text: TextSpan(
                            style: AppTypography.subtitle4.copyWith(color: Colors.black),
                            children: const [
                              TextSpan(text: "Kenal lebih jauh dengan "),
                              TextSpan(
                                text: "kesehatan mental!",
                                style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      // === Grid Bacaan ===
                      Expanded(
                        child: filteredItems.isEmpty
                            ? Center(child: Text("Tidak ada hasil ditemukan."))
                            : KomynfoGridCard(
                                items: repeatItems(articleCards, 8),
                                onTap: (item) {
                                  Navigator.pushNamed(context, '/articleDetail', arguments: item);
                                },
                              ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

