import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lista_contatos/helpers/contact_hepers.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  final Contact? contact;

  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode();

  bool _userEdited = false;
  late Contact _editContact;

  @override
  void initState() {
    super.initState();
    if (widget.contact == null) {
      _editContact = Contact();
    } else {
      _editContact = Contact.fromMap(widget.contact!.toMap());

      _nameController.text = _editContact.name;
      _emailController.text = _editContact.email;
      _phoneController.text = _editContact.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(_editContact.name != "" ? _editContact.name : "Novo Contato"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            if(_editContact.name.isNotEmpty){
              Navigator.pop(context, _editContact);
            } else {
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
          child: const Icon(Icons.save),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              GestureDetector(
                child: Container(
                  width: 140.0,
                  height: 140.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: _editContact.img != "" ?
                          FileImage(File(_editContact.img)) :
                          const AssetImage('images/person.png') as ImageProvider,
                          fit: BoxFit.cover
                      )
                  ),
                ),
                onTap: (){
                  ImagePicker.pickImage(
                    source: ImageSource.camera
                  ).then((file){
                    if(file == null){
                      return;
                    }
                    setState(() {
                      _editContact.img = file.path;
                    });
                  });
                },
              ),
              TextField(
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: const InputDecoration(
                  labelText: "Nome",
                ),
                onChanged: (text){
                  _userEdited = true;
                  setState(() {
                    _editContact.name = text;
                  });
                },
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                ),
                onChanged: (text){
                  _userEdited = true;
                  _editContact.email = text;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone",
                ),
                onChanged: (text){
                  _userEdited = true;
                  _editContact.phone = text;
                },
                keyboardType: TextInputType.phone,
              )
            ],
          ),
        ),
      ),
      onWillPop: _requestPop
    );
  }

  Future<bool> _requestPop(){
    if(_userEdited){
      showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: const Text("Descartar Alterações?"),
            content: const Text("Se sair as alterações serão perdidas"),
            actions: [
              TextButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: const Text("Cancelar")
              ),
              TextButton(
                onPressed: (){
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("Sim")
              )
            ],
          );
        }
      );
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
