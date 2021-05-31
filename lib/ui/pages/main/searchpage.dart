part of '../pages.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {

  String uid = FirebaseAuth.instance.currentUser.uid;
  CollectionReference ideaCollection = FirebaseFirestore.instance.collection("ideas");
  bool isLoading = true;

  // bool show = false;
  // getDataIdea(Ideas ideas) {
  //   try {
  //     ideaCollection.doc(ideas.ideaBy).collection('participants').doc(uid).get();
  //     show =false;
  //   } catch (e) {
  //     show = true;
  //   }
  //
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 50,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    offset: Offset(0, 10),
                    blurRadius: 50,
                    color: cTextColor.withOpacity(0.23)
                )
              ]
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search Ideas.',
            ),
          ),
        ),
        backgroundColor: cPrimaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white,),
            onPressed: () {},
          )
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      height: SizeConfig.screenHeight * 0.1 -5,
                      color: cPrimaryColor,
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30)
                            )
                        ),
                      ),
                    )
                  ],
                ),
                Expanded(
                  child: ListView(
                    children: [
                      SingleChildScrollView(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: ideaCollection.where('ideaBy', isNotEqualTo: uid).snapshots(),
                          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                            if (snapshot.hasError) {
                              return Text("Failed to load post");
                            }

                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return ActivityServices.loadings();
                            }

                            return new Column(
                              children: snapshot.data.docs.map((DocumentSnapshot doc) {
                                Ideas ideas;
                                ideas = new Ideas(
                                  doc.data()['ideaId'],
                                  doc.data()['ideaTitle'],
                                  doc.data()['ideaDesc'],
                                  doc.data()['ideaCategory'],
                                  doc.data()['ideaImage'],
                                  doc.data()['ideaMaxParticipants'],
                                  doc.data()['ideaParticipant'],
                                  doc.data()['ideaBy'],
                                  doc.data()['createdAt'],
                                  doc.data()['updatedAt'],
                                );
                                // return IdeaPostCardView(
                                //   ideas: ideas,
                                // );
                                // getDataIdea(ideas);
                                int con = 0;
                                return StreamBuilder<QuerySnapshot>(
                                  stream: ideaCollection.doc(ideas.ideaId).collection('participants').snapshots(),
                                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                                    if (snapshot.hasError) {
                                      return Text("Failed to load post");
                                    }
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return ActivityServices.loadings();
                                    }

                                    return Column(
                                      children: snapshot.data.docs.map((DocumentSnapshot doc) {
                                        if (doc.data()['uid'] != uid && con == 0) {
                                          con = 1;
                                          return IdeaPostCardView(
                                            ideas: ideas,
                                            routename: DetailPost.routeName,
                                            argument: DetailArgument(ideas),
                                          );
                                        }
                                        con = 1;
                                        return Container();
                                      }).toList(),
                                    );
                                  },
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}