import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Orderan {
  String kode;
  String nama;
  String toko;
  DateTime waktuPesanan;
  List<String> daftarPesanan = new List();
  Orderan(this.kode, this.waktuPesanan, this.daftarPesanan);

  void setNama(nama) {
    this.nama = nama;
  }

  void setToko(toko) {
    this.toko = toko;
  }

  void setDaftarPesanan(i, pesanan) {
    this.daftarPesanan[i] = pesanan;
    print(daftarPesanan[0] + ', ' + daftarPesanan[1]);
  }
}

class AddingOrder extends StatefulWidget {
  @override
  _AddingOrder createState() => _AddingOrder();
}

class _AddingOrder extends State<AddingOrder> {
  static GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  Widget _childContainer;
  double _containerHeight = 0;

  List<bool> _isCheckedSederhana = List.generate(2, (bool) => false);
  List<bool> _isCheckedNasiPadang = List.generate(2, (bool) => false);
  List<bool> _isCheckedMulyarasa = List.generate(2, (bool) => false);

  bool _isSelectedMenu = false;

  String _isValueStore = 'Pilih toko';

  Orderan orderan = new Orderan(
      new DateTime.now().millisecondsSinceEpoch.toString(),
      new DateTime.now(),
      new List<String>.generate(2, (i) => ''));
  Widget build(BuildContext con) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Tambah orderan"),
        ),
        body: Builder(
          builder: (context) => Form(
                key: _formKey,
                child: Column(
                  children: children(context),
                ),
              ),
        ));
  }

  List<Widget> children(BuildContext context) {
    return <Widget>[
      ListTile(
        leading: const Icon(Icons.person),
        title: new TextFormField(
          decoration: InputDecoration(hintText: 'Nama kamu'),
          validator: (value) {
            if (value.isEmpty)
              return 'Harap isikan kolom nama';
            else
              orderan.setNama(value);
          },
        ),
      ),
      ListTile(
        leading: new Icon(Icons.place),
        title: DropdownButton(
          items:
              ['RM Sederhana', 'Nasi Padang', 'Mulyarasa'].map((String value) {
            return new DropdownMenuItem(
              value: value,
              child: Text(value),
            );
          }).toList(),
          hint: Text(_isValueStore),
          onChanged: (String val) {
            setState(() {
              _isValueStore = val;
              orderan.setToko(val);
              _containerHeight = 115;
            });
          },
        ),
      ),
      animatedContainer(),
      Container(
        margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
        child: Column(
          children: <Widget>[
            RaisedButton(
              padding: EdgeInsets.all(15.0),
              color: Colors.green,
              textColor: Colors.white,
              elevation: 2.0,
              child: Text('Pesan'),
              onPressed: () {
                if (_formKey.currentState.validate() && _isSelectedMenu) {
                  Navigator.pop(context, {'orderan': orderan});
                  Firestore.instance.collection('Orderan').document()
                  .setData(
                    {
                      'kode' : orderan.kode,
                      'nama' : orderan.nama,
                      'toko' : orderan.toko,
                      'pesanan' : orderan.daftarPesanan,
                      'created_at' : orderan.waktuPesanan
                    }
                  );
                }
              },
            )
          ],
        ),
      )
    ];
  }

  Widget animatedContainer() {
    if (_isValueStore == 'RM Sederhana') {
      _childContainer = Container(
        child: Column(
          children: <Widget>[
            CheckboxListTile(
              title: Text('Teh manis'),
              value: _isCheckedSederhana[0],
              selected: _isCheckedSederhana[0],
              onChanged: (bool value) {
                if (value){
                  _isSelectedMenu = true;
                  orderan.setDaftarPesanan(0, "Teh manis");
                }
                else
                  orderan.setDaftarPesanan(0, "");

                setState(() {
                  if (!_isCheckedSederhana[0]) {
                    _isCheckedSederhana[0] = true;
                  } else
                    _isCheckedSederhana[0] = false;
                });
              },
              secondary: const Icon(Icons.local_drink),
            ),
            CheckboxListTile(
              title: Text('Paket ayam'),
              value: _isCheckedSederhana[1],
              selected: _isCheckedSederhana[1],
              onChanged: (bool value) {
                if (value){
                  _isSelectedMenu = true;
                  orderan.setDaftarPesanan(1, "Paket ayam");
                }
                else
                  orderan.setDaftarPesanan(1, "");

                setState(() {
                  if (!_isCheckedSederhana[1]) {
                    _isCheckedSederhana[1] = true;
                  } else
                    _isCheckedSederhana[1] = false;
                });
              },
              secondary: const Icon(Icons.fastfood),
            )
          ],
        ),
      );
    } else if (_isValueStore == 'Mulyarasa') {
      _childContainer = Container(
        child: Column(
          children: <Widget>[
            CheckboxListTile(
              title: Text('Nutrisari'),
              value: _isCheckedMulyarasa[0],
              selected: _isCheckedMulyarasa[0],
              onChanged: (bool value) {
                if (value){
                  _isSelectedMenu = true;
                  orderan.setDaftarPesanan(0, "Nutrisari");
                  }
                else
                  orderan.setDaftarPesanan(0, "");

                setState(() {
                  if (!_isCheckedMulyarasa[0]) {
                    _isCheckedMulyarasa[0] = true;
                  } else
                    _isCheckedMulyarasa[0] = false;
                });
              },
              secondary: const Icon(Icons.local_drink),
            ),
            CheckboxListTile(
              title: Text('Burger'),
              value: _isCheckedMulyarasa[1],
              selected: _isCheckedMulyarasa[1],
              onChanged: (bool value) {
                if (value){
                  _isSelectedMenu = true;
                  orderan.setDaftarPesanan(1, "Burger");
                }
                else
                  orderan.setDaftarPesanan(1, "");

                setState(() {
                  if (!_isCheckedMulyarasa[1]) {
                    _isCheckedMulyarasa[1] = true;
                  } else
                    _isCheckedMulyarasa[1] = false;
                });
              },
              secondary: const Icon(Icons.fastfood),
            )
          ],
        ),
        color: Colors.transparent,
      );
    } else if (_isValueStore == 'Nasi Padang') {
      _childContainer = Container(
        child: Column(
          children: <Widget>[
            CheckboxListTile(
              title: Text('Teh panas'),
              value: _isCheckedNasiPadang[0],
              selected: _isCheckedNasiPadang[0],
              onChanged: (bool value) {
                if (value){
                  _isSelectedMenu = true;
                  orderan.setDaftarPesanan(0, "Teh panas");
                }
                else
                  orderan.setDaftarPesanan(0, "");

                setState(() {
                  if (!_isCheckedNasiPadang[0]) {
                    _isCheckedNasiPadang[0] = true;
                  } else
                    _isCheckedNasiPadang[0] = false;
                });
              },
              secondary: const Icon(Icons.local_drink),
            ),
            CheckboxListTile(
              title: Text('Nasi Rendang'),
              value: _isCheckedNasiPadang[1],
              selected: _isCheckedNasiPadang[1],
              onChanged: (bool value) {
                if (value){
                  _isSelectedMenu = true;
                  orderan.setDaftarPesanan(1, "Nasi Rendang");
                }
                else
                  orderan.setDaftarPesanan(1, "");

                setState(() {
                  if (!_isCheckedNasiPadang[1]) {
                    _isCheckedNasiPadang[1] = true;
                  } else
                    _isCheckedNasiPadang[1] = false;
                });
              },
              secondary: const Icon(Icons.fastfood),
            )
          ],
        ),
      );
    }

    return AnimatedContainer(
      duration: Duration(milliseconds: 650),
      height: _containerHeight,
      child: _childContainer,
    );
  }
}
