import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lista_contatos/helpers/contact_hepers.dart';
import 'package:lista_contatos/ui/contact_page.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions {orderaz, orderza}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  ContactHelper helper = ContactHelper();

  List<dynamic> contacts = [];

  @override
  void initState() {
    super.initState();

    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem(
                child: Text("Ordernar de A-Z"),
                value: OrderOptions.orderaz,
              ),
              const PopupMenuItem(
                child: Text("Ordernar de Z-A"),
                value: OrderOptions.orderza,
              ),
            ],
            onSelected: _orderList,
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _showContactPage();
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: contacts.length,
        itemBuilder: (context, index){
          return _contactCard(context, index);
        }
      ),
    );
  }

  Widget _contactCard(BuildContext context, int index){
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                    image: DecorationImage(
                        image: contacts[index].img != "" ?
                        FileImage(File(contacts[index].img)) :
                        const AssetImage('images/person.png') as ImageProvider,
                        fit: BoxFit.cover
                    )
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contacts[index].name ?? "",
                        style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      Text(
                        contacts[index].email ?? "",
                        style: const TextStyle(
                            fontSize: 16.0
                        ),
                      ),
                      Text(
                        contacts[index].phone ?? "",
                        style: const TextStyle(
                            fontSize: 16.0
                        ),
                      )
                    ],
                  ),
                )
              )
            ],
          ),
        ),  
      ),
      onTap: (){
        _ShowOptions(context, index);
      },
    );
  }

  void _ShowOptions(BuildContext context, int index){
    showModalBottomSheet(
      context: context,
      builder: (context){
        return BottomSheet(
          onClosing: (){},
          builder: (context){
            return Container(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: (){
                      launch("tel:${contacts[index].phone}");
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Ligar",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20.0
                      ),
                    )
                  ),
                  TextButton(
                      onPressed: (){
                        Navigator.pop(context);
                        _showContactPage(contact: contacts[index]);
                      },
                      child: const Text(
                        "Editar",
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 20.0
                        ),
                      )
                  ),
                  TextButton(
                      onPressed: (){
                        helper.deleteContact(contacts[index].id);
                        setState(() {
                          contacts.removeAt(index);
                          Navigator.pop(context);
                        });
                      },
                      child: const Text(
                        "Excluir",
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 20.0
                        ),
                      )
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  }

  void _showContactPage({Contact? contact}) async{
    final recContact = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactPage(contact: contact)
    ));
    if(recContact != null){
      if(contact != null){
        await helper.updateContact(recContact);
      } else {
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  void _getAllContacts(){
    helper.getAllContacts().then((list){
      setState(() {
        contacts = list;
      });
    });
  }

  void _orderList(OrderOptions result){
    switch(result){
      case OrderOptions.orderaz:
        setState(() {
          contacts.sort((a, b){
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });
        });
        break;
      case OrderOptions.orderza:
        setState(() {
          contacts.sort((a, b){
            return b.name.toLowerCase().compareTo(a.name.toLowerCase());
          });
        });
        break;
    }
  }
}
