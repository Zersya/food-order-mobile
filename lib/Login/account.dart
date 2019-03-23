class Account {
  String nama;
  String role;
  String uid;
  String docid;
  String namaToko;
  Account(this.nama, this.uid, this.role);

  void setDocId(val){
    this.docid = val;
  }
  void setNamaToko(val){
    this.namaToko = val;
  }
}