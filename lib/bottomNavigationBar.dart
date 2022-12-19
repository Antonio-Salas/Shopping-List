import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:my_own_list/routes/homeProducts.dart';
import 'package:my_own_list/routes/productsNotAvailable.dart';

import 'elements/add_item.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _paginaActual = 0;

  List<Widget> _paginas = [
    HomeProducts(),
    ProductsNotAvailable(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo_myownlistSC.png',
              fit: BoxFit.contain,
              height: 32,
            ),
            const SizedBox(
              width: 2,
            ),
            Container(
              child: _paginaActual == 0
                  ? const Text('Productos disponibles')
                  : const Text('Productos agotados'),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFe9791a),
      ),
      body: _paginas[_paginaActual],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => AddItem()));
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xFFff9a3e),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
          onTap: (index) {
            setState(() {
              _paginaActual = index;
            });
          },
          currentIndex: _paginaActual,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                color: Color(0xFFe9791a),
              ),
              label: 'Inicio',
              backgroundColor: Color(0xFFe9791a),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.menu,
                color: Color(0xFFe9791a),
              ),
              label: 'Productos agotados',
              backgroundColor: Color(0xFFe9791a),
            ),
          ]),
    );
  }
}
