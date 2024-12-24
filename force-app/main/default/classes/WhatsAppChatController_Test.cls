// Created by Shreyash Urkude on 22/08/2024 . Description : Test class for WhatsAppChatController Apex class

@isTest
public class WhatsAppChatController_Test {
    @isTest
    public static void tempWar_Test(){
         Account con = new Account();
        con.FirstName = 'Test';
        con.LastName = 'Test';
        con.WhatsApp_No__c = '9579853991';
        insert con;
        
      	Ticket__c tc = new Ticket__c();
      	tc.Account__c = con.Id;
        insert tc;        
        
        Test.startTest();
        WhatsAppChatController.tempwap(con.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void dateSend_Test(){
         Whatsapp_Text__c text = new Whatsapp_Text__c();
        text.Text__c = 'Test';
        text.Sent_To__c = '919579853991';
        text.Message_Type__c = 'Outbound';
            
        text.Msg_Sent__c = false;
        insert text;
        
        Test.startTest();
        TicketWhatsAppChatController.dateSend(text.Id);
        Test.stopTest();
    }
    
    
	@isTest
    public static void startTest(){
        
        Account con = new Account();
        con.FirstName = 'Test';
        con.LastName = 'Test';
        con.WhatsApp_No__c = '9579853991';
        insert con;
        
        Whatsapp_Text__c text = new Whatsapp_Text__c();
        text.Text__c = 'Test';
        text.Sent_To__c = '919579853991';
        text.Message_Type__c = 'Outbound';
        text.Account__c = con.Id;
        text.Msg_Sent__c = false;
        insert text;
        
        
        Test.setMock(HttpCalloutMock.class, new Send_Wap_Class_Mock());
        
        // Create a ContentVersion
        ContentVersion cv = new ContentVersion();
        cv.Title = 'text.txt';
        cv.VersionData = Blob.valueOf('Hi');
        cv.PathOnClient = 'text.txt';
        insert cv;
        
        // Create a ContentDocumentLink
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        cdl.LinkedEntityId = text.Id; // Assuming text is the parent object
        cdl.ShareType = 'V'; // 'V' for sharing with all users who have access
        cdl.Visibility = 'AllUsers'; // All users can see this document
        insert cdl;

        test.startTest();
        WhatsAppChatController.getChats(con.Id);
        test.stopTest();
    }	
    
    @isTest
    public static void sendMessage_Test(){        
        Account con = new Account();
        con.FirstName = 'Test';
        con.LastName = 'Test';
        con.WhatsApp_No__c = '9579853991';
        insert con;    
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new Send_Wap_Class_Mock());
        WhatsAppChatController.sendMessage('Messgae' ,con.Id);
        test.stopTest();
    }
    
    @isTest
    public static void UploadFiles_test(){
        Test.startTest();
        WhatsAppChatController.UploadFiles('Messgae' , 'ABC');
        Test.stopTest();
    }
    
    @isTest
    public static void sendMessageWithAttchments_test(){
        Account con = new Account();
        con.FirstName = 'Test';
        con.LastName = 'Test';
        con.WhatsApp_No__c = '9579853991';
        insert con;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'text.txt';
        cv.VersionData = Blob.valueOf('Hi');
        cv.PathOnClient = 'text.txt';
        insert cv;
        
        List<String> att = new List<string>();
        att.add(cv.Id);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Send_Wap_Class_Mock());
        WhatsAppChatController.sendMessageWithAttchments('Messgae', con.Id , att);
        Test.stopTest();
    } 
        
    @isTest
    public static void SendTemplate_test(){
        Account con = new Account();
        con.FirstName = 'Test';
        con.LastName = 'Test';
        con.WhatsApp_No__c = '9579853991';
        insert con;
            
        Whatsapp_Templates__c wt = new Whatsapp_Templates__c();
        wt.Name = 'Test';
        wt.Text__c = 'Test';
        insert wt;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'text.txt';
        cv.VersionData = Blob.valueOf('Hi');
        cv.PathOnClient = 'text.txt';
        insert cv;
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        cdl.LinkedEntityId = wt.Id; // Assuming text is the parent object
        cdl.ShareType = 'V'; // 'V' for sharing with all users who have access
        cdl.Visibility = 'AllUsers'; // All users can see this document
        insert cdl;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Send_Wap_Class_Mock());
        WhatsAppChatController.SendTemplate(wt.Id, con.Id , 'att');
        Test.stopTest();
    }
    
    
    @isTest
    public static void getTemplates_test(){
        Whatsapp_Templates__c wt = new Whatsapp_Templates__c();
        wt.Name = 'Test';
        wt.Text__c = 'Test';
        insert wt; 
        
        Test.startTest();       
        WhatsAppChatController.getTemplates();
        Test.stopTest();
    }
}