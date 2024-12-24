//Last Modified By : Abdul Aziz , Date : 04/05/2024 , Add Rejected Docs also in list
global without sharing class Account_Required_Doc {
    
    public String rid;
    public list<wrap_files> wrap_doc_list{get;set;}
    
    public Account_Required_Doc(ApexPages.StandardController controller) {
        rid= ApexPages.CurrentPage().getParameters().get('id');
        
        wrap_doc_list= new list<wrap_files>();
        
        list<Required_Documents__c> rd_list= [select id , name, Account__c,Colour_Status__c,Comments__c,Doc_Link__c,Doc_Link_F__c,Doc_Name__c,
                                              Doc_Type__c,Instruction__c,RecordTypeId,Rejected__c,Rejected_Reason__c,Stages__c,Status__c from Required_Documents__c where
                                              Account__c =:rid and (Status__c='Yet to Submit' OR Status__c = 'Rejected')];
        
        for(Required_Documents__c rd : rd_list){
            wrap_files doc = new wrap_files(rd);
            wrap_doc_list.add(doc);
        }
        system.debug('Wrap list'+wrap_doc_list);
    }
    
    /*@future(callout = true)
public static void makecall(string rid,string doclink,string comment) {
string cKey='3MVG9fe4g9fhX0E6u_KuA_kXed4T99.sy1U7lx3P_oh_7R0hplk6YzGUDmq_aePc6UN80GtXc5ET1t4Yd0trI';
string cSecret='010D60C19B0DBBDFFF4CC8F032B213BAC8C8CC98CC30389421314AC7DE63B970';
string uName='s@edu.com';
string passwd='cloud@123';

string reqBody = 'grant_type=password&client_id=' + cKey + '&client_secret=' + cSecret + '&username=' + uName + '&password=' + passwd;

Http h = new Http();
HttpRequest req = new HttpRequest();
req.setBody(reqBody);
req.setMethod('POST');
req.setEndpoint('https://login.salesforce.com/services/oauth2/token');

HttpResponse hresp = h.send(req);
responseWrapper wResp = (responseWrapper) JSON.deserialize(hresp.getBody(), responseWrapper.class);
system.debug('Instance url' + wResp.instance_url);
system.debug('session id' + wResp.access_token);

string updatebody='{"Comments__c":'+'"'+comment+'"'+',"Status__c" : "Submitted","Doc_Link__c" : '+'"'+doclink+'"'+'}';
system.debug('final reqbody-'+updatebody);

string endPoint = wResp.instance_url+'/services/data/v36.0/sobjects/Required_Documents__c/'+rid;
system.debug('recordId-'+rid);
Http h1 = new Http();
HttpRequest req1 = new HttpRequest();
req1.setHeader('Authorization', 'Bearer ' + wResp.access_token);
req1.setHeader('Content-Type', 'application/json');
req1.setBody(updatebody);
//req1.setHeader('X-HTTP-Method-Override','PATCH');
req1.setMethod('POST');
req1.setEndpoint(endPoint+'?_HttpMethod=PATCH');
HttpResponse hresp1 = h1.send(req1);
system.debug('final response'+hresp1.getStatus());
system.debug('response code-'+hresp1.getStatusCode());
}*/
    
    public pageReference SaveRecords() {
        system.debug('=================== SaveRecords() ===================');
        
        try{
            
            
            /*List<Required_Documents__c> documents = new List<Required_Documents__c> ();
List<ContentVersion> cv_list = new List<ContentVersion> ();
List<ContentDocumentLink> cdl_list = new List<ContentDocumentLink> ();
for(wrap_files docs : wrap_doc_list) {
System.debug('doc number : ' + docs.doc_no);
if(docs.file_content != null) {
System.debug('file name : ' + docs.file_name);
String filename = docs.file_name;
String extension = '';
if(filename.contains('.')) {
List<String> temp = filename.split('\\.');
System.debug('temp size : ' + temp.size());
System.debug('temp : ' + temp);
extension = temp[temp.size() - 1];
}

String new_filename = docs.doc_no + '_' + docs.doc_name + '.' + extension;
System.debug('new_filename : ' + new_filename);
System.debug('file_content for version data : ' + docs.file_content);

ContentVersion v = new ContentVersion();
v.VersionData = docs.file_content; 
v.title = new_filename;
v.pathOnClient ='/' + new_filename;
v.FirstPublishLocationId = docs.rd_id;
cv_list.add(v);

system.debug('cvList : ' + cv_list);
}                
}
insert cv_list;

List<ContentDistribution> cd_list = new List<ContentDistribution> ();
for(ContentVersion cv : cv_list) {
ContentDistribution cd = new ContentDistribution(
Name = cv.title,
ContentVersionId = cv.Id,
PreferencesAllowViewInBrowser= true

);
cd_list.add(cd);

ContentDocumentLink cdl = new ContentDocumentLink();
//cdl.ContentDocumentId = cv.ContentDocumentId;
cdl.LinkedEntityId = rid;
cdl.ShareType='V';
cdl.ContentDocumentId=[SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;


cdl_list.add(cdl);
}
insert cd_list;
insert cdl_list;

List<ContentDistribution> NEW_CD_LIST = [SELECT Id, Name, DistributionPublicUrl, ContentDownloadUrl, PdfDownloadUrl, ContentVersionId 
FROM ContentDistribution WHERE Id IN: cd_list];

Map<String, String> MAP_CD = new Map<String, String> ();
for(ContentDistribution cd : NEW_CD_LIST) {
MAP_CD.put(cd.Name, cd.DistributionPublicUrl);
}



for(wrap_files docs : wrap_doc_list) {
if(docs.file_content != null) {
System.debug('file name : ' + docs.file_name);
String filename = docs.file_name;
String extension = '';
if(filename.contains('.')) {
List<String> temp = filename.split('\\.');
System.debug('temp size : ' + temp.size());
System.debug('temp : ' + temp);
extension = temp[temp.size() - 1];
}

String new_filename = docs.doc_no + '_' + docs.doc_name + '.' + extension;
System.debug('new_filename : ' + new_filename);


Required_Documents__c rd = docs.rd;
rd.Comments__c=docs.Comments;

//  rd.Comments__c= docs.rd.Comments__c;
system.debug('Comments'+docs.Comments);
rd.Doc_Name__c = new_filename;
rd.Status__c = 'Submitted';
rd.Doc_Link__c = MAP_CD.containsKey(new_filename) ? MAP_CD.get(new_filename) : 'none';
documents.add(rd);
string doclink=MAP_CD.containsKey(new_filename) ? MAP_CD.get(new_filename) : 'none';
string commentonpage=docs.Comments;
system.debug('comment-'+commentonpage);




Account_Required_Doc.makecall(docs.rd.id, doclink, commentonpage) ;                   
update rd;


}

}*/
            for(wrap_files docs : wrap_doc_list) {
                
                if(docs.file_content != null) {
                    System.debug('file name : ' + docs.file_name);
                    String filename = docs.file_name;
                    String extension = '';
                    if(filename.contains('.')) {
                        List<String> temp = filename.split('\\.');
                        System.debug('temp size : ' + temp.size());
                        System.debug('temp : ' + temp);
                        extension = temp[temp.size() - 1];
                        system.debug('extension-'+extension);
                    }
                    
                    String new_filename = docs.doc_no + '_' + docs.doc_name + '.' + extension;
                    System.debug('new_filename : ' + new_filename);
                    System.debug('file_content for version data : ' + docs.file_content);
                    
                    ContentVersion v = new ContentVersion();
                    v.VersionData = docs.file_content; 
                    v.title = new_filename;
                    v.pathOnClient ='/' + new_filename;
                    v.FirstPublishLocationId = docs.rd_id;
                    
                    Attachment att=new Attachment();
                    att.Body=docs.file_content;
                    att.Name=new_filename;
                    // att.ContentType=extension;
                    att.ParentId=docs.rd.id;
                    
                    insert att;
                    Required_Documents__c rd = docs.rd;
                    rd.Comments__c=docs.Comments;
                    rd.Status__c = 'Submitted';
                    // rd.Doc_Link__c='https://finhaatinsurancebrokingpvtltd--subhadeep1.sandbox.my.salesforce.com/servlet/servlet.FileDownload?file='+att.id;
                    //For Production
                    rd.Doc_Link__c='https://finhaatinsurancebrokingpvtltd.lightning.force.com/servlet/servlet.FileDownload?file='+att.id;
                    //for sandox
                    //rd.Doc_Link__c=URL.getSalesforceBaseUrl().toExternalForm()+'/servlet/servlet.FileDownload?file='+att.id;
                    
                    update rd; 
                    
                } 
                
            }
            
            //if(documents.size() > 0) update documents;
            
            pageReference pageref = new pageReference(URL.getSalesforceBaseUrl().toExternalForm()+'/apex/ThankYOuPage');
            
            return pageref;
        }
        catch(Exception e2) {
            system.debug('error line number : ' + e2.getLineNumber());
            system.debug('error message : ' + e2.getMessage());
            pageReference pageref = new pageReference(URL.getSalesforceBaseUrl().toExternalForm()+'/apex/ThankYOuPage');
            
            return pageref;
        } 
    }
    
    // WRAPPER CLASS
    public class wrap_files {
        public Id rd_id {get; set;}
        public String doc_name {get; set;}
        public String instruction {get; set;}
        public String Comments {get; set;}
        public String Rej_reas {get; set;}
        public String doc_no {get; set;}
        public Required_Documents__c rd {get; set;}
        public Blob file_content {get; set;}
        public String file_name {get; set;}
        public Id cv_id {get; set;}
        public Id cd_id {get; set;}
        
        public wrap_files(Required_Documents__c doc) {
            rd = doc;
            doc_name = doc.Doc_Type__c;
            rd_id = doc.Id;
            doc_no = doc.Name;
            Rej_reas = doc.Rejected_Reason__c;
            instruction=doc.Instruction__c;
        }
    }
    
    public class responseWrapper {
        public string id;
        public string access_token;
        public string instance_url;
    }
}