// Created By vishal singh, On 02-05-2024
@isTest(SeeAllData=true)
private class massAccountDeleteClass_Test {
    
    @isTest
    public static void testRecordIdListPopulation() {
        // Create a test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        // Create a List of Account Ids
        List<Id> accountIds = new List<Id>{testAccount.Id};
        
        // Create a StandardSetController with the test Account
        ApexPages.StandardSetController controller = new ApexPages.StandardSetController(new List<Account>{testAccount});
        
        // Instantiate massAccountDeleteClass to populate recordIdList
        massAccountDeleteClass controllerExtension = new massAccountDeleteClass(controller);
        
    }
    
    @isTest
    public static void testDeleteAccounts() {
        // Create a test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        // Create a List of Account Ids
        List<Id> accountIds = new List<Id>{testAccount.Id};
        
        // Call the deleteAccounts method with the test Account Id
        String result = massAccountDeleteClass.deleteAccounts(accountIds);
        
        // Check if the method returns 'Success' for a valid Account Id
        System.assertEquals('Success', result);
        
        // Verify that the Account has been deleted
        List<Account> deletedAccounts = [SELECT Id FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(0, deletedAccounts.size());
    }
}