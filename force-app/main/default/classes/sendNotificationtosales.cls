/* Created By : sUraj : 08/07/2024  Description : Need to send Notifcation to ticket owner
* Last Modified by: Sougata Paul; Last ModifiedDate: 11/07/2024; Des: Custom Notification Title updated
Last Modified by: Suraj ; Last ModifiedDate: 11/07/2024; Des: Need to update the stage and stage details by current user on selecting stage
Last Modified By : Vijay Somvashi 
Last Modified Date : 4/09/2024 
Last Modified for : Created Task
*/ 
public Without Sharing class sendNotificationtosales {
    @AuraEnabled(cacheable=true)
    // get ticket details
    public static Ticket__c getdetails1(Id recordId ) {
        Ticket__c record = [SELECT Name,OwnerId,Stage__c,id ,Account__r.Name, Quotation_Sent_By__c , Quotation_Sent_Date_Time__c FROM Ticket__c WHERE Id = :recordId LIMIT 1];
        return record;
    }
    @AuraEnabled
    public static String sendCustomNotification1(Id recordId, String comment, string stage ) {
        // system.debug('get stage '+stage);
        // Get the owner of the record
        try {
            Ticket__c record = [SELECT Name,OwnerId,Stage__c,id ,Hold_Issued_By__c,Hold_Issued_Date_Time__c, Quotation_Sent_By__c ,Payment_link_sent_at_date_time__c,Payment_Link_Sent_By__c,Policy_Issued_Date_Time__c,Policy_issued_By__c,
                                Quotation_Sent_Date_Time__c, Lost_Reason__c FROM Ticket__c WHERE Id = :recordId LIMIT 1];
            CustomNotificationType notificationType = [
                SELECT Id
                FROM CustomNotificationType
                WHERE DeveloperName = :'sendCustomNotification'
                LIMIT 1
            ]; 
            
            String comentTitle; 
            CustomNotificationType cnType = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'sendCustomNotification'];
            Id userId = Userinfo.getUserId();
            // System.debug('Current User ID: ' + userId);
            User currentUser = [SELECT Profile.Name,Name  FROM User WHERE Id = :UserInfo.getUserId()];
            String profileuserName = currentUser.Name;
            // System.debug('Current User Name: ' + profileuserName);
            
            comentTitle = profileuserName + ' ' + 'has commented on' + ' ' + record.Name;
            Messaging.CustomNotification customNotificationObj = new Messaging.CustomNotification();
            customNotificationObj.setBody(comment);
            //customNotificationObj.setTitle('New Comment');
            customNotificationObj.setTitle(comentTitle);
            customNotificationObj.setNotificationTypeId(cnType.id);
            customNotificationObj.setSenderId(userId);
            customNotificationObj.setTargetId(recordId);
         //   customNotificationObj.send(new Set<String> {record.OwnerId});
            //updating stage details
            if(stage =='Quotation'){  
                record.Stage__c ='Quotation';
                record.Quotation_Sent_Date_Time__c = System.now();
                record.Quotation_Sent_By__c = userinfo.getUserId();
            }
            if(stage =='Payment Link Sent'){  
                record.Stage__c ='Payment Link Sent';
                record.Payment_link_sent_at_date_time__c = System.now();
                record.Payment_Link_Sent_By__c = userinfo.getUserId();
                
            }
            if(stage =='Policy Issued'){ 
                record.Stage__c ='Policy Issued';
                record.Policy_Issued_Date_Time__c = System.now();
                record.Policy_issued_By__c = userinfo.getUserId();
            }
            if(stage =='Hold'){
                record.Stage__c ='Hold';
                record.Lost_Reason__c = comment;
                record.Hold_Issued_Date_Time__c = system.now();
                record.Hold_Issued_By__c =  userinfo.getUserId();
            }
            update record;
            return record.id;
        }
        catch (exception e){        System.debug('error message: ' + e.getMessage());           System.debug('error line number: ' + e.getLineNumber());           throw new AuraHandledException(e.getMessage());
                           }
        
    }
    @AuraEnabled
    public static void createtask(String recordId, Task taskobject){
        try {
            system.debug('task '+taskobject);
            Ticket__c record = [SELECT Id,OwnerId from Ticket__c Where ID =: recordId];
            taskobject.Status = 'Not Started';
            taskobject.OwnerId = record.OwnerId;
            taskobject.WhatId = record.Id;
            taskobject.IsReminderSet = true;
            taskobject.ReminderDateTime = Datetime.now().addMinutes(120);
            insert taskobject;
        } catch (exception e){        System.debug('error message: ' + e.getMessage());           System.debug('error line number: ' + e.getLineNumber());
                             }
        
    }
}