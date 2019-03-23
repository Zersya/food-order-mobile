import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:flutter/animation.dart';
import 'package:flutter_toko/Order/addOrder.dart';
import 'package:flutter_toko/Order/detailOrder.dart';
import 'package:flutter_toko/Login/account.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'Aplikasi kantin'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum FilterToko { semua, nasipadang, mulyarasa, rmsederhana }

enum PositionScreen { login, rolepick, insertStoreName, main }

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  Orderan orderan;
  Account _account;
  List<Orderan> daftarOrderan = new List();
  Stream<QuerySnapshot> snapShots;
  FilterToko _selectionFilter;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignInAccount _currentUser;
  FirebaseUser _user;
  AnimationController _animationController;
  Animation<double> _animation;
  PositionScreen _positionScreen;

  @override
  void initState() {
    super.initState();

    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      _currentUser = account;

      _handleSignInFireAuth(_currentUser);

      setState(() {
//        _positionScreen = PositionScreen.main;
        _animationController.reverse(from: 1);
      });
    });

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController)
      ..addStatusListener((state) {});

    _animationController.forward(from: 0);

    _googleSignIn.signInSilently();
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
    _handleSignOut();
    _user = null;
    _positionScreen = PositionScreen.login;
  }

  @override
  Widget build(BuildContext context) {
//          return _buildMain();
//    return _pickRole();

    switch (_positionScreen) {
      case PositionScreen.login:
        return _buildLogin();
      case PositionScreen.rolepick:
        return _pickRole();
      case PositionScreen.insertStoreName:
        return _pickRole();
      case PositionScreen.main:
        return _buildMain();
      default:
        return _buildLogin();
    }

//    return _buildLogin();
  }

  Widget _buildMain() {
    if (orderan != null) {
      daftarOrderan.add(orderan);
      orderan = null;
    }
    if (daftarOrderan.isNotEmpty)
      daftarOrderan = daftarOrderan.reversed.toList();
    timeago.setLocaleMessages('id', timeago.IdMessages());
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
              icon: Icon(FontAwesomeIcons.signOutAlt,
                  size: 35, color: Colors.white),
              onPressed: () {
                _handleSignOut();
              }),
          PopupMenuButton<FilterToko>(
            tooltip: 'Filter toko',
            icon: Icon(Icons.filter_list, size: 30),
            onSelected: (FilterToko result) {
              setState(() {
                _selectionFilter = result;
              });
            },
            itemBuilder: itemBuilderPopupMenu(),
          ),
        ],
      ),
      body: buildStreamBuilder(),
      floatingActionButton: new Builder(
        builder: (con) => FloatingActionButton(
              onPressed: () {
                _navigateToAddingOrder(con);
              },
              child: Icon(Icons.add),
            ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _pickRole() {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              child: Text(
            'Selamat datang',
            style: TextStyle(color: Colors.black45, fontSize: 35.0),
          )),
          Container(height: 45.0),
          Container(
            child: _fieldAwalToko(),
          ),
        ],
      ),
    ));
  }

  Widget _fieldAwalToko() {
    if (_positionScreen == PositionScreen.rolepick) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 55.0,
            child: RaisedButton.icon(
                color: Colors.lightGreen,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                onPressed: () {
                  _handleAuthFireStore(_user, 'Penjual');
                  setState(() {
                    _positionScreen = PositionScreen.insertStoreName;
                  });
                },
                icon: Icon(Icons.person),
                label: Text('Penjual'),
                textColor: Colors.white),
          ),
          Container(
            width: 20.0,
          ),
          Container(
            height: 55.0,
            child: RaisedButton.icon(
              color: Colors.lightBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              onPressed: () {
                _handleAuthFireStore(_user, 'Pembeli');
                setState(() {
                  _positionScreen = PositionScreen.main;
                });
              },
              icon: Icon(Icons.person),
              label: Text('Pembeli'),
              textColor: Colors.white,
            ),
          ),
        ],
      );
    } else if (_positionScreen == PositionScreen.insertStoreName) {
      final _formKey = GlobalKey<FormState>();
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Container(
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Masukan nama toko',
                      contentPadding: EdgeInsets.all(5),
                      icon: Icon(FontAwesomeIcons.store),
                    ),
                    validator: (value) {
                      if (value.isEmpty)
                        return 'Haram isikan nama toko';
                      else
                        _account.setNamaToko(value);
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 25, 0, 0),
                  height: 45,
                  width: 125,
                  child: RaisedButton(
                    child: Text(
                      'Simpan',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.lightGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    onPressed: () {
                      print(_account.docid);
                      print(_account.namaToko);
                      if (_formKey.currentState.validate()) {
                        Firestore.instance
                            .collection('Account')
                            .document(_account.docid)
                            .setData({'namaToko': _account.namaToko}, merge: true);

                        setState(() {
                          _positionScreen = PositionScreen.main;
                        });
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildLogin() {
    return Scaffold(
      body: FadeTransition(
        opacity: _animation,
        child: Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FlutterLogo(
                    size: 255, duration: const Duration(milliseconds: 750)),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 25, 0, 50),
                  child: googleLoginBtn(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget googleLoginBtn() {
    if (_googleSignIn.currentUser == null) {
      return RaisedButton.icon(
        color: Colors.lightBlue,
        icon: Icon(FontAwesomeIcons.signInAlt, size: 25, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        label: Text(
          'Masuk dengan akun google.',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          _handleSignIn();
        },
      );
    }
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<FirebaseUser> _handleSignInFireAuth(
      GoogleSignInAccount googleUser) async {
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    FirebaseUser user = await _auth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    print("signed in " + user.displayName);
    _user = user;
    _handleRoleStore(user);

    return user;
  }

  _handleAuthFireStore(FirebaseUser user, _role) {
    Firestore.instance
        .collection('Account')
        .document()
        .setData({'uid': user.uid, 'role': _role, 'namaToko': null});

    _account = Account(user.displayName, user.uid, _role);
  }

  _handleRoleStore(FirebaseUser user) {
    Firestore.instance
        .collection('Account')
        .where('uid', isEqualTo: user.uid)
        .snapshots()
        .listen((QuerySnapshot snap) {
//      print(snap.documents);
      setState(() {
        if (snap.documents.length == 0)
          _positionScreen = PositionScreen.rolepick;
        else {
          snap.documents.forEach((DocumentSnapshot doc) {
            if(_account == null) {
              _account = Account(user.displayName, user.uid, doc.data['role']);
              _account.setDocId(doc.documentID);
            }else{
              Account ac = _account;
              _account = ac;
              _account.setDocId(doc.documentID);
              _account.setNamaToko(ac.namaToko);
            }

          });
          print(_account.namaToko);
          if (_account.role == 'Pembeli' || (_account.role == 'Penjual' && _account.namaToko != null))
            _positionScreen = PositionScreen.main;
          else _positionScreen = PositionScreen.insertStoreName;

        }
      });
//      print(_positionScreen);
    });
  }

  Future<void> _handleSignOut() async {
    await FirebaseAuth.instance.signOut();
    await _googleSignIn.disconnect();
    setState(() {
      _positionScreen = PositionScreen.login;
    });
    _animationController.forward(from: 0);
  }

  itemBuilderPopupMenu() {
    return (BuildContext context) => <PopupMenuEntry<FilterToko>>[
          const PopupMenuItem<FilterToko>(
            value: FilterToko.semua,
            child: Text('Semua'),
          ),
          const PopupMenuItem<FilterToko>(
            value: FilterToko.rmsederhana,
            child: Text('RM Sederhana'),
          ),
          const PopupMenuItem<FilterToko>(
            value: FilterToko.nasipadang,
            child: Text('Nasi Padang'),
          ),
          const PopupMenuItem<FilterToko>(
            value: FilterToko.mulyarasa,
            child: Text('Mulyarasa'),
          )
        ];
  }

  String penamaanToko() {
    String _namaToko = '';
    switch (_selectionFilter) {
      case FilterToko.nasipadang:
        _namaToko = 'Nasi Padang';
        snapShots = Firestore.instance
            .collection('Orderan')
            .where('toko', isEqualTo: _namaToko)
            .snapshots();
        break;
      case FilterToko.rmsederhana:
        _namaToko = 'RM Sederhana';
        snapShots = Firestore.instance
            .collection('Orderan')
            .where('toko', isEqualTo: _namaToko)
            .snapshots();
        break;
      case FilterToko.mulyarasa:
        _namaToko = 'Mulyarasa';
        snapShots = Firestore.instance
            .collection('Orderan')
            .where('toko', isEqualTo: _namaToko)
            .snapshots();
        break;
      default:
        snapShots = Firestore.instance.collection('Orderan').snapshots();
        break;
    }
    return _namaToko;
  }

  StreamBuilder<QuerySnapshot> buildStreamBuilder() {
    String _namaToko = penamaanToko();
    return StreamBuilder<QuerySnapshot>(
        stream: snapShots,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          if (snapshot.data != null && snapshot.data.documents.length == 0)
            return Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 0, 0),
                child: Text('Tidak ada pesanan di toko ' + _namaToko + '...',
                    style: TextStyle(fontWeight: FontWeight.w700)));
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 0, 0),
                child: Text(
                  'Tunggu...',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              );
            case ConnectionState.none:
              return Text('Anda tidak terkoneksi..');
            default:
              return buildListView(snapshot, context);
          }
        });
  }

  Column buildListView(
      AsyncSnapshot<QuerySnapshot> snapshot, BuildContext context) {
    return Column(
      children: <Widget>[
        Flexible(
          child: ListView(
            children: snapshot.data.documents.reversed
                .map((DocumentSnapshot document) {
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade600, width: 0.5),
                ),
                child: buildSlidable(document, context),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Slidable buildSlidable(DocumentSnapshot document, BuildContext context) {
    return Slidable(
      delegate: SlidableBehindDelegate(),
      actionExtentRatio: 0.25,
      child: Container(
        color: Colors.white,
        child: buildListTile(document, context),
      ),
      secondaryActions: <Widget>[
        new IconSlideAction(
            caption: 'Hapus',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () {
              setState(() {
                Firestore.instance
                    .collection('Orderan')
                    .document(document.documentID)
                    .delete()
                    .then((_) {
                  Scaffold.of(context).showSnackBar(
                      SnackBar(content: Text("Pesanan terhapus")));
                });
              });
            }),
      ],
    );
  }

  ListTile buildListTile(DocumentSnapshot document, BuildContext context) {
    return ListTile(
      leading: Hero(
        tag: document['kode'],
        child: Icon(
          Icons.free_breakfast,
          size: 50,
        ),
      ),
      title: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                buildChip(document),
                Text(document['pesanan'][0] + ', ' + document['pesanan'][1]),
                Text(timeago.format(document['created_at'], locale: 'id'),
                    style: TextStyle(color: Colors.grey))
              ],
            ),
          )
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              orderan = Orderan(document['kode'], document['created_at'],
                  List.generate(2, (i) => ''));
              orderan.setNama(document['nama']);
              orderan.setToko(document['toko']);
              orderan.setDaftarPesanan(0, document['pesanan'][0]);
              orderan.setDaftarPesanan(1, document['pesanan'][1]);
              return new DetailOrder(orderan: orderan);
            },
          ),
        );
      },
    );
  }

  Chip buildChip(DocumentSnapshot document) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: Colors.grey.shade800,
        child: Text(document['nama'][0].toUpperCase()),
      ),
      label: Text(
        document['nama'] + ' - ' + document['toko'],
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  _navigateToAddingOrder(context) async {
    Map results = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => AddingOrder()));

    if (results.containsKey('orderan')) {
      orderan = results['orderan'];
      final SnackBar snackbar = SnackBar(
        content: Text('Orderan tersimpan'),
      );
      Scaffold.of(context).showSnackBar(snackbar);
    }
  }
}
