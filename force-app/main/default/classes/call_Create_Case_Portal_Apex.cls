/**
 * Using this apex to get all user & Org information for Portal component
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
public without sharing class call_Create_Case_Portal_Apex {
    
@AuraEnabled
    public static Map<String, String> getUserAndOrgInfo() {
        system.debug('Inside getUserAndOrgInfo');
        
        Map<String, String> info = new Map<String, String>();
        
        // Fetch user information
        User currentUser = [SELECT Name, Email,Payment_Checkboxes__c, MobilePhone FROM User WHERE Id = :UserInfo.getUserId()];
        
        // Fetch organization information
        Organization orgInfo = [SELECT Name FROM Organization LIMIT 1];
        
        // Add user and org info to the map
        info.put('userName', currentUser.Name);
        info.put('orgName', orgInfo.Name);
        info.put('userEmail', currentUser.Email);
        info.put('paymentCheckboxes', String.valueOf(currentUser.Payment_Checkboxes__c));

        // Check if MobilePhone is not null before adding it
        if (currentUser.MobilePhone != null) {
            info.put('userMobile', currentUser.MobilePhone);
        }else{
            info.put('userMobile', '');
        }
        
        system.debug('info-- ' + info);
        return info;
    }
}