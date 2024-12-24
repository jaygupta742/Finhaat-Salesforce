public without sharing class CallDetails_Handler {
    
    @future(callout=true)
    public static void getRecording(String recordingUrl, String linkedId) {
        if (String.isNotBlank(recordingUrl)) {
            try {
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(recordingUrl);
                request.setMethod('GET');
                HttpResponse response = http.send(request);
                
                if (response.getStatusCode() == 200) {
                   	AddFilesInFinhaatLibrary_handler.runOn = true;
                    ContentVersion contentVersion = new ContentVersion();
                    contentVersion.Title = 'Call Recording.wav';
                    contentVersion.PathOnClient = 'Call Recording.wav';
                    contentVersion.VersionData = response.getBodyAsBlob();
                    contentVersion.FirstPublishLocationId = linkedId;
                    insert contentVersion;
                    
                    contentVersion = [SELECT Id,ContentDocumentId From contentVersion WHERE Id =: contentVersion.Id];
                    String link = '/sfc/servlet.shepherd/document/download/'+contentVersion.ContentDocumentId;
                    
                    Call_Detail__c callDetail = new Call_Detail__c();
                    callDetail.Id = linkedId;
                    callDetail.Org_Recording_Link__c = link;
                    update callDetail;
                    
                }
            } catch (Exception e) {
                System.debug('Error in getRecording: ' + e.getMessage());
            }
        }
    }
    
}