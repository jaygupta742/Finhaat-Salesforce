public class massOpportunityDeleteClass {
Public static List<String> recordIdList{get;set;}
    public massOpportunityDeleteClass(ApexPages.StandardSetController controller){
        recordIdList = new List<String>();
        for(sObject acc : controller.getSelected()){
            recordIdList.add(acc.Id);
            system.debug('recIdList '+recordIdList);
        }
    }
    @AuraEnabled
    Public static string deleteOpportunities(List<String> oppIds){
        List<Opportunity> opportunititesToDelete = [SELECT Id FROM Opportunity WHERE Id IN :oppIds];
        system.debug('opportunititesToDelete '+opportunititesToDelete);
        if(opportunititesToDelete.size()>0){
            delete opportunititesToDelete;
            return 'Success';
        }
        return 'Fail';
    }
}