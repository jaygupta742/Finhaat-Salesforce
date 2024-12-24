// Dont't do any modification this class it using in send whats app notification from Account and Ticket and Also from when account stage changes then whats app notification is sending
// Last modified by: Sougata Paul; Last modfied on : 19-06-2024;When whatsapp message send Last whatsapp message is updated
public Without sharing class Send_Wap_Class{
    @future(callout = true)
    public static void send_wap(string mobileno, String textsms, String objectname, String ids, String[] docid){
        
        try{
            // Account ac = [select id,LastName,FirstName,PersonMobilePhone from Account where id=:recId ];
            system.debug('The mobile no  is : ' + mobileno);
            system.debug('The text sms  is : ' + textsms);
            system.debug('The docid docid  is : ' + docid.Size());
            if ( mobileno != '' && mobileno != null ){
                // SET JSON BODY  //
                mobileno = mobileno.replaceAll('[^\\d]', '');
                mobileno = mobileno.length() > 10 ? mobileno.substring(mobileno.length() - 10) : mobileno;
                mobileno = '91' + mobileno;
                
                Map<String, Object> mapBody = new Map<String, Object>();
                mapBody.put('accessToken', System.label.Whatsera_Send_Sms);
                mapBody.put('mobile', mobileno);
                mapBody.put('text', textsms);
                
                String jsonBody = JSON.serialize(mapBody);
                system.debug('The JSON BODY is : ' + jsonBody);
                system.debug('The End Point  is : ' + System.label.Whatsera_Send_Sms_EndPoint);
                system.debug('The AccessToken is : ' + System.label.Whatsera_Send_Sms);
                
                // MAKE HTTP REQUEST  //
                /*HttpRequest request = new HttpRequest();
                request.setEndpoint(System.label.Whatsera_Send_Sms_EndPoint);
                request.setMethod('POST');
                request.setHeader('Content-Type', 'Application/json');
                request.setBody(jsonBody);
                Http hnew = new Http();
                HTTPResponse response = hnew.send(request);
                System.debug('response status code : ' + response.getStatusCode());
                System.debug('response status : ' + response.getStatus());
                System.debug('response body : ' + response.getBody());
                map<String, Object> get_res = (Map<String, Object>)JSON.Deserializeuntyped(response.getBody());*/
                Whatsapp_Text__c aa = New Whatsapp_Text__c();
                aa.Msg_Sent__c = false;
                aa.Delivery_Status__c = 'In-Queue';
                // aa.Id__c ='12345567890';
                aa.Message_Type__c = 'Outbound';
                aa.Text__c = textsms;
                aa.user__c = userinfo.getUserid();
                if ( objectname == 'Account' )   aa.Account__c = ids;
                if(objectname == 'Contact'){
                    aa.Contact__c = ids;
                    Contact t= [Select id,AccountId From Contact where id =: ids]; 
                    aa.Account__c = t.AccountId;
                }
                if ( objectname == 'Ticket__c' ){
                    system.debug('inside ticket---->'+ids);
                    Ticket__c t= [Select id,Account__c From Ticket__c where id =: ids]; 
                      aa.Ticket__c = ids;
                     aa.Account__c = t.Account__c;
                    t.Last_Whatsapp_Sent_On__c = system.now();
                    update t;
                }
                  
                aa.Sent_To__c = mobileno;
                
                insert aa;
                //  Database.commit();
                if ( docid.Size() >0 ){
                    MyQueueablesenddoc myQueueableInstance = new MyQueueablesenddoc(aa.id,ids, docid,mobileno);  
                    System.enqueueJob(myQueueableInstance);
                    /*  ContentVersion[] contentVersionlist = [SELECT Id, Title, FileType, ContentDocumentId, VersionData, PathonClient
FROM ContentVersion
WHERE ContentDocumentId IN:docid
];
Attachment[] attachmentlist = new Attachment[]{};
system.debug(' contentVersion ' + contentVersionlist.SIZE());
For(ContentVersion ContentVersion:contentVersionlist){
Attachment attachment = new Attachment();
attachment.Name = contentVersion.Title + '.' + contentVersion.FileType;
attachment.Body = contentVersion.VersionData; 
attachment.ParentId = aa.id; // Specify the Id of the record to attach the file to 
attachmentlist.add(attachment);
String fileName = contentVersion.PathonClient;
String fileContent = EncodingUtil.base64Encode(contentVersion.VersionData);
Blob formData = HttpHexFormBuilder.build().writeParam('accessToken', '65d4491e913949c6cd70b9f6').writeParam('mobile', mobileno).writeParam('caption', attachment.Name + ' ' + Date.today().format()).writeFile('file', fileName, fileContent).getFormAsBlob();
system.debug(formData + ' formData ');
request = new HttpRequest();
request.setEndpoint('https://whatsera.com/api/send/attach/doc');
request.setMethod('POST');
request.setHeader('Connection', 'keep-alive');
request.setHeader('Content-Length', String.valueOf(formData.size()));
request.setHeader('Content-Type', HttpHexFormBuilder.GetContentType());
request.setBodyAsBlob(formData);
Http http = new Http();
response = http.send(request);
system.debug(response);

}
insert attachmentlist;
system.debug('insert attachmentlist '+attachmentlist);*/
                }
                // aa.Message_Id__c ='5345325435423423515135241';
                
                
            }
        } catch ( Exception e ){
            System.debug('error in Send_Wap_Class send method');
            System.debug('error message: ' + e.getMessage());
            System.debug('error line number: ' + e.getLineNumber());
            
            
        }
    }
    
}