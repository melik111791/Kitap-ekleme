import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';


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

  //Resmin koyulacağı container'ın büyümesi küçülmesi için gerekli değişkenler
  double containerheight = 100;
  double containerwidth = 100;
  double timerSeconds = 2;
  //--------------------------------------

  //Resim yükleme kısmı için gerekli olanlar
  File? image;
  final picker = ImagePicker();
  //----------------------------------------

  //Galeriden resim seçmek
  Future GetImageGallery() async {
    final pickedGalleryField =
        await picker.pickImage(source: ImageSource.gallery);

    //Eğer seçilmiş resim varsa basıcaz eğer yoksa 'resim seçilmedi'yi print edicez
    setState(() {
      if (pickedGalleryField != null) {
        image = File(pickedGalleryField.path);
      } else {
        print('resim seçilmedi');
      }
    });
  }
  //-------------------------------------

  //Kameradan resim çekmek
  Future GetImageCamera() async {
    final pickedCameraField =
        await picker.pickImage(source: ImageSource.camera);

    //Eğer seçilmiş resim varsa basıcaz eğer yoksa 'resim seçilmedi'yi print edicez
    setState(() {
      if (pickedCameraField != null) {
        image = File(pickedCameraField.path);
      } else {
        print('resim seçilmedi');
      }
    });
  }

  //-----------------------------------//

  CollectionReference userBooks =
      FirebaseFirestore.instance.collection('userbooks');

  List<QueryDocumentSnapshot<Object?>> kitaplar = [];

  bool isSearching = false; // Flag to track if the user is searching

  

  @override
  void initState() {
    super.initState();
  }

  //Olmayan bir kullanıcı adı girildiğinde hata mesajı vermek için yazılan fonkisyon
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
        kitaplar.clear();
      });
      return;
    }

    var data = await userBooks.where("username", isEqualTo: value.trim()).get();
    setState(() {
      kitaplar = data.docs;
    });
  }

  //Resmi storage'a yüklemek için gereken fonksiyon
  void _uploadImageToStorage() async {
    if (image == null) {
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
    Reference referenceImageToUpload =
        referenceDirectoryImage.child(uniqueFileName);
    
       
        

    try {
      // Upload the selected image to Firebase Storage
      await referenceImageToUpload.putFile(File(image!.path));

      

     

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
    } catch (error) {}
  }

  //Sil tuşuna bastıktan sonra veya kaydettikten sonra resmin container içinden silinmesini sağlayan fonkisyon
  void deleteImage() {
   
      setState(() {
        image = null;
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

              // Kitap Resmi
              Padding(
                padding: EdgeInsets.only(top: 48),
                child: TextFormField(
                  controller: searchController,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      // Set isSearching to true only when the field is not empty
                      setState(() {
                        isSearching = true;
                      });
                      _onSearchTextChanged(value);
                    } else {
                      // Clear the search results and set isSearching to false
                      setState(() {
                        isSearching = false;
                        kitaplar.clear();
                      });
                    }
                  },
                  obscureText: true,
                  obscuringCharacter: ' ',
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
                      Icons.image_outlined,
                      color: Colors.purple,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    labelText: "Kitabın Fotoğrafı",
                    labelStyle: TextStyle(color: Colors.purple),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.add_circle,
                        color: Colors.purple,
                      ),
                      onPressed: () async {
                        //Resim seçme bölümünün açıldığı alertdialogu oluşturduk ve iconlara gereken özellikleir verdik
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor:
                                  Color.fromARGB(255, 222, 172, 229),
                              title: Text(
                                  "Resmi seçeceğiniz uygualamayı seçin..."),
                              content: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 65.0),
                                    child: IconButton(
                                      onPressed: () {
                                        GetImageGallery();
                                        Navigator.pop(context);
                                      },
                                      icon: Icon(
                                        Icons.image_outlined,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      GetImageCamera();
                                      Navigator.pop(context);
                                    },
                                    icon: Icon(
                                      Icons.camera_alt_sharp,
                                      size: 40,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    icon: Icon(
                                      Icons.arrow_back,
                                    ),
                                    padding: EdgeInsets.fromLTRB(50, 90, 0, 2),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },

                      //-------------------------------
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),

              //Fotoğrafın koyulacağı alanı oluşturduk! ve fotoğrafa basınca büyüyor!

              Padding(
                padding: const EdgeInsets.only(left: 75.0),
                child: Row(
                  children: [
                    //Fotoğraftan emin olunca fotoğrafı kaydetmek istediğimizde gereken buton
                    TextButton(
                      onPressed: () async {
                        if (image != null) {
                          _uploadImageToStorage();
                          deleteImage();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Herhangi Bir Resim Seçilmedi!!!',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      child: Text('Kaydet'),
                    ),

                    SizedBox(
                      width: 10,
                    ),

                    //Fotoğrafın gözüktüğü container...
                    Flexible(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            containerheight = 300;
                            containerwidth = 300;
                          });
                          Timer(timerSeconds.seconds, () {
                            setState(() {
                              containerheight = 100;
                              containerwidth = 100;
                            });
                          });
                        },
                        child: Container(
                          child: image != null
                              ? Image.file(
                                  image!.absolute,
                                  fit: BoxFit.fill,
                                )
                              : Center(child: Icon(Icons.image)),
                          height: containerheight,
                          width: containerwidth,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),

                    //Eklenen fotoğraftan emin diiliz ve silmek istiyoruz
                    TextButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor:
                                    Color.fromARGB(255, 222, 172, 229),
                                title: Text(
                                    "Resmi silmek istediğinize emin misiniz?"),
                                content: Center(
                                    child: Row(
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        deleteImage();
                                        Navigator.pop(context);
                                      },
                                      child: Text('Evet'),
                                    ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('Hayır'),
                                    ),
                                  ],
                                )),
                              );
                            });
                      },
                      child: Text('Sil'),
                    ),
                  ],
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

              // Kullanıcı adıyla arama kısmı
              Padding(
                padding: EdgeInsets.only(top: 28),
                child: TextFormField(
                  controller: searchController,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      setState(() {
                        isSearching = true;
                      });
                      _onSearchTextChanged(value);
                    } else {
                      setState(() {
                        isSearching = false;
                        kitaplar.clear();
                      });
                    }
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
                      Icons.accessibility_new,
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

              //Kaydedince kitapların liste şeklinde geldiği yer
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

                                    userBooks.doc(kitaplar[index].id).update({
                                      "bookname": updateController.text,
                                    });

                                    var data = await userBooks
                                        .where(
                                          "username",
                                          isEqualTo:
                                              searchController.text.trim(),
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
