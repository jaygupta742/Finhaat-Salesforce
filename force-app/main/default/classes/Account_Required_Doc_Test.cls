@IsTest
public class Account_Required_Doc_Test {
    @IsTest
    public static void Test_Account_Required_Test(){
        
        
        Account acc = new Account();
        //  String recordtype = [Select Id from RecordType where (Name='Person Account') and (SobjectType='Account')].id;
        // acc.RecordTypeId= recordtype;
        acc.FirstName='test';
        acc.LastName='test';
        //  acc.DDM3__Email__c='acctest@gmail.com';
        acc.PersonMobilePhone='123654789';
        insert acc;
        
        list<Required_Documents__c> rdlist=new list<Required_Documents__c>();
        Required_Documents__c rd=new Required_Documents__c();
        rd.Doc_Type__c = 'Post Graduate All Semester Marksheets';
        rd.Account__c = acc.id;
        rd.Status__c = 'Yet to Submit';
        rd.Approved__c = true;
        rd.Doc_Link__c = 'https://finhaatinsurancebrokingpvtltd--subhadeep1.sandbox.my.salesforce.com/sfc/p/1e0000000Nod/a/1e000000Cf0X/w7NvUqEzgIsCduF4r4VATJOlG_y.uJGw3Sya8ALabvo';
        rdlist.add(rd);
        
        
        insert rdlist;
        
        Attachment doc1 = new Attachment();
        doc1.Body = Blob.valueOf('test');
        doc1.Name = 'test';
        doc1.parentId = acc.Id;
        doc1.IsPrivate = false;
        insert doc1;
        
        test.startTest();
        // Test.setMock(HttpCalloutMock.class, new Example_Callout());
        list<Account_Required_Doc.wrap_files> wlist=new list<Account_Required_Doc.wrap_files>();
        
        Account_Required_Doc.wrap_files w=new  Account_Required_Doc.wrap_files(rd);
        w.cd_id = rd.id;
        w.cv_id = rd.id;
        
        w.rd =  rd;
        w.file_name='f1';
        String b111 = 'StringToBlob';
        Blob b1111 = Blob.valueof(b111);
        w.file_content=b1111;
        wlist.add(w);
        
        Account_Required_Doc.wrap_files w2=new  Account_Required_Doc.wrap_files(rd);
        w2.file_name='f1';
        String b112 = 'StringToBlob';
        Blob b1112 = Blob.valueof(b112);
        w2.file_content=b1112;
        wlist.add(w2);
        
        Apexpages.currentPage().getParameters().put('id', acc.id);
        ApexPages.StandardController sc12 = new ApexPages.StandardController(acc);
        Account_Required_Doc obj11 = new Account_Required_Doc(sc12);
        
        String b5 = 'StringToBlob';
        Blob b55 = Blob.valueof(b5);
        obj11.rid = acc.id;
        obj11.wrap_doc_list = wlist;
        obj11.SaveRecords();
        
        test.stopTest();
    }
}