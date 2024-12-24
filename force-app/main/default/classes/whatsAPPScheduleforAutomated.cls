/* Created By Suraj 09/08/2024  : This scheduler class will schedule at 8 PM every for automated WhatsaPP Notification
*  LastModified by : Suraj , 21/08/2024 :  Need to add filter for skipp 	whatsapp it should be createddate today 
*/ 
public class whatsAPPScheduleforAutomated  implements schedulable{
    list<Whatsapp_Text__c> whatsAppTextList = new list<Whatsapp_Text__c>(); 
    public void execute(SchedulableContext context){
        
        whatsAppTextList = [SELECT id,Text__c,Ticket__c,Sent_Date_Time__c,Skipped_Record_Due_to_Error__c,Skipped_Error__c,Delivery_Status__c,Skipped_Date_Time__c From Whatsapp_Text__c Where Msg_Sent__c = false AND Message_Type__c = 'Outbound'
                            and Skipped_Record_Due_to_Error__c = false and Automated_Process__c = true    and   CreatedDate=today// 'System Administrator'  //Profile_Name__c =: 'PT1'
                            ORDER BY CreatedDate ASC];
        
        list<Whatsapp_Text__c> alreadySendedWhatappText = [Select Id, Sent_Date_Time__c,Delivery_Status__c, Skipped_Record_Due_to_Error__c,Skipped_Error__c From Whatsapp_Text__c Where Msg_Sent__c = false AND Message_Type__c = 'Outbound' AND Automated_Process__c = false AND Skipped_Error__c = null];
        
        system.debug(alreadySendedWhatappText.size());
        
        // if(alreadySendedWhatappText.size() > 0){
        //    System.abortJob(context.getTriggerId());
        //            Datetime sysTime = System.now().addMinutes(alreadySendedWhatappText.size());
        //     String cronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        //     System.schedule('Automated Whatsapp Queue - Other Queue Has ' + alreadySendedWhatappText.size() + 'Meesages', cronExpression, new whatsAPPScheduleforAutomated());
        // }else
        
        if(whatsAppTextList.size() > 0){
            System.abortJob( context.getTriggerId());executeOnce(whatsAppTextList[0].Id,(whatsAppTextList.size() - 1));
        }else{
            // here skipp 	whatsapp msg query with createddate today
            list<Whatsapp_Text__c>    repettext = [SELECT id, Skipped_Record_Due_to_Error__c,Skipped_Error__c From Whatsapp_Text__c Where Msg_Sent__c = false AND Message_Type__c = 'Outbound'
                                                   and Skipped_Record_Due_to_Error__c = true and Automated_Process__c = True and   CreatedDate=today
                                                   ORDER BY CreatedDate ASC];
            for(Whatsapp_Text__c wt:repettext){
                If(wt.Skipped_Error__c != null && !wt.Skipped_Error__c.Contains('no account exists'))   wt.Skipped_Record_Due_to_Error__c = false;  
            } 
            if(!repettext.IsEmpty()) update repettext; 
            System.abortJob( context.getTriggerId());
            Datetime sysTime = System.now().addMinutes(1);
            //  String cronExpression = system.label.AutomatedSchedulerCronEx; //  label use for to set the Cron Exression
            
            String cronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            System.schedule('Automated Whatsapp Queue - No Messages Are Left', cronExpression, new whatsAPPScheduleforAutomated());
            
        }      
    }
    
    @future(callout = true)
    public static void executeOnce(String whatsappTextId,Integer msgSize){
        try{
            Whatsapp_Text__c text = [SELECT id,Text__c,Sent_To__c,OwnerId ,Delivery_Status__c,Sent_Date_Time__c , Skipped_Date_Time__c,Skipped_Record_Due_to_Error__c,Skipped_Error__c, Ticket__c From Whatsapp_Text__c Where Id =: whatsappTextId]; 
            
            
            User user = [Select Id, whatsEra_Api_Key__c From User WHERE ID =: text.OwnerId];
            
            String modifiedMessage = text.Text__c;
            
            String mobile = String.valueOf(contact.MobilePhone);
            
            HttpRequest request = new HttpRequest();
            Http http = new Http();
            HttpResponse response = new HttpResponse();
            
            
            map<String, Object> JSONBody = new map<String, Object>{ 'accessToken' => user.whatsEra_Api_Key__c, 'mobile' => text.Sent_To__c, 'text' => text.Text__c };
                
                request = new HttpRequest();
            request.setEndpoint(system.label.Whatsera_Send_Sms_EndPoint + '/api/send/text');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'Application/Json');
            request.setBody(JSON.serialize(JSONBody));
            request.setTimeout(120000);
            http = new Http();
            system.debug(request);
            
            response = http.send(request);  
            list<Attachment> attchmentList = [SELECT Name,Body FROM attachment Where parentId =: whatsappTextId];
            
            if(!attchmentList.isEmpty()){
                for(Attachment attachment : attchmentList){
                    String fileName = attachment.Name;
                    String fileContent = EncodingUtil.base64Encode(attachment.Body);
                    Blob formData = HttpHexFormBuilder.build().writeParam('accessToken', user.whatsEra_Api_Key__c).writeParam('mobile', text.Sent_To__c).writeParam('caption', '').writeFile('file', fileName, fileContent).getFormAsBlob();
                    system.debug(formData);
                    request = new HttpRequest();
                    request.setEndpoint(system.label.Whatsera_Send_Sms_EndPoint + '/api/send/attach/doc');
                    request.setMethod('POST');
                    request.setHeader('Connection', 'keep-alive');
                    request.setHeader('Content-Length', String.valueOf(formData.size()));
                    request.setHeader('Content-Type', HttpHexFormBuilder.GetContentType());
                    request.setBodyAsBlob(formData);
                    request.setTimeout(120000);
                    system.debug(request);
                    http = new Http();
                    try { 
                        response = http.send(request);
                        system.debug(response.getBody());
                    } catch (Exception e) {
                        System.debug('Error sending text: ' + e.getMessage());
                        // Log the error and continue to the next message
                    }
                } 
            }
            system.debug('response.getStatusCode() '+response.getStatusCode());
            if (response.getStatusCode() == 200) {
                text.Msg_Sent__c = true;
                text.Delivery_Status__c = 'Sent'; 
                text.Skipped_Error__c= null;
                text.Skipped_Date_Time__c = null;
                text.Skipped_Record_Due_to_Error__c = false;
                text.Sent_Date_Time__c = datetime.Now();
                update text; 
            }
            
            else{
                system.debug('got error sending msg '+response.getBody());
                text.Skipped_Record_Due_to_Error__c = true;
                text.Skipped_Error__c = string.Valueof(response.getBody());
                text.Skipped_Date_Time__c = datetime.Now();
                update text;
            }              
            
            Datetime sysTime = System.now().addMinutes(1);
            String cronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            if(!Test.isRunningTest()){
                System.schedule('Automated Whatsapp Queue For ' + Date.today().format() + ' - ' + DateTime.now().format('HH:mm:ss') + ' Msg Left ' + msgSize, cronExpression, new whatsAPPScheduleforAutomated());
            }
            
        }catch(Exception e){
            Datetime sysTime = System.now().addMinutes(1);
            String cronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            System.schedule('Automated Whatsapp Queue - No Messages Are Left', cronExpression, new whatsAPPScheduleforAutomated());
            system.debug(e.getMessage());
            system.debug(e.getLineNumber());            
            throw new AuraHandledException(e.getMessage());
        }
    }
}