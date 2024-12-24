public class SendWAforContacts {
    
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
    
    @AuraEnabled 
    public static String deletdoc( String Docid){
        ContentDocument  Docidid  =[SELECT Id FROM ContentDocument where id =: docid];
        delete Docidid;          
        return 'Success';
    }
    @AuraEnabled(cacheable=true)
    public static list<Whatsapp_Templates__c> tempwap( ){
        
        list<Whatsapp_Templates__c> ggt=New  list<Whatsapp_Templates__c> (); 
        ggt=[select id,name,Text__c from Whatsapp_Templates__c WHERE Notify_For__c = 'Contact' ORDER BY Name ASC NULLS LAST]; 
        return ggt;
    }
    
    @AuraEnabled 
    public static string onsave(string recordId,  string text_body, string docid){  
        try { 
            string  accName='';
            
            String [] lstDocumentId = docid.Split(',');
            system.debug('lstDocumentId '+lstDocumentId);
            
            system.debug('Inside for Account ');
            
            Contact acc=[Select id ,Name,WhatsApp_No__c  from Contact where Id =: recordId];
            Send_Wap_Class.send_wap(acc.WhatsApp_No__c, text_body,'Contact',acc.id,lstDocumentId);  
            accName = acc.Name;
            
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