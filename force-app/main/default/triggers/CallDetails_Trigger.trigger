trigger CallDetails_Trigger on Call_Detail__c (after insert, after update) {
    
    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            List<SObject> SobjList = new List<SObject>();
            for (Call_Detail__c cd : Trigger.new) {
                if (cd.Account__c != null) {
                    Account acc = new Account();
                    acc.Id = cd.Account__c;
                    acc.Last_Call_Date_Time__c = cd.Start_Time__c;
                    acc.Last_Call_Status__c = cd.Status__c;
                    SobjList.add(acc);
                } else if (cd.Contact__c != null) {
                    Contact con = new Contact();
                    con.Id = cd.Contact__c;
                    con.Last_Call_Date_Time__c = cd.Start_Time__c;
                    con.Last_Call_Status__c = cd.Status__c;
                    SobjList.add(con);
                }
            }
            
            if (!SobjList.isEmpty()) {
                Database.Upsert(SobjList, false);
            }
        }
    }
    
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        Map<Id, Call_Detail__c> mapofOldCallDetail = Trigger.oldMap;
        
        for (Call_Detail__c newCallDetail : Trigger.new) {
            Call_Detail__c oldCallDetail = (mapofOldCallDetail != null) ? mapofOldCallDetail.get(newCallDetail.Id) : null;
            
            if (oldCallDetail == null || oldCallDetail.Recording_File__c != newCallDetail.Recording_File__c) {
                CallDetails_Handler.getRecording(newCallDetail.Recording_File__c, newCallDetail.Id);
            }
        }
    }
}