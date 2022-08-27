import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:restful_api/add_products.dart';
import 'package:restful_api/auth.dart';
import 'package:restful_api/auth_screen.dart';
import 'package:restful_api/product_details.dart';
import 'package:restful_api/splash.dart';
import 'home_screen.dart';
import 'products.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<Auth>(
          create: (_) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (_) => Products(),
          update: (ctx, auth, previousProducts) => previousProducts!
            ..getData(auth.token!, previousProducts.productsList),
        ),
      ],
      child: MyApp(),
    ),
  );
  /*
  const firebaseOptions = FirebaseOptions(
      appId: '491394684241:android:e8779f974ce029addaaf70',
      apiKey: 'AIzaSyAcKxAyjNPUb9shY8noj1EFwrXZIfoNfjo',
      projectId: 'flutter-app-1e44d',
      messagingSenderId: 'flutter-app-1e44d.firebaseapp.com',
      authDomain: '491394684241');

  await Firebase.initializeApp(options: firebaseOptions);

  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: 'ri7am.3.ri7am@gmail.com', password: 'reham123.');
    print('Done');
  } catch (e) {
    print(e);
  }*/

  /* DatabaseReference _ref = FirebaseDatabase.instance.ref().child("ffff");
  // API :
  final String url =
      'https://flutter-app-1e44d-default-rtdb.firebaseio.com/product.json';
  http.post(Uri.parse(url),
      body: json.encode({
        'id': 9,
        'title': 'reham',
        'body': 'reham',
      }));
  // push :  فريد idبيعطيني
  _ref.push().set({'id': 10});*/
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Auth>(
      builder: (ctx, value, _) {
        print(value.isAuth);
        return MaterialApp(
          theme: ThemeData(
              primaryColor: Colors.orange,
              canvasColor: const Color.fromRGBO(232, 175, 120, 1.0)),
          debugShowCheckedModeBanner: false,
          home: value.isAuth
              ? MyHomePage()
              : FutureBuilder(
                  future: value.tryAutoLogin(),
                  builder: (ctx, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoading = true;

  @override
  void initState() {
    Provider.of<Products>(context, listen: false)
        .fetchData()
        .then((_) => _isLoading = false)
        .catchError((onError) => print(onError));

    super.initState();
  }

  Widget detailCard(id, tile, desc, price, imageUrl) {
    return Builder(
      builder: (innerContext) => FlatButton(
        onPressed: () {
          print(id);
          Navigator.push(
            innerContext,
            MaterialPageRoute(builder: (_) => ProductDetails(id)),
          ).then(
              (id) => Provider.of<Products>(context, listen: false).delete(id));
        },
        child: Column(
          children: [
            SizedBox(height: 5),
            Card(
              elevation: 10,
              color: Color.fromRGBO(115, 138, 119, 1),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: EdgeInsets.only(right: 10),
                      width: 130,
                      child: Hero(
                        tag: id,
                        child: Image.network(imageUrl, fit: BoxFit.fill),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 10),
                        Text(
                          tile,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        Divider(color: Colors.white),
                        Container(
                          width: 200,
                          child: Text(
                            desc,
                            style: TextStyle(color: Colors.white, fontSize: 14),
                            softWrap: true,
                            overflow: TextOverflow.fade,
                            textAlign: TextAlign.justify,
                            maxLines: 3,
                          ),
                        ),
                        Divider(color: Colors.white),
                        Text(
                          "\$$price",
                          style: TextStyle(color: Colors.black, fontSize: 18),
                        ),
                        SizedBox(height: 13),
                      ],
                    ),
                  ),
                  Expanded(flex: 1, child: Icon(Icons.arrow_forward_ios)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Product> prodList =
        Provider.of<Products>(context, listen: true).productsList;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text(
          'My Products',
        ),
        actions: [
          IconButton(
              onPressed: () =>
                  Provider.of<Auth>(context, listen: false).logout(),
              icon: Icon(Icons.logout))
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : (prodList.isEmpty
              ? Center(
                  child: Text('No Products Added.',
                      style: TextStyle(fontSize: 22)))
              : RefreshIndicator(
                  onRefresh: () async =>
                      await Provider.of<Products>(context, listen: false)
                          .fetchData(),
                  child: ListView(
                    children: prodList
                        .map(
                          (item) => detailCard(item.id, item.title,
                              item.description, item.price, item.imageUrl),
                        )
                        .toList(),
                  ),
                )),
      floatingActionButton: Container(
        width: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Theme.of(context).primaryColor,
        ),
        child: FlatButton.icon(
          label: Text("Add Product",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
          icon: Icon(Icons.add),
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => AddProduct())),
        ),
      ),
    );
  }
}
