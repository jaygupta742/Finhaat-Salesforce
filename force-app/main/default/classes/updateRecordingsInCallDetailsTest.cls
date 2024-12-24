@isTest(SeeAllData = true) public class updateRecordingsInCallDetailsTest {
    
    @isTest public static void test1(){
        Test.setMock(HttpCalloutMock.class, new CalloutMockForTestClass());
        updateRecordingsInCallDetails batch = new updateRecordingsInCallDetails('1','1');
        Database.executeBatch(batch, 1);
    }
    
}