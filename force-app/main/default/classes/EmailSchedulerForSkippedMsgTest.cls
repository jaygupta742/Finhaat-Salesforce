@isTest
public class EmailSchedulerForSkippedMsgTest {

    @testSetup
    static void setupTestData() {
        // Create test data for Whatsapp_Text__c records
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        List<Whatsapp_Text__c> whatsAppTexts = new List<Whatsapp_Text__c>();
        for (Integer i = 0; i < 5; i++) {
            Whatsapp_Text__c whatsappText = new Whatsapp_Text__c(
               
                Text__c = 'This is test message ' + i,
                Account__c = testAccount.Id,
                Skipped_Record_Due_to_Error__c = true,
                Skipped_Error__c = 'Sample error ' + i,
                Skipped_Date_Time__c = Datetime.now().addMinutes(-i),
                Msg_Sent__c = false,
                Message_Type__c = 'Outbound'
            );
            whatsAppTexts.add(whatsappText);
        }
        insert whatsAppTexts;
    }

   /* @isTest
    static void testExecuteWithSkippedMessages() {
        Test.startTest();
        
        // Schedule the job
        String jobId = System.schedule('Test Email Scheduler', '0 0 0 1 1 ? 2025', new EmailSchedulerForSkippedMsg());

        // Execute the scheduled job
        Test.executeBatch(new EmailSchedulerForSkippedMsg(), 1);
        
        // Verify that the job was aborted and rescheduled
        List<AsyncApexJob> jobs = [SELECT Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE Id = :jobId];
        System.assertEquals('Aborted', jobs[0].Status);

        Test.stopTest();
    }*/

    @isTest
    static void testSendEmail() {
        List<Whatsapp_Text__c> testWhatsAppTexts = [SELECT Id, Name, Text__c, Account__r.Name, Skipped_Error__c, Skipped_Date_Time__c 
                                                     FROM Whatsapp_Text__c 
                                                     WHERE Msg_Sent__c = false 
                                                     AND Message_Type__c = 'Outbound'
                                                     LIMIT 5];
        
        Test.startTest();
        
        
        EmailSchedulerForSkippedMsg.sendEmail(testWhatsAppTexts);

        
        List<Whatsapp_Text__c> updatedTexts = [SELECT Msg_Sent__c FROM Whatsapp_Text__c WHERE Id IN :testWhatsAppTexts];


        Test.stopTest();
    }
}