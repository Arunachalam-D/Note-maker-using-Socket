import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: new ThemeData(scaffoldBackgroundColor: Colors.black),
      title: "Web Socket",
      debugShowCheckedModeBanner: false,
      home: WebSocket(
      ),
    );
  }
}

class WebSocket extends StatefulWidget {
  const WebSocket({super.key});

  @override
  State<WebSocket> createState() => _WebSocketState();
}

class _WebSocketState extends State<WebSocket> {

  final TextEditingController _controller = TextEditingController();
  final _channel = WebSocketChannel.connect(
      Uri.parse('wss://echo.websocket.events'));


  final url = "https://6528ece2931d71583df29722.mockapi.io/selftalk";
  List<String> items = [];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Web Messenger"),
        backgroundColor: Colors.teal,
      ),
      body:
         Column(

          children: [
            Expanded(
              child: StreamBuilder(
                stream: _channel.stream,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData) {
                    return Center(child: Text('No Data'));
                  }
                  String message = snapshot.data.toString();

                  // Check if the message is equal to the initial message and ignore it
                  if (message == "echo.websocket.events sponsored by Lob.com") {
                    return SizedBox.shrink(); // This will render nothing
                  }

                  //items.add(message);
                  items.add(snapshot.data.toString());

                  return ListView.builder(
                    reverse: true, // Start from the bottom
                    itemCount: items.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ItemWidget(item: items.reversed.toList()[index]);
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),

              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: TextStyle(color: Colors.white),
                    controller: _controller,
                    decoration: InputDecoration(

                        border: OutlineInputBorder( //<-- SEE HERE
                          borderRadius: BorderRadius.circular(50.0),),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Colors.teal, width: 2.0),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Colors.teal, width: 2.0),
                          borderRadius: BorderRadius.circular(25.0),
                        ),


                        labelText: "Send a message",
                        labelStyle: TextStyle(
                            color: Colors.teal,
                            fontSize: 14
                        )
                    ),
                  ),),
                  IconButton(
                    onPressed: _sendData,color: Colors.teal, icon: Icon(Icons.send), iconSize: 30,),
                ],
              ),
            ),
          ],
        ),

    );
  }
  @override
  void initState(){
    super.initState();
    items.clear();
    print(items);

  }
  @override
  void dispose() {
    _channel.sink.close();
    _controller.dispose();
    super.dispose();
  }
  void _sendData() {
    if (_controller.text.isNotEmpty) {
      _channel.sink.add(_controller.text);
      _controller.clear();
    }
  }
}

class ItemWidget extends StatelessWidget {
  final String item;

  ItemWidget({required this.item});

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0,horizontal: 2.0),
      child: Align(
        alignment: Alignment.topRight,
        child: Container(

          decoration: BoxDecoration(
            color: Colors.teal,
            borderRadius: BorderRadius.circular(20),

          ),
          child: Padding(
             padding: EdgeInsets.fromLTRB(10,10,10,10),


            child: Text(
              item,
              style: TextStyle(fontSize: 14,color: Colors.white),
            ),

          ),

        ),
      ),
    );

  }
}