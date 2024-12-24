/* LastModified by : Suraj , 27/07/2024 : Descripion need to skipp 	whatsapp text if any error occured while sending and again skipped record will proceed
 * LastModified by : Suraj , 21/08/2024 :  Need to add filter for skipp 	whatsapp it should be createddate today 
 */ 
public class whatsAppScheduler implements schedulable{
    
    list<Whatsapp_Text__c> whatsAppTextList = new list<Whatsapp_Text__c>();
    
    public void execute(SchedulableContext context){
        
        whatsAppTextList = [SELECT id,Text__c,Ticket__c,Sent_Date_Time__c,Skipped_Record_Due_to_Error__c,Skipped_Error__c,Delivery_Status__c,Skipped_Date_Time__c From Whatsapp_Text__c Where Msg_Sent__c = false AND Message_Type__c = 'Outbound'
                            and Skipped_Record_Due_to_Error__c = false
                            and Automated_Process__c = false 
                            and  (CreatedBY.profile.Name =:system.label.POS_Sales or CreatedBY.profile.Name =:system.label.POS_Ops)
                              and   CreatedDate=today
                            ORDER BY CreatedDate ASC];
        
        if(whatsAppTextList.size() > 0){
            System.abortJob( context.getTriggerId());
            executeOnce(whatsAppTextList[0].Id,(whatsAppTextList.size() - 1));
        }else{
            // here skipp 	whatsapp msg query with createddate today
           list<Whatsapp_Text__c>    repettext = [SELECT id, Skipped_Record_Due_to_Error__c,Skipped_Error__c From Whatsapp_Text__c Where Msg_Sent__c = false AND Message_Type__c = 'Outbound'
                                                   and Skipped_Record_Due_to_Error__c = true and Automated_Process__c = false  
                                                  and (CreatedBY.profile.Name =:system.label.POS_Sales or  CreatedBY.profile.Name =:system.label.POS_Ops) and   CreatedDate=today
                                                
                                                   ORDER BY CreatedDate ASC];
            for(Whatsapp_Text__c wt:repettext){
               If(wt.Skipped_Error__c != null && !wt.Skipped_Error__c.Contains('no account exists'))   wt.Skipped_Record_Due_to_Error__c = false;  
            }
            if(!repettext.IsEmpty()) update repettext; 
            System.abortJob( context.getTriggerId());
            Datetime sysTime = System.now().addMinutes(1);
            String cronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            System.schedule('Whatsapp Queue POS Ops & Sales - No Messages Are Left', cronExpression, new whatsAppScheduler());
        }      
    }
    
    @future(callout = true)
    public static void executeOnce(String whatsappTextId,Integer msgSize){
        try{
            Whatsapp_Text__c text = [SELECT id,Text__c,Sent_To__c,OwnerId ,Sent_Date_Time__c,Delivery_Status__c,Skipped_Date_Time__c,Skipped_Record_Due_to_Error__c,Skipped_Error__c, Ticket__c From Whatsapp_Text__c Where Id =: whatsappTextId]; 
            
            
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
                 text.Sent_Date_Time__c = datetime.Now();
                text.Delivery_Status__c = 'Sent'; 
                 text.Skipped_Error__c= null;
                 text.Skipped_Date_Time__c = null;
                 text.Skipped_Record_Due_to_Error__c = false;
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
                System.schedule('Whatsapp Queue POS Ops & Sales Queue For ' + Date.today().format() + ' - ' + DateTime.now().format('HH:mm:ss') + ' Msg Left ' + msgSize, cronExpression, new whatsAppScheduler());
            }
            
        }catch(Exception e){
              Datetime sysTime = System.now().addMinutes(1);
            String cronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            System.schedule('Whatsapp Queue POS Ops & Sales  - No Messages Are Left', cronExpression, new whatsAppScheduler());
            system.debug(e.getMessage());
            system.debug(e.getLineNumber());            
            throw new AuraHandledException(e.getMessage());
        }
    }
}