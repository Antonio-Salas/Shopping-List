import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_own_list/elements/item_details.dart';
import 'package:speech_to_text/speech_to_text.dart';

class EditItem extends StatefulWidget {
  Map<String, dynamic> shoppingItem;
  EditItem(this.shoppingItem, {Key? key});

  @override
  State<EditItem> createState() => _EditItemState();
}

class _EditItemState extends State<EditItem> {
  late TextEditingController _controllerName;
  late TextEditingController _controllerQuantity;
  var _speechToText = SpeechToText();
  GlobalKey<FormState> _key = GlobalKey();

  //Funcion de escucha del microfono
  void _listen() async {
    bool disponible = await _speechToText.initialize(
        onStatus: (status) => print("$status"),
        onError: (errorNotification) => print("$errorNotification"));
    if (disponible) {
      _speechToText.listen(
        onResult: (result) => setState(() {
          _controllerName.text = result.recognizedWords;
        }),
      );
    }
  }

  String imageUrl = "";

  @override
  void initState() {
    super.initState();
    _controllerName = TextEditingController(text: widget.shoppingItem["name"]);
    _controllerQuantity =
        TextEditingController(text: widget.shoppingItem["quantity"]);
    _speechToText = SpeechToText();
  }

  //Obtener imagen de la camara
  void _getImagen() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: ImageSource.camera);

    if (file == null) return;

    String uniqueFileName = DateTime.now().microsecondsSinceEpoch.toString();

    Reference referenceImageToUpload =
        FirebaseStorage.instance.refFromURL(widget.shoppingItem["image"]);

    try {
      await referenceImageToUpload.putFile(File(file.path));
      var url = await referenceImageToUpload.getDownloadURL();

      setState(() {
        imageUrl = url;
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar producto'),
        backgroundColor: const Color(0xFFe9791a),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _key,
          child: ListView(
            children: [
              Container(
                height: 280.0,
                // color: Colors.blue,
                child: imageUrl == ""
                    ? Text(
                        "Imagen del producto",
                        textAlign: TextAlign.center,
                      )
                    : Image.network(imageUrl),
              ),
              TextFormField(
                controller: _controllerName,
                decoration: InputDecoration(
                    hintText: 'Introduce el nombre del producto'),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor introduce el nombre del producto';
                  }

                  return null;
                },
              ),
              TextFormField(
                controller: _controllerQuantity,
                decoration: InputDecoration(
                    hintText: 'Introduce la cantidad del producto'),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor introduce la cantidad del producto';
                  }

                  return null;
                },
              ),
              IconButton(
                onPressed: () {
                  _getImagen();
                },
                icon: Icon(Icons.camera_alt),
              ),
              IconButton(
                  onPressed: () {
                    _listen();
                  },
                  icon: Icon(Icons.mic)),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: const Color(0xFFff9a3e),
                  ),
                  onPressed: () async {

                    if (_key.currentState!.validate()) {
                      String name = _controllerName.text;
                      String quantity = _controllerQuantity.text;

                      Map<String, String> dataToUpdate = {
                        'name': '',
                        'quantity': '',
                        'image': '',
                      };

                      if (imageUrl.isEmpty || imageUrl == "") {
                        dataToUpdate = {
                          'name': name,
                          'quantity': quantity,
                        };
                      } else {
                        dataToUpdate = {
                          'name': name,
                          'quantity': quantity,
                          'image': imageUrl
                        };
                      }

                      CollectionReference collection = FirebaseFirestore
                          .instance
                          .collection("shopping_list");
                      DocumentReference reference =
                          collection.doc(widget.shoppingItem["doc_id"]);

                      reference.update(dataToUpdate);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Se ha guardado correctamente")));
                      Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => ItemDetails(
                                      widget.shoppingItem["doc_id"])))
                          .then((_) => setState(() {}));
                    }
                  },
                  child: Text('Guardar')),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Consejo: Puedes dictar por voz el nombre del producto presionando el icono del micrófono"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
