public class Commerce_StoreLocatorService implements Commerce_Int_StoreLocatorService {

    public static List<Commerce_LocationWrapper> fetchLocations(Integer distance, String unit, Decimal userLatitude, Decimal userLongitude){

        Decimal lat = userLatitude;
        Decimal lng = userLongitude;

        Location loc1 = Location.newInstance(lat,lng);
        Location loc2;

        Decimal dist;
        Decimal roundedDist;

        List<Commerce_LocationWrapper> storeWrapperList = new List<Commerce_LocationWrapper>();

        String userId = UserInfo.getUserId();
        User usr = [SELECT Id, AccountId FROM User WHERE Id =: userId];
        String accId = usr.AccountId;

        //List<Schema.Location> storeList = Database.query('SELECT Id, Name, LocationType, VisitorAddressId, Store_Timings__c, Services__c, Facilities__c, (SELECT Id FROM Accounts__r), (SELECT Id, Name, Street, City, State, PostalCode, Country, Phone__c, Latitude, Longitude, Location__c FROM Addresses WHERE DISTANCE(Location__c, GEOLOCATION(' + lat + ', ' + lng + ' ), \'' + String.escapeSingleQuotes(unit) + '\') < ' + String.escapeSingleQuotes(String.valueOf(distance)) + ' ORDER BY DISTANCE(Location__c, GEOLOCATION(' + lat + ', ' + lng + ' ), \'' + String.escapeSingleQuotes(unit) + '\')) FROM Location');
       
        //List<Schema.Location> storeList = Database.query('SELECT Id, Name, Location, LocationType, VisitorAddressId, Store_Timings__c, Services__c, Facilities__c, (SELECT Id FROM Accounts__r WHERE Id =:accId), (SELECT Id, Name, Street, City, State, PostalCode, Country, Phone__c, Latitude, Longitude, Location__c FROM Addresses WHERE DISTANCE(Location__c, GEOLOCATION(' + lat + ', ' + lng + ' ), \'' + String.escapeSingleQuotes(unit) + '\') < ' + String.escapeSingleQuotes(String.valueOf(distance)) + ') FROM Location ORDER BY DISTANCE(Location, GEOLOCATION(' + lat + ', ' + lng + ' ), \'' + String.escapeSingleQuotes(unit) + '\') WHERE LocationType = \'Site\'');

        List<Schema.Location> storeList = Database.query('SELECT Id, Name, Location, LocationType, VisitorAddressId, Store_Timings__c, Services__c, Facilities__c, (SELECT Id FROM Accounts__r), (SELECT Id, Name, Street, City, State, PostalCode, Country, Phone__c, Latitude, Longitude, Location__c FROM Addresses) FROM Location WHERE LocationType = \'Site\'');

        if(!storeList.isEmpty()){
            for(Schema.Location loc : storeList){

                Commerce_LocationWrapper locWrapper = new Commerce_LocationWrapper();                

                if(!loc.Addresses.isEmpty()){

                    locWrapper.Addresses = loc.Addresses;
                    //locWrapper.Phone = loc.Addresses[0].Phone__c;
                    locWrapper.VisitorAddressId = loc.VisitorAddressId;
                    locWrapper.LocationType = loc.LocationType;
                    locWrapper.Id = loc.Id;
                    locWrapper.Name = loc.Name;
                    locWrapper.Timings = loc.Store_Timings__c;
                    locWrapper.Services = loc.Services__c;
                    locWrapper.Facilities = loc.Facilities__c;

                    if(loc.Accounts__r.size() == 0){
                        locWrapper.isDefault = false;
                    }
                    else if(loc.Accounts__r.size() > 0){
                        locWrapper.isDefault = true;
                    }
    
                    loc2 = Location.newInstance(locWrapper.Addresses[0].Latitude,locWrapper.Addresses[0].Longitude);
    
                    dist = Location.getDistance(loc1, loc2, unit);
                    roundedDist = dist.setScale(2);
    
                    locWrapper.Distance = roundedDist;
    
                    System.debug('dist->'+locWrapper.Addresses[0].Latitude);
                    storeWrapperList.add(locWrapper);
                }

            }
        }
        System.debug('storeWrapperList ' + storeWrapperList);

        return storeWrapperList;
    }

    public static List<Commerce_LocationWrapper> fetchPreferredStore(Integer distance, String unit, Decimal userLatitude, Decimal userLongitude){

        Decimal lat = userLatitude;
        Decimal lng = userLongitude;

        Location loc1 = Location.newInstance(lat,lng);
        Location loc2;

        Decimal dist;
        Decimal roundedDist;

        List<Commerce_LocationWrapper> storeWrapperList = new List<Commerce_LocationWrapper>();

        List<Schema.Location> storeList = Database.query('SELECT Id, Name, LocationType, VisitorAddressId, Store_Timings__c, Services__c, Facilities__c, (SELECT Id, Name, Street, City, State, PostalCode, Country, Phone__c, Latitude, Longitude, Location__c FROM Addresses WHERE DISTANCE(Location__c, GEOLOCATION(' + lat + ', ' + lng + ' ), \'' + String.escapeSingleQuotes(unit) + '\') < ' + String.escapeSingleQuotes(String.valueOf(distance)) + ' ORDER BY DISTANCE(Location__c, GEOLOCATION(' + lat + ', ' + lng + ' ), \'' + String.escapeSingleQuotes(unit) + '\')) FROM Location WHERE Preferred_Store__c = true AND LocationType = \'Site\'');
        

        if(!storeList.isEmpty()){
            for(Schema.Location loc : storeList){

                Commerce_LocationWrapper locWrapper = new Commerce_LocationWrapper();    
                
                System.debug('##'+loc.Addresses);

                locWrapper.Addresses = loc.Addresses;
                //locWrapper.Phone = loc.Addresses[0].Phone__c;
                locWrapper.VisitorAddressId = loc.VisitorAddressId;
                locWrapper.LocationType = loc.LocationType;
                locWrapper.Id = loc.Id;
                locWrapper.Name = loc.Name;
                locWrapper.Timings = loc.Store_Timings__c;
                locWrapper.Services = loc.Services__c;
                locWrapper.Facilities = loc.Facilities__c;

                loc2 = Location.newInstance(locWrapper.Addresses[0].Latitude,locWrapper.Addresses[0].Longitude);

                dist = Location.getDistance(loc1, loc2, unit);
                roundedDist = dist.setScale(2);

                locWrapper.Distance = roundedDist;

                storeWrapperList.add(locWrapper);
            }
        }
        System.debug('storeWrapperList ' + storeWrapperList);

        return storeWrapperList;
    }

    public static void updateDefaultStore(Id storeId){
        
        String userId = UserInfo.getUserId();
        
        User usr = [SELECT Id, AccountId FROM User WHERE Id =: userId];

        String accId = usr.AccountId;

        System.debug('accId ' + accId);
	
        List<Account> accList = new List<Account>([SELECT Id FROM Account WHERE Id =: accId]);
        
        if(!accList.isEmpty()){
            accList[0].Default_Store__c = storeId;
        	update accList[0];
        }
        
    }

    public static void updateLocations(){
        
        String userId = UserInfo.getUserId();
        
        List<Schema.Location> locList = [SELECT Id, Name, Latitude, Longitude, VisitorAddressId, (SELECT Id, Name, Location__Latitude__s, Location__Longitude__s FROM Addresses) FROM Location WHERE VisitorAddressId != ''];

        System.debug('locList-> ' + locList);

        for (Integer i = 0; i < locList.size(); i++) {
            locList[i].Latitude = locList[i].Addresses[0].Location__Latitude__s;
            locList[i].Longitude = locList[i].Addresses[0].Location__Longitude__s;            
        }
        update locList;
    }

}