// Created By vishal singh, On 02-05-2024
@isTest(SeeAllData=true)
private class massOpportunityDeleteClass_Test {
    
    @isTest
    public static void testRecordIdListPopulation() {
         List<Account> accountsToTest = new List<Account>{ new Account(Name = 'Test Account 1'), new Account(Name = 'Test Account 2') };
            
            list<String> listOfAccountInJson = new list<String>();
        
        insert accountsToTest;
        List<Opportunity> oppListToTest = new List<Opportunity>{new Opportunity(Name = 'Test Opp 1', StageName = 'StageName', AccountId = accountsToTest[0].Id, CloseDate = Date.today().addDays(30))};
        insert oppListToTest;
        for(Opportunity opp : oppListToTest){
            listOfAccountInJson.add(opp.Id);
        }
       
        // Create a StandardSetController with the test Account
        ApexPages.StandardSetController controller = new ApexPages.StandardSetController(new List<Account>{accountsToTest[0]});
        
        // Instantiate massOpportunityDeleteClass to populate recordIdList
        massOpportunityDeleteClass controllerExtension = new massOpportunityDeleteClass(controller);
        
    }
    
    @isTest
    public static void testDeleteAccounts() {
         List<Account> accountsToTest = new List<Account>{ new Account(Name = 'Test Account 1'), new Account(Name = 'Test Account 2') };
            
         list<String> listOfOppInJson = new list<String>();
        
        insert accountsToTest;
        List<Opportunity> oppListToTest = new List<Opportunity>{new Opportunity(Name = 'Test Opp 1', StageName = 'StageName', AccountId = accountsToTest[0].Id, CloseDate = Date.today().addDays(30))};
        insert oppListToTest;
        for(Opportunity opp : oppListToTest){
            listOfOppInJson.add(opp.Id);
        }
        
        //List<Id> oppIds = new List<Id>{oppListToTest[0].Id};
        
        // Call the deleteAccounts method with the test Account Id
        String result = massOpportunityDeleteClass.deleteOpportunities(listOfOppInJson);
        
    }
}