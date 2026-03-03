/**
 * @description Mock class for Bitly API callout.
 * @description This class is used to mock the Bitly API callout.
 * @author Mauricio Zelarayán
 * @date 2025-11-14
 */
@isTest
global class BitlyCalloutMock implements HttpCalloutMock{
 
    /**
     * @description Receive the HTTP callout request and returns a simulated response object.
     * This method is required by the HttpCalloutMock interface.
     * @param req The HTTP request made by the service class.
     * @return HttpResponse A fake response containing a status code of 200 and a mock link.
     */
    public HttpResponse respond(HttpRequest req) {
        // Simulate a response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');

        // Simulate the JSON
        res.setBody('{"link":  "https://bit.ly/TEST1234", "long_url": "https://www.salesforce.com"}');
        res.setStatusCode(200);

        return res;
    }
}

