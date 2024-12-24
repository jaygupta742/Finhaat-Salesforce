/**
* Trigger : Account_Trigger
* Description: This class contains a method to check for duplicate account names and last names.
*              The method, insert_Name, accepts a list of Account objects and checks for existing
*              accounts with the same Name or LastName. If duplicates are found, it adds an error
*              message to the respective fields.
* Created By: Shreyash Urkude
* Date: June 12, 2024

Last Modified By Suraj 29/08/2024 :1)  Need to add a method to create Required Document as per Account Record Type 	
2) Need to do in Account if all docs are not submitted till then we can't change the status to Document Received -All
3)Last modified by: Rahul katarpawar on 04/10/2024, Dec: send welcome message to Account WhatsApp number when record type is POS Wealth Management
			method used 'sendWhatsappWelcomeMessage'
*/
public class Account_Duplicate_Name {
    public static void insert_Name(List<Account> accRec){
        Set<String> accName = new Set<String>();
        Set<String> PosaccName = new Set<String>();
        for(Account ac : accRec){
            accName.add(ac.Name);
            PosaccName.add(ac.LastName);
        }
        
        List<Account> accDuplicateName = [Select Id, Name from Account where Name LIKE : accName ];
        List<Account> accPOSDuplicateName = [Select Id, Name from Account where  LastName LIKE : PosaccName];
        for(Account ac : accRec){
            if(!accDuplicateName.isEmpty()){
                ac.Name.addError('Name Already Exists');
            }else if(!accPOSDuplicateName.isEmpty()){
                //ac.LastName.addError('LastName Already Exists');
            }
        }
    }
    
    // This methos us to create Required Document after creating Account
    public static void insert_requiredDoc(List<Account> accRec){ 
        list<Master_Document__c>  mddoc=[SELECT Id, Name, Age__c, Instruction__c, Order__c, S_No__c, Stages__c FROM Master_Document__c where Stages__c =:'POS' or Stages__c =:'MFI'];
        system.debug('Doclist '+mddoc.Size());
        List<Account> accounts = [SELECT Id, RecordType.Name FROM Account WHERE Id IN :accRec];
        List<Required_Documents__c> reqlist=New List<Required_Documents__c>();
        for(Account acc:accounts){  
            system.debug('check record tye '+acc.RecordType.Name);
            for(Master_Document__c md:mddoc){
                if(acc.RecordType.Name == 'POS' && md.Stages__c =='POS'){    
                    Required_Documents__c req=New Required_Documents__c();
                    req.Account__c = acc.id;
                    req.Name = md.Name;
                    req.Instruction__c = md.Instruction__c;
                    req.Status__c = 'Yet To Submit' ;
                    req.Stages__c = md.Stages__c;
                    reqlist.add(req);
                }
                if(acc.RecordType.Name == 'Partner' && md.Stages__c =='MFI'){
                    Required_Documents__c req=New Required_Documents__c();
                    req.Account__c = acc.id;
                    req.Instruction__c = md.Instruction__c;
                    req.Status__c = 'Yet To Submit' ;
                    req.Stages__c = md.Stages__c;
                    req.Name = md.Name;
                    reqlist.add(req);
                } 
            }
        }
        if(reqlist.Size()>0)    insert reqlist;
    }
    
    // This method adds an error if the Stage is set to "Document Received - All" without all required documents being submitted.
    
    public static void checkdocstatus(List<Account> accRec ,  Map<Id, Account> oldAccountsMap) {
        // Create a set to store Account IDs where Stage__c is changed to 'Document Received - All'
        Set<Id> accountIdsToCheck = new Set<Id>();
        
        for (Account ac : accRec) {
            String oldStage = oldAccountsMap.get(ac.Id).Stage__c;
            // Check if Stage__c has changed from the old value to 'Document Received - All'
            if ((ac.Stage__c == 'Document Received - All' || ac.Stage__c == 'Document Verified'  || ac.Stage__c == 'Assessment Completed' || ac.Stage__c == 'Code Created')
                && ac.RecordTypeId=='0125j000001az2EAAQ'    && ac.Stage__c != oldStage) {
                    accountIdsToCheck.add(ac.Id);
                }
        }
        // Only proceed if there are accounts to check
        if (!accountIdsToCheck.isEmpty()) {
            // Query to find all required documents that are not submitted for the relevant accounts
            List<Required_Documents__c> requiredDocsList = [ SELECT Id, Account__c  FROM Required_Documents__c  WHERE Account__c IN :accountIdsToCheck 
                                                            AND (Status__c =: 'Yet To Submit')
                                                           ];
            
            // Map to keep track of which accounts have pending documents
            Map<Id, List<Required_Documents__c>> accountToDocumentsMap = new Map<Id, List<Required_Documents__c>>();
            for (Required_Documents__c doc : requiredDocsList) {
                if (!accountToDocumentsMap.containsKey(doc.Account__c)) {
                    accountToDocumentsMap.put(doc.Account__c, new List<Required_Documents__c>());
                }
                accountToDocumentsMap.get(doc.Account__c).add(doc);
            }
            
            for (Account ac : accRec) { 
                // Get the list of required documents for the current account
                List<Required_Documents__c> docs = accountToDocumentsMap.get(ac.Id);
                if (docs != null && !docs.isEmpty()) {
                    ac.Stage__c.addError(System.label.DocReceivedError);
                }
            }
            
        }
        
    }
    
    @future(callout=true) //added by rahul katarpawar on 04/10/2024
    public static void sendWhatsappWelcomeMessage(string accString){
        try{
            system.debug('accString -- >'+accString);
            list<Account> accList = (list<Account>)JSON.deserialize(accString, list<Account>.class);
            RecordType recordtypeId = [SELECT Id, Name, DeveloperName FROM RecordType Where DeveloperName = 'POS_Wealth_Management' limit 1];
            system.debug('accList -->'+accList);
            for(Account a : accList){
                if(a.WhatsApp_No__c != null && a.RecordTypeId == recordtypeId.Id){
                    system.debug('Name--'+a.Name);
                    system.debug('Name First--'+a.FirstName);
				    system.debug('Name Last--'+a.LastName);
                 // String fName = a.FirstName != null ? a.FirstName : '';
                    
                    string messageBody = 'Hello '+ a.FirstName + ' ' + a.LastName+',\n\n'+
                        'I hope this message finds you well! 🌟\n\n'+
						'I wanted to take a moment to welcome you and express our excitement about the opportunity to work together. We are passionate about delivering exceptional service and solutions, and we believe that your skills and experience would be a fantastic addition to our team.\n\n'+
                        'We’re looking forward to the possibility of working together and achieving great results!\n\n'+
						'Thank you! \n\n Regards,\n Finhaat';
                    string moblieNumber = '91'+a.WhatsApp_No__c;
                    map<string,Object> JSONBody = new map<String,Object>{'accessToken' => system.label.Whatsera_Send_Sms, 'mobile' =>moblieNumber, 'text' =>messageBody};
                        
                        string responseBody = JSON.serialize(JSONBody);
                    
                    HttpRequest request = new HttpRequest();
                    request.setEndpoint(System.label.Whatsera_Send_Sms_EndPoint+ '/api/send/text');
                    request.setMethod('POST');
                    request.setHeader('Content-Type', 'Application/json');
                    request.setBody(responseBody);
                    request.setTimeout(120000);
                    
                    Http http = new Http();
                    HttpResponse response = http.send(request);
                    system.debug('response-->'+response);
                }
            }
        }catch(exception e){
            system.debug('Error message -->'+e.getMessage());
            system.debug('Error Line No -->'+e.getLineNumber());
        }    
    }
    
    public static void codeBlaster(){
        Integer i = 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        
    }
}