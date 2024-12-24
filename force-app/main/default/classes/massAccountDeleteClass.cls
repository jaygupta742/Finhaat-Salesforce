public class massAccountDeleteClass {
	Public static List<String> recordIdList{get;set;}
    public massAccountDeleteClass(ApexPages.StandardSetController controller){
        recordIdList = new List<String>();
        for(sObject acc : controller.getSelected()){
            recordIdList.add(acc.Id);
            system.debug('recIdList '+recordIdList);
        }
    }
    @AuraEnabled
    Public static string deleteAccounts(List<String> accIds){
        List<Account> accountsToDelete = [SELECT Id FROM Account WHERE Id IN :accIds];
        system.debug('accountsToDelete '+accountsToDelete);
        if(accountsToDelete.size()>0){
            delete accountsToDelete;
            return 'Success';
        }
        return 'Fail';
    }
}