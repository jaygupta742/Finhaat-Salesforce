@isTest
public class RCPhoneHelperTest {
    // Test method for searchContact
    @isTest
    static void testSearchContact() {
        // Create test data
        Contact contact = RCPhoneHelper.addContact('918056517034');

        // Call the method being tested
        Contact result = RCPhoneHelper.searchContact('918056517034');
        // Verify the result
        System.assertNotEquals(null, result);
        System.assertEquals(contact.Id, result.Id);
    }

    // Test method for logACall
    @isTest
    static void testLogACall() {
        // Create test data, e.g., a test Contact record
        Contact testContact = new Contact(
            LastName = 'TestContact',
            Phone = '987-654-3210'
        );
        insert testContact;

        // Call the method being tested
        RCPhoneHelper.logACall(
            testContact.Id,
            60, // Example duration
            '123-456-7890', // Example fromNumber
            '987-654-3210', // Example toNumber
            'Completed', // Example callStatus
            'Test Client' // Example clientName
        );

        // Query the created Task record and verify its existence
        Task createdTask = [SELECT Id FROM Task LIMIT 1];
        System.assertNotEquals(null, createdTask);
    }

    // Test method for addContact
    @isTest
    static void testAddContact() {
        // Call the method being tested
        Contact result = RCPhoneHelper.addContact('999-999-9999');

        // Query the created Contact record and verify its existence
        Contact createdContact = [SELECT Id FROM Contact WHERE Phone = '999-999-9999' LIMIT 1];
        System.assertNotEquals(null, createdContact);
        System.assertEquals(result.Id, createdContact.Id);
    }
    
    @isTest
    static void testSearchContactNotFound() {
        // We won't insert any contact, so the search should return null

        // Call the method being tested
         Contact result = RCPhoneHelper.searchContact('918056517034');
        
        

        // Verify the result
        System.assertEquals(null, result);
    }

    // Test method for logInCall
    @isTest
    static void testLogInCall() {
        // Create test data, e.g., a test Contact record
        Contact testContact = new Contact(
            LastName = 'TestContact',
            Phone = '123-456-7890'
        );
        insert testContact;

        // Call the method being tested
        RCPhoneHelper.logInCall(
            testContact.Id,
            45, // Example duration
            '987-654-3210', // Example fromNumber
            '123-456-7890', // Example toNumber
            'Completed', // Example callStatus
            'Test Client' // Example clientName
        );

        // Query the created Task record and verify its existence
        Task createdTask = [SELECT Id FROM Task LIMIT 1];
        System.assertNotEquals(null, createdTask);
    }
    
    @isTest
static void testPermissionWithProfile() {
    // Fetch a profile which has restricted access
  Profile p = [SELECT Id FROM Profile WHERE Name='Limited Access User'];
       
    // Create a user with that profile
   User u = new User(Alias = 'test', Email='cmi@test.com',
                     EmailEncodingKey='UTF-8', LastName='Tester', LanguageLocaleKey='en_US',
                     LocaleSidKey='en_US', ProfileId = p.Id,
                      TimeZoneSidKey='America/Los_Angeles', UserName='cmi@test.com');
    insert u;
    

    

    // Use System.runAs to run the following code as the user with the restricted profile
    System.runAs(u) {
        // Your test code here
        // Call the method being tested
        Contact contact = RCPhoneHelper.addContact('918056517034');
        
        
        // Verify the result
        System.assertEquals(null, contact);
       
    }
}

}