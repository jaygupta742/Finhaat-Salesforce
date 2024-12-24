@istest
public class whatsAPPScheduleforAutomated_Test {
@istest
    public static void test_data(){
          Whatsapp_Text__c text = new Whatsapp_Text__c();
        text.Text__c = 'Test';
        text.Sent_To__c = '917041733029';
        text.Message_Type__c = 'Outbound';
        text.Automated_Process__c = true;
        insert text;
        
        
        Test.setMock(HttpCalloutMock.class, new Send_Wap_Class_Mock());
        
        Attachment attachment = new Attachment();
        attachment.name = 'text.txt';
        attachment.Body = Blob.valueOf('Hi');
        attachment.ParentId = text.Id;
        
        insert attachment;
        
        whatsAPPScheduleforAutomated.executeOnce(text.Id,1);    
        
        Datetime sysTime = System.now().addMinutes(10);
        String cronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        System.schedule('Test', cronExpression, new whatsAPPScheduleforAutomated());
    }
}