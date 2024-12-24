public class TicketNotificationForAccount {
    Public Static void getNotification(List<Ticket__c> ticketList, Map<Id,Ticket__c> oldMap){
        Set<Id> accid = new Set<Id>();
        Map<Id,Ticket__c> ticektMap = New Map<Id,Ticket__c>();
        System.debug('Class to Call');
        for(Ticket__c tk :ticketList){
            if(tk.Account__c != null){
                system.debug('Account is there');
                // Check the Record is Created or Update 
                if(oldMap == null || oldMap.get(tk.Id).Account__c != tk.Account__c){
                    System.debug('Work fine');
                    accid.add(tk.Account__c);
                    ticektMap.put(tk.Account__c, tk);
                }
                
            } 
        }
        if(!accid.isEmpty()){
            List<Account> acclist = [Select Id,Name,OwnerId,Owner.Name,Owner.Email, Owner.MobilePhone
                                     From Account Where Id IN : accid AND (RecordType.DeveloperName = 'POS_Wealth_Management' OR RecordType.DeveloperName = 'FW_Investor')];
            System.debug('Account Dev Name '+acclist);
            if(!acclist.isEmpty()){
                List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
                for(Account acc : acclist){
                    if(ticektMap.ContainsKey(acc.id)){
                        Ticket__c tk = ticektMap.get(acc.Id);
                        // Create email notification
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setToAddresses(new String[] { acc.Owner.Email }); // Add email address
                        email.setSubject('New Ticket Assigned to Your Account : ' + acc.Name);
                        String Body = (
                            'Hello '+acc.Owner.Name+',\n\n' +
                            'We hope this message finds you well.\n'+
                            'This is to inform you that a ticket has been assigned to your account. Below are the details of the ticket:\n\n' +
                            'Priority: ' + (tk.Priority__c != null ? tk.Priority__c : 'N/A') + '\n' +
                            'Ticket Requirement: ' + (tk.text__c != null ? tk.text__c : 'N/A') + '\n' +
                            'Remarks by Sales: ' + (tk.Remarks_By_Sales__c != null ? tk.Remarks_By_Sales__c : 'N/A') + '\n\n' +
                            'We kindly request you to review the ticket at your earliest convenience. If you have any questions or require further assistance, please do not hesitate to contact us.\n\n' +
                            'Thank you for your attention to this matter.\n\n' +
                            'Best Regards,\n' +
                            'Finhaat Technologies Pvt Ltd'
                        );
                        email.setPlainTextBody(Body);
                        emailMessages.add(email);
                        if(acc.Owner.MobilePhone != null){
                            String mobilenumber = '91'+acc.Owner.MobilePhone;
                              sendTextMessageIntegration(mobilenumber,Body);
                            
                        }
                    }
                }
                // Send all email messages
                if (!emailMessages.isEmpty()) {
                    Messaging.sendEmail(emailMessages);
                }
            }
        }
        
    }
    @future(callout = true)
    public static void sendTextMessageIntegration(String mobileNumberWithCountryCode, String WhatsAppMessage){
        try{
            String whatsEra_Api_Key = system.label.Whatsera_Send_Sms;
            map<String, Object> JSONBody = new map<String, Object>{ 'accessToken' => whatsEra_Api_Key, 'mobile' => mobileNumberWithCountryCode, 'text' => WhatsAppMessage };
                HttpRequest request = new HttpRequest();
            request.setEndpoint('https://app.whatsera.com/api/send/text');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'Application/Json');
            request.setBody(JSON.serialize(JSONBody));
            request.setTimeout(120000);
            Http http = new Http();
            HttpResponse response = http.send(request);
            system.debug('Response >> '+response.getBody());
        } catch ( Exception e ){
            system.debug('get line '+e.getLinenumber()+' get sms '+e.getmessage());
            throw new AuraHandledException(e.getMessage());
        }
    }  
    
    
}