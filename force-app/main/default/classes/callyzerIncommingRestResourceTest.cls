@isTest public class callyzerIncommingRestResourceTest {
    
    @TestSetup public static void createDate(){
        Account accountRecord = new Account();
        accountRecord.Name = 'Test Account';
        accountRecord.Account_Created_By_Callyzer__c = true;
        accountRecord.Phone = '6325698565';
        
        Insert accountRecord;
        
        Contact contactRecord = new Contact();
        contactRecord.LastName = 'Test Contact';
        contactRecord.AccountId = accountRecord.Id;
        contactRecord.Phone = '6325698565';
        contactRecord.MobilePhone = '6325698565';
        
        Insert contactRecord;
    }
    
    @isTest public static void startTest(){
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/callyzerBizIncomming/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('[{"emp_name":"John Doe","emp_number":"1234567890","call_logs":[{"id":"1","client_name":"Client A","client_number":"6325698565","call_time": "20:07:27","call_type":"Incoming","duration":"0","call_recording_url":"http://example.com/recording1.mp3"}]}]');
        
        // Set the request and response objects
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        // Call the method to test
        Test.startTest();
        String result = callyzerIncommingRestResource.postRequest();
        Test.stopTest();
    }
    
    @isTest public static void startTest1(){
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/callyzerBizIncomming/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('[{"emp_name":"John Doe","emp_number":"1234567890","call_logs":[{"id":"1","client_name":"Client A","client_number":"6325698565","call_time": "20:07:27","call_type":"Outgoing","duration":"10","call_recording_url":"http://example.com/recording1.mp3"}]}]');
        
        // Set the request and response objects
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        // Call the method to test
        Test.startTest();
        String result = callyzerIncommingRestResource.postRequest();
        Test.stopTest();
    }
    
    @isTest public static void startTest2(){
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/callyzerBizIncomming/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('[{"emp_name":"John Doe","emp_number":"1234567890","call_logs":[{"id":"1","client_name":"Client A","client_number":"6325698565","call_time": "20:07:27","call_type":"Rejected","duration":"0","call_recording_url":"http://example.com/recording1.mp3"}]}]');
        
        // Set the request and response objects
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        // Call the method to test
        Test.startTest();
        callyzerIncommingRestResource.convertStringIntoDateTime('20:07:27','2024-06-23');
        String result = callyzerIncommingRestResource.postRequest();
        Test.stopTest();
    }
}