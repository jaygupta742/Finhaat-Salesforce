//Last modified by ashish kurzeakr on 19.08.24 >> Added functionality to preview files in ticket attachment component
public class ticket_Attachments {
    
    @AuraEnabled
    Public static string createTicket(Ticket__c ticket){
        system.debug('ticket>> '+ticket);
        Ticket__c tkt = new Ticket__c();
        tkt.Account__c = ticket.Account__c;
        tkt.Stage__c = ticket.Stage__c;
        tkt.text__c = ticket.text__c;
        insert tkt;
        return tkt.Id;
    }
    @AuraEnabled(cacheable=true)
    public static List<Ticket__c> getAllTickets(String accountId){
        return [select id, name, Account__c,CreatedDate, text__c from Ticket__c where Account__c =: accountId];
    }
    
	@AuraEnabled(cacheable=true)
    public static List<ContentVersion> getDocumentsForOpportunity(String AccountId) {
        Set<Id> contentDocumentIds = new Set<Id>();        
        List<ContentDocumentLink> contentDocumentLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :AccountId];        
        for (ContentDocumentLink c : contentDocumentLinks) {
            contentDocumentIds.add(c.ContentDocumentId);
        }
        return [ SELECT Id ,ContentDocumentId,  FileType, Title, CreatedDate, CreatedBy.Name, LastModifiedDate FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIds order by Title ASc ];
	}   
    
    public static String checkFileType(String typeFile){
            String fileType = typeFile ; String contentType;  fileType = fileType.toLowerCase();        
            if (fileType == 'txt' || fileType == 'text') {contentType = 'text/plain';}
            else if (fileType == 'csv') {contentType = 'text/csv';}
            else if (fileType == 'html') {contentType = 'text/html';}
            else if (fileType == 'jpg' || fileType == 'jpeg') {contentType = 'image/jpeg';}
            else if (fileType == 'png') {contentType = 'image/png';}
            else if (fileType == 'gif') {contentType = 'image/gif';}
            else if (fileType == 'pdf') {contentType = 'application/pdf';} 
            else if (fileType == 'doc' || fileType == 'docx' || fileType == 'word') {contentType = 'application/msword';}
            else if (fileType == 'xls' || fileType == 'xlsx' || fileType == 'excel_x' || fileType == 'excel') {contentType = 'application/vnd.ms-excel';}
            else if (fileType == 'ppt' || fileType == 'pptx' || fileType == 'POWER_POINT_X') {contentType = 'application/vnd.ms-powerpoint';}
            else if (fileType == 'odt') {contentType = 'application/vnd.oasis.opendocument.text';}
            else if (fileType == 'zip') {contentType = 'application/zip';}
            else if (fileType == 'json') { contentType = 'application/json';}
            else if (fileType == 'xml') {contentType = 'application/xml';}
            else if (fileType == 'mp3') {contentType = 'audio/mpeg';}
			else if (fileType == 'mp4') { contentType = 'video/mp4';}
            else contentType = 'application/octet-stream'; 
            return  contentType;
    }
    
    @AuraEnabled()
    public static void attachToTicket(String accountId, String ticketId, List<String> selectAttachmentId){
        System.debug(selectAttachmentId);
        List<ContentVersion> conver = [ SELECT Id ,  FileType, VersionData, PathOnClient, Title from ContentVersion where Id =: selectAttachmentId];
        List<ContentVersion> conUpdate = new List<ContentVersion>();
        for(ContentVersion cv : conver){
            ContentVersion cc = new ContentVersion();
            cc.PathOnClient = cv.PathOnClient;
            cc.Title  = cv.Title;
            cc.VersionData = cv.VersionData;
            cc.FirstPublishLocationId = ticketId;
            conUpdate.add(cc);
        }
        if(!conUpdate.isEmpty()){
            insert conUpdate;
        }
        
        
        Set<Id> contentDocumentIds = new Set<Id>();
        List<ContentVersion> conVerDelete = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id =: selectAttachmentId
        ];
        
        for (ContentVersion cv : conVerDelete) {
            contentDocumentIds.add(cv.ContentDocumentId);
        }
        
        if (!contentDocumentIds.isEmpty()) {
            List<ContentDocument> contentDocumentsToDelete = [
                SELECT Id 
                FROM ContentDocument 
                WHERE Id IN :contentDocumentIds
            ];
            
            if (!contentDocumentsToDelete.isEmpty()) {
                delete contentDocumentsToDelete;
            }
        }
        
    }
}