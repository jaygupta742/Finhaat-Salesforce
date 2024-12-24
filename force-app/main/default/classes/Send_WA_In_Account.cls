/* Created by : Suraj Mahabudhe , Created Date : 22/02/2024 , Description : Need to create this apex class for send Whatsapp msg to account
* LastModified by : Suraj Mahabudhe , LastModified Date : 15/03/2024 , Description :1) Need to Send multiple attachments
2) Need to when attachement send that attachement should attach to send perticular whatsapp text
3) LastModified by : Suraj Mahabudhe , LastModified Date : 09/07/2024 , Description :1) Need to work on send whatsapp component need to show WhatsApp template as per current user profile
*/  
public  Without sharing class Send_WA_In_Account {
    
    
    @AuraEnabled(cacheable=true)
    public static Decimal getDocumentSize1(String documentId) {
        Decimal sizeInBytes = 0;
        
        ContentVersion cv = [SELECT ContentSize FROM ContentVersion WHERE ContentDocumentId = :documentId LIMIT 1]; 
        if (cv != null) {
            sizeInBytes = Decimal.valueOf(cv.ContentSize);
        } 
        // Convert bytes to megabytes (MB)
        Decimal sizeInMB = sizeInBytes / (1024 * 1024); 
        // Round to 2 decimal places
        sizeInMB = sizeInMB.setScale(2, System.RoundingMode.HALF_UP);
        
        return sizeInMB;
    }
    
@AuraEnabled(cacheable=true)
    public static boolean getwhats(String recordId) {
        boolean disabled = false;
          if(recordId.StartsWith('001')){ 
                Account acc=[Select id ,Name,WhatsApp_No__c  from Account where Id =: recordId];  
              if(acc.WhatsApp_No__c == null) disabled = true;
            }
        else{
            Ticket__c t= [Select id,Account__r.WhatsApp_No__c, Account__r.Name From Ticket__c where id =: recordId];  
             if(t.Account__r.WhatsApp_No__c == null) disabled = true;
        }
        
        return disabled;
    }
    
    @AuraEnabled(cacheable=true)
    public static list<Whatsapp_Templates__c> tempwap(String recordId){
        System.debug('recordid------->'+recordId);
        string paymnetlinsk;
      // system.debug(recid);
        if(recordId !=null &&  recordId.StartsWith('a05')){ 
            Ticket__c t= [Select id,Account__r.WhatsApp_No__c, Payment_Link__c,Account__r.Name From Ticket__c where id =: recordId];  
            paymnetlinsk = t.Payment_Link__c;
        }
        User u =[Select id, Profile.Name from user where Id=: userinfo.getUserId()];
        list<Whatsapp_Templates__c> ggt=New  list<Whatsapp_Templates__c> ();
        // here we are chcking current user profiles and return that whatsapp template on the basis of profile name
        if(u.Profile.Name=='POS Agents' || u.profile.Name =='POS Ops' || u.Profile.Name == 'POS Sales'){
            ggt=[select id,name,Text__c from Whatsapp_Templates__c where Profiles__c =:u.Profile.Name ORDER BY Name ASC NULLS LAST];
        }
        // else it will show all template
        else {
            ggt=[select id,name,Text__c from Whatsapp_Templates__c ORDER BY Name ASC NULLS LAST];
        } 
        
        
        for(Whatsapp_Templates__c sd:ggt){
            system.debug(paymnetlinsk+'  '+sd.Name);
            if(sd.Name =='Payment Link' && paymnetlinsk != null){ 
                sd.Text__c = sd.Text__c.replace('<Link>',paymnetlinsk );
            }
            
        }
        return ggt;
    }
    
    @AuraEnabled 
    public static string onsave(string recordId,  string text_body, string docid){  
        try { 
            string  accName='';
            system.debug(docid+'  docid'); 
            String [] lstDocumentId = docid.Split(',');
            //  List<String> lstDocumentId = (List<String>) JSON.deserialize(docid, List<String>.class);
            system.debug('lstDocumentId '+lstDocumentId);
            if(recordId.StartsWith('001')){
                system.debug('Inside for Account ');
                
                Account acc=[Select id ,Name,WhatsApp_No__c  from Account where Id =: recordId];
                Send_Wap_Class.send_wap(acc.WhatsApp_No__c, text_body,'Account',acc.id,lstDocumentId); 
                // aa.Account__c = acc.id;
                //  aa.Sent_To__c = acc.Phone;
                accName = acc.Name;
            }
            //For Sandbox Ticket Id Start with a06 and for production ticket id start with a05
            if(recordId.StartsWith('a05')){
                system.debug('Inside for Tickets '); 
                Ticket__c t= [Select id,Account__r.WhatsApp_No__c, Account__r.Name From Ticket__c where id =: recordId];
                
                Send_Wap_Class.send_wap(t.Account__r.WhatsApp_No__c, text_body,'Ticket__c',t.id,lstDocumentId);     
                accName = t.Account__r.Name;
                                          }
            
            
            system.debug('recordId '+recordId);
            system.debug('text_body '+text_body); 
            return accName;
        } catch(Exception e) {
            System.debug('error in SendWAQueryfromListView send method');
            System.debug('error message: ' + e.getMessage());
            System.debug('error line number: ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
}