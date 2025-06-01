import 'package:flutter/material.dart';
import 'package:komfy/shared/widgets/komynfo_card.dart';
import 'package:komfy/themes/typography.dart';
import 'package:komfy/themes/colors.dart';

class KomynfoScreen extends StatefulWidget {
  const KomynfoScreen({super.key});

  @override
  State<KomynfoScreen> createState() => _KomynfoScreenState();
}

class _KomynfoScreenState extends State<KomynfoScreen> {
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

  final List<Map<String, dynamic>> videoCards = [
    {
      'title': "Tips regulasi stress untuk kestabilan mental",
      'type': "Tontonan",
      'image': 'assets/images/regulasi_stress.png',
      'isVideo': true,
    },
    {
      'title': "Lelah obatnya tidur aja? Kenali jenis lelah dan cara mengatasinya",
      'type': "Tontonan",
      'image': 'assets/images/jenis_lelah.png',
      'isVideo': true,
    },
  ];

  final List<Map<String, dynamic>> sharingCards = [
    {
      'title': "Taking care to others by become Peer Conselor",
      'type': "Sharing",
      'image': 'assets/images/sharing.png',
      'isVideo': false,
    },
  ];

  List<Map<String, dynamic>> repeatItems(List<Map<String, dynamic>> items, int targetLength) {
    return List.generate(targetLength, (index) => items[index % items.length]);
  }

  late List<Map<String, dynamic>> allItems;

  @override
  void initState() {
    super.initState();
    allItems = [...articleCards, ...videoCards];
    filteredItems = List.from(allItems);
    _searchController.addListener(_filterItems);
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredItems = allItems.where((item) {
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
                      mainAxisSize: MainAxisSize.min, 
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
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 5.0), 
                                child: RichText(
                                  text: TextSpan(
                                    style: AppTypography.subtitle4.copyWith(color: Colors.black),
                                    children: [
                                      TextSpan(text: "Kenal lebih jauh dengan "),
                                      TextSpan(
                                        text: "kesehatan mental!",
                                        style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              _searchController.text.isEmpty
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        KomynfoCard(
                                          items: repeatItems(articleCards, 6),
                                          onCardTap: (data) {
                                            Navigator.pushNamed(
                                              context,
                                              '/articleDetail',
                                              arguments: {
                                                'title': data['title'],
                                                'type': data['type'],
                                                'isVideo': data['isVideo'],
                                              },
                                            );
                                          },
                                        ),
                                        SizedBox(height: 10),
                                        Padding(
                                          padding: EdgeInsets.only(left: 5.0),
                                          child: Text(
                                            "Video interaktif yang tidak kalah menarik!",
                                            style: AppTypography.subtitle4.copyWith(color: Colors.black),
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        KomynfoCard(
                                          items: repeatItems(videoCards, 6),
                                          onCardTap: (data) {
                                            Navigator.pushNamed(
                                              context,
                                              '/videoDetail',
                                              arguments: {
                                                'title': data['title'],
                                                'type': data['type'],
                                                'isVideo': data['isVideo'],
                                              },
                                            );
                                          },
                                        ),
                                        SizedBox(height: 10),
                                        Padding(
                                          padding: EdgeInsets.only(left: 5.0),
                                          child: RichText(
                                            text: TextSpan(
                                              style: AppTypography.subtitle4.copyWith(color: Colors.black),
                                              children: [
                                                TextSpan(text: "Sharing session with "),
                                                TextSpan(
                                                  text: "KBMFILKOM!",
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 7),
                                        KomynfoCard(
                                          items: repeatItems(sharingCards, 6),
                                          onCardTap: (data) {
                                            Navigator.pushNamed(
                                              context,
                                              '/articleDetail',
                                              arguments: {
                                                'title': data['title'],
                                                'type': data['type'],
                                                'isVideo': data['isVideo'],
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    )
                                  : filteredItems.isEmpty
                                      ? Text("Tidak ada hasil yang ditemukan.")
                                      : KomynfoCard(
                                          items: filteredItems,
                                          onCardTap: (data) {
                                            if (data['isVideo'] == true) {
                                              Navigator.pushNamed(
                                                context,
                                                '/videoDetail',
                                                arguments: data,
                                              );
                                            } else {
                                              Navigator.pushNamed(
                                                context,
                                                '/articleDetail',
                                                arguments: data,
                                              );
                                            }
                                          },
                                        ),
                            ],
                          ),
                        ),
                      ),
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

