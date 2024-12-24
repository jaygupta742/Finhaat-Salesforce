/* Created By : Suraj  , Created date : 07/03/2024 , description : convert Lead Into Account
 * Last Modified by: Sougata Paul ; Last Modified Date: 01/08/2024; Owner id From custom setting mapped with Account Owner
 */ 
public class CreateAccountFromLead_helper {
    public static void insert_Account(Lead[] list_l){
        lead_Owner__c loa = [Select id, Owner_Id__c from lead_Owner__c limit 1];
        system.debug('Laed owner custom setting --->'+loa.Owner_Id__c);
        
        account[] accLIst=New Account[]{};
            for(Lead l : list_l){
                Account acc= New Account ();
                acc.Salutation = l.Salutation;
                acc.FirstName = l.FirstName;
                acc.LastName = L.LastName;
                acc.Description = l.description;
                acc.WhatsApp_No__c = l.WhatsApp_No__c;
                acc.PersonMobilePhone = l.MobilePhone;
                acc.PersonEmail = L.Email;
                acc.Lead_Source__c = l.LeadSource;
                acc.OwnerId = loa.Owner_Id__c;
                acc.Stage__c = 'Lead';
                
                acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('POS').getRecordTypeId();
                accLIst.add(acc);
            }
        try{
        if(!accLIst.IsEmpty())insert accLIst;
        }
        catch(exception e){
            system.debug(e.getMessage());
        }
    }
}