import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ut_messenger/helper/api.dart';
import 'package:ut_messenger/helper/app_contants.dart';
import 'package:ut_messenger/helper/colors.dart';
import 'package:ut_messenger/home/bottom_navbar.dart';
import 'package:ut_messenger/model/contact_model.dart';
import 'package:ut_messenger/widgets/networkimage.dart';
import 'package:http/http.dart'as http;

import '../helper/global.dart';

class AddGroupScreen extends StatefulWidget {
  const AddGroupScreen({super.key,this.groupMembers, this.fromBroadCast});

  final List<MyContactModel>? groupMembers;

  final bool? fromBroadCast ;


  @override
  State<AddGroupScreen> createState() => _AddGroupScreenState();
}

File? image ;
class _AddGroupScreenState extends State<AddGroupScreen> {

  final nameC= TextEditingController();
  final descriptionC= TextEditingController();

  SharedPreferences? pref;
  String? token ;
  bool isLoading = false ;

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(title:  Text( widget.fromBroadCast ?? false ? 'New Broadcast' : 'New Group'),),
      floatingActionButton: FloatingActionButton(
        backgroundColor: MyColor.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        onPressed: () {

          if(nameC.text.isEmpty){
            Fluttertoast.showToast(msg: widget.fromBroadCast ?? false ? 'please add group name' : 'please add group Broadcast');
          }else if(!(isLoading)){
            createGroup() ;
          }else {

          }


        },
      child: isLoading ? const Center(child: CircularProgressIndicator(strokeWidth: 3,color: MyColor.white,),) : const Icon(Icons.check
      ),),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          const SizedBox(height: 20),

          Row(
            children: [
              // Group Icon
              widget.fromBroadCast ?? false ? const SizedBox() :  GestureDetector(
                onTap: () async{

                  image =   await getLostData(ImageSource.gallery);
                  setState(() {

                  });
                  // Add functionality to change group icon
                },
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[300],
                  child: ClipOval(

                    clipBehavior: Clip.hardEdge,
                    child: image == null ? Icon(
                      Icons.camera_alt,
                      color: Colors.grey[700],
                    ) : Image.file(image!, fit: BoxFit.fill,height: 60,width: 60,),
                  ),
                ),
              ),
              widget.fromBroadCast ?? false ? const SizedBox() : const SizedBox(width: 16),
              // Group Name Input
               Expanded(
                child: TextField(
                  controller: nameC,
                  decoration:  InputDecoration(
                    hintText: widget.fromBroadCast ?? false ? 'Broadcast name' :'Group name',
                    border: const UnderlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
            TextField(
              minLines: 3, // Set this
              maxLines: 6, // and this
              controller: descriptionC,
              keyboardType: TextInputType.multiline,
                cursorColor: MyColor.black,
                decoration: InputDecoration(
                  hintText: 'Write a ${widget.fromBroadCast ?? false ? 'broadcast':'group'} description(Optional)',
                  filled: true,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: MyColor.primary.withOpacity(0.2),
                ),

            ),
          const SizedBox(height: 16),

          // Selected Members Section
          Text(
            'Participants: ${widget.groupMembers?.length}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: widget.groupMembers?.length ?? 0,
              itemBuilder: (context, index) {

                var data = widget.groupMembers![index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[300],
                    child: ClipOval(child: AppImage(image: data.image ?? '', width: 40, height: 40, personImage: true,),),
                  ),
                  title: Text(data.name == '' ? 'Unknown' : data.name!),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () {
                      widget.groupMembers?.removeAt(index);
                      setState(() {

                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],),
      ),
    );
  }




  init() async{
   pref = await SharedPreferences.getInstance();

   token = pref?.getString(AppConstants.token);
}

 Future<void> createGroup() async{

   isLoading = true ;
   setState(() {
     isLoading = true ;
   });

   var headers = {
     'Authorization': 'Bearer $token'
   };
   var request = http.MultipartRequest('POST', Uri.parse(AppUrl.createChatGroup));
   request.fields.addAll({
     'group_type': widget.fromBroadCast ?? false ? 'broadcast' :'group',
     'group_name': nameC.text,
     'group_description': descriptionC.text,
     'user_id': widget.groupMembers!.map((e) => e.id.toString(),).toList().join(',')
   });

   if(image !=null) {
     request.files.add(await http.MultipartFile.fromPath('image',image!.path));
   }   
   
   request.headers.addAll(headers);

   http.StreamedResponse response = await request.send();



   if (response.statusCode == 200) {
     var result = await response.stream.bytesToString();
     
     var finalResult = jsonDecode(result);
     
     Fluttertoast.showToast(msg: '${finalResult['message']}');

     if(mounted) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const BottomNavBarMain()));
      }
    }

   else {
     print(response.reasonPhrase);
   }
   setState(() {
     isLoading = false ;
   });
 }
}
