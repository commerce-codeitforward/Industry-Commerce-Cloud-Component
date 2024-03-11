public interface Commerce_Int_StoreLocatorService {

    List<Commerce_LocationWrapper> fetchLocations(Integer distance, String unit, Decimal userLatitude, Decimal userLongitude);
    List<Commerce_LocationWrapper> fetchPreferredStore(Integer distance, String unit, Decimal userLatitude, Decimal userLongitude);
    void updateDefaultStore(Id storeId);
    void updateLocations();
}