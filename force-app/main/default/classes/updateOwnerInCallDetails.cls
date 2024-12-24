global class updateOwnerInCallDetails implements Database.Batchable<SObject> {
    
    global String query = 'SELECT Id,Call_From__c,OwnerId,CreatedDate  From Call_Detail__c WHERE OwnerId = \'0055j00000CCvzaAAD\' ORDER BY CreatedDate DESC';
    
    global updateOwnerInCallDetails(String query){
        if(query != ''){
            this.query = query;
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Query all Call_Detail__c records, assuming you want to process all records
        // For test, limit to 10 records
        if (!Test.isRunningTest()) {
            return Database.getQueryLocator(this.query);
        }
        
        String query = 'SELECT Id, Call_From__c, OwnerId FROM Call_Detail__c LIMIT 1';
        return Database.getQueryLocator(query);               
    }
    
    global void execute(Database.BatchableContext BC, List<Call_Detail__c> scope) {
        
        List<Call_Detail__c> tobeUpdatedRecords = new List<Call_Detail__c>();
        
        for (Call_Detail__c log : scope) {
            String userPhone = '%' + log.Call_From__c + '%';
            try{
                User userRecord = [SELECT Name 
                                   From User 
                                   WHERE MobilePhone 
                                   LIKE : userPhone OR Phone LIKE : userPhone];
                
                log.OwnerId = userRecord.Id;
                tobeUpdatedRecords.add(log);
            }catch(exception e){
                system.debug(log.Call_From__c + 'Not Found');
            }
        }
        
        if (!tobeUpdatedRecords.isEmpty()) {
            update tobeUpdatedRecords;
        }
    }

    global void finish(Database.BatchableContext BC) {
        // Any post-processing logic can be added here
    }
}