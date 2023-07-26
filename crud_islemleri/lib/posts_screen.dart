import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({Key? key}) : super(key: key);

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final TextEditingController bookNameController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController updateController = TextEditingController();

  String imgUrl = '';
  XFile? selectedImage; // Added to store the selected image

  CollectionReference userBooks = FirebaseFirestore.instance.collection('userbooks');

  List<QueryDocumentSnapshot<Object?>> kitaplar = [];

  bool isSearching = false; // Flag to track if the user is searching

  @override
  void initState() {
    super.initState();
  }

  void _showSnackBarKullaniciYok() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Kullanıcı Bulunamadı!!!',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        dismissDirection: DismissDirection.up,
        backgroundColor: Colors.red,
      ),
    );
  }

  void _onSearchTextChanged(String value) async {
    if (value.isEmpty) {
      setState(() {
        kitaplar.clear(); // Clear the list if the username field is empty
      });
      return;
    }

    var data = await userBooks.where("username", isEqualTo: value.trim()).get();
    setState(() {
      kitaplar = data.docs;
    });
  }

  void _uploadImageToStorage() async {
    if (selectedImage == null) {
      // Show an error message to the user if no image is selected.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lütfen bir resim seçin',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirectoryImage = referenceRoot.child('images');
    Reference referenceImageToUpload = referenceDirectoryImage.child(uniqueFileName);

    try {
      // Upload the selected image to Firebase Storage
      await referenceImageToUpload.putFile(File(selectedImage!.path));
      imgUrl = await referenceDirectoryImage.getDownloadURL();

      // Show a success message to the user after successful upload
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Resim başarıyla yüklendi',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      // Handle errors, if any
    }
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Kullanıcı adı girme kısmı
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: TextFormField(
                  controller: userNameController,
                  decoration: const InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
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

              // Kitap adı girme kısmı
              Padding(
                padding: EdgeInsets.only(top: 40),
                child: TextFormField(
                  controller: bookNameController,
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
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
                        if (bookNameController.text.isNotEmpty &&
                            userNameController.text.isNotEmpty) {
                          await userBooks.add({
                            'bookname': bookNameController.text,
                            'username': userNameController.text,
                          }).then((value) => print('Kitap eklendi'));
                          bookNameController.clear();
                        } else if (userNameController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Lütfen bir kullanıcı adı giriniz!!!',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else if (bookNameController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Lütfen bir kitap adı giriniz!!!',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          print('Bir kitap yok');
                        }
                      },
                    ),
                  ),
                ),
              ),

              // Resim yükleme kısmı
              Padding(
                padding: EdgeInsets.only(top: 40),
                child: TextFormField(
                  controller: searchController,
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    prefixIcon: Icon(
                      Icons.image,
                      color: Colors.purple,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    labelText: "Kitabın resmi",
                    labelStyle: TextStyle(color: Colors.purple),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.add_circle,
                        color: Colors.purple,
                      ),
                      onPressed: () {
                        if (bookNameController.text.isNotEmpty &&
                            userNameController.text.isNotEmpty) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Resmi nerden seçmek istersiniz"),
                                content: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 58),
                                      child: IconButton(
                                        onPressed: () async {
                                          // Galeriden resim seçtik
                                          ImagePicker imagePicker = ImagePicker();
                                          selectedImage = await imagePicker.pickImage(
                                            source: ImageSource.gallery,
                                          );
                                          print('${selectedImage?.path}');
                                        },
                                        icon: Icon(
                                          Icons.image,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 35),
                                    IconButton(
                                      onPressed: () async {
                                        ImagePicker imagePicker = ImagePicker();
                                        selectedImage = await imagePicker.pickImage(
                                          source: ImageSource.camera,
                                        );
                                        print('${selectedImage?.path}');
                                      },
                                      icon: Icon(
                                        Icons.camera_alt_outlined,
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    child: Text("yükle"),
                                    onPressed: () {
                                      if (selectedImage != null) {
                                        _uploadImageToStorage();
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Herhangi Bir Resim Seçilmedi!!!',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            dismissDirection: DismissDirection.up,
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                      Navigator.pop(context);
                                    },
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Icon(
                                      Icons.arrow_back,
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        } else if (bookNameController.text.isNotEmpty &&
                            userNameController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Önce Bir Kullanıcı Adı Giriniz!!!',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              dismissDirection: DismissDirection.up,
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else if (bookNameController.text.isEmpty &&
                            userNameController.text.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Önce Bir Kitap Ekleyiniz!!!',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              dismissDirection: DismissDirection.up,
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else if (bookNameController.text.isEmpty &&
                            userNameController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Lütfen Daha Önceki Kısımları Doldurunuz!!!',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              dismissDirection: DismissDirection.up,
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),

              // Kullanıcı adıyla arama kısmı
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
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    prefixIcon: Icon(
                      Icons.menu_book_sharp,
                      color: Colors.purple,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    labelText: "Kullanıcı Adıyla Ara",
                    labelStyle: TextStyle(color: Colors.purple),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.search,
                        color: Colors.purple,
                      ),
                      onPressed: () {
                        if (kitaplar.isEmpty) {
                          print('Kullanıcı bulunamadı!!!');
                          _showSnackBarKullaniciYok();
                        }
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
                  return Column(
                    children: [
                      Image.network(
                        "",
                        height: 60,
                        width: 60,
                      ),
                      ListTile(
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

                                        userBooks.doc(kitaplar[index].id).update({
                                          "bookname": updateController.text,
                                        });

                                        var data = await userBooks
                                            .where(
                                              "username",
                                              isEqualTo: searchController.text.trim(),
                                            )
                                            .get();
                                        setState(() {
                                          kitaplar = data.docs;
                                        });
                                        updateController.clear();
                                      },
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Icon(
                                        Icons.arrow_back,
                                      ),
                                    ),
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
                            userBooks.doc(kitaplar[index].id).delete();

                            var data = await userBooks
                                .where(
                                  "username",
                                  isEqualTo: searchController.text.trim(),
                                )
                                .get();
                            setState(() {
                              kitaplar = data.docs;
                            });
                          },
                        ),
                      ),
                    ],
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
