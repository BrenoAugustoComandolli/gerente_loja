import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:gerente_loja/blocs/orders_bloc.dart';
import 'package:gerente_loja/blocs/user_bloc.dart';
import 'package:gerente_loja/tabs/orders_tab.dart';
import 'package:gerente_loja/tabs/products_tab.dart';
import 'package:gerente_loja/tabs/users_tab.dart';
import 'package:gerente_loja/widgets/edit_category_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController? _pageController;
  int _page = 0;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController!.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.pinkAccent,
          primaryColor: Colors.white,
          textTheme: Theme.of(context).textTheme.copyWith(
            caption: const TextStyle(
              color: Colors.white54,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _page,
          onTap: (p) {
            _pageController!.animateToPage(
              p,
              duration: const Duration(milliseconds: 500),
              curve: Curves.ease,
            );
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Clientes",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: "Pedidos",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: "Produtos",
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: BlocProvider(
          dependencies: const [],
          blocs: [
            Bloc((i) => UserBloc()),
            Bloc((i) => OrdersBloc()),
          ],
          child: PageView(
            controller: _pageController,
            onPageChanged: (p) {
              setState(
                    () {
                  _page = p;
                },
              );
            },
            children: const [
              UsersTab(),
              OrdersTab(),
              ProductsTab(),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloating(),
    );
  }

  Widget? _buildFloating() {
    switch (_page) {
      case 0:
        return null;
      case 1:
        return SpeedDial(
          backgroundColor: Colors.pinkAccent,
          overlayOpacity: 0.4,
          overlayColor: Colors.black,
          children: [
            SpeedDialChild(
              child: const Icon(
                Icons.arrow_downward,
                color: Colors.pinkAccent,
              ),
              backgroundColor: Colors.white,
              label: "Concluídos Abaixo",
              labelStyle: const TextStyle(fontSize: 14),
              onTap: () {
                BlocProvider.getBloc<OrdersBloc>().setOrderCriteria(SortCriteria.readyLast);
              },
            ),
            SpeedDialChild(
              child: const Icon(
                Icons.arrow_upward,
                color: Colors.pinkAccent,
              ),
              backgroundColor: Colors.white,
              label: "Concluídos Acima",
              labelStyle: const TextStyle(
                fontSize: 14,
              ),
              onTap: () {
                BlocProvider.getBloc<OrdersBloc>().setOrderCriteria(SortCriteria.readyFirst);
              },
            ),
          ],
          child: const Icon(Icons.sort),
        );
      case 2:
        return FloatingActionButton(
          backgroundColor: Colors.pinkAccent,
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const EditCategoryDialog(),
            );
          },
          child: const Icon(Icons.add),
        );
      default:
        return null;
    }
  }
}

