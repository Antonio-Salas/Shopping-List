import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../elements/add_item.dart';
import '../elements/shopping_list.dart';

class HomeProducts extends StatefulWidget {
  const HomeProducts({Key? key}) : super(key: key);

  @override
  State<HomeProducts> createState() => _HomeProductsState();
}

class _HomeProductsState extends State<HomeProducts> {
  Query _referenceShoppingList = FirebaseFirestore.instance
      .collection("shopping_list")
      .where("quantity", isNotEqualTo: "0");

  late Stream<QuerySnapshot> _streamShoppingItems;

  // @override
  initState() {
    super.initState();
    _streamShoppingItems = _referenceShoppingList.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const Padding(
            padding:
                EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Text(
              "Bienvenido",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 40,
              ),
            ),
          ),
          const Padding(
            padding:
                EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Text(
              "Los siguientes productos estan disponibles en tu hogar. Inicia agregando uno presionando el boton de más.",
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height - 300,
            child: StreamBuilder(
              stream: _streamShoppingItems,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }
                if (snapshot.connectionState == ConnectionState.active) {
                  QuerySnapshot querySnapshot = snapshot.data;
                  List<QueryDocumentSnapshot> listQueryDocumentSnapshot =
                      querySnapshot.docs;
                  List<Map> items = listQueryDocumentSnapshot
                      .map((e) => e.data() as Map)
                      .toList();

                  return ListView.builder(
                    itemCount: listQueryDocumentSnapshot.length,
                    itemBuilder: (context, index) {
                      Map thisItem = items[index];
                      QueryDocumentSnapshot document =
                          listQueryDocumentSnapshot[index];
                      return ShoppingList(document: document, item: thisItem);
                    },
                  );
                }

                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}
