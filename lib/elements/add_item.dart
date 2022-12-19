import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';

class AddItem extends StatefulWidget {
  const AddItem({Key? key}) : super(key: key);

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  TextEditingController _controllerName = TextEditingController();
  TextEditingController _controllerCantidad = TextEditingController();
  var _speechToText = SpeechToText();

  GlobalKey<FormState> key = GlobalKey();

  String imageUrl = "";

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

  void _getImagen() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: ImageSource.camera);

    if (file == null) return;

    String uniqueFileName = DateTime.now().microsecondsSinceEpoch.toString();

    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child("images");

    Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

    try {
      await referenceImageToUpload.putFile(File(file.path));
      imageUrl = await referenceImageToUpload.getDownloadURL();

      setState(() {
        imageUrl = imageUrl;
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Añadir un producto"),
        backgroundColor: const Color(0xFFe9791a),
      ),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: key,
            child: ListView(
              children: [
                Container(
                  height: 280.0,
                  // color: Colors.blue,
                  child: imageUrl == ""
                      ? Text(
                          "La imagen del producto se mostrará aquí cuando se cargue",
                          textAlign: TextAlign.center,
                        )
                      : Image.network(imageUrl),
                ),
                TextFormField(
                  controller: _controllerName,
                  decoration: InputDecoration(hintText: "Introduce el nombre"),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Por favor introduce un nombre";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _controllerCantidad,
                  keyboardType: TextInputType.number,
                  decoration:
                      InputDecoration(hintText: "Introduce la cantidad"),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Por favor introduce una cantidad";
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
                      if (imageUrl.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "Por favor suba una imagen o espere un momento a que se cargue la imagen")));
                        return;
                      }

                      if (key.currentState!.validate()) {
                        Map<String, String> dataToSave = {
                          "name": _controllerName.text,
                          "quantity": _controllerCantidad.text,
                          "image": imageUrl,
                        };
                        CollectionReference reference = FirebaseFirestore
                            .instance
                            .collection("shopping_list");
                        try {
                          await reference.add(dataToSave);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Producto agregado")));
                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Ocurrio un error")));
                        }
                      }
                    },
                    child: Text("Guardar")),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Consejo: Puedes dictar por voz el nombre del producto presionando el icono del micrófono"),
                    ),
              ],
            ),
          )),
    );
  }
}
