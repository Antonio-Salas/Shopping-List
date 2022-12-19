import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'item_details.dart';

class ShoppingList extends StatefulWidget {
  ShoppingList({
    Key? key,
    required this.document,
    required this.item,
  }) : super(key: key);

  final QueryDocumentSnapshot<Object?> document;
  Map item;

  @override
  State<ShoppingList> createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 15,
        ),
        padding: EdgeInsets.symmetric(
          vertical: 2,
          horizontal: 2,
        ),
        child: _card(widget.document['name'], widget.document['quantity'],
            widget.document['image']));
  }

  Widget _card(String titulo, String cantidad, String imagen) {
    return Card(
      clipBehavior: Clip.hardEdge,
      color: Colors.orange[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(25),
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            height: 155,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  "${imagen}",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          titulo,
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          'Cant. $cantidad',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                ItemDetails(widget.document.id)));
                      },
                      icon: Icon(
                        Icons.arrow_circle_right,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          // Text("data")
        ],
      ),
    );
  }
  //final
}
