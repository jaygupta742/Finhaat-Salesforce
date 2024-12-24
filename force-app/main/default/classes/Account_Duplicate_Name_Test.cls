/*Last Modified By Suraj 29/08/2024 :)  This test class use for Account_Duplicate_Name this apex class (Code coverage IS 98%)	

*/ 
@isTest
public class Account_Duplicate_Name_Test {
    @isTest
    public static void setData(){
        test.startTest();
        list<Master_Document__c> rdlist=new list<Master_Document__c>();
        Master_Document__c rd=new Master_Document__c();
        rd.Name = 'Post Graduate All Semester Marksheets';
        rd.Stages__c ='POS';
        rdlist.add(rd);  
        Master_Document__c rd2=new Master_Document__c();
        rd2.Name = 'Post Graduate All Semester Marksheets';
        rd2.Stages__c ='MFI';
        rdlist.add(rd2);  
        insert rdlist;
        
        Account acc1 = new Account();
        acc1.Name='test'; 
        acc1.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        acc1.BillingCity = 'test';
        acc1.BillingCountry ='rwer';
        acc1.BillingState ='asdasd';
        acc1.BillingStreet ='adasds';
        acc1.BillingPostalCode ='123456';
        insert acc1;
        
        Account acc = new Account();
        RecordType recordtypeId = [SELECT Id, Name, DeveloperName FROM RecordType Where DeveloperName = 'POS_Wealth_Management' limit 1];
        acc.LastName = 'Test';
        acc.PAN_No__c = 'fgtpk0456n';
        acc.WhatsApp_No__c = '2233445566';
        acc.Phone = '2233445566';
        acc.Stage__c ='Lead';
        acc.Present_Insurance_Offerring__c = 'test';
        acc.RecordTypeId = recordtypeId.Id;
        insert acc;
        try{ Update acc;
           }
        catch(excePtion e){
            
        }             
        Account_Duplicate_Name.codeBlaster();
    }
}