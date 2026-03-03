
/**
 * @description Service class to integrate with the Bitly API for asynchronous URL shortening.
 * This class handles external callouts and adheres to bulkification standards for correct and efficient processing.
 * @author Mauricio Zelarayán
 * @date 2025-11-14
 */

public with sharing class BitlyIntegrationService {

    private static final String token = System.Label.Bitly_Access_Token; //  Custom Label to store the Bitly access token
    private static final String BITLY_ENDPOINT = 'https://api-ssl.bitly.com/v4/shorten';

    /**
     * @description Generates and updates short URLs for a set of Industrial Tank records asynchronously.
     * This method is marked @future(callout=true) to allow the necessary external connection.
     * @param tankIdsSet A Set of Industrial_Tank__c IDs that require URL generation.
     * @return void
     */
    @future(callout=true)
    public static void generateShortUrl(Set<Id> tankIdsSet) {
        
        if(tankIdsSet == null || tankIdsSet.isEmpty()) {
            System.debug(LoggingLevel.WARN, 'An attempt is being made to insert an empty or null list.'); 
            return; // prevent the code from continuing
        }

        List<Industrial_Tank__c> tanksList = [SELECT Id, Long_URL__c FROM Industrial_Tank__c WHERE Id IN : tankIdsSet];
        List<Industrial_Tank__c> tanksToUpdate = new List<Industrial_Tank__c>();

        for(Industrial_Tank__c tank : tanksList) {

            // If the Long_URL__c field is empty, we skip the tank
            if(String.isBlank(tank.Long_URL__c)){
                continue;
            }

            //If this point is reached, a debug notification is triggered.
            System.debug(LoggingLevel.INFO, 'A callout to the Bitly API is going to be performed');
            try {
                // Make a callout to the Bitly API
                Http http = new Http();
                HttpRequest request = new HttpRequest();

                // Request Config
                request.setEndpoint(BITLY_ENDPOINT);
                request.setMethod('POST');
                request.setHeader('Content-Type', 'application/json'); // Informs to the system that the content is in JSON format
                request.setHeader('Authorization', 'Bearer ' + token); // Api Token

                // Now, we need to create the body of the request
                String body = '{"long_url": "' + tank.Long_URL__c + '"}';
                request.setBody(body);

                // Send the request and get the response. Then, finish de callout
                HttpResponse response = http.send(request);
  
                // At this point, we verify if the response is successful
                if(response.getStatusCode() == 200 || response.getStatusCode() == 201){

                    System.debug(LoggingLevel.INFO, 'The callout to the Bitly API was successful');
                    
                    // If the response is successful, we need to parse the response. 
                    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

                    // Store de response in a variable, then assign the value to the Short_URL__c field.
                    String shortUrl = (String) responseMap.get('link');
                    tank.Short_URL__c = shortUrl;

                    // save the tank in the list to be updated
                    tanksToUpdate.add(tank);
                }
                else{
                    System.debug(LoggingLevel.ERROR, 'An error has occurred while calling the Bitly API: ' + response.getBody());
                }

            } catch (Exception e) {
                // Log the callout error
                System.debug(LoggingLevel.ERROR, 'An callout error has occurred: ' + e.getMessage());
            }
        }
        
        // If this point is reached, update the tanks
        if(tanksToUpdate != null && !tanksToUpdate.isEmpty()){
            update tanksToUpdate;
        }
    }
}