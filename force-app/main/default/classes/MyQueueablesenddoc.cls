// this class is used in send whats app notification for attachments 
public class MyQueueablesenddoc implements Queueable {
    private String myString,parrentid;
    private String mobileno;
    private List<Id> myIdList;
    
    // Constructor to initialize the parameters
    public MyQueueablesenddoc(String str,String ids, List<Id> idList,string mobile) {
        this.myString = str;
        this.myIdList = idList;
        this.mobileno = mobile;
        this.parrentid = ids;
    }
    public void execute(QueueableContext context) {
        sendHttpRequest( this.myString, this.parrentid,   this.myIdList ,    this.mobileno);
    }
    @future(callout=true)
    public static void sendHttpRequest(String myString ,string parrentid, list<id>myIdList, String mobileno) { 
        System.debug('String parameter: ' + myString);
        System.debug('List of IDs parameter: ' + myIdList);
        
       list< ContentVersion> contentVersionlist = [SELECT Id, Title, FileType,PathOnClient, FileExtension,ContentDocumentId, VersionData
                                               FROM ContentVersion
                                               WHERE ContentDocumentId IN:myIdList
                                              ];
        
        List<ContentVersion>  newlsit= new List<ContentVersion>();
        For(ContentVersion cv:contentVersionlist){
          ContentVersion cv1=New ContentVersion();
            
            cv1.Title =System.label.AtachmentName+' '+cv.Title;
            cv1.PathOnClient = cv.PathOnClient ;
            cv1.ContentDocumentId = cv.ContentDocumentId;
            cv1.VersionData = cv.VersionData;
            newlsit.add(cv1);
           // cv1.FileType = cv.FileType;
            //cv1.FileExtension = cv.FileExtension;
        }
        insert newlsit;
        
        ContentVersion[] newlsit1 = [SELECT Id, Title, FileType,PathOnClient, FileExtension,ContentDocumentId, VersionData
                                               FROM ContentVersion
                                               WHERE id IN:newlsit
                                              ];
        Attachment[] attachmentlist = new Attachment[]{};
            system.debug(' newlsit1 ' + newlsit1.SIZE());
        list<ContentDocumentLink> conlink=New List<ContentDocumentLink>();
        For(ContentVersion ContentVersion:newlsit1){
            
            ContentDocumentLink cdl2 = new ContentDocumentLink();
            cdl2.ContentDocumentId = ContentVersion.ContentDocumentId;
            cdl2.LinkedEntityId = parrentid;
            cdl2.ShareType = 'I'; 
            cdl2.Visibility = 'AllUsers'; 
            conlink.add(cdl2);
            
            Attachment attachment = new Attachment();
            attachment.Name = contentVersion.PathonClient;
            attachment.Body = contentVersion.VersionData; 
            attachment.ParentId = myString; // Specify the Id of the record to attach the file to 
            attachmentlist.add(attachment);
            String fileName = contentVersion.PathonClient;
            String fileContent = EncodingUtil.base64Encode(contentVersion.VersionData); //attachment.Name + ' ' + Date.today().format()
            Blob formData = HttpHexFormBuilder.build().writeParam('accessToken', '65d4491e913949c6cd70b9f6').writeParam('mobile', mobileno).writeParam('caption','' ).writeFile('file', fileName, fileContent).getFormAsBlob();
            system.debug(formData + ' formData ');
            HttpRequest request = new HttpRequest();
            request = new HttpRequest();
            request.setEndpoint('https://whatsera.com/api/send/attach/doc');
            request.setMethod('POST');
            request.setHeader('Connection', 'keep-alive');
            request.setHeader('Content-Length', String.valueOf(formData.size()));
            request.setHeader('Content-Type', HttpHexFormBuilder.GetContentType());
            request.setBodyAsBlob(formData);
            Http http = new Http();
            //HTTPResponse  response = http.send(request);
            //system.debug(response);
            
        }
        insert attachmentlist;
        
        try{   Database.SaveResult[] saveResults = Database.insert(conlink, false);
       //   delete  contentVersionlist;
            system.debug('attach doc list '+conlink.Size());
           }catch(Exception e){
               
           }
        // Queue the next job if needed
    }
}