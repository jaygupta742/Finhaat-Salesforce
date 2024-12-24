/* Suraj Mahabudhe 26/02/2024 :  this is test class use of restresource apex cass
*/ 
@IsTest
public class Restapi_Inbound_sms_Test {
    @Istest
    Public static void TestData(){
        Ticket_Key_Words__c dd=New Ticket_Key_Words__c();
        dd.Name='#new_quote#';
        dd.text__c ='#new_quote#';
        insert new Ticket_Key_Words__c[]{dd};        
            
            Map<string, Object> new_Body=New Map<String, Object>();
        new_Body.Put('remoteJid','917798056741@s.whatsapp.net');
        new_Body.Put('fromMe', false);
        new_Body.Put('type', 'video');
        new_Body.Put('mimeType', 'video/mp4');
        new_Body.Put('video', 'data:video/mp4;base64,AAAAGGZ0eXBtcDQyAAAAAG1wNDJpc29tAAAAGGJlYW0BAAAAAQAAAAAAAAAGAAAAAABJO21vb3YAAABsbXZoZAAAAAAAAAAAAAAAAAAAu4AAFlwAAAEAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMAADAzdHJhawAAAFx0a2hkAAAABwAAAAAAAAAAAAAAAQAAAAAAFf9AAAAAAAAAAAAAAAAAAQAAAAABAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAQAAAAAKAAAABaAAAAAAvz21kaWEAAAAgbWRoZAAAAAAAAAAAAAAAAAAAAB4AAAOFAAAAAAAAACJoZGxyAAAAAAAAAAB2aWRlAAAAAAAAAAAAAAAAAAAAAC+FbWluZgAAABR2bWhkAAAAAAAAAAAAAAAAAAAAJGRpbmYAAAAcZHJlZgAAAAAAAAABAAAADHVybCAAAAABAAAvRXN0YmwAAACYc3RzZAAAAAAAAAABAAAAiGF2YzEAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAACgAFoAEgAAABIAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAY//8AAAAyYXZjQwFkAB//4QAaZ2QAH6zZQKAv+XARAAADAAEAAAMAPA8YMZYBAAVo6+yyLAAAABhzdHRzAAAAAAAAAAEAAAOFAAAAAQAAG');
        
        Account acc=New Account();
        acc.WhatsApp_No__c ='7798056741';
        acc.LastName ='Suraj';
        acc.RecordTypeId =    Schema.SObjectType.Account.getRecordTypeInfosByName().get('POS').getRecordTypeId(); 
        insert acc;
        
        
        RestRequest req=New RestRequest();
        req.requestURI ='https://finhaatinsurancebrokingpvtltd--subhadeep1.sandbox.my.salesforce-sites.com/InboundMsg/services/apexrest/Restapi_Inbound_sms';
        req.httpMethod  ='POST';
        req.requestBody  = blob.valueof(JSON.serialize(new_Body));
        
        restContext.request = req;
        Restapi_Inbound_sms.doPost();
    }
    
    @Istest
    Public static void TestData1(){
        Ticket_Key_Words__c dd=New Ticket_Key_Words__c();
        dd.Name='#new_quote#';
        dd.text__c ='#new_quote#';
        insert new Ticket_Key_Words__c[]{dd};        
            
            Map<string, Object> new_Body=New Map<String, Object>();
        new_Body.Put('remoteJid','917798056741@s.whatsapp.net');
        new_Body.Put('fromMe', false);
        new_Body.Put('type', 'text');
        new_Body.Put('text', '#need_quote##new_quote##need_proposal# ghvhjvhjvjnb nb jhb');
        
        Account acc=New Account();
        acc.WhatsApp_No__c ='7798056741';
        acc.LastName ='Suraj';
        acc.RecordTypeId =    Schema.SObjectType.Account.getRecordTypeInfosByName().get('POS').getRecordTypeId(); 
        insert acc;
        
        
        RestRequest req=New RestRequest();
        req.requestURI ='https://finhaatinsurancebrokingpvtltd--subhadeep1.sandbox.my.salesforce-sites.com/InboundMsg/services/apexrest/Restapi_Inbound_sms';
        req.httpMethod  ='POST';
        req.requestBody  = blob.valueof(JSON.serialize(new_Body));
        
        restContext.request = req;
        Restapi_Inbound_sms.doPost();
    }
}