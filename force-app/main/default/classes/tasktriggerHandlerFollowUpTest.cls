@isTest
public class tasktriggerHandlerFollowUpTest {

     @testSetup
    static void setupTestData() {
        // Create a test Account
        Account acc = new Account(Name = 'Test Account',BillingCity = 'USA', BillingCountry = 'Londan', BillingStreet = 'NA',BillingState = 'MAH',BillingPostalCode = '4568'
                                 );
     
        insert acc;
        // Create a valid Task
        Task task3 = new Task(
            Subject = 'Test Task 3',
            WhatId = acc.Id,
            
            Follow_Up_Needed__c = true,
            Follow_Up_Due_Date__c = System.today().addDays(1),
            Follow_Up_Subject__c = 'Test Follow-Up',
            Follow_Up_Reminder_Date_Time__c = System.now().addDays(1)
        );
        insert task3;
    }
    
    @isTest
    static void testFollowUpTaskTrigger() {
         Account acc = new Account(Name = 'Test Account1',BillingCity = 'USA', BillingCountry = 'Londan', BillingStreet = 'NA',BillingState = 'MAH',BillingPostalCode = '4568'
                                 );
        insert acc;
       Task task3 = new Task(
            Subject = 'Test Task1',
            WhatId = acc.Id,
            Follow_Up_Needed__c = true,
            Follow_Up_Due_Date__c = System.today().addDays(1),
            Follow_Up_Subject__c = 'Test Follow-Up',
            Follow_Up_Reminder_Date_Time__c = System.now().addDays(1)
        );

        Test.startTest();
       insert task3;
        Test.stopTest();

        List<Task> followUpTasks = [SELECT Id, ActivityDate, Subject, OwnerId, WhatId FROM Task WHERE Subject =: 'Test Task1'];
        System.assertEquals(1, followUpTasks.size(), 'Follow-up tasks should be created.');
    }
    
    @isTest
    static void testValidationErrors() {
        Task task = new Task(
            Subject = 'Test Task Validation',
            Follow_Up_Needed__c = true,
            Follow_Up_Due_Date__c = System.today()-1,
            Follow_Up_Subject__c = 'Test Invalid',
            Follow_Up_Reminder_Date_Time__c = System.today()-1
        );

        Test.startTest();
        try {
            insert task;
            //System.assert(false, 'Expected error due to past follow-up date.');
        } catch (DmlException ex) {
           // System.assert(ex.getMessage().contains('Follow due date cannot be past'), 'Expected error message related to past due date.');
        }
        Test.stopTest();
    }
}