import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import 'products.dart';

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  String title = "";
  String description = "";
  String price = "";
  String imageUrl = "";

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                        labelText: "Title", hintText: "Add title"),
                    //title بداخل  val ومن ثم اسناد قيمة ال  onChanged الى ال  controller  استنبدل ال
                    onChanged: (val) => setState(() => title = val),
                  ),
                  TextField(
                    decoration: const InputDecoration(
                        labelText: "Description", hintText: "Add description"),
                    onChanged: (val) => setState(() => description = val),
                  ),
                  TextField(
                    decoration: const InputDecoration(
                        labelText: "Price", hintText: "Add price"),
                    onChanged: (val) => setState(() => price = val),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: const InputDecoration(
                        labelText: "Image Url",
                        hintText: "Paste your image url here"),
                    onChanged: (val) => setState(() => imageUrl = val),
                  ),
                  const SizedBox(height: 30),
                  Consumer<Products>(
                    builder: (ctx, value, _) => RaisedButton(
                        color: Colors.orangeAccent,
                        textColor: Colors.black,
                        child: Text("Add Product"),
                        onPressed: () {
                          //double ويحوله الى Price ياخد ال
                          var doublePrice;
                          setState(() {
                            // 0.0 وتسند قيمته واذا ما اتستطعت ؟؟ أنا من عندي هسند الو قيمة  double الى  Price حاول تحويل ال
                            //else if ومن ثم بنتحقق من شرط معين
                            doublePrice = double.tryParse(price) ?? 0.0;
                          });
                          // يساوي قيمة فارغةtitle  هل ال
                          if (title == "" ||
                              description == "" ||
                              price == "" ||
                              imageUrl == "") {
                            Toast.show("Please enter all field",
                                textStyle: context, duration: Toast.lengthLong);
                          } else if (doublePrice == 0.0) {
                            Toast.show("Please enter a valid price",
                                textStyle: context, duration: Toast.lengthLong);
                          } else {
                            setState(() {
                              _isLoading = true;
                            });
                            value
                                .add(
                              id: DateTime.now().toString(),
                              title: title,
                              description: description,
                              price: doublePrice,
                              imageUrl: imageUrl,
                            )
                                .catchError((_) {
                              return showDialog<Null>(
                                context: context,
                                builder: (innerContext) => AlertDialog(
                                  title: Text("An error occurred!"),
                                  content: Text('Something went wrong.'),
                                  actions: [
                                    FlatButton(
                                        child: Text("Okay"),
                                        onPressed: () =>
                                            Navigator.of(innerContext).pop())
                                  ],
                                ),
                              );
                            }).then((_) {
                              setState(() {
                                _isLoading = false;
                              });
                              Navigator.pop(context);
                            });
                          }
                        }),
                  ),
                ],
              ),
            ),
    );
  }
}
