@isTest(SeeAllData = true) public class updateOwnerInCallDetailsTest {
    
    @isTest public static void test1(){
        updateOwnerInCallDetails batch = new updateOwnerInCallDetails('');
        Database.executeBatch(batch, 200);
    }
    
}