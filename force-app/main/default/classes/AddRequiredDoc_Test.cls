@IsTest
public class AddRequiredDoc_Test {
    @IsTest
    public static void Test_AddRequiredDoc_Test(){
        
        
        Account acc = new Account();
        Id rtypeId = [SELECT Id FROM RecordType WHERE Name ='POS' Limit 1].Id;
        acc.LastName = 'Test';
        acc.WhatsApp_No__c = '7777777777';
        //acc.PersonMobilePhone = '8888888888';
        //acc.LastName = 'Test';
        acc.RecordTypeId = rtypeId;
        insert acc;
        
        
        list<Master_Document__c> masterlist = new list<Master_Document__c>();
        
        Master_Document__c mdd = new Master_Document__c();
        mdd.Name='Test Master Document';
        mdd.Stages__c='POS';
        masterlist.add(mdd);
        insert masterlist;
        
        
        List<AddRequiredDoc.wrapper> llll1=new List<AddRequiredDoc.wrapper>();
        
        
        
        list<Required_Documents__c> rdlist=new list<Required_Documents__c>();
        Required_Documents__c rd=new Required_Documents__c();
        rd.Doc_Type__c = 'Post Graduate All Semester Marksheets';
        rd.Account__c = acc.id;
        rd.Approved__c = true;
        rd.Doc_Link__c = 'https://finhaatinsurancebrokingpvtltd--subhadeep1.sandbox.my.salesforce.com//sfc/p/1e0000000Nod/a/1e000000Cf0X/w7NvUqEzgIsCduF4r4VATJOlG_y.uJGw3Sya8ALabvo';
        rdlist.add(rd);
        insert rdlist;
        
        
        
        
        //AddRequiredDoc.educationhistory();
        
        try{
            AddRequiredDoc.getinstant(acc.Id);
            AddRequiredDoc.onsave(String.valueOf(acc.Id), json.serialize(rdlist) , 'MFI');
            AddRequiredDoc.onsave(String.valueOf(mdd.Id), json.serialize(rdlist) , 'MFI');	// Wrong Data passed to generate Error
            // AddRequiredDoc.onsavenotify(String.valueOf(acc.Id), json.serialize(rdlist) , 'GERMANY');
            //AddRequiredDoc.onsavenotify(String.valueOf(mdd.Id), json.serialize(rdlist) , 'GERMANY');
        }
        catch(Exception e){
            system.debug('Error'+e.getMessage());
        }
        try{
            // AddRequiredDoc.onsavenotify(String.valueOf(acc.Id), json.serialize(rdlist) , 'GERMANY');
            // AddRequiredDoc.onsavenotify(String.valueOf(mdd.Id), json.serialize(rdlist) , 'GERMANY');
        }
        catch(Exception e){
            system.debug('Error'+e.getMessage());
        }
        
        try{
            AddRequiredDoc.getmasterdoc('MFI'); 
            AddRequiredDoc.getmasterdoc('MFI'); 
        }
        catch(Exception e){
            system.debug('Error'+e.getMessage());
        }
        
    }
    
}