@isTest(SeeAllData = true) public class emailToTicketHandlerTest {
    @isTest public static void TestinBoundEmail(){
        Case Cas = new Case(Description='Test Class');
        insert Cas ;
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        // intialize the list string to store emails.
        List<string> emails = new List<string>{'jaysgupta742@gmail.com'};
            
            email.subject = 'Create case';
        email.fromAddress = 'someaddress@email.com';
        //assigning the emails to toAddresses 
        email.toAddresses = emails;
        email.plainTextBody = 'email body';
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
            
            emailToTicketHandler  testInbound=new emailToTicketHandler ();
        testInbound.handleInboundEmail(email, env);
    }
}