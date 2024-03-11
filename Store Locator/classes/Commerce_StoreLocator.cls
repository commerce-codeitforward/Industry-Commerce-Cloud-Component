public without sharing class Commerce_StoreLocator {

    @AuraEnabled (cacheable=true)
    public static List<Commerce_LocationWrapper> fetchLocations(Integer distance, String unit, Decimal userLatitude, Decimal userLongitude, String serviceClassName){
        Type serviceType = Type.forName(serviceClassName);
        Commerce_Int_StoreLocatorService serviceClass = (Commerce_Int_StoreLocatorService)serviceType.newInstance();
        return serviceClass.fetchLocations(distance, unit, userLatitude, userLongitude);
    }

    @AuraEnabled (cacheable=true)
    public static List<Commerce_LocationWrapper> fetchPreferredStore(Integer distance, String unit, Decimal userLatitude, Decimal userLongitude, String serviceClassName){
        Type serviceType = Type.forName(serviceClassName);
        Commerce_Int_StoreLocatorService serviceClass = (Commerce_Int_StoreLocatorService)serviceType.newInstance();
        return serviceClass.fetchPreferredStore(distance, unit, userLatitude, userLongitude);
    }

    @AuraEnabled
    public static void updateDefaultStore(Id storeId, String serviceClassName){
        Type serviceType = Type.forName(serviceClassName);
        Commerce_Int_StoreLocatorService serviceClass = (Commerce_Int_StoreLocatorService)serviceType.newInstance();
        serviceClass.updateDefaultStore(storeId);
    }

    @AuraEnabled
    public static void updateLocations(String serviceClassName){
        Type serviceType = Type.forName(serviceClassName);
        Commerce_Int_StoreLocatorService serviceClass = (Commerce_Int_StoreLocatorService)serviceType.newInstance();
        serviceClass.updateLocations();
    }
}