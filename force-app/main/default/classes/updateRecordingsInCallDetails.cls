global class updateRecordingsInCallDetails implements Database.Batchable<SObject>,Queueable, Database.AllowsCallouts {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        if(!Test.isRunningTest()){
            String query = 'SELECT Id,Call_From__c,OwnerId,CreatedDate,Recording_File__c  From Call_Detail__c WHERE Recording_File__c != null ORDER BY CreatedDate DESC';
            return Database.getQueryLocator(query);
        }
        
        String query = 'SELECT Id,Call_From__c,OwnerId,Recording_File__c  From Call_Detail__c WHERE Recording_File__c != null LIMIT 1';
        return Database.getQueryLocator(query);               
    }
    
    global void execute(Database.BatchableContext BC, List<Call_Detail__c> scope) {
        
        for(Call_Detail__c callDetail : scope){
            
            System.enqueueJob(new updateRecordingsInCallDetails(callDetail.Recording_File__c, callDetail.Id));
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
    private String recordingUrl;
    private String linkedId;
    
    public updateRecordingsInCallDetails(String recordingUrl, String linkedId) {
        this.recordingUrl = recordingUrl;
        this.linkedId = linkedId;
    }
    
    public void execute(QueueableContext context) {
        if (String.isNotBlank(recordingUrl)) {
            try {
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(recordingUrl);
                request.setMethod('GET');
                HttpResponse response = http.send(request);
                
                if (response.getStatusCode() == 200) {
                    ContentVersion contentVersion = new ContentVersion();
                    contentVersion.Title = 'Call Recording.wav';
                    contentVersion.PathOnClient = 'Call Recording.wav';
                    contentVersion.VersionData = response.getBodyAsBlob();
                    contentVersion.FirstPublishLocationId = linkedId;
                    insert contentVersion;
                }
            } catch (Exception e) {
                System.debug('Error in getRecording: ' + e.getMessage());
            }
        }
    } 
}