import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final bookNamecontroller = TextEditingController();
  final namecontroller = TextEditingController();
  final searchController = TextEditingController();
  final updateController = TextEditingController();
  CollectionReference userbooks =
      FirebaseFirestore.instance.collection('userbooks');

  List<QueryDocumentSnapshot<Object?>> kitaplar = [];

  bool isSearching = false; // Flag to track if user is searching

  void _showsnackbarkullaniciyok() {
    setState(() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Böyle bir kullanıcı yok',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          dismissDirection: DismissDirection.up,
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  /* void _showsnackbarkullanicibos() {
    setState(() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lütfen bir kullanıcı adı giriniz',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          dismissDirection: DismissDirection.up,
          backgroundColor: Colors.red,
        ),
      );
    });
  } */

  @override
  void initState() {
    super.initState();
  }

  void _onSearchTextChanged(String value) async {
    if (value.isEmpty) {
      setState(() {
        kitaplar.clear(); // Clear the list if username field is empty
      });
      return;
    }

    var data = await userbooks.where("username", isEqualTo: value.trim()).get();
    setState(() {
      kitaplar = data.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(
                  child: Text(
                    'Kitapları girmeye başlayın...',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: TextFormField(
                  controller: namecontroller,
                  decoration: const InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    prefixIcon: Icon(
                      Icons.person,
                      color: Colors.purple,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    labelText: "Kullanıcı adı",
                    labelStyle: TextStyle(color: Colors.purple),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 40),
                child: TextFormField(
                  controller: bookNamecontroller,
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    prefixIcon: Icon(
                      Icons.menu_book_sharp,
                      color: Colors.purple,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    labelText: "Kitap adı",
                    labelStyle: TextStyle(color: Colors.purple),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.add_circle,
                        color: Colors.purple,
                      ),
                      onPressed: () async {
                        await userbooks.add({
                          'bookname': bookNamecontroller.text,
                          "username": namecontroller.text
                        }).then((value) => print('Kitap eklendi'));
                        bookNamecontroller.clear();
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 40),
                child: TextFormField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      isSearching = value.isNotEmpty;
                    });
                    _onSearchTextChanged(value);
                  },
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    prefixIcon: Icon(
                      Icons.menu_book_sharp,
                      color: Colors.purple,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    labelText: "Kullanici Adiyla Ara",
                    labelStyle: TextStyle(color: Colors.purple),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.search,
                        color: Colors.purple,
                      ),
                      onPressed: () {
                        if (kitaplar.isEmpty) {
                          print('Kullanıcı bulunamadı!!!');
                          _showsnackbarkullaniciyok();
                        }
                        /* else if (searchController.text.isEmpty) {
                          _showsnackbarkullanicibos();
                          print('kullanıcı kısmı boş'); 
                        } */
                      },
                    ),
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: kitaplar.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      "Kitap adı: ${kitaplar[index]["bookname"] ?? ""} ",
                      style: TextStyle(color: Colors.red),
                    ),
                    leading: IconButton(
                      icon: Icon(Icons.update),
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("GÜNCELLEME"),
                              content: TextFormField(
                                controller: updateController,
                                decoration: InputDecoration(
                                  label: Text('Yeni kitabın adını yazınız'),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  child: Text("güncelle"),
                                  onPressed: () async {
                                    Navigator.of(context).pop();

                                    userbooks.doc(kitaplar[index].id).update(
                                        {"bookname": updateController.text});
                                    var data = await userbooks
                                        .where("username",
                                            isEqualTo:
                                                searchController.text.trim())
                                        .get();
                                    setState(() {
                                      kitaplar = data.docs;
                                    });
                                    updateController.clear();
                                  },
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                        context, '/postscreen');
                                  },
                                  child: Icon(
                                    Icons.arrow_back,
                                  ),
                                )
                              ],
                            );
                          },
                        );
                      },
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.remove,
                        color: Colors.red,
                      ),
                      onPressed: () async {
                        userbooks.doc(kitaplar[index].id).delete();
                        var data = await userbooks
                            .where("username",
                                isEqualTo: searchController.text.trim())
                            .get();
                        setState(() {
                          kitaplar = data.docs;
                        });
                      },
                    ),
                  );
                },
              ),
            
            ],
          ),
        ),
      ),
    );
  }
}
