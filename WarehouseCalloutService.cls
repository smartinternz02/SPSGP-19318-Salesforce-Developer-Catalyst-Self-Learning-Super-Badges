public with sharing class WarehouseCalloutService {
    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    
    @future(callout=true)
    public static void runWarehouseEquipmentSync() {
        //ToDo: complete this method to make the callout (using @future) to the
        //      REST endpoint and update equipment on hand.
    
        
        HttpResponse response = getResponse(); 
        if(response.getStatusCode() == 200)
        {
            List<Product2> results = getProductList(response); //get list of products from Http callout response
            
            if(results.size() >0)
            upsert results Warehouse_SKU__c; //Upsert the products in your org based on the external ID SKU
        }
        
    }
        //Get the product list from the external link
        public static List<Product2> getProductList(HttpResponse response)
        {
            
            List<Object> externalProducts = (List<Object>) JSON.deserializeUntyped(response.getBody()); //desrialize the json response
            List<Product2> newProducts = new List<Product2>();
            
            for(Object p : externalProducts)
            {
                Map<String, Object> productMap = (Map<String, Object>) p;
                Product2 pr = new Product2();
                //Map the fields in the response to the appropriate fields in the Equipment object
                pr.Replacement_Part__c = (Boolean)productMap.get('replacement');
                pr.Cost__c = (Integer)productMap.get('cost');
                pr.Current_Inventory__c = (Integer)productMap.get('quantity');
                pr.Lifespan_Months__c = (Integer)productMap.get('lifespan') ;
                pr.Maintenance_Cycle__c = (Integer)productMap.get('maintenanceperiod');
                pr.Warehouse_SKU__c = (String)productMap.get('sku');
                pr.ProductCode = (String)productMap.get('_id');
                pr.Name = (String)productMap.get('name');
                
            
                newProducts.add(pr);
            }
            
            return newProducts;
            
        }
        
        // Send Http GET request and receive Http response
    
    public static HttpResponse getResponse() {
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        
        return response;
        
    }
    }