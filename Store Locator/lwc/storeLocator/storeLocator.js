import { LightningElement, wire, track, api } from 'lwc';
import { getPicklistValues, getObjectInfo} from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import userId from '@salesforce/user/Id';
import communityPath from '@salesforce/community/basePath';


import fetchLocations from '@salesforce/apex/B2B2C_StoreLocator.fetchLocations';
import updateDefaultStore from '@salesforce/apex/B2B2C_StoreLocator.updateDefaultStore';
import fetchPreferredStore from '@salesforce/apex/B2B2C_StoreLocator.fetchPreferredStore';
import updateLocations from '@salesforce/apex/B2B2C_StoreLocator.updateLocations';
import LOCATION_OBJECT from '@salesforce/schema/Location';
import TYPE_FIELD from '@salesforce/schema/Location.LocationType';
import { mockedPreferredStoreData, mockedMapMarker } from './storeLocatorMockData';

     
    export default class StoreLocator extends NavigationMixin(LightningElement)  {

        @track error;
        @track mapMarkers = [];
        @track markersTitle = 'Accounts';
        @track zoomLevel = 7;
        @track record;
        @track selectedStoreId;
        @track selectedStoreName;
        @track selectedStoreStreet;
        @track selectedStoreCity;
        @track selectedStoreState;
        @track selectedStoreZipCode;
        @track selectedStorePhone;
        @track selectedStoreTimings;
        @track selectedStoreFacilities;
        @track selectedStoreServices;
        @track searchInput = '';


        @api serviceClassName;
        @api distance;
        @api unit;
        @api isLoading = false;
        @api searchIconUrl = '';


        maxRadius;

        timingsMap = {};
        mapData = [];
        value = ['Site'];
        splitArray = [];
        finalArray = [];
        days = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
        
        loggedinUser = false;
        showStoreDetails = false;
        isSelected = false;
        foundStore = false;

        openTime;
        storeTimings;
        type;
        address;
        selectedMarkerValue = 'SF1';
        userLatitude;
        userLongitude;
        filterCount = 1;
        date;
        day;
        weekday;
        iconName = '';
        displayClass = 'slds-hide';



        get selectedValues() {
            return this.value.join(',');
        }

        handleChange(e) {
            this.value = e.detail.value;
        }

        @wire(getObjectInfo, { objectApiName: LOCATION_OBJECT })
        objectInfo;
      
        // this can be used to pull in the picklist values dynamically instead of the hardcoded values
        /* @wire(getPicklistValues, {
          recordTypeId: "$objectInfo.data.defaultRecordTypeId",
          fieldApiName: TYPE_FIELD
        })
        typePicklistValues; */

        filterPicklistValues = [
            {
              "attributes": null,
              "label": "Site",
              "validFor": [],
              "value": "Site"
            }
        ];


        connectedCallback(){
            this.isPreview = this.isInSitePreview();

            // load the location and get preferred store if we're not in experience builder
            // otherwise, load mock data
            if(!this.isPreview){
                this.isLoading = true;
                this.searchIconUrl = communityPath + '/assets/icons/utility-sprite/svg/symbols.svg#search';

                if(userId){
                    this.loggedinUser = true;
                }

                this.maxRadius = this.distance;

                navigator.geolocation.getCurrentPosition(
                function (position) {
                    this.userLatitude = position.coords.latitude;
                    this.userLongitude = position.coords.longitude;

                    if(this.userLatitude && this.userLongitude){
                        this.getPreferredStore();
                        this.getUserLocation();
                    }
                }.bind(this),
                function (e) {
                    
                }.bind(this),
                {
                    enableHighAccuracy: true,
                }
                );

                var today = new Date();
                this.date=today.toISOString();
                this.day = today.getDay();

                updateLocations({ serviceClassName: this.serviceClassName })
                .then((data) => {
                })
                .catch((error) => {
                    this.error = error;
                    this.isLoading = true;
                });
            }else{
                this.foundStore = true;
                this.isLoading = false;
                let mockMapMarker = mockedMapMarker;
                this.mapMarkers = mockMapMarker;
            }
        }  

        getUserLocation(){
            navigator.geolocation.getCurrentPosition(
                function (position) {
                  this.userLatitude = position.coords.latitude;
                  this.userLongitude = position.coords.longitude;
                }.bind(this),
                function (e) {
                }.bind(this),
                {
                  enableHighAccuracy: true,
                }
              );
              this.searchInput = 'My Location';

              this.mapMarkers = [];

              this.foundStore = false;

              fetchLocations({ distance: this.distance, unit: this.unit, userLatitude: this.userLatitude, userLongitude: this.userLongitude, serviceClassName: this.serviceClassName })
              .then((data) => {
  
                if(data.length > 0){

                  this.isLoading = false;
                  this.foundStore = false;
  
                  this.mapData = data;
                  this.mapMarkers = [];
  
                  data.forEach(result => {
                      if(result.Distance <= this.distance){
  
                          this.foundStore = true;
  
                          // process the timings for the stores
                          this.processTimings(result);

                          this.mapMarkers = [...this.mapMarkers,
                              {
                                  location: {
                                      City: result.Addresses[0].City,
                                      Country: result.Addresses[0].Country,
                                      PostalCode: result.Addresses[0].PostalCode,
                                      State: result.Addresses[0].State,
                                      Street: result.Addresses[0].Street,
                                  },
                                  icon: 'custom:custom26',
                                  title: result.Name,
                                  description: result.Addresses[0].Street + ', ' + result.Addresses[0].City + ', ' + result.Addresses[0].PostalCode,
                                  Id: result.Id,
                                  distance: result.Distance,
                                  timings: result.Timings,
                                  storetime: this.storeTimings,
                                  phone: result.Phone,
                                  facilities: result.Facilities,
                                  services: result.Services,
                                  isDefault: result.isDefault,
                                  value: result.Id
                              }
                              ];
                      }
                      else{
                          this.displayClass = 'slds-p-around--small';
                      }                      
                  });
  
                  this.error = undefined;
                }
                  
              })
              .catch((error) => {
                  this.error = error;
                  this.isLoading = true;
                  console.log(JSON.parse(JSON.stringify(error)));
              });

        }

        getPreferredStore(){
            this.isLoading = true;

            fetchPreferredStore({ distance: this.distance, unit: this.unit, userLatitude: this.userLatitude, userLongitude: this.userLongitude, serviceClassName: this.serviceClassName })
            .then((data) => {

                this.isLoading = false;
                this.foundStore = false;

                this.mapData = data;
                this.mapMarkers = [];

                data.forEach(result => {
                    this.foundStore = true;

                    // process the timings for the stores
                    this.processTimings(result);

                    this.mapMarkers = [...this.mapMarkers,
                        {
                            location: {
                                City: result.Addresses[0].City,
                                Country: result.Addresses[0].Country,
                                PostalCode: result.Addresses[0].PostalCode,
                                State: result.Addresses[0].State,
                                Street: result.Addresses[0].Street,
                            },
                            icon: 'custom:custom26',
                            title: result.Name,
                            description: result.Addresses[0].Street + ', ' + result.Addresses[0].City + ', ' + result.Addresses[0].PostalCode,
                            Id: result.Id,
                            distance: result.Distance,
                            timings: result.Timings,
                            storetime: this.storeTimings,
                            phone: result.Phone,
                            facilities: result.Facilities,
                            services: result.Services,
                            isDefault: result.isDefault,
                            value: result.Id
                        }
                        ];                    
                });

                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.isLoading = true;
                console.log(JSON.parse(JSON.stringify(error)));
            });
        }

        handleSearch() {
            this.isLoading = true;

            if(this.searchInput != undefined){
                fetchLocations({ distance: this.distance, unit: this.unit, userLatitude: this.userLatitude, userLongitude: this.userLongitude, serviceClassName: this.serviceClassName })
                .then((data) => {
    
                    this.isLoading = false;
                    this.foundStore = false;
    
                    this.mapData = data;
                    this.mapMarkers = [];
    
                    if(this.searchInput != 'My Location'){
                        // if the search is no My Location then we need to show the stores that match the search input
                        data.forEach(result => {
                            if(this.matchesSearchInput(result, this.searchInput)){
                                this.foundStore = true;
                                
                                // process the timings for the stores
                                this.processTimings(result);
        
                                this.mapMarkers = [...this.mapMarkers,
                                    {
                                        location: {
                                            City: result.Addresses[0].City,
                                            Country: result.Addresses[0].Country,
                                            PostalCode: result.Addresses[0].PostalCode,
                                            State: result.Addresses[0].State,
                                            Street: result.Addresses[0].Street,
                                        },
                                        icon: 'custom:custom26',
                                        title: result.Name,
                                        description: result.Addresses[0].Street + ', ' + result.Addresses[0].City + ', ' + result.Addresses[0].PostalCode,
                                        Id: result.Id,
                                        distance: result.Distance,
                                        timings: result.Timings,
                                        storetime: this.storeTimings,
                                        phone: result.Phone,
                                        facilities: result.Facilities,
                                        services: result.Services,
                                        isDefault: result.isDefault,
                                        value: result.Id
                                    }
                                ];
                            }
                            else{
                                this.displayClass = 'slds-p-around--small';
                            }                      
                        });
                    }else{
                        // if the search is My Location then we need to show all the stores
                        data.forEach(result => {
                            this.foundStore = true;
                                
                            // process the timings for the stores
                            this.processTimings(result);
        
                            this.mapMarkers = [...this.mapMarkers,
                                {
                                    location: {
                                        City: result.Addresses[0].City,
                                        Country: result.Addresses[0].Country,
                                        PostalCode: result.Addresses[0].PostalCode,
                                        State: result.Addresses[0].State,
                                        Street: result.Addresses[0].Street,
                                    },
                                    icon: 'custom:custom26',
                                    title: result.Name,
                                    description: result.Addresses[0].Street + ', ' + result.Addresses[0].City + ', ' + result.Addresses[0].PostalCode,
                                    Id: result.Id,
                                    distance: result.Distance,
                                    timings: result.Timings,
                                    storetime: this.storeTimings,
                                    phone: result.Phone,
                                    facilities: result.Facilities,
                                    services: result.Services,
                                    isDefault: result.isDefault,
                                    value: result.Id
                                }
                            ];
                        });
                    }
    
                    this.error = undefined;
                })
                .catch((error) => {
                    this.error = error;
                    this.isLoading = false;
                    console.log(JSON.parse(JSON.stringify(error)));
                });
            }
            
        }

        handlePicklistChange(event){
            this.type = event.target.value;
            this.value = event.detail.value;
            this.filterCount = this.value.length; 
        }

        handleSliderChange(event){
            this.distance = event.target.value;
        }

        handleApplybtn(){
            //this.mapMarkers = [];
            if(this.searchInput == 'My Location'){
                this.getUserLocation();
            }
            else{
                this.handleSearch();
            }
        }

        handleOnChange(event){
            this.searchInput = event.target.value;
        }

        handleKeyPress(event){
            if(event.keyCode == 13){
                this.handleSearch();
            }
        }

        handleMarkerSelect(event) {
            this.selectedMarkerValue = event.detail.selectedMarkerValue;
        }    

        handleStoreSelect(event){

            this.selectedStoreId = event.target.dataset.store;
            this.selectedStoreStreet = event.target.dataset.street;
            this.selectedStoreCity = event.target.dataset.city;
            this.selectedStoreState = event.target.dataset.state;
            this.selectedStoreZipCode = event.target.dataset.zipcode;
            this.selectedStoreName = event.target.dataset.name;
            this.selectedStorePhone = event.target.dataset.phone;
            this.selectedStoreTimings = event.target.dataset.timings;
            this.selectedStoreFacilities = event.target.dataset.facilities;
            this.selectedStoreServices = event.target.dataset.services;

            this.showStoreDetails = true;

            //console.log('clicked button id->' + event.target.dataset.store);

            updateDefaultStore({ storeId: this.selectedStoreId, serviceClassName: this.serviceClassName })
            .then(result => {
                console.log('success');
                this.showToastMsg();
            })
            .catch(error => {
                this.error = error;
                console.log(error);
            });

            this.iconName = '';

            var btnid = event.currentTarget?.dataset.store;
            console.log(btnid);

            this.mapMarkers.forEach(element => {
                
                var temp = this.template.querySelector("[data-store='" + element.Id + "']");
                temp.label = 'Make Default'
                temp.variant = 'brand';
                temp.iconName = '';
                temp.class = '';

                if(element.Id === btnid){
                    temp.label = 'Default Store';
                    temp.variant = 'neutral';
                    temp.iconName = 'utility:check';
                    temp.class = 'btn-inverse';
                }

            });

        }

        handleGuestClick(){
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'Login'
                }
            });
        }

        handleTileClick(e){
            var btnid = e.currentTarget?.dataset.id;


            this.mapMarkers.forEach(element => {
                
                var temp = this.template.querySelector("[data-id='" + element.Id + "']");
                temp.classList.remove('product-option_line-item-selected');

                if(element.Id === btnid){
                    temp.classList.add('product-option_line-item-selected');
                }

            });
        }

        showToastMsg(){
            const evt = new ShowToastEvent({
                title: 'Success',
                message: 'Default store has been updated.',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }

        /**
         * helper function that checks the search input against the store name, city, and postal code
         */
        matchesSearchInput(result, searchInput) {
            return result.Name.toUpperCase().includes(searchInput.toUpperCase()) || 
                   (result.Addresses[0].City && result.Addresses[0].City.toUpperCase() == searchInput.toUpperCase()) || 
                   (result.Addresses[0].State && result.Addresses[0].State.toUpperCase() == searchInput.toUpperCase()) || 
                   (result.Addresses[0].PostalCode && result.Addresses[0].PostalCode == searchInput);
        }

        /**
         * helper function that processes the timing information
         */
        processTimings(result) {
            if (result.Timings && result.Timings.trim() !== '') {
                var storeTime = result.Timings;
                var splitArray = [];
                var timeArray = storeTime.split('<p>');
        
                for (let i = 1; i < timeArray.length; i++) {
                    const element = timeArray[i].replace(/<[^>]+>/g, '');
                    splitArray.push(element.split('-'));
                }
        
                var startDay;
                var endDay;
                var closeTime;
        
                for (let i = 0; i < splitArray.length; i++) {
                    if(splitArray[i].length == 3){
                        startDay = splitArray[i][0];
                        endDay = splitArray[i][1].substring(0,3);
                        closeTime = splitArray[i][2].substr(1);
                    }
                    else if(splitArray[i].length == 2){
                        startDay = splitArray[i][0].substring(0,3);
                        endDay = startDay;
                        closeTime = splitArray[i][1].substr(1);
                    }
                    else if(splitArray[i].length == 1){
                        startDay = splitArray[i][0].substring(0,3);
                        endDay = startDay;
                        closeTime = splitArray[i][0].substr(4);
                    }
                    if(this.day >= this.days.indexOf(startDay) && this.day <= this.days.indexOf(endDay))
                        break;
                }
        
                if(closeTime == 'Closed'){    
                    this.storeTimings = closeTime;
                }else{
                    this.storeTimings = 'Open until ' + closeTime;
                }
            }
        }
        

        /**
         * helper class that checks if we are in site preview mode
         */
        isInSitePreview() {
            let url = document.URL;
            
            return (url.indexOf('sitepreview') > 0 
                || url.indexOf('livepreview') > 0
                || url.indexOf('live-preview') > 0 
                || url.indexOf('live.') > 0
                || url.indexOf('.builder.') > 0);
        }
    }