/**
 * test class for the apex class call_Create_Case_Portal_Apex
 * 
 * Author: Rahul katarpawar
 * Date: 11/12/24
 */

/***************************************************************************************************************************
 * Modified By			Modfied Date	Modified Description
 * 
 * 
 * 
 * 
 * 
 * *************************************************************************************************************************/
@isTest
public class call_Create_Case_Portal_Apex_Test {
	@isTest
    Public Static void testgetUserAndOrgInfo(){
        
        
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser@example.com.' + System.currentTimeMillis(),
            Alias = 'tuser',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        // Set the current user context to the created test user
        System.runAs(testUser) {
            // Create an organization record
            Organization org = [SELECT Id, Name FROM Organization LIMIT 1];
            
            // Step 2: Execute the Method
            Test.startTest();
            Map<String, String> userInfo = call_Create_Case_Portal_Apex.getUserAndOrgInfo();
            Test.stopTest();
            
            // Step 3: Assertions
            // Validate the returned map
            System.assertEquals(testUser.FirstName + ' ' + testUser.LastName, userInfo.get('userName'), 'The userName should match.');
            System.assertEquals(testUser.Email, userInfo.get('userEmail'), 'The userEmail should match.');
            System.assertEquals(org.Name, userInfo.get('orgName'), 'The orgName should match.');
            System.assert(userInfo.containsKey('userMobile'), 'The userMobile key should exist.');
            
        }
    }
}