import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:my_own_list/bottomNavigationBar.dart';

import 'edit_item.dart';

class ItemDetails extends StatelessWidget {
  ItemDetails(this.itemId, {Key? key}) : super(key: key) {
    _reference =
        FirebaseFirestore.instance.collection("shopping_list").doc(itemId);
    _futureData = _reference.get();
  }

  String itemId;
  late DocumentReference _reference;

  late Future<DocumentSnapshot> _futureData;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: _futureData,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("Ocurrio algun error"),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          DocumentSnapshot documentSnapshot = snapshot.data;
          Map<String, dynamic> mapData =
              documentSnapshot.data() as Map<String, dynamic>;
          mapData["doc_id"] = documentSnapshot.id;
          return buildWidgetTree(
              context,
              Column(
                children: [
                  Expanded(
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            mapData["image"],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 150.0,
                    // color: Colors.transparent,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50.0),
                        topRight: Radius.circular(50.0),
                      ),
                      color: Colors.black,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black45,
                          offset: Offset(4.0, 4.0),
                          blurRadius: 10.0,
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.orange[400],
                        // color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50.0),
                          topRight: Radius.circular(50.0),
                        ),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                "${mapData["name"]}",
                                style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                "Cantidad: ${mapData["quantity"]}",
                                style: TextStyle(
                                  fontSize: 27,
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              data: mapData);
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget buildWidgetTree(BuildContext context, Widget widgetBody,
      {Map<String, dynamic> data = const {}}) {
    eliminarProducto() {
      // print("Entro");
      return AlertDialog(
        title: Text("¿Estas seguro de eliminar este producto?"),
        actions: [
          FlatButton(
              onPressed: () {
                _reference.delete();
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("El producto ha sido eliminado")));
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => Home()));
              },
              child: Text("Si")),
          FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("No")),
        ],
      );
    }

    return Scaffold(
      // backgroundColor: Colors.orange[100],

      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => Home()));
            },
            icon: Icon(Icons.arrow_back)),
        title: Text("Detalles del producto"),
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFe9791a),
        actions: [
          data.isEmpty
              ? Container()
              : IconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => EditItem(data)));
                  },
                  icon: Icon(Icons.edit)),
          IconButton(
              onPressed: () {
                // eliminarProducto();
                showDialog(
                    context: context,
                    builder: ((context) {
                      return eliminarProducto();
                    }));
              },
              icon: Icon(Icons.delete)),
        ],
      ),
      body: widgetBody,
    );
  }
}
