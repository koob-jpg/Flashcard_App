class Userb {
  String? email;
  List<String> Folders;

  Userb(this.email, this.Folders);

  Map<String, dynamic> toMap() {
    return {'email': email, 'Folders': Folders};
  }
}
