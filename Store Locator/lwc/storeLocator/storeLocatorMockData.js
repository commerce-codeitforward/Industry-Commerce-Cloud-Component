const mockedPreferredStoreData = [
  {
    Addresses: [
      {
        ParentId: "131DI000000LJ8ZYAW",
        State: "mn",
        Phone__c: "1112223333",
        Street: "2930 Magnolia Dr",
        PostalCode: "55125",
        Country: "US",
        Latitude: "44.906101000000000",
        Id: "130DI0000004K81YAE",
        City: "woodbury",
        Location__c: { latitude: 44.906101, longitude: -92.932286 },
        Longitude: "-92.932286000000000",
        Name: "A00000001"
      }
    ],
    Distance: 899.91,
    Id: "131DI000000LJ8ZYAW",
    LocationType: "Site",
    Name: "MSP",
    Timings: "<p>Mon-Wed 10:00 AM - 11:00 PM</p>",
    VisitorAddressId: "130DI0000004K81YAE"
  }
];

const mockedMapMarker = [
  {
    location: {
      City: "woodbury",
      Country: "US",
      PostalCode: "55125",
      State: "mn",
      Street: "2930 Magnolia Dr"
    },
    icon: "custom:custom26",
    title: "MSP",
    description: "2930 Magnolia Dr, woodbury, 55125",
    Id: "131DI000000LJ8ZYAW",
    distance: 899.91,
    timings: "<p>Mon-Wed 10:00 AM - 11:00 PM</p>",
    storetime: "Open until 11:00 PM",
    value: "131DI000000LJ8ZYAW"
  }
];

export { mockedPreferredStoreData, mockedMapMarker };
