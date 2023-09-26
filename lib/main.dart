import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_stream/models/api_model.dart';
import 'package:flutter_stream/services/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isClicked = false;
  Stream<List<Products>> fetchDataFromApi() async* {
    bool isDone = false;
    int limit = 50;
    int skip = 0;
    while (!isDone) {
      var data = await fetchProducts(limit: limit, skip: skip);
      skip += limit;
      await Future.delayed(const Duration(seconds: 5));

      if (data[0].products.isEmpty) {
        isDone = true;
      }
      yield data;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Flutter Demo')),
        body: buildStream(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              isClicked = !isClicked;
            });
          },
          child: const Icon(Icons.get_app),
        ),
      ),
    );
  }

  StreamBuilder<List<Products>> buildStream() {
    return StreamBuilder(
      stream: isClicked ? fetchDataFromApi() : null,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return const Center(child: Text('Click to download data button', style: TextStyle(fontSize: 20)));
          case ConnectionState.waiting:
            return const Center(child: Text('Loading...', style: TextStyle(fontSize: 20)));
          case ConnectionState.active:
            return buildData(snapshot.data[0].products);
          case ConnectionState.done:
            return Center(
                child: Text('Done',
                    style: Theme.of(context).textTheme.displaySmall));
        }
      },
    );
  }

  GridView buildData(List<Product> data) {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: data.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (BuildContext context, int index) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                offset: Offset(1, 6),
              )
            ],
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                    child: Image.network(
                      data[index].thumbnail,
                      fit: BoxFit.cover,
                      height: 100,
                      width: double.infinity,
                    )),
                Text(data[index].title,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis)),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('\$${data[index].price.toString()}',
                      style: const TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
