import 'package:flutter/material.dart';
import 'package:animated_indexed_stack/animated_indexed_stack.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: AnimatedIndexedStack(
        index: _currentIndex,
        children: [
          CounterWidget(
            name: 'Car',
          ),
          CounterWidget(
            name: 'Bike',
          ),
          CounterWidget(
            name: 'Transit',
          ),
        ],
        duration: const Duration(seconds: 1),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            title: Text('Car'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bike),
            title: Text('Bike'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_transit),
            title: Text('Transit'),
          ),
        ],
      ),
    );
  }
}

class CounterWidget extends StatefulWidget {
  CounterWidget({Key key, this.name}) : super(key: key);

  final String name;

  @override
  _CounterWidgetState createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Counter ${widget.name} - $_counter'),
          const SizedBox(height: 8.0),
          FloatingActionButton(
            heroTag: '_counter${widget.name}',
            child: Icon(Icons.add),
            onPressed: () {
              setState(() {
                _counter++;
              });
            },
          )
        ],
      ),
    );
  }
}
