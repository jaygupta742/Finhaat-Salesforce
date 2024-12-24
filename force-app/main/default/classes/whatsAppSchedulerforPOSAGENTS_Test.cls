@isTest
public class whatsAppSchedulerforPOSAGENTS_Test {
  @isTest
    public static void startTest(){
        Whatsapp_Text__c text = new Whatsapp_Text__c();
        text.Text__c = 'Test';
        text.Sent_To__c = '917041733029';
        text.Message_Type__c = 'Outbound';
        insert text;
        
        
        Test.setMock(HttpCalloutMock.class, new Send_Wap_Class_Mock());
        
        Attachment attachment = new Attachment();
        attachment.name = 'text.txt';
        attachment.Body = Blob.valueOf('Hi');
        attachment.ParentId = text.Id;
        
        insert attachment;
        
        whatsAppSchedulerforPOSAGENTS.executeOnce(text.Id,1);    
        
        Datetime sysTime = System.now().addMinutes(1);
        String cronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        System.schedule('Test', cronExpression, new whatsAppSchedulerforPOSAGENTS());
    }
}