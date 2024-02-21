import 'package:flutter/material.dart';

// ignore: camel_case_types
class Preview_Photo_Desktop extends StatefulWidget {
  const Preview_Photo_Desktop({super.key});

  @override
  State<Preview_Photo_Desktop> createState() => _Preview_Photo_DesktopState();
}

// ignore: camel_case_types
class _Preview_Photo_DesktopState extends State<Preview_Photo_Desktop> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Card(
                elevation: 0,
                child: SizedBox(
                  width: 600,
                  height: 450,
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 370,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                              fit: BoxFit.fill,
                              image: NetworkImage(
                                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTlBLORxmuwMNWRDP-AHNGnLl9fO-vaHpr1iA&usqp=CAU"),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Photo',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 14)),
                              SizedBox(
                                height: 2,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Date : 08-Oct-2023',
                                      style: TextStyle(
                                          color: Color(0xff7D7878),
                                          fontSize: 14)),
                                  Icon(
                                    Icons.download,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(240, 50),
                          backgroundColor: Colors.white),
                      onPressed: () {},
                      child: const Text(
                        "SEND TO EMAIL",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(240, 50)),
                      onPressed: () {},
                      child: const Text(
                        "SEND TO EMAIL",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView(children: [
              GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 3 / 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: 12,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: (){},
                    child: Card(
                      elevation: 0,
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            child: SizedBox(
                              width: 190,
                              height: 120,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  image: const DecorationImage(
                                    fit: BoxFit.fill,
                                    image: NetworkImage(
                                        "https://cdn.futura-sciences.com/cdn-cgi/image/width=200,quality=60,format=auto/sources/images/androgyne%20f%C3%A9minin%20utilise%20chatgpt.jpeg"),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Align(
                            child: SizedBox(
                              width: 180,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 2),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Photo',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontSize: 14)),
                                    SizedBox(
                                      height: 2,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Date : 08-Oct-2023',
                                            style: TextStyle(
                                                color: Color(0xff7D7878),
                                                fontSize: 14)),
                                        Icon(
                                          Icons.download,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  );
                },
                shrinkWrap: true,
                physics: const ScrollPhysics(),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
