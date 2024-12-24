public class SendWAnoti_forStage {
    @InvocableMethod(label='Send WhatsApp Notification for POS Stage Changed')
    public static void sendnotification(List<id> ids){
        
        Account[] accList=[Select id ,Name,WhatsApp_No__c,Stage__c, POS_Code__c from Account where Id IN: ids];
        
        list<Whatsapp_Templates__c> ggt=[select id,name,Text__c from Whatsapp_Templates__c ORDER BY Name ASC NULLS LAST];
        Map<String, String> templatebod=New   Map<String, String>();
        for(Whatsapp_Templates__c ww:ggt){
            if(ww.Text__c != null){
                templatebod.put(ww.Name, ww.Text__c);
            }
        }  
        List<Whatsapp_Text__c>  wtlist=New  List<Whatsapp_Text__c>();
        For(Account acc:acclist){
            if(acc.Stage__c != null  && templatebod.ContainsKey(acc.Stage__c) ){   
                String text_body = templatebod.get(acc.Stage__c); if(text_body.contains('<name>')){text_body = text_body.replace('<name>', acc.Name);}
               if(text_body.contains('<code>')){text_body = text_body.replace('<code>', acc.pos_Code__c != null ? acc.pos_Code__c : '');}
                //Send_Wap_Class.send_wap(acc.WhatsApp_No__c, text_body,'Account',acc.id,new String[]{}); 
                
                if ( acc.WhatsApp_No__c != '' && acc.WhatsApp_No__c != null ){
                    // SET JSON BODY  //
                    acc.WhatsApp_No__c = acc.WhatsApp_No__c.replaceAll('[^\\d]', '');
                    acc.WhatsApp_No__c = acc.WhatsApp_No__c.length() > 10 ? acc.WhatsApp_No__c.substring(acc.WhatsApp_No__c.length() - 10) : acc.WhatsApp_No__c;
                    acc.WhatsApp_No__c = '91' + acc.WhatsApp_No__c; 
                    /* Map<String, Object> mapBody = new Map<String, Object>();
mapBody.put('accessToken', System.label.Whatsera_Send_Sms);
mapBody.put('mobile', mobileno);
mapBody.put('text', textsms);

String jsonBody = JSON.serialize(mapBody);
system.debug('The JSON BODY is : ' + jsonBody);
system.debug('The End Point  is : ' + System.label.Whatsera_Send_Sms_EndPoint);
system.debug('The AccessToken is : ' + System.label.Whatsera_Send_Sms);*/ 
                    Whatsapp_Text__c aa = New Whatsapp_Text__c();
                    aa.Msg_Sent__c = false;
                    aa.Delivery_Status__c = 'In-Queue';
                    // aa.Id__c ='12345567890';
                    aa.Message_Type__c = 'Outbound';
                    aa.Text__c = text_body;
                    aa.user__c = userinfo.getUserid();
                    aa.Account__c = acc.id; 
                    aa.Automated_Process__c = true;
                    aa.Sent_To__c = acc.WhatsApp_No__c; 
                    wtlist.add(aa); 
                }
            } 
        }
        if(!wtlist.IsEmpty()) insert wtlist;
    }
}