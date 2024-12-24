@istest
public class CalloutMockForTestClass implements HttpCalloutMock{
    public HttpResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        String body ='[{  "status": "SENT", "responseMessage": null, "messageId": 1, "id": "13BF014A3A6747FA8799346E987AB406"  }]';
        res.setBody(body);
        return res;
    }
}