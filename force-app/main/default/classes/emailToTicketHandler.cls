public without sharing class emailToTicketHandler implements Messaging.InboundEmailHandler {
    
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env){
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        
        String myPlainText = '';
        myPlainText = email.plainTextBody;
        
        system.debug(email.toAddresses);
        
        Account account = new Account();
        
        try {
            try{
                account = [SELECT Id, Name, PersonEmail
                           FROM Account
                           WHERE PersonEmail =: email.fromAddress
                           LIMIT 1];
            }catch(Exception e){
                system.debug('No Account Found');
            }
            
            Ticket__c ticket = new Ticket__c();
            if(account != null){
                ticket.Account__c = account.Id;
            }
            ticket.text__c = email.Subject + '\n\n' + myPlainText;
            ticket.client_Email__c = email.fromAddress;
            insert ticket;
            
            List<ContentVersion> contentVersions = new List<ContentVersion>();
            if (email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
                for (Integer i = 0; i < email.binaryAttachments.size(); i++) {
                    ContentVersion cv = new ContentVersion();
                    cv.Title = email.binaryAttachments[i].filename;
                    cv.PathOnClient = email.binaryAttachments[i].filename;
                    cv.VersionData = email.binaryAttachments[i].body;
                    cv.Origin = 'H';
                    contentVersions.add(cv);
                }
            }
            
            if (!contentVersions.isEmpty()) {
                insert contentVersions;
            }

            List<ContentVersion> textContentVersions = new List<ContentVersion>();
            if (email.textAttachments != null && email.textAttachments.size() > 0) {
                for (Integer i = 0; i < email.textAttachments.size(); i++) {
                    ContentVersion cv = new ContentVersion();
                    cv.Title = email.textAttachments[i].FileName;
                    cv.PathOnClient = email.textAttachments[i].FileName;
                    cv.VersionData = Blob.valueOf(email.textAttachments[i].body);
                    cv.Origin = 'H';
                    textContentVersions.add(cv);
                }
            }

            if (!textContentVersions.isEmpty()) {
                insert textContentVersions;
            }
            
            contentVersions = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id IN : contentVersions];
            textContentVersions = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id IN : textContentVersions];

            List<ContentDocumentLink> contentDocLinks = new List<ContentDocumentLink>();
            for (ContentVersion cv : contentVersions) {
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = cv.ContentDocumentId;
                cdl.LinkedEntityId = ticket.Id;
                cdl.ShareType = 'V';
                cdl.Visibility = 'AllUsers';
                contentDocLinks.add(cdl);
            }

            for (ContentVersion cv : textContentVersions) {
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = cv.ContentDocumentId;
                cdl.LinkedEntityId = ticket.Id;
                cdl.ShareType = 'V';
                cdl.Visibility = 'AllUsers';
                contentDocLinks.add(cdl);
            }

            if (!contentDocLinks.isEmpty()) {
                insert contentDocLinks;
            }
            
            EmailMessage emailMessage = new EmailMessage();
            emailMessage.Subject = email.subject;
            emailMessage.TextBody = email.plainTextBody;
            emailMessage.ToAddress = email.toAddresses[0];
            emailMessage.FromAddress = email.fromAddress;
            emailMessage.fromName = email.fromName;
            emailMessage.RelatedToId = ticket.Id; 
            emailMessage.MessageDate = System.now();
            emailMessage.Status = '3';
            insert emailMessage;
        }
        catch (QueryException e) {
            System.debug('Query Issue: ' + e);
        }
        
        result.success = true;
        
        return result;
    }
}