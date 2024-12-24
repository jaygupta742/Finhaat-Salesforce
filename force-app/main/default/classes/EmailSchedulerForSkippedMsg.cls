public class EmailSchedulerForSkippedMsg Implements Schedulable{
    list<Whatsapp_Text__c> whatsAppTextList = new list<Whatsapp_Text__c>();
    public void execute(SchedulableContext sc){
        Datetime oneHourAgo = Datetime.now().addMinutes(-330);
        System.debug('Current Time: ' + oneHourAgo);
        oneHourAgo = oneHourAgo.addHours(-1) ;
        System.debug('One Hour Ago: ' + oneHourAgo);
        whatsAppTextList = [SELECT Id, Text__c,Name, Skipped_Record_Due_to_Error__c, Account__c,Account__r.Name , Skipped_Error__c,Skipped_Email_Sent_Date_Time__c, Delivery_Status__c, Skipped_Date_Time__c 
                            FROM Whatsapp_Text__c 
                            WHERE Msg_Sent__c = false 
                            AND Message_Type__c = 'Outbound'
                            AND Skipped_Date_Time__c >=: oneHourAgo 
                            ORDER BY Skipped_Date_Time__c ASC];
        
        IF(whatsAppTextList.Size()>0){
            System.abortJob(sc.getTriggerId()); 
            sendEmail(whatsAppTextList);
        }
        else {
            System.debug('Record Not Found');
            System.abortJob(sc.getTriggerId());  
            Datetime sysTime = Datetime.now().addHours(1);  
            Datetime oneHourAgo1 = Datetime.now().addMinutes(-330);
            String cronExp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            System.schedule('Skipped Message Scheduled at ' + oneHourAgo1 , cronExp, new EmailSchedulerForSkippedMsg());
        }
    }
    
    public static void sendEmail(List<Whatsapp_Text__c> Send_whatsAppTextList){ 
        
        try{    String subject = 'Critical : URGENT !! Action required for WhatsApp notification';
          
            
            String bodyValue  = 'Hi Sir / Madam,<br/><br/>Following messages has been skipped / not delivered in last 1 hour. Potential reason could be<br/><br/>01. Channel is not active in whatsera portal.<br/> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Please login to whatsera portal and refresh your channels and reconnect the numbers.<br/> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Otherwise it will start skipping all the messages onwards.<br/>02. WhatsApp number is not available in that number.<br/> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Please update the correct number in salesforce, which is having an whatsapp account. <br/><br/>Please take the action accordingly as per the error message.<br/><br/>'+
                
                '<table style="border-collapse: collapse;font-family: Tahoma, Geneva, sans-serif;width:100%; ">'
                +'<thead>'
                +' <tr>'
                +'<th style="background-color: #54585d;padding: 9px;text-align: left;width:5%;	color: #ffffff;	font-weight: bold;	font-size: 12px;border: 1px solid white;border-left: 1px solid #54585d;">Sr No.</th>'
                +'<th style="background-color: #54585d;padding: 9px;text-align: left;width:15%;	color: #ffffff;	font-weight: bold;	font-size: 12px;border: 1px solid white;">Message Id</th>'
                +'<th style="background-color: #54585d;padding: 9px;text-align: left;width:15%;	color: #ffffff;	font-weight: bold;	font-size: 12px;border: 1px solid white;">Account</th>'
                +'<th style="background-color: #54585d;padding: 9px;text-align: left;width:35%;	color: #ffffff;	font-weight: bold;	font-size: 12px;border: 1px solid white;">Text</th>'
                +'<th style="background-color: #54585d;padding: 9px;text-align: left;width:15%;	color: #ffffff;	font-weight: bold;	font-size: 12px;border: 1px solid white;">Skipped Error</th>'
                +'<th style="background-color: #54585d;padding: 9px;text-align: left;width:15%;	color: #ffffff;	font-weight: bold;	font-size: 12px;border: 1px solid white;">Skipped Date & Time</th>' 
                
                
                +' </tr>'
                +' </thead>'
                +'<tbody>';
            integer i=1;
            for (Whatsapp_Text__c record : Send_whatsAppTextList) {     
            string accname=    (record.Account__c ==null)?'':record.Account__r.Name;
                String tr = '<tr>'
                    +'<td style=" padding-left:5px; text-align: left;center: #636363;border: 1px solid black;font-size:13px;">'+i+'</td>'
                    +'<td style="padding: 2px; text-align: left;color: #636363;border: 1px solid black;font-size:13px;">'+record.Name+ '</td>'
                    +'<td style="padding: 2px; text-align: left;color: #636363;border: 1px solid black;font-size:13px;">'+accname+ '</td>'
                    +'<td style="padding: 2px; text-align: left;color: #636363;border: 1px solid black;font-size:13px;">'+record.Text__c+'</td>'
                    +'<td style="padding:2px; text-align: left;color: #636363;border: 1px solid black;font-size:13px;">' + record.Skipped_Error__c+'</td>'
                    +'<td style="padding: 2px; text-align: left;color: #636363;border: 1px solid black;font-size:13px;">'+ record.Skipped_Date_Time__c.format()+'</td>'
                    +'</tr>';
                bodyValue+=tr;
                i++;
            }
            bodyValue+='</tbody>'
                +'</table>'+
                '<br/>Thank you for your attention to this matter.<br/><br/>Best regards,<br/>'+
                'Finhaat';//+
            String emailString = system.label.EmaiilScheduledEmail;
            List<String> emailList = emailString.split(',');
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses( emailList);
            mail.setSubject(subject);
            mail.setHtmlBody(bodyValue);
            if(!Send_whatsAppTextList.isEmpty())
            {Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
             if (results != null && results[0].isSuccess()) {
                 System.debug('  send email Email Sent Successfuly : ' + results);
                 update Send_whatsAppTextList;
             } else {
                 
                 System.debug('Failed to send email: ' + results[0].getErrors()[0].getMessage());
             }
            }
            Datetime sysTime = Datetime.now().AddHours(1); 
            Datetime oneHourAgo = Datetime.now().addMinutes(-330);
            String cronExp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            
            
             System.schedule('Skipped Message Scheduled at ' + oneHourAgo, cronExp, new EmailSchedulerForSkippedMsg());
           }
        catch (exception e){
            system.debug(e.getMessage());
            system.debug(e.getLineNumber());            
            throw new AuraHandledException(e.getMessage());
        } 
    }
    
}