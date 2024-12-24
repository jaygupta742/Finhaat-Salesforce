public class setmockhttpforfinhaat implements HttpCalloutMock {
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);    
        res.setBody ('{"leadId": "001H4000004g2qzIAA",    "requestId": "172542REQ1434",    "returnCode": null,    "message": "Send for E-sign process not compelete",    "success": "failed"}');
        return res;
    }

}