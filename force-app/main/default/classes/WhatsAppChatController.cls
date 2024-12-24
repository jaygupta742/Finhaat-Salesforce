//Created by Shreyash Urkude on 23 August. Description : Apex class for LWC Component Whatsapp Chat Controller.
public with sharing class WhatsAppChatController {
    @AuraEnabled(cacheable=true)
    public static DateTime dateSend(String recordId){ 
        Whatsapp_Text__c whatsAppChats = [SELECT Id, Name, Text__c, CreatedDate, Message_Type__c, Owner.Name, (SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.Title FROM ContentDocumentLinks) 
                                          FROM Whatsapp_Text__c where Id =: recordId];
        return whatsAppChats.CreatedDate;
    }
    
    @AuraEnabled(cacheable=true)
    public static list<Whatsapp_Templates__c> tempwap(String recordId){ 
        System.debug('recordid------->'+recordId);
        Account acc = [Select id, FirstName, LastName,POS_Code__c from Account Where Id =:recordId];
         String firstName = (acc.FirstName != null) ? acc.FirstName : '';
        String lastName = (acc.LastName != null) ? acc.LastName : '';
        String poscode = (acc.POS_Code__c != null) ? acc.POS_Code__c : '';
        string paymnetlinsk;
       /* if(recordId !=null &&  recordId.StartsWith('a05')){ 
            Ticket__c t= [Select id,Account__r.WhatsApp_No__c, Payment_Link__c,Account__r.Name From Ticket__c where id =: recordId];  
            paymnetlinsk = t.Payment_Link__c;
        }*/
        User u =[Select id, Profile.Name from user where Id=: userinfo.getUserId()];
        list<Whatsapp_Templates__c> ggt=New  list<Whatsapp_Templates__c> ();
        if(u.Profile.Name=='POS Agents' || u.profile.Name =='POS Ops' || u.Profile.Name == 'POS Sales'){
            ggt=[select id,name,Text__c from Whatsapp_Templates__c where Profiles__c =:u.Profile.Name AND Notify_For__c = 'Account' ORDER BY Name ASC NULLS LAST];
        }
        else {
            ggt=[select id,name,Text__c from Whatsapp_Templates__c  WHERE Notify_For__c = 'Account' ORDER BY Name ASC NULLS LAST];
        } 
        for(Whatsapp_Templates__c sd:ggt){
          if(paymnetlinsk != null){ 
                sd.Text__c = sd.Text__c.replace('<Link>',paymnetlinsk );
            }
            sd.Text__c = sd.Text__c.replace('<name>',firstName+' '+lastName);
            sd.Text__c = sd.Text__c.replace('<code>',poscode);
            
        }
        return ggt;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getChats(String contactId){
        try{
            Account con = [Select Id, WhatsApp_No__c, Name, LastName, FirstName from Account WHERE Id = :contactId];
            
            List<Whatsapp_Text__c> whatsAppChats = [SELECT Id, Name, Text__c, CreatedDate, Message_Type__c, Owner.Name, (SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.Title FROM ContentDocumentLinks) 
                                                    FROM Whatsapp_Text__c
                                                    WHERE Account__c = :contactId AND Message_Type__c != null
                                                    ORDER BY CreatedDate ASC];
            
            chatDetailWrapper chatdetails = new chatDetailWrapper();
            chatdetails.shortName = con.FirstName != null ? con.FirstName.subString(0, 1) + con.LastName.subString(0, 1) : con.LastName.subString(0, 1);
            List<chatWrapper> chats = new List<chatWrapper>();
            
            if (!whatsAppChats.isEmpty()){
                chatdetails.startedcontactName = whatsAppChats[0].Message_Type__c == 'Outbound' ? 'Me' : con.Name;
                chatdetails.endedcontactName = whatsAppChats[whatsAppChats.size() - 1].Message_Type__c == 'Outbound' ? 'Me' : con.Name;
                chatdetails.startedDateTime = whatsAppChats[0].CreatedDate;
                chatdetails.endedDateTime = whatsAppChats[whatsAppChats.size() - 1].CreatedDate;
                
                for (Whatsapp_Text__c chat : whatsAppChats){
                    if (chat.ContentDocumentLinks != null && !chat.ContentDocumentLinks.isEmpty()) chats.add(new chatWrapper(chat, chat.ContentDocumentLinks, con.Name));
                    else chats.add(new chatWrapper(chat, new list<ContentDocumentLink>(), con.Name));
                }
            }
            chatdetails.chats = chats;
            return JSON.serialize(chatdetails);
        } catch (Exception e){
            System.debug(e.getMessage());
            System.debug(e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static String getImageUrl(String contentVersionId) {
        try {
            ContentVersion contentVersion = [
                SELECT Id, ContentDocumentId, VersionData
                FROM ContentVersion
                WHERE ContentDocumentId = :contentVersionId
                LIMIT 1
            ];
            // Construct the URL to access the image file
            String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
            return baseUrl + '/sfc/servlet.shepherd/version/download/' + contentVersion.Id;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving image URL: ' + e.getMessage());
        }
    }
    
    // This method is used when we send text message
    @AuraEnabled
    public static String sendMessage(String message, String contactId){
        try{
            message = message.replace('My Reply', '*My Reply*');
            message = message.replace('Your Comment was', '*Your Comment was*');
            message = message.replace('My Msg was', '*My Msg was*');
            Account con = [Select Id, WhatsApp_No__c, Name from Account WHERE Id = :contactId];
            if (con.WhatsApp_No__c != null && con.WhatsApp_No__c.length() == 10){
                con.WhatsApp_No__c = '91' + con.WhatsApp_No__c;
            }
            system.debug('Mobile no ---->'+con.WhatsApp_No__c);
            
            map<String, Object> JSONBody = new map<String, Object>{ 'accessToken' => system.label.Whatsera_Send_Sms, 'mobile' =>con.WhatsApp_No__c, 'text' =>message };
                String requestBody = JSON.serialize(JSONBody);
            
            system.debug('The JSON BODY is : ' + requestBody);
            system.debug('The End Point  is : ' + System.label.Whatsera_Send_Sms_EndPoint);
            system.debug('The AccessToken is : ' + System.label.Whatsera_Send_Sms);
            System.debug(requestBody);
            
            
            HttpRequest request = new HttpRequest();
            request.setEndpoint(System.label.Whatsera_Send_Sms_EndPoint+ '/api/send/text');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'Application/json');
            request.setBody(requestBody);
            
            // HttpResponse response = new Http().send(request);
            // System.debug('response------->'+response);
            //  if (response.getStatusCode() == 200){
            //   system.debug('get body '+response.getBody());//
            //    system.debug('get body as blob  '+response.getBodyasBlob());
            //     system.debug('responseList------->');
            
            message = message.replace('*My Reply*', 'My Reply');
            message = message.replace('*Your Comment was*', 'Your Comment was');
            message = message.replace('*My Msg was*', 'My Msg was');
            Whatsapp_Text__c textRecord = new Whatsapp_Text__c();
            textRecord.Account__c = contactId;
            textRecord.Message_Type__c = 'Outbound';
            textRecord.Sent_To__c = con.WhatsApp_No__c;
            textRecord.Delivery_Status__c = 'In-Queue';
            textRecord.Text__c = message;
            textRecord.Msg_Sent__c = FALSE;
              textRecord.User__c = UserInfo.getUserId() ;
            insert textRecord;
            
            //}
            return 'success';
        } catch (Exception e){
            System.debug('@@ Send Message error message : ' + e.getMessage());
            System.debug('@@ Send Message error line number : ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string UploadFiles(String FileContent, String FileName) {
        try {
           string cvid;
            try{ContentVersion cv=[Select id , Title from ContentVersion where Title =:FileName limit 1];
                cvid = cv.id;
               }
            catch(Exception e){
                 ContentVersion content = new ContentVersion(
                VersionData = EncodingUtil.base64Decode(FileContent),
                Title = FileName,
                PathOnClient = '/' + FileName
            );
                   insert content;
                cvid =content.ID;
            }
         
            return cvid;
        } catch (Exception e) {
            System.debug('@@ Upload Files error message: ' + e.getMessage());
            System.debug('@@ Upload Files error line number: ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //This method is used when we send Attachments
    @AuraEnabled
    public static string sendMessageWithAttchments(String Message, String contactId, List<String> lstDocumentId){
        try {
            System.debug('document ids : ' + lstDocumentId);
            System.debug('message : ' + Message);
            System.debug('contact id : ' + contactId);
            if(message==null) message ='Hi, We have sent documents kindly review...!!!';
            if(lstDocumentId.size() > 0) {
                List<ContentVersion> lstAttachments = [SELECT VersionData, FileType, Title, ContentSize, ContentDocumentId, PathOnClient, FirstPublishLocationId
                                                       FROM ContentVersion WHERE Id IN: lstDocumentId];
                
                Account con = [Select Id, WhatsApp_No__c, Name from Account WHERE Id = :contactId];
                if (con.WhatsApp_No__c != null && con.WhatsApp_No__c.length() == 10) {
                    con.WhatsApp_No__c = '91' + con.WhatsApp_No__c;
                }
                
                List<Map<String, Object>> lstMessages = new List<Map<String, Object>>();
                
                Attachment[] attachmentlist = new Attachment[]{};
                    String EndPoint = 'https://app.whatsera.com/api/send/attach/doc';
                Integer index = 1;
                Whatsapp_Text__c text = new Whatsapp_Text__c();
                text.Sent_To__c = con.WhatsApp_No__c;
                text.Message_Type__c = 'Outbound';
                text.Delivery_Status__c = 'In-Queue';
                text.Text__c = Message;
                text.Account__c = ContactId;
                  text.User__c = userInfo.getUserId();
                insert text;
                list<ContentDocumentLink> conlink=New List<ContentDocumentLink>();
                    
                for(ContentVersion item : lstAttachments) {
                    ContentDocumentLink cdl2 = new ContentDocumentLink();
                    cdl2.ContentDocumentId = item.ContentDocumentId;
                    cdl2.LinkedEntityId = ContactId;
                    cdl2.ShareType = 'V'; 
                    cdl2.Visibility = 'AllUsers'; 
                    conlink.add(cdl2);
                    
                    Attachment attachment = new Attachment();
                    attachment.Name = item.PathonClient.remove('/') ;// System.label.AtachmentName+' '+contentVersion.PathonClient+'.'+contentVersion.FileType;
                    //   attachment.Title = contentVersion.Title;
                    attachment.Body = item.VersionData; 
                    attachment.ParentId = text.Id; // Specify the Id of the record to attach the file to 
                    attachmentlist.add(attachment);
                    /*   String fileName = item.PathonClient;
String fileContent = EncodingUtil.base64Encode(item.VersionData);
Blob formData = HttpHexFormBuilder.build().writeParam('accessToken', system.label.Whatsera_Send_Sms).writeParam('mobile', con.WhatsApp_No__c).writeParam('caption', '').writeFile('file', fileName, fileContent).getFormAsBlob();
HttpRequest request = new HttpRequest();
request.setEndpoint('https://app.whatsera.com/api/send/attach/doc');
request.setMethod('POST');
request.setHeader('Connection', 'keep-alive');
request.setHeader('Content-Length', String.valueOf(formData.size()));
request.setHeader('Content-Type', HttpHexFormBuilder.GetContentType());
request.setBodyAsBlob(formData);
request.setTimeout(120000);
Http http = new Http();
if(!Test.isRunningTest()){
HttpResponse response = http.send(request);
system.debug(response);
}*/
                    
                    /*String caption = Message == null ? item.Title : Message;

Map<String, Object> mapMessage = new Map<String, Object>();
mapMessage.put('phone', con.WhatsApp_No__c);
mapMessage.put('content', EncodingUtil.base64Encode(item.VersionData));
if(index == 1) mapMessage.put('caption', caption);
else mapMessage.put('caption', caption);
mapMessage.put('fileName', item.Title);

lstMessages.add(mapMessage);

index += 1;*/
                }
                
                /* String requestBody = JSON.serialize(lstMessages);
System.debug('@@ Request Body : ' + requestBody);
System.debug('@@ Request Body : ' + lstMessages.size());

HttpRequest request = new HttpRequest();
request.setMethod('POST');
request.setHeader('access-token', system.label.Whatsera_Send_Sms);
request.setHeader('Content-Type', 'application/json');
request.setTimeout(120000);
request.setEndpoint(EndPoint);
request.setBody(requestBody);

HttpResponse response = new Http().send(request);
System.debug('response.getBody()'+response.getBody());*/
                
                
                List<ContentDocumentLink> lstNDocumentLink = new List<ContentDocumentLink> ();
                for(ContentVersion item : lstAttachments) {
                    ContentDocumentLink newDocumentLink = new ContentDocumentLink();
                    newDocumentLink.LinkedEntityId = text.Id;
                    newDocumentLink.ContentDocumentId = item.ContentDocumentId;
                    
                    lstNDocumentLink.add(newDocumentLink);
                } 
                   if(lstNDocumentLink.Size()>0)  insert lstNDocumentLink;
              if(attachmentlist.Size()>0)  insert attachmentlist;
                 if(conlink.Size()>0)  Database.SaveResult[] saveResults = Database.insert(conlink, false);
            }
            return 'success';
        } catch (Exception e){
            System.debug('@@ Send Message with Attachment error message: ' + e.getMessage());
            System.debug('@@ Send Message with Attachment error line number: ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /* @AuraEnabled
public static string getAttachmentLink(String recordId){        
String imageUrl = 'https://finhaatinsurancebrokingpvtltd--subhadeep1.sandbox.my..salesforce.com/sfc/servlet.shepherd/version/download/' + recordId;
return imageUrl;
}*/
    
    @AuraEnabled
    public static string SendTemplate(String TemplateId, String ContactId, String Message) {
        try {
            Whatsapp_Templates__c Template = [SELECT Id, Name, Text__c FROM Whatsapp_Templates__c WHERE Id =: TemplateId];
            
            List<ContentDocumentLink> lstDocumentLink = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: TemplateId];
            
            Set<String> setContentDocumentId = new Set<String> ();
            for(ContentDocumentLink item : lstDocumentLink) {
                setContentDocumentId.add(item.ContentDocumentId);
            }
            
            List<ContentVersion> lstAttachments = [SELECT VersionData, FileType, Title, ContentSize, ContentDocumentId, PathOnClient, FirstPublishLocationId
                                                   FROM ContentVersion WHERE ContentDocumentId IN: setContentDocumentId];
            
            Message = Message == null ? Template.Text__c : Message;
            
            Account con = [SELECT Id, WhatsApp_No__c FROM Account WHERE Id =: ContactId];
            if (con.WhatsApp_No__c != null && con.WhatsApp_No__c.length() == 10) {
                con.WhatsApp_No__c = '91' + con.WhatsApp_No__c;
            }
            
            List<Map<String, Object>> lstMessages = new List<Map<String, Object>>();
            
            String EndPoint = '';
            if(lstAttachments.size() > 0) {
                EndPoint = System.label.Whatsera_Send_Sms_EndPoint + '/api/send/attach/doc';
                Integer index = 1;
                for(ContentVersion item : lstAttachments) {
                    Map<String, Object> mapMessage = new Map<String, Object>();
                    mapMessage.put('phone', con.WhatsApp_No__c);
                    mapMessage.put('contentType', '2');
                    mapMessage.put('content', EncodingUtil.base64Encode(item.VersionData));
                    if(index == 1) mapMessage.put('caption', Message);
                    else mapMessage.put('caption', item.PathOnClient);
                    mapMessage.put('fileName', item.PathOnClient);
                    
                    lstMessages.add(mapMessage);
                    
                    index += 1;
                }
            } else {
                EndPoint = System.label.Whatsera_Send_Sms_EndPoint+ '/api/send/text';
                
                Map<String, Object> mapMessage = new Map<String, Object>();
                mapMessage.put('dst', con.WhatsApp_No__c);
                mapMessage.put('messageType', 0);
                
                Map<String, String> mapContent = new Map<String, String>();
                mapContent.put('content', Message);
                
                mapMessage.put('textMessage', mapContent);
                lstMessages.add(mapMessage);
            } 
            
            String requestBody = JSON.serialize(lstMessages);
            System.debug('@@ Request Body : ' + requestBody);
            System.debug('@@ Request Body : ' + lstMessages.size());
            
            HttpRequest request = new HttpRequest();
            request.setEndpoint(System.label.Whatsera_Send_Sms_EndPoint+ '/api/send/text');
            request.setMethod('POST');
            request.setTimeout(120000);
            request.setHeader('Content-Type', 'Application/json');
            request.setBody(requestBody);
            
            
            
          //  HttpResponse response = new Http().send(request);
         //   System.debug(response.getBody());
            
            
            
            Whatsapp_Text__c text = new Whatsapp_Text__c();
            text.Sent_To__c = con.WhatsApp_No__c;
            text.Message_Type__c = 'Outbound';
            text.User__c = userInfo.getUserId();
            text.Delivery_Status__c ='In-Queue';
            text.Text__c = Message;
            text.Account__c = ContactId;
            insert text;
              list<ContentDocumentLink> conlink=New List<ContentDocumentLink>();
                  Attachment[] attachmentlist = new Attachment[]{};
            for(ContentVersion item : lstAttachments) {
               ContentDocumentLink cdl2 = new ContentDocumentLink();
                    cdl2.ContentDocumentId = item.ContentDocumentId;
                    cdl2.LinkedEntityId = ContactId;
                    cdl2.ShareType = 'V'; 
                    cdl2.Visibility = 'AllUsers'; 
                    conlink.add(cdl2);
                    
                    Attachment attachment = new Attachment();
                       attachment.Name = item.PathonClient ;//System.label.AtachmentName+' '+contentVersion.PathonClient+'.'+contentVersion.FileType;
                    //   attachment.Title = contentVersion.Title;
                    attachment.Body = item.VersionData; 
                    attachment.ParentId = text.Id; // Specify the Id of the record to attach the file to 
                    attachmentlist.add(attachment);  
                
            }
            List<ContentDocumentLink> lstNDocumentLink = new List<ContentDocumentLink> ();
            for(ContentDocumentLink item : lstDocumentLink) {
                ContentDocumentLink newDocumentLink = new ContentDocumentLink();
                newDocumentLink.LinkedEntityId = text.Id;
                newDocumentLink.ContentDocumentId = item.ContentDocumentId;
                
                lstNDocumentLink.add(newDocumentLink);
            } 
            
            insert lstNDocumentLink;
            if(attachmentlist.Size()>0)  insert attachmentlist;
             if(conlink.Size()>0)  Database.SaveResult[] saveResults = Database.insert(conlink, false);
            return 'success';
        } catch(Exception e) {
            System.debug('@@ Send Template error message : ' + e.getMessage());
            System.debug('@@ Send Template error line number : ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    @AuraEnabled
    public static List<Whatsapp_Templates__c> getTemplates() {
        try {
            return [SELECT Id, Name, Text__c FROM Whatsapp_Templates__c ORDER BY Name];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public class WhatsAppApiResponse{
        public String status, responseMessage, id;
        public Integer messageId;
    }
    
    public class fileWrapper{
        public String Title, link, Id;
        public fileWrapper(ContentDocumentLink conDocList){
            this.Title = conDocList.ContentDocument.Title;
            this.link = '/' + conDocList.ContentDocumentId;
            this.Id = conDocList.ContentDocumentId;
        }
    }
    
    public class chatDetailWrapper{
        public String shortName, startedcontactName, endedcontactName;
        public Datetime startedDateTime, endedDateTime;
        public list<chatWrapper> chats = new list<chatWrapper>();
    }
    
    public class chatWrapper{
        public String message, createdBy, Id, name;
        public Boolean inbound, mediaMsg = false;
        public list<fileWrapper> files = new list<fileWrapper>();
        public Datetime chatDateTime;
        
        public chatWrapper(Whatsapp_Text__c chat, list<ContentDocumentLink> conDocList, String accName){
            this.message = chat.Text__c;
            this.inbound = chat.Message_Type__c == 'Incoming' ? true : false;
            this.Id = chat.Id;
            this.chatDateTime = chat.CreatedDate;
            this.createdBy = chat.Owner.Name;
            this.name = accName;
            if (conDocList.size() != 0){
                this.mediaMsg = true;
                for (ContentDocumentLink condoc : conDocList){
                    this.files.add(new fileWrapper(condoc));
                }
            }
        }
    }
    
    
}