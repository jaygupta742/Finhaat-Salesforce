/*
Last Modified By : Vijay Somvashi 
Last Modified Date : 4/09/2024 
Last Modified for : Increase Test Covarage 
*/
@istest
public class sendNotificationtosales_Test {
    @istest
    Public static void testdata(){
        Ticket__c t=New Ticket__c();
        t.Stage__c = 'Quotation';
        insert t;
        Task tt = new Task();
        tt.Subject = 'test';
        tt.ActivityDate = system.today();
        tt.Priority = 'Normal';
        tt.Status = 'Not Started';
        tt.WhatId = t.Id;
        tt.OwnerId = t.OwnerId;
        
        test.starttest();
        sendNotificationtosales.getdetails1(t.id);
        sendNotificationtosales.sendCustomNotification1(t.id, 'comment','Quotation');
        sendNotificationtosales.sendCustomNotification1(t.id, 'comment','Payment Link Sent');
        sendNotificationtosales.sendCustomNotification1(t.id, 'comment','Policy Issued');
       // sendNotificationtosales.sendCustomNotification1(t.id, 'comment','Hold');
        sendNotificationtosales.createtask(t.Id, tt); 
        test.stopTest();
    }
}