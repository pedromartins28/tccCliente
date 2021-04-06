import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  _launchURL() async {
    const url = 'https://saudeemcasadiv.web.app/download/policy1.html';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SOBRE"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          margin: EdgeInsets.all(12.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(6.0),
                    topRight: Radius.circular(6.0),
                  ),
                  child: Image.asset(
                    'assets/about.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 8.0),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "DESENVOLVEDORES",
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Center(
                            child: Column(
                          children: <Widget>[
                            Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: 6.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    margin:
                                        EdgeInsets.only(right: 10, left: 18),
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image:
                                              AssetImage('assets/gabriel.jpg'),
                                          fit: BoxFit.fill),
                                    ),
                                  ),
                                  Text(
                                    "Gabriel Penido de Oliveira",
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w300,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: 6.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    margin:
                                        EdgeInsets.only(right: 10, left: 18),
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image:
                                              AssetImage('assets/pedro.jpeg'),
                                          fit: BoxFit.fill),
                                    ),
                                  ),
                                  Text(
                                    "Pedro Igor Ferreira Martins",
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w300,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: 6.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    margin:
                                        EdgeInsets.only(right: 10, left: 18),
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image:
                                              AssetImage('assets/ronan.jpeg'),
                                          fit: BoxFit.fill),
                                    ),
                                  ),
                                  Text(
                                    "Ronan Ferreira de Resende",
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w300,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )),
                        SizedBox(height: 18),
                        Text(
                          "EQUIPE DO PROJETO",
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        SizedBox(height: 6.0),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6.0),
                          child: Text(
                            "Alisson Marques da Silva – Coordenador\nLetícia Helena Januário – Coordenador Adjunto\n  Inês Alcione Guimarães - Colaborador\nMichel Pires da Silva - Colaborador\nThiago Magela Rodrigues Dias – Colaborador",
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w300,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18),
                    Column(
                      children: <Widget>[
                        Text(
                          "SOBRE",
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        SizedBox(height: 6.0),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18.0),
                          child: Text(
                            "Projeto desenvolvido com apoio da Diretoria de Extensão e Desenvolvimento Comunitário (DEDC) do CEFET-MG (Edital 32/2020 - Seleção pública para apoio a projetos de extensão emergenciais) – Projeto PJ099-2020.",
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w300,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.0),
                    GestureDetector(
                      child: Text(
                        "Política de Privacidade",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      onTap: () {
                        _launchURL();
                      },
                    ),
                    SizedBox(height: 12.0),
                  ],
                ),
              ],
            ),
          ),
          elevation: 2.0,
        ),
      ),
    );
  }
}
