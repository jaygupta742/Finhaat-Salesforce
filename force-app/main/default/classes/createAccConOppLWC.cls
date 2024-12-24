/*
 * @Created By   : Vishal Singh 
 * @Created Date : 29-08-2024
 * @Description  : Need to create a LWC component to create account, contact and opportunity form List view button on account 
 * 
 * @Last Modified by		: vishal singh
 * @Last Modified Date      : 30-08-2024
 * @Description             : check if we are not entering the Pan no number, gst nuber or website component is throwing the error of duplicate account
 */
public class createAccConOppLWC {
    
    @AuraEnabled(cacheable=true)
    public static string get_Details(){
        
        Account acc=new Account();
        Contact con=new Contact();
        Opportunity opp=new Opportunity();
        opp.StageName='Lead';
        opp.CloseDate=System.today();
        
        
        wrapMaster wrap = new wrapMaster(acc, con,opp);
        return JSON.serialize(wrap);
    }
    
    /*
    @AuraEnabled
    public static string save(String acc ,String con ,String opp) {
        try {
            RecordType reordtype = [SELECT Id, Name, DeveloperName, Description, SobjectType, IsActive FROM RecordType Where Name = 'Partner' Limit 1];
            Account accInsert = (Account) JSON.deserialize(acc, Account.class);
			String panNo = '';
            String gstNo = '';
            String Name  = '';
            String website = '';
            System.debug('Pan no ####'+accInsert.PAN_No__c);
            if (accInsert.PAN_No__c == null) {
               panNo = '';
            }
            if (accInsert.GST_No__c == null) {
                gstNo = '';
            }
            if (accInsert.Name == null) {
                Name = '';
            }
            if (accInsert.Website == null) {
                website = '';
            }
            //List<Account> existingAccount = [select id, Name, GST_No__c,Website,PAN_No__c from Account where PAN_No__c =: accInsert.PAN_No__c OR GST_No__c =: accInsert.GST_No__c OR Name =: accInsert.Name OR Website =: accinsert.Website Limit 1];
            List<Account> existingAccount = [select id, Name, GST_No__c,Website,PAN_No__c from Account where PAN_No__c =: panNo OR GST_No__c =: gstNo OR Name =: Name OR Website =: website Limit 1];
            
            if(!existingAccount.isEmpty()){
                return 'Account already exits';
            }else {
                accInsert.RecordTypeId = reordtype.Id;
            insert accInsert;
            
            
            Contact conInsert = (Contact) JSON.deserialize(con, Contact.class);
            conInsert.AccountId=accInsert.id;
            insert conInsert;

           
            
            Opportunity oppInsert = (Opportunity) JSON.deserialize(opp, Opportunity.class);
            oppInsert.AccountId=accInsert.id;
            oppInsert.ContactId=conInsert.Id;
            oppInsert.Contact__c=conInsert.Id;
            
            insert oppInsert;
            
            return accInsert.Id;

            }
                        
        } catch(Exception e) {
            System.debug(' error message : ' + e.getMessage());
            System.debug(' error line number : ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    */
    @AuraEnabled
public static string save(String acc, String con, String opp) {
    try {
        // Fetch the RecordType for Partner
        RecordType reordtype = [SELECT Id FROM RecordType WHERE Name = 'Partner' LIMIT 1];

        // Deserialize the Account JSON
        Account accInsert = (Account) JSON.deserialize(acc, Account.class);

        // Initialize a list for existing accounts
        List<Account> existingAccount = new List<Account>();

        // Check if at least one of the fields is not null or empty
        if (String.isNotBlank(accInsert.PAN_No__c) || String.isNotBlank(accInsert.GST_No__c) || 
            String.isNotBlank(accInsert.Name) || String.isNotBlank(accInsert.Website)) {

            // Construct the query string dynamically
            String queryString = 'SELECT Id, Name, GST_No__c, Website, PAN_No__c FROM Account WHERE ';
            List<String> conditions = new List<String>();

            // Add conditions for the fields that are not blank
            if (String.isNotBlank(accInsert.PAN_No__c)) {
                conditions.add('PAN_No__c = \'' + String.escapeSingleQuotes(accInsert.PAN_No__c) + '\'');
            }
            if (String.isNotBlank(accInsert.GST_No__c)) {
                conditions.add('GST_No__c = \'' + String.escapeSingleQuotes(accInsert.GST_No__c) + '\'');
            }
            if (String.isNotBlank(accInsert.Name)) {
                conditions.add('Name = \'' + String.escapeSingleQuotes(accInsert.Name) + '\'');
            }
            if (String.isNotBlank(accInsert.Website)) {
                conditions.add('Website = \'' + String.escapeSingleQuotes(accInsert.Website) + '\'');
            }

            // Join the conditions and complete the query string
            queryString += String.join(conditions, ' OR ') + ' LIMIT 1';

            // Execute the query
            existingAccount = Database.query(queryString);
        }

        // If a matching account is found, return a message
        if (!existingAccount.isEmpty()) {
            return 'Account already exits';
        } else {
            // Set the RecordTypeId and insert the account
            accInsert.RecordTypeId = reordtype.Id;
            insert accInsert;

            // Deserialize and insert the Contact
            Contact conInsert = (Contact) JSON.deserialize(con, Contact.class);
            conInsert.AccountId = accInsert.Id;
            insert conInsert;

            // Deserialize and insert the Opportunity
            Opportunity oppInsert = (Opportunity) JSON.deserialize(opp, Opportunity.class);
            oppInsert.AccountId = accInsert.Id;
            oppInsert.ContactId = conInsert.Id;
            oppInsert.Contact__c = conInsert.Id;
            insert oppInsert;

            // Return the Account Id
            return accInsert.Id;
        }
    } catch (Exception e) {
        System.debug('Error message: ' + e.getMessage());
        System.debug('Error line number: ' + e.getLineNumber());
        throw new AuraHandledException('An error occurred: ' + e.getMessage());
    }
}

    
    public class wrapMaster {
        public Account acc;
        public Contact con;
        public Opportunity opp;
      
        public wrapMaster(Account accInput,Contact conInput,Opportunity oppInput) {
            acc = accInput;
            con = conInput;
            opp = oppInput;
            
        }
    }
    
}