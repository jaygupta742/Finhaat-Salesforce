public class SendDocSampleEmailApex {
	@AuraEnabled
    public static void sendtoWhatsApp(String recid, String documentIds){        
        List<Required_Documents__c> documentlist = [Select id, Name, Status__c, Stages__c, Instruction__c 
                from Required_Documents__c WHERE Account__c =: recid];
        List<Id> reqId = new List<Id>();
        for(Required_Documents__c rd : documentlist){
            reqId.add(rd.Id);
        }
        System.debug('Document List>>' + documentIds);    
    }
    
    @AuraEnabled(cacheable = true) 
    public Static String getStudentEmail(String recId){
        Account acc = [Select Id, Name, Salutation, PersonEmail , Owner.Name, PersonMobilePhone  From Account WHERE id =: recId ];
        sendMailWrap sWrap = new sendMailWrap(acc, recId);
        return Json.serialize(sWrap);        
    }
    
    @AuraEnabled
    public static void DeleteAttachments(List<String> lstDocumentId){        
        List<ContentDocument> lstAttachments = [SELECT Id, Title
                                                FROM ContentDocument
                                                WHERE Id IN:lstDocumentId];
        Delete lstAttachments;        
    }
    
    @AuraEnabled
    public static string sendEmailmethod(String Subject, String EmailBody, String recipients, String ccaddress, String documentIds, String recid,Boolean isBodyChanged) { 
        try {
            List<Object> lstRecipients = (List<Object>) JSON.deserializeUntyped(recipients);
            string[]  emmailids =new string[]{};
                for(Object item : lstRecipients) {
                    Map<String, Object> mapRecipients = (Map<String, Object>) item;
                    String emailId = (String) mapRecipients.get('emailId');
                    emmailids.add(emailId); 
                }
            String newEmailBody2;
            if(isBodyChanged){
                String newEmailBody = EmailBody.replaceAll('<p>', '');
                String result = newEmailBody.replaceAll('</p>', '');  
                String pattern = '<br\\s*/?>';
        		String input = result.replaceAll(pattern, '<br/><br/>');
                String substring = 'Best Regards,';
                String searchString = 'Best regards,';
                String replacementString = 'Best regards,<br/>';
                newEmailBody2 = input.replace(searchString, replacementString);
            }
           
            List<Object> lstCC = (List<Object>) JSON.deserializeUntyped(ccaddress);
            List<String> ccemmailids = new List<String>();
                for(Object item : lstCC) {
                    Map<String, Object> mapRecipients = (Map<String, Object>) item;
                    String emailId = (String) mapRecipients.get('emailId');
                    ccemmailids.add(emailId); 
                }
            List<String> lstDocumentId = (List<String>) JSON.deserialize(documentIds, List<String>.class);
            List<String> lstProjectContactsId = new List<String> (); 
            
            User u = [Select id,Name, Email, MobilePhone, Profile.Name From User WHERE Id =:  UserInfo.getUserId()];
            
            List<Messaging.Emailfileattachment>   fileAttachments=new List<Messaging.Emailfileattachment>();
            Account so = new Account();
            so = [select id, name from Account WHERE Id =: recid];
            List<Messaging.SingleEmailMessage> lstEmails = new List<Messaging.SingleEmailMessage> ();  
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject(Subject);
            if(!isBodyChanged)email.setHtmlBody(EmailBody);
            if(isBodyChanged) email.setHtmlBody(newEmailBody2); 
            email.setToAddresses(emmailids);
            email.setCcAddresses(ccemmailids);
            email.setWhatId(so.id); 
            email.setSenderDisplayName(u.Name);        
            email.setFileAttachments(fileAttachments);
            
            List<ContentVersion> lstContentVersion = [SELECT Id, ContentDocumentId, Title, VersionNumber, VersionData, PathOnClient ,FirstPublishLocationId
                                                      FROM ContentVersion WHERE ContentDocumentId IN: lstDocumentId];
            Attachment[] attlist=New Attachment[]{};
                list<ContentDocumentLink> contentDocumentLinkList = new list<ContentDocumentLink>();
            
            if(lstContentVersion.size()>0) {
                for(ContentVersion cv : lstContentVersion) {
                    Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();   attach.setFileName(cv.PathOnClient); attach.setBody(cv.VersionData);    fileAttachments.add(attach);  
                    
                }
                email.setFileAttachments(fileAttachments);
            }
            lstEmails.add(email);
            Messaging.SendEmailResult[] sendEmailResults = Messaging.sendEmail(lstEmails);
            RETURN 'SUCCESS';
        }catch(Exception e) { 
            system.debug(e.getlinenumber());
            system.debug(e.getmessage());
            throw new AuraHandledException(e.getMessage()); 
        }
    }
    
    public class sendMailWrap{
        public string email{ get; set; } 
        public string ccmail{ get; set; } 
        public string subject{ get; set; } 
        public string body{ get; set; } 
        public Account so{ get; set; } 
        public sendMailWrap(Account Studend, String recordId){
            so = new Account();
            so = Studend;
            email = so.PersonEmail  == null ? '' : so.PersonEmail ;
            User u = [Select id,Name, Email, MobilePhone From User WHERE Id =:  UserInfo.getUserId()];
            ccmail = u.Email;
            subject = 'Request for Document Upload';
            String accountName = so.Name != null ? so.Name : '';
            String sal;
            if(so.Salutation != null){
                sal = so.Salutation; 
            }
            else{
                sal = '';
            }
            
            body = ('Hi ' + sal + ' ' + so.Name + ',<br/><br/>' +
            'We hope this message finds you well.<br/><br/>In order to move forward, please upload the necessary documents at your earliest convenience by using our secure upload portal linked below:<br/><br/>' +
            '<a href="https://finhaatinsurancebrokingpvtltd.my.salesforce-sites.com/UploadDocs?id='+so.Id+'"><strong>Upload Your Documents Here</strong></a><br/><br/>' +
            
            'If you have any questions or need assistance, please do not hesitate to contact us at <b>' + u.MobilePhone + '</b> or reply to this email <b>' + u.Email + '</b>. <br/><br/>' +
            'Thank you for your prompt attention to this matter<br/><br/>' +
            'Sincerely,<br/>' + u.Name + 
            '<br/>Finhaat Insurance Broking Pvt. Ltd');

        }
    }
}