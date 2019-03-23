import 'package:flutter/material.dart';
import 'package:flutter_toko/Order/addOrder.dart';

class DetailOrder extends StatefulWidget {
  DetailOrder({Key key, @required this.orderan}) : super(key: key);
  final Orderan orderan;
  @override
  _DetailOrder createState() => _DetailOrder();
}

class _DetailOrder extends State<DetailOrder> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail order'),
      ),
      body: Container(
          child: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Hero(
                  tag: widget.orderan.kode,
                  child: new Icon(Icons.free_breakfast, size: 200),
                ),
                Text(widget.orderan.kode),
                Text(widget.orderan.nama),
              ],
            ),
            )
          ),
        ],
      )),
    );
  }
}
