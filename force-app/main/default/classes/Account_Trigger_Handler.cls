/*
 *	Created By   : Vishal Singh  
 *  Created date : 05-10-2024
 * 	Description  : when account stage is change for the record type FW Partner then a what's app message will to acccount what's app number 
 * 
 * Last Modified By: Shubham Gour
 * Last Modified Date: 08/10/2024
 * Description: The wp notification should be different for KYC and agreement and For Payment, soo added new templates for them.
 * 
 * Last Modified By: Shubham Gour
 * Last Modified Date: 17/10/2024
 * Description: The wp notification should not be send for KYC and Agreement Stage, It should only get sent for Payment Stage.
 */ 

public class Account_Trigger_Handler {
	
    //The method is create by vishal singh 
    // This method sends WhatsApp messages to the relevant accounts
    @future(callout=true)
    public static void sendWhatsMessageWhenAccountStagechange(string accString) {
        
        try{
            system.debug('accString -- >'+accString);
            list<Account> accList = (list<Account>)JSON.deserialize(accString, list<Account>.class);
            system.debug('accList -->'+accList);
            RecordType recordtypeId = [SELECT Id, Name, DeveloperName FROM RecordType Where Name = 'FW Partner' limit 1];
            system.debug('recordtypeId -->'+recordtypeId.Id);
            
            RecordType recordtypeId2 = [SELECT Id, Name, DeveloperName FROM RecordType Where Name = 'FW Investor' limit 1];
            system.debug('recordtypeId -->'+recordtypeId2.Id);
            
            
            User u = [SELECT FirstName,LastName FROM User WHERE Id = : accList[0].OwnerId];
            String userFname  = u.FirstName != null ? u.FirstName : '';
            for(Account a : accList){
                system.debug('recordtypeId -->'+a.RecordTypeId);
                if(a.WhatsApp_No__c != null && (a.RecordTypeId != recordtypeId.Id && a.RecordTypeId != recordtypeId2.Id)){
                    String fallbackName = String.isNotBlank(a.Name) ? a.Name : '';
                     String fName = a.FirstName != null ? a.FirstName : '';
                     String messageBody = 'Hello ' + (String.isNotBlank(fName) ? fName : fallbackName) + ' ' +
                                        (String.isNotBlank(a.LastName) ? a.LastName : '') + ',\n\n'+

                                     'We wanted to inform you that your lead stage has been updated to: *' + a.Stage__c + '*.\n\n' +
                         			 'Please let us know if have any query regarding to your lead.\n\n'+
                                     'Thanks and regards,\n' +
                                      userFname + ' '+ u.LastName;
                    string moblieNumber = '91'+a.WhatsApp_No__c;
                    
                    //modification by shubham start
  					if(a.Stage__c == 'Payment'){
                        string messageBody1 = 'Hello ' + fName + ' ' + a.LastName + ',\n\n' +
                                     'Congratulations! We are excited to inform you that you have been successfully onboarded.\n\n' +
                                     'If you have any questions or need further assistance, please don’t hesitate to reach out to us.\n\n' +
                                     'Looking forward to a successful journey together!\n\n' +
                                     'Thanks and regards,\n' +
                                     userFname + ' ' + u.LastName;
                        messageBody = messageBody1;
                    }  
                    //modification by shubham end
                    map<string,Object> JSONBody = new map<String,Object>{'accessToken' => system.label.Whatsera_Send_Sms, 'mobile' =>moblieNumber, 'text' =>messageBody};
                    string responseBody = JSON.serialize(JSONBody); 
                    
                    HttpRequest request = new HttpRequest();
                    request.setEndpoint(System.label.Whatsera_Send_Sms_EndPoint+ '/api/send/text');
                    request.setMethod('POST');
                    request.setHeader('Content-Type', 'Application/json');
                    request.setBody(responseBody);
                    request.setTimeout(120000);
                    Http http = new Http();
                    If(a.Stage__c != 'KYC' && a.Stage__c != 'Agreement'){  //This Condition Added By Shubham Gour
                        HttpResponse response = http.send(request);
                        system.debug('response-->'+response);
                    }
                }
            }
        }catch(exception e){
            system.debug('Error message -->'+e.getMessage());
            system.debug('Error Line No -->'+e.getLineNumber());
        }
    }
}