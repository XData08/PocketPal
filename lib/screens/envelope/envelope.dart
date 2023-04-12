import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_pal/const/color_palette.dart';
import 'package:pocket_pal/screens/envelope/widgets/money_flow_card.dart';
import 'package:pocket_pal/screens/envelope/widgets/new_transaction_dialog.dart';
import 'package:pocket_pal/screens/envelope/widgets/total_balance_card.dart';
import 'package:pocket_pal/screens/envelope/widgets/transaction_card.dart';
import 'package:intl/intl.dart';
import 'package:pocket_pal/services/authentication_service.dart';
import 'package:pocket_pal/services/database_service.dart';
import 'package:pocket_pal/utils/envelope_structure_util.dart';
import 'package:pocket_pal/utils/folder_structure_util.dart';
import 'package:pocket_pal/utils/transaction_structure_util.dart';


class EnvelopeContentPage extends StatefulWidget {
  final Envelope envelope;
  final Folder folder;

  const EnvelopeContentPage({
    required this.envelope,
    required this.folder,
    super.key});

  @override
  State<EnvelopeContentPage> createState() => _EnvelopeContentPageState();
}

class _EnvelopeContentPageState extends State<EnvelopeContentPage> {

  bool isIncome = false;
  double expenseTotal = 0;
  double incomeTotal = 0;
  double totalBalance = 0;

  final auth = PocketPalAuthentication();
  //profileName: auth.getUserDisplayName,

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final DateFormat formatter = DateFormat('MMM dd');
  
  late final TextEditingController transactionType;
  late final TextEditingController transactionAmount;
  late final TextEditingController transactionName;

  List<dynamic> transactions = [];

  @override
  void initState(){
    super.initState();
    //fetchTransactions();
    //getEnvelopeData("folderName", "envelopeName");
    //getEnvelopeData();
    transactionType = TextEditingController(text : "Expense");
    transactionAmount = TextEditingController(text : "");
    transactionName = TextEditingController(text : "");
    return; 
  }

  @override
  void dispose(){
    super.dispose();
    transactionType.dispose();
    transactionAmount.dispose();
    transactionName.dispose();
    return; 
  } 

  void addTransaction (String envelopeId) {
    final data = Transaction(
      transactionUsername: auth.getUserDisplayName,
      transactionType: transactionType.text.trim(), 
      transactionName: transactionName.text.trim(), 
      transactionAmount: double.parse(transactionAmount.text.trim()),
      ).toMap();

      PocketPalDatabase().createEnvelopeTransaction(
        widget.folder.folderId,
        widget.envelope.envelopeId,
        data
      ); 

      Navigator.of(context).pop();
      clearController();
  }

  void newTransaction(){
    showDialog(
      barrierDismissible: false,
      context: context, 
      builder: (BuildContext context){
        return MyNewTransactionDialogWidget(
          formKey: formKey,
          isIncome: false,
          fieldName: widget.envelope.envelopeId,
          transactionAmountController: transactionAmount,
          transactionNameController: transactionName,
          transactionTypeController: transactionType,
          addTransactionFunction: addTransaction,
        );
      });
  }

  void clearController(){
    transactionType.clear();
    transactionAmount.clear();
    transactionName.clear();
    return;
  }

  

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
      backgroundColor: ColorPalette.rustic,
      foregroundColor: ColorPalette.white,
      elevation: 12,
      onPressed: newTransaction,
      child: Icon(FeatherIcons.plus),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              "assets/images/envelope_bg.png",
            ),
            fit: BoxFit.cover,
          )
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h),
                  child: Container(
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: (){
                            Navigator.of(context).pop();
                          },
                          child: Icon(FeatherIcons.arrowLeft,
                            size: 28,
                            color: ColorPalette.white,),
                        ),
                        SizedBox( width: 10.h,),
                        Text(
                          "Envelope Name",
                          style: GoogleFonts.poppins(
                            fontSize : 18.sp,
                            color: ColorPalette.white,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w ),
                  child: TotalBalanceCard(
                    width: screenWidth, 
                    balance: totalBalance.toStringAsFixed(2),),
                ),
                SizedBox( height: 12.h,),
                // Padding(
                //   padding: EdgeInsets.symmetric(
                //     horizontal: 14.w),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       MoneyFlowCard(
                //         name: "Income",
                //         width: (screenWidth / 2) - 20,
                //         amount: incomeTotal.toStringAsFixed(2), 
                //         iconColor: Colors.green.shade700,
                //         icon: FeatherIcons.arrowDown,
                //        ),
                //       MoneyFlowCard(
                //         name: "Expense",
                //         width: (screenWidth / 2) - 20,
                //         amount: expenseTotal.toStringAsFixed(2), 
                //         iconColor: Colors.red.shade700,
                //         icon: FeatherIcons.arrowUp,
                //         ),
                //     ],
                //   ),
                // ),
                SizedBox( height: 15.h,),
                Expanded(
                  child: Container(
                    width: screenWidth,
                    decoration: const BoxDecoration(
                       color: Colors.white,
                       borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25)
                       )
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 20.h,
                        left: 14,
                        right: 14
                        ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children:[
                              Text(
                                "Recent Transactions",
                                style: GoogleFonts.poppins(
                                  fontSize: 16.h,
                                  fontWeight: FontWeight.w600
                                )
                              ),
                              Text(
                                "See All",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: ColorPalette.grey
                                )
                              ),
                            ]
                          ),
                          SizedBox( height: screenHeight * 0.02,),
                          Expanded(
                            child: ListView.builder(
                              itemCount: 0,
                              itemBuilder: (context, index){
                                return  
                                  TransactionCard(
                                    width: screenWidth,
                                    dateCreated: "null",
                                    transactionAmount: null.toString(),
                                    transactionName: "null",
                                    transactionType: "null",
                                    username: "null",
                                    );
                                  
                              }),
                          ),
                          
                        ],
                      ),
            
                    )
                     
                  )
                  ),
              ],
            ),
              
          ),
        ),
        
      )
    );
  }
}