//
//  AddExperienceViewController.swift
//  Live
//
//  Created by ips on 11/05/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import MobileCoreServices
import Alamofire
import AVFoundation
import IQKeyboardManagerSwift
import GooglePlaces
import GooglePlacePicker

var TimeStamp:String{
    return "\(NSDate().timeIntervalSince1970 * 1000)"
}
extension Date {
    var ticks: UInt64 {
        return UInt64((self.timeIntervalSince1970 + 62_135_596_800) * 10_000_000)
    }
}
struct Currency {
    var currencyId:String = ""
    var currencyText:String = ""
}
struct ExperienceLangauge {
    var langaugeID:String = ""
    var langaugeName:String = ""
    var langaugeCode:String = ""
}
class AddExperienceViewController: UIViewController {
    fileprivate let kExperienceUserID = "UserId"
    fileprivate let kExperienceTitle = "Title"
    fileprivate let kExperienceCurrency = "Currency"
    fileprivate let kExperienceIsPricePerPerson = "IsPricePerPerson"
    fileprivate let kExperiencePricePerson = "PricePerson"
    fileprivate let kExperienceIsGroupPrice = "IsGroupPrice"
    fileprivate let kExperienceGroupPrice = "GroupPrice"
    fileprivate let KExperienceDiscription = "Description"
    fileprivate let kExperienceDuration = "Duration"
    fileprivate let kExperienceEffort = "Effort"
    fileprivate let kExperienceGroupSizeMin = "GroupSizeMin"
    fileprivate let kExperienceGroupSizeMax = "GroupSizeMax"
    fileprivate let kExperienceLanguages = "Languages"
    fileprivate let kExperienceLanguageId = "LanguageIds"
    fileprivate let kExperienceCollectionId = "CollectionIds"
    fileprivate let kExperienceLocationID = "LocationId"
    fileprivate let kExperienceMeetingAddress = "Address"
    fileprivate let kExperienceLatitude = "Latitude"
    fileprivate let kExperienceLongitude = "Longitude"
    fileprivate let kExperiencePostal = "Postal"
    fileprivate let kExperienceAddressRef = "AddressReference"
    fileprivate var kInstant:String = "Instant"
    fileprivate var kWheelChair:String = "Accessible"
    fileprivate var kPetFriendly:String = "PetFriendly"
    fileprivate var kFreeForChildern:String = "FreeChildren"
    fileprivate var kFreeForElderly:String = "FreeElderly"
    fileprivate let kExperienceRistriction = "Restrictions"
    fileprivate let kExperienceOccurrences = "Occurrences"
    fileprivate let kExperienceImages = "Images"
    fileprivate let kExperienceVideos = "Videos"
    fileprivate let kExperienceBlock:String = "IsBlock"
    fileprivate let kExeriencePricePerPersonHourly:String = "PricePersonHourly"
    fileprivate let kExerienceGroupPriceHourly:String = "GroupPriceHourly"
    
    fileprivate  var kRecurrence = "Recurrence"
    fileprivate  var kRecurrenceDay = "RecurrenceDays"
    fileprivate  var kTime = "Time"
    
    @IBOutlet var buttonBack:UIButton!
    @IBOutlet var lblTitle:UILabel!
    @IBOutlet var buttonAddMedia:UIButton!
    @IBOutlet var buttonAddMediaWidth:NSLayoutConstraint!
    @IBOutlet var tableViewAddExperience:UITableView!
    @IBOutlet var tableViewHeaderView:UIView!
    @IBOutlet var tableViewFooterView:UIView!
    @IBOutlet var lblInstanceExperience:UILabel!
    @IBOutlet var lblWheelchairAccessible:UILabel!
    @IBOutlet var lblPetFriendly:UILabel!
    @IBOutlet var lblFreeChildren:UILabel!
    @IBOutlet var lblNavTitle:UILabel!
    @IBOutlet var lblPrice:UILabel!
    @IBOutlet var lblPricePerPerson:UILabel!
    @IBOutlet var lblPricePerGroup:UILabel!
    @IBOutlet var lblActiveExperience:UILabel!
    @IBOutlet var lblMinGuestNumber:UILabel!
    @IBOutlet var lblMaxGuestNumber:UILabel!
    @IBOutlet var imgUser:ImageViewForURL!
    @IBOutlet var lblUserName:UILabel!
    @IBOutlet var lblUserCity:UILabel!
    @IBOutlet var collectionPreview:UICollectionView!
    @IBOutlet var lblTesting:UILabel!
    @IBOutlet var txtExperienceTitle:UITextView!
    @IBOutlet var lblExperienceTitleLimit:UILabel!
    @IBOutlet var txtTitleOfExperience:TweeActiveTextField!
    @IBOutlet var txtCurrency :TweeActiveTextField!
    @IBOutlet var txtPricePerPerson:TweeActiveTextField!
    @IBOutlet var txtPricePerGroup:TweeActiveTextField!
    @IBOutlet var imgPricePerPerson:UIImageView!
    @IBOutlet var imgPricePerGroup:UIImageView!
    @IBOutlet var txtDescriptionOfExperience:TweeActiveTextField!
    @IBOutlet var txtExperienceDescription:UITextView!
    @IBOutlet var lblExperienceDescriptionLimit:UILabel!
    @IBOutlet var txtExperienceEffort:TweeActiveTextField!
    @IBOutlet var txtExperienceDuration:TweeActiveTextField!
    @IBOutlet var buttonReduceMinGuest:UIButton!
    @IBOutlet var buttonAddMinGuest:UIButton!
    @IBOutlet var buttonReduceMaxGuest:UIButton!
    @IBOutlet var buttonAddMaxGuest:UIButton!
    @IBOutlet var lblMinimumNumberOfGuest:UILabel!
    @IBOutlet var lblMaximumumberOfGuest:UILabel!
    @IBOutlet var lblMaximumumberOfGuestDesc:UILabel!
    @IBOutlet var txtExperienceLangauge:UITextView!
    @IBOutlet var txtLanguageOfExperience:TweeActiveTextField!
    @IBOutlet var txtExperienceCollection:UITextView!
    @IBOutlet var txtCollectionOfExperience:TweeActiveTextField!
    @IBOutlet var priceCurrencyContainer:UIView!
    @IBOutlet var pricePersonAndGroupContainer:UIView!
    @IBOutlet var txtExperienceLocation:UITextView!
    @IBOutlet var txtLocationOfExperience:TweeActiveTextField!
    @IBOutlet var txtExperienceMeetingAdd:UITextView!
    @IBOutlet var txtMeetingAddOfExperience:TweeActiveTextField!
    @IBOutlet var txtExperiencePostalZip:UITextView!
    @IBOutlet var txtPostalZipOfExperience:TweeActiveTextField!
    @IBOutlet var txtExperienceAddReference:UITextView!
    @IBOutlet var txtAddReferenceOfExperience:TweeActiveTextField!
    @IBOutlet var txtExperienceRistriction:UITextView!
    @IBOutlet var txtRistrictionOfExperience:TweeActiveTextField!
    @IBOutlet var lblExperienceAddRefLimit:UILabel!
    @IBOutlet var lblExperienceRistrictionLimit:UILabel!
    @IBOutlet var buttonLocation:UIButton!
    @IBOutlet var buttonAddSchedule:UIButton!
    @IBOutlet var buttonSave:RoundButton!
    @IBOutlet var tableViewScheduleHeight:NSLayoutConstraint!
    @IBOutlet var tableViewSchedule:UITableView!
    @IBOutlet var isActiveInActiveContainer:UIView!
    @IBOutlet var lblDetail:UILabel!
    @IBOutlet var lblOptions:UILabel!
    
    var imageForCrop: UIImage!
    
    @IBOutlet var objInstantSwitch:UISwitch!
    @IBOutlet var objWheelChairSwitch:UISwitch!
    @IBOutlet var objPetFriendlySwitch:UISwitch!
    @IBOutlet var objFreeForChildSwitch:UISwitch!
    @IBOutlet var objFreeForEldertSwitch:UISwitch!
    @IBOutlet var objActiveExperienceSwitch:UISwitch!
    
    @IBOutlet var collectionViewContainer:UIView!
    @IBOutlet var bottomConstraintOfLocation:NSLayoutConstraint!
    @IBOutlet var buttonForgroundShadow:UIButton!
    @IBOutlet var lblSchedule:UILabel!
    @IBOutlet var heightOfPricePerPersonHourly:NSLayoutConstraint!
    @IBOutlet var txtPricePerPersonHourly:TweeActiveTextField!
    @IBOutlet var heightOfPricePerGroupHourly:NSLayoutConstraint!
    @IBOutlet var txtPricePerGroupHourly:TweeActiveTextField!
    @IBOutlet var viewPricePerPersonHourly:UIView!
    @IBOutlet var viewGroupPriceHourly:UIView!
    
    var placesClient: GMSPlacesClient = GMSPlacesClient.shared()
    var mediaDictionary:[String:Any] = [:]
    var currentUser:User?
    var selectedCurrency:Currency?
    var selectedEffort:String = ""
    var selectedLangauges:[ExperienceLangauge] = []
    var selectedCollection:[Collections] = []
    var arrayOfImages:[NSString] = []
    var arrayOfVideo:[NSString] = []
    var arrayOfThumNail:[NSString] = []
    var arrayOfPreview:[NSString] = []
    var arrayOfCurrency:[Currency] = []
    var objImagePickerController = UIImagePickerController()
    var addExperienceParameters:[String:Any] = [:]
    var durationPicker:UIDatePicker = UIDatePicker()
    var durationToolBar:UIToolbar = UIToolbar()
    let maximumNumberOfGuest:Int = 999
    var arrayOfLanguage:[ExperienceLangauge] = []
    var arrayOfExploreCollection:[Collections] = []
    var selectedCountryDetail:CountyDetail?
    let alertTitleFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Heavy", size: 17.0)!]
    let alertMessageFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Roman", size: 13.0)!]
    var newScheduleParameters:[String:Any]?
    var arrayOfSchedules:[[String:Any]] = []
    var tableViewRowheight:CGFloat{
        get{
            return 272.0//UIScreen.main.bounds.width*0.9
        }
    }
    var tableViewScheduleRowHeight:CGFloat{
        get{
            return 72.0
        }
    }
    var experienceTitleMax:Int{
        get{
            return 50
        }
    }
    var maximumTextLimit:Int{
        get{
            return 1800//600
        }
    }
    var experienceDescriptionMax:Int{
        get{
            return 300
        }
    }
    var experiencePostalCodeMax:Int{
        get{
            return 10
        }
    }
    private var selectedPage:Int = 0
    var currentSelectedPage:Int{
        get{
            return  selectedPage
        }
        set{
          self.selectedPage = newValue
            DispatchQueue.main.async {
                self.collectionPreview.reloadData()
                self.tableViewAddExperience.setContentOffset(.zero, animated: true)
                
            }
        }
    }
    var mainImage:Int?
    private var isPerson:Bool = false
    var isPricePerPerson:Bool{
        get{
            return self.isPerson
        }
        set{
            self.isPerson = newValue
            //Configure Person Price
            self.addExperienceParameters[kExperienceIsPricePerPerson] = newValue
            self.configurePricePerPerson()
        }
    }
    private var isGroup:Bool = false
    var isPricePerGroup:Bool{
        get{
            return self.isGroup
        }
        set{
            self.isGroup = newValue
            //Configure Group Price
            self.addExperienceParameters[kExperienceIsGroupPrice] = newValue
            self.configurePricePerGroup()
        }
    }
    var numberOfMinGuest:Int = 1{
        didSet{
            //ConfigureMinNumberOfGuest
            self.configureMinNumberOfGuest()
        }
    }
    var numberOfMaxGuest:Int = 1{
        didSet{
            //ConfigureMaxNumberOfGuest
            self.configureMaxNumberOfGuest()
        }
    }
    var instant:Bool = false
    var isInstant:Bool{
        get{
            return instant
        }
        set{
            self.instant = newValue
            //UpdateInstant
            self.addExperienceParameters[kInstant] = newValue ? 1 : 0
            
        }
    }
    var wheelChair:Bool = false
    var isWheelChair:Bool{
        get{
            return wheelChair
        }
        set{
            self.wheelChair = newValue
            //UpdateWheelChair
            self.addExperienceParameters[kWheelChair] = newValue ? 1 : 0
            
        }
    }
    var petFriendly:Bool = false
    var isPetFriendly:Bool{
        get{
            return petFriendly
        }
        set{
            self.petFriendly = newValue
            //UpdatePetFriendly
            self.addExperienceParameters[kPetFriendly] = newValue ? 1 : 0
            
        }
    }
    var freeforchildern:Bool = false
    var isFreeforChildern:Bool{
        get{
            return freeforchildern
        }
        set{
            self.freeforchildern = newValue
            //UpdateFreeforchildern
            self.addExperienceParameters[kFreeForChildern] = newValue ? 1 : 0
            
        }
    }
    var freeforelderly:Bool = false
    var isFreeforElderly:Bool{
        get{
            return freeforelderly
        }
        set{
            self.freeforelderly = newValue
            //UpdateFreeforelderly
            self.addExperienceParameters[kFreeForElderly] = newValue ? 1 : 0
            
        }
    }
    var isActive:Bool = false
    var isActiveExperience:Bool{
        get{
            return isActive
        }
        set{
            self.isActive = newValue
            //ConfigureActiveExperience
            self.addExperienceParameters[kExperienceBlock] = newValue ? 0 : 1

        }
    }
    var edit:Bool = false
    var isEdit:Bool{
        get{
            return edit
        }
        set{
            self.edit = newValue
        }
    }
    
    var editExperience:Experience?
    
    let tintBorderColor:UIColor = UIColor.init(red: 101.0/255.0, green: 131.0/255.0, blue: 191.0/255.0, alpha: 1.0)
    var timerReduceMinGuest:Timer?
    var timerAddMinGuest:Timer?
    var timerReduceMaxGuest:Timer?
    var timerAddMaxGuest:Timer?
    var currencyPicker:UIPickerView = UIPickerView.init()
    var currencyToolBar:UIToolbar = UIToolbar()
    var currentCurrency:String = ""
    
    var effortPicker:UIPickerView = UIPickerView.init()
    var effortToolBar:UIToolbar = UIToolbar()
    var currentEffort:String = "\(Vocabulary.getWordFromKey(key:"Soft"))"
    var araryOfEffort:[String] = ["\(Vocabulary.getWordFromKey(key:"Soft"))","\(Vocabulary.getWordFromKey(key:"Moderate"))","\(Vocabulary.getWordFromKey(key:"Hard"))","\(Vocabulary.getWordFromKey(key:"Extreme"))"]
    override func viewDidLoad() {
        isFromAddExperience = true
        super.viewDidLoad()
        self.changeTextAsLanguage()
        //Configure AddNewExperienceView
        self.configureAddExperienceView()
        //GET Currency
        self.getCurrencyList()
       
        //self.priceCurrencyContainer.layer.borderColor = UIColor.lightGray.cgColor
        //self.priceCurrencyContainer.layer.borderWidth = 0.85
        //self.priceCurrencyContainer.clipsToBounds = true
//        self.pricePersonAndGroupContainer.layer.borderColor = UIColor.lightGray.cgColor
//        self.pricePersonAndGroupContainer.layer.borderWidth = 0.85
//        self.pricePersonAndGroupContainer.clipsToBounds = true
        self.configureCurrencyPicker()
        self.configureCurrencyPickerToolBar()
        self.configureEffortPicker()
        self.configureEffortToolBar()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //IQKeyboardManager.sharedManager().enableAutoToolbar = false
        self.navigationController?.navigationBar.isHidden = true
        self.addExperienceParameters[kExperienceGroupSizeMin] = "\(self.numberOfMinGuest)"
        self.addExperienceParameters[kExperienceGroupSizeMax] = "\(self.numberOfMaxGuest)"
        self.addExperienceParameters[kExperienceIsPricePerPerson] = "\(self.isPricePerPerson)"
        self.addExperienceParameters[kExperienceIsGroupPrice] = "\(self.isPricePerGroup)"
        self.addExperienceParameters[kInstant] = "\(self.isInstant ? 1:0)"
        self.addExperienceParameters[kWheelChair] = "\(self.isWheelChair ? 1:0)"
        self.addExperienceParameters[kPetFriendly] = "\(self.isPetFriendly ? 1:0)"
        self.addExperienceParameters[kFreeForChildern] = "\(self.isFreeforChildern ? 1:0)"
        self.addExperienceParameters[kFreeForElderly] = "\(self.isFreeforElderly ? 1:0)"
        DispatchQueue.main.async {
            self.addDynamicFont()
            self.swipeToPop()
        }
        print(self.addExperienceParameters.count)
    }
    func swipeToPop() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    func addDynamicFont(){
        self.buttonBack.setImage(#imageLiteral(resourceName: "back_update").withRenderingMode(.alwaysTemplate), for: .normal)
        self.buttonBack.imageView?.tintColor = UIColor.black
        
        self.lblNavTitle.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblNavTitle.adjustsFontForContentSizeCategory = true
        self.lblNavTitle.adjustsFontSizeToFitWidth = true
        
        self.lblTitle.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblTitle.adjustsFontForContentSizeCategory = true
        self.lblTitle.adjustsFontSizeToFitWidth = true
        
        self.lblUserName.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblUserName.adjustsFontForContentSizeCategory = true
        self.lblUserName.adjustsFontSizeToFitWidth = true
        
        //self.lblUserCity.font = CommonClass.shared.getScaledWithOutMinimum(forFont: "Avenir-Roman", textStyle: .body)
        self.lblUserCity.adjustsFontForContentSizeCategory = true
        self.lblUserCity.adjustsFontSizeToFitWidth = true
        
        //self.txtTitleOfExperience.originalPlaceholderFontSize = CommonClass.shared.getScaledFont(forFont: "Avenir-Medium", textStyle: .title1).pointSize
        self.txtTitleOfExperience.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.txtTitleOfExperience.adjustsFontForContentSizeCategory = true
        
        self.txtExperienceTitle.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        
        //self.lblPrice.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblPrice.adjustsFontForContentSizeCategory = true
        self.lblPrice.adjustsFontSizeToFitWidth = true
        
        //self.txtCurrency.originalPlaceholderFontSize = CommonClass.shared.getScaledFont(forFont: "Avenir-Medium", textStyle: .title1).pointSize
        self.txtCurrency.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.txtCurrency.adjustsFontForContentSizeCategory = true
        
        self.lblPricePerPerson.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblPricePerPerson.adjustsFontForContentSizeCategory = true
        self.lblPricePerPerson.adjustsFontSizeToFitWidth = true
        
        //.txtPricePerPerson.originalPlaceholderFontSize = CommonClass.shared.getScaledFont(forFont: "Avenir-Medium", textStyle: .title1).pointSize
        self.txtPricePerPerson.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.txtPricePerPerson.adjustsFontForContentSizeCategory = true
        
        self.txtPricePerPersonHourly.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.txtPricePerPersonHourly.adjustsFontForContentSizeCategory = true
        
        self.lblPricePerGroup.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblPricePerGroup.adjustsFontForContentSizeCategory = true
        self.lblPricePerGroup.adjustsFontSizeToFitWidth = true
        
        //self.txtPricePerGroup.originalPlaceholderFontSize = CommonClass.shared.getScaledFont(forFont: "Avenir-Medium", textStyle: .title1).pointSize
        self.txtPricePerGroup.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.txtPricePerGroup.adjustsFontForContentSizeCategory = true
        
        //self.txtDescriptionOfExperience.originalPlaceholderFontSize = CommonClass.shared.getScaledFont(forFont: "Avenir-Medium", textStyle: .title1).pointSize
        self.txtDescriptionOfExperience.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.txtDescriptionOfExperience.adjustsFontForContentSizeCategory = true
        self.txtExperienceDescription.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        
        //self.txtExperienceDuration.originalPlaceholderFontSize = CommonClass.shared.getScaledFont(forFont: "Avenir-Medium", textStyle: .title1).pointSize
        self.txtExperienceDuration.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.txtExperienceDuration.adjustsFontForContentSizeCategory = true
        
        //self.txtExperienceEffort.originalPlaceholderFontSize = CommonClass.shared.getScaledFont(forFont: "Avenir-Medium", textStyle: .title1).pointSize
        self.txtExperienceEffort.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.txtExperienceEffort.adjustsFontForContentSizeCategory = true
        
        self.lblMinGuestNumber.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblMinGuestNumber.adjustsFontForContentSizeCategory = true
        self.lblMinGuestNumber.adjustsFontSizeToFitWidth = true
        
        self.lblMaxGuestNumber.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblMaxGuestNumber.adjustsFontForContentSizeCategory = true
        self.lblMaxGuestNumber.adjustsFontSizeToFitWidth = true
        
        self.lblMaximumumberOfGuest.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblMaximumumberOfGuest.adjustsFontForContentSizeCategory = true
        self.lblMaximumumberOfGuest.adjustsFontSizeToFitWidth = true
        
        //self.txtLanguageOfExperience.originalPlaceholderFontSize = CommonClass.shared.getScaledFont(forFont: "Avenir-Medium", textStyle: .title1).pointSize
        self.txtLanguageOfExperience.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.txtLanguageOfExperience.adjustsFontForContentSizeCategory = true
        self.txtExperienceLangauge.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        
        //self.txtLocationOfExperience.originalPlaceholderFontSize = CommonClass.shared.getScaledFont(forFont: "Avenir-Medium", textStyle: .title1).pointSize
        self.txtLocationOfExperience.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.txtLocationOfExperience.adjustsFontForContentSizeCategory = true
        self.txtExperienceLocation.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        
        //self.txtCollectionOfExperience.originalPlaceholderFontSize = CommonClass.shared.getScaledFont(forFont: "Avenir-Medium", textStyle: .title1).pointSize
        self.txtCollectionOfExperience.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.txtCollectionOfExperience.adjustsFontForContentSizeCategory = true
        self.txtExperienceCollection.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        
        //self.txtMeetingAddOfExperience.originalPlaceholderFontSize = CommonClass.shared.getScaledFont(forFont: "Avenir-Medium", textStyle: .title1).pointSize
        self.txtMeetingAddOfExperience.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.txtMeetingAddOfExperience.adjustsFontForContentSizeCategory = true
        self.txtExperienceMeetingAdd.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        
        //self.txtPostalZipOfExperience.originalPlaceholderFontSize = CommonClass.shared.getScaledFont(forFont: "Avenir-Medium", textStyle: .title1).pointSize
        self.txtPostalZipOfExperience.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.txtPostalZipOfExperience.adjustsFontForContentSizeCategory = true
        self.txtExperiencePostalZip.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        
        //self.txtAddReferenceOfExperience.originalPlaceholderFontSize = CommonClass.shared.getScaledFont(forFont: "Avenir-Medium", textStyle: .title1).pointSize
        self.txtAddReferenceOfExperience.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.txtAddReferenceOfExperience.adjustsFontForContentSizeCategory = true
        self.txtExperienceAddReference.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        
        self.lblActiveExperience.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblActiveExperience.adjustsFontForContentSizeCategory = true
        self.lblActiveExperience.adjustsFontSizeToFitWidth = true
        
        self.lblInstanceExperience.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblInstanceExperience.adjustsFontForContentSizeCategory = true
        self.lblInstanceExperience.adjustsFontSizeToFitWidth = true
        
        self.lblWheelchairAccessible.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblWheelchairAccessible.adjustsFontForContentSizeCategory = true
        self.lblWheelchairAccessible.adjustsFontSizeToFitWidth = true
        
        self.lblPetFriendly.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblPetFriendly.adjustsFontForContentSizeCategory = true
        self.lblPetFriendly.adjustsFontSizeToFitWidth = true
        
        self.lblFreeChildren.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblFreeChildren.adjustsFontForContentSizeCategory = true
        self.lblFreeChildren.adjustsFontSizeToFitWidth = true
        
        //self.txtRistrictionOfExperience.originalPlaceholderFontSize = CommonClass.shared.getScaledFont(forFont: "Avenir-Medium", textStyle: .title1).pointSize
        self.txtRistrictionOfExperience.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.txtRistrictionOfExperience.adjustsFontForContentSizeCategory = true
        self.txtExperienceRistriction.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        
//        self.buttonAddSchedule.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
//        self.buttonAddSchedule.titleLabel?.adjustsFontForContentSizeCategory = true
//        self.buttonAddSchedule.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.buttonSave.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.buttonSave.titleLabel?.adjustsFontForContentSizeCategory = true
        self.buttonSave.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    func changeTextAsLanguage() {
        self.lblSchedule.text = Vocabulary.getWordFromKey(key: "Schedule")
        self.lblOptions.text = Vocabulary.getWordFromKey(key: "options.hint")
        self.lblDetail.text = Vocabulary.getWordFromKey(key: "detail.hint")
        self.lblNavTitle.text = Vocabulary.getWordFromKey(key: "addNewExperience")
        self.txtTitleOfExperience.tweePlaceholder = Vocabulary.getWordFromKey(key: "experienceTitle")
        //self.txtTitleOfExperience.tweePlaceholder = Vocabulary.getWordFromKey(key: "experienceTitle")
        self.lblPrice.text = Vocabulary.getWordFromKey(key: "price")
        self.txtCurrency.tweePlaceholder = "\(Vocabulary.getWordFromKey(key:"Select")) \(Vocabulary.getWordFromKey(key: "currency"))"
        self.txtCurrency.maximumPlaceHolder = "\(Vocabulary.getWordFromKey(key:"Select")) \(Vocabulary.getWordFromKey(key: "currency"))"
        self.txtCurrency.minimumPlaceHolder = "\(Vocabulary.getWordFromKey(key: "currency"))".firstUppercased
        self.lblPricePerPerson.text = Vocabulary.getWordFromKey(key: "priceperperson")
        self.lblPricePerGroup.text = Vocabulary.getWordFromKey(key: "pricepergroup")
        
        self.txtPricePerPerson.tweePlaceholder = "\(Vocabulary.getWordFromKey(key: "enter.hint")) \(Vocabulary.getWordFromKey(key: "priceperperson") )"//Vocabulary.getWordFromKey(key: "price")
        self.txtPricePerPerson.maximumPlaceHolder = "\(Vocabulary.getWordFromKey(key: "enter.hint")) \(Vocabulary.getWordFromKey(key: "priceperperson") )"
        self.txtPricePerPerson.minimumPlaceHolder = "\(Vocabulary.getWordFromKey(key: "priceperperson"))".firstUppercased
        
        self.txtPricePerPersonHourly.tweePlaceholder = "\(Vocabulary.getWordFromKey(key: "enter.hint")) \(Vocabulary.getWordFromKey(key: "priceperpersonhourly.hint") )"//Vocabulary.getWordFromKey(key: "price")
        self.txtPricePerPersonHourly.maximumPlaceHolder = "\(Vocabulary.getWordFromKey(key: "enter.hint")) \(Vocabulary.getWordFromKey(key: "priceperpersonhourly.hint") )"
        self.txtPricePerPersonHourly.minimumPlaceHolder = "\(Vocabulary.getWordFromKey(key: "priceperpersonhourly.hint"))".firstUppercased
        
        self.txtPricePerGroup.tweePlaceholder =  "\(Vocabulary.getWordFromKey(key: "enter.hint")) \(Vocabulary.getWordFromKey(key: "pricepergroup") )"
        self.txtPricePerGroup.maximumPlaceHolder = "\(Vocabulary.getWordFromKey(key: "enter.hint")) \(Vocabulary.getWordFromKey(key: "pricepergroup") )"
        self.txtPricePerGroup.minimumPlaceHolder = "\(Vocabulary.getWordFromKey(key: "pricepergroup"))".firstUppercased
        
        //grouppricehourly.hint
        self.txtPricePerGroupHourly.tweePlaceholder =  "\(Vocabulary.getWordFromKey(key: "enter.hint")) \(Vocabulary.getWordFromKey(key: "grouppricehourly.hint") )"
        self.txtPricePerGroupHourly.maximumPlaceHolder = "\(Vocabulary.getWordFromKey(key: "enter.hint")) \(Vocabulary.getWordFromKey(key: "grouppricehourly.hint") )"
        self.txtPricePerGroupHourly.minimumPlaceHolder = "\(Vocabulary.getWordFromKey(key: "grouppricehourly.hint"))".firstUppercased
        
        self.txtDescriptionOfExperience.tweePlaceholder = Vocabulary.getWordFromKey(key: "Description")
        
        self.txtExperienceDuration.tweePlaceholder =  "\(Vocabulary.getWordFromKey(key: "Select")) \(Vocabulary.getWordFromKey(key: "duration") )"
        self.txtExperienceDuration.maximumPlaceHolder = "\(Vocabulary.getWordFromKey(key: "Select")) \(Vocabulary.getWordFromKey(key: "duration") )"
        self.txtExperienceDuration.minimumPlaceHolder = Vocabulary.getWordFromKey(key: "duration").firstUppercased
        
        self.txtExperienceEffort.tweePlaceholder = "\(Vocabulary.getWordFromKey(key: "Select")) \(Vocabulary.getWordFromKey(key: "effort") )"//Vocabulary.getWordFromKey(key: "effort")
        self.txtExperienceEffort.maximumPlaceHolder = "\(Vocabulary.getWordFromKey(key: "Select")) \(Vocabulary.getWordFromKey(key: "effort") )"
        self.txtExperienceEffort.minimumPlaceHolder = Vocabulary.getWordFromKey(key: "effort").firstUppercased
        
        self.lblMinGuestNumber.text = Vocabulary.getWordFromKey(key: "MinGuestNumber")
        self.lblMaxGuestNumber.text = Vocabulary.getWordFromKey(key: "MaxGuestNumber")
        
        self.txtLanguageOfExperience.tweePlaceholder = "\(Vocabulary.getWordFromKey(key: "Select")) \(Vocabulary.getWordFromKey(key: "language") )" //
        self.txtLanguageOfExperience.maximumPlaceHolder = "\(Vocabulary.getWordFromKey(key: "Select")) \(Vocabulary.getWordFromKey(key: "language") )"
        self.txtLanguageOfExperience.minimumPlaceHolder = Vocabulary.getWordFromKey(key: "language").firstUppercased
        
        self.txtCollectionOfExperience.tweePlaceholder = "\(Vocabulary.getWordFromKey(key: "Select")) \(Vocabulary.getWordFromKey(key: "collections") )"//
        self.txtCollectionOfExperience.maximumPlaceHolder = "\(Vocabulary.getWordFromKey(key: "Select")) \(Vocabulary.getWordFromKey(key: "collections") )"
        self.txtCollectionOfExperience.minimumPlaceHolder = Vocabulary.getWordFromKey(key: "collections").firstUppercased
        
        self.txtLocationOfExperience.tweePlaceholder = "\(Vocabulary.getWordFromKey(key: "Select")) \(Vocabulary.getWordFromKey(key: "Location") )"
        //Vocabulary.getWordFromKey(key: "Location")
        self.txtLocationOfExperience.maximumPlaceHolder = "\(Vocabulary.getWordFromKey(key: "Select")) \(Vocabulary.getWordFromKey(key: "Location") )"
        self.txtLocationOfExperience.minimumPlaceHolder = Vocabulary.getWordFromKey(key: "Location").firstUppercased
        
        self.txtMeetingAddOfExperience.tweePlaceholder = Vocabulary.getWordFromKey(key: "meetingAddress")
        
        self.txtPostalZipOfExperience.tweePlaceholder = "\(Vocabulary.getWordFromKey(key: "enter.hint")) \(Vocabulary.getWordFromKey(key: "postalZip") )"//Vocabulary.getWordFromKey(key: "postalZip")
        self.txtPostalZipOfExperience.maximumPlaceHolder = "\(Vocabulary.getWordFromKey(key: "enter.hint")) \(Vocabulary.getWordFromKey(key: "postalZip") )"
        self.txtPostalZipOfExperience.minimumPlaceHolder = Vocabulary.getWordFromKey(key: "postalZip").firstUppercased
        
        self.txtAddReferenceOfExperience.tweePlaceholder = "\(Vocabulary.getWordFromKey(key: "enter.hint")) \(Vocabulary.getWordFromKey(key: "addressReference") )"//Vocabulary.getWordFromKey(key: "addressReference")
        self.txtAddReferenceOfExperience.maximumPlaceHolder = "\(Vocabulary.getWordFromKey(key: "enter.hint")) \(Vocabulary.getWordFromKey(key: "addressReference") )"
        self.txtAddReferenceOfExperience.minimumPlaceHolder = Vocabulary.getWordFromKey(key: "addressReference").firstUppercased
        
        self.lblInstanceExperience.text = Vocabulary.getWordFromKey(key: "InstantExperience")
        self.lblWheelchairAccessible.text = Vocabulary.getWordFromKey(key: "WheelchairAccessible")
        self.lblPetFriendly.text = Vocabulary.getWordFromKey(key: "PetFriendly")
        self.lblFreeChildren.text = Vocabulary.getWordFromKey(key: "FreeChildren")
        self.txtRistrictionOfExperience.tweePlaceholder = Vocabulary.getWordFromKey(key: "Restrictions")
        self.buttonAddSchedule.setTitle("\(Vocabulary.getWordFromKey(key: "addSchedules"))", for: .normal)
        if let _ = kUserDefault.value(forKey:kExperienceDetail) as? [String:Any]{
            self.buttonSave.setTitle(Vocabulary.getWordFromKey(key: "AddExperience.hint"), for: .normal)
        }else{
            self.buttonSave.setTitle(Vocabulary.getWordFromKey(key: "CreateExperience.hint"), for: .normal)
        }
        
        
        self.lblActiveExperience.text = Vocabulary.getWordFromKey(key: "ActivateTour")
    }
    func configureCurrencyPickerToolBar(){
        self.currencyToolBar.sizeToFit()
        self.currencyToolBar.tintColor = UIColor.init(hexString:"36527D")
        
        self.currencyToolBar.layer.borderColor = UIColor.darkGray.cgColor
        self.currencyToolBar.layer.borderWidth = 0.0
        self.currencyToolBar.clipsToBounds = true
        self.currencyToolBar.backgroundColor = UIColor.white
        let doneButton = UIBarButtonItem(title: Vocabulary.getWordFromKey(key:"Done"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(AddExperienceViewController.doneCurrencyPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let title = UILabel.init()
        
        title.attributedText = NSAttributedString.init(string:
            "\(Vocabulary.getWordFromKey(key:"Select")) \(Vocabulary.getWordFromKey(key: "currency"))", attributes:[NSAttributedStringKey.font:UIFont.init(name:"Avenir-Heavy", size: 15.0)!])
        title.sizeToFit()
        let cancelButton = UIBarButtonItem(title:Vocabulary.getWordFromKey(key:"Cancel"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(AddExperienceViewController.cancelCurrencyPicker))
        self.currencyToolBar.setItems([cancelButton,spaceButton,UIBarButtonItem.init(customView: title),spaceButton,doneButton], animated: false)
    }
    func configureCurrencyPicker(){
        self.currencyPicker.delegate = self
        self.currencyPicker.dataSource = self
    }
    @objc func doneCurrencyPicker(){
        self.addExperienceParameters[kExperienceCurrency] = "\(self.currentCurrency)"
        DispatchQueue.main.async {
            self.buttonForgroundShadow.isHidden = true
            self.validTextField(textField: self.txtCurrency)
            self.txtCurrency.text = self.currentCurrency
            self.view.endEditing(true)
        }
    }
    @objc func cancelCurrencyPicker(){
        DispatchQueue.main.async {
            self.buttonForgroundShadow.isHidden = true
            self.view.endEditing(true)
        }
    }
    func configureEffortToolBar(){
        self.effortToolBar.sizeToFit()
        self.effortToolBar.tintColor = UIColor.init(hexString:"36527D")

        self.effortToolBar.backgroundColor = UIColor.white
        let doneButton = UIBarButtonItem(title: Vocabulary.getWordFromKey(key:"Done"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(AddExperienceViewController.doneEffortPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let title = UILabel.init()
        
        title.attributedText = NSAttributedString.init(string:
            "\(Vocabulary.getWordFromKey(key: "Select")) \(Vocabulary.getWordFromKey(key: "effort") )", attributes:[NSAttributedStringKey.font:UIFont.init(name:"Avenir-Heavy", size: 15.0)!])
        title.sizeToFit()
        let cancelButton = UIBarButtonItem(title:Vocabulary.getWordFromKey(key:"Cancel"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(AddExperienceViewController.cancelEffortPicker))
        self.effortToolBar.setItems([cancelButton,spaceButton,UIBarButtonItem.init(customView: title),spaceButton,doneButton], animated: false)
    }
    func configureEffortPicker(){
        self.effortPicker.delegate = self
        self.effortPicker.dataSource = self
    }
    @objc func doneEffortPicker(){
        self.addExperienceParameters[kExperienceEffort] = "\(self.currentEffort)"
        DispatchQueue.main.async {
            self.buttonForgroundShadow.isHidden = true
            self.txtExperienceEffort.text = "\(self.currentEffort)"
            self.validTextField(textField: self.txtExperienceEffort)
            self.view.endEditing(true)
        }
        defer{
            self.sizeFooterToFit()
        }
    }
    @objc func cancelEffortPicker(){
        DispatchQueue.main.async {
            self.buttonForgroundShadow.isHidden = true
            self.view.endEditing(true)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
        //IQKeyboardManager.sharedManager().enableAutoToolbar = true

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Custom Methods
    /*func testUploadVideo(){
        if let urlpath = Bundle.main.path(forResource: "sample", ofType: "mp4"),let videoURL:NSURL = NSURL.fileURL(withPath: urlpath) as NSURL{
            guard let data = NSData(contentsOf: videoURL as URL) else {
                return
            }
            ProgressHud.show()
            
            print("File size before compression: \(Double(data.length / 1048576)) mb")
            
            let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + "\(videoURL.lastPathComponent)")
            
            self.compressVideo(inputURL: videoURL as URL, outputURL: compressedURL) { (exportSession) in
                guard let session = exportSession else {
                    return
                }
                if session.status == .completed{
                    guard let compressedData = NSData(contentsOf: compressedURL) else {
                        return
                    }
                    self.uploadVideoRequest(videoData: compressedData as Data, videoName:"\(videoURL.lastPathComponent)")
                }else{
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        }
    }*/
    
    func openEditor(_ sender: UIBarButtonItem?, pickingViewTag: Int) {
        guard let image = self.imageForCrop else {
            return
        }
        // Use view controller
        let controller = CropViewController()
        controller.delegate = self
        controller.image = image
        controller.isBadge = false
        kUserDefault.set(false, forKey: "isBadge")
        let navController = UINavigationController(rootViewController: controller)
        present(navController, animated: false, completion: nil)
    }
    
    func configureAddExperienceView(){
        let discriptionTap = UITapGestureRecognizer(target: self, action:#selector(discriptionTapGesture(_:)))
        discriptionTap.numberOfTapsRequired = 1
        self.txtExperienceDescription.addGestureRecognizer(discriptionTap)
        self.mediaDictionary["Image"] = self.arrayOfImages
        self.mediaDictionary["Video"] = self.arrayOfVideo
        self.mediaDictionary["Thumbnail"] = self.arrayOfThumNail
        //Configure ImagePickerController
        let nibHeaderCell = UINib.init(nibName: "BookDetailHeaderCell", bundle: nil)
        self.tableViewAddExperience.register(nibHeaderCell, forCellReuseIdentifier: "BookDetailHeaderCell")
        self.tableViewAddExperience.delegate = self
        self.tableViewAddExperience.dataSource = self
        let tapped = UITapGestureRecognizer(target: self, action: #selector(hideKeyBoardSelector))
        tapped.numberOfTapsRequired = 1
        self.tableViewAddExperience.tableHeaderView?.addGestureRecognizer(tapped)
        //self.tableViewAddExperience.tableFooterView?.addGestureRecognizer(tapped)
        //self.tableViewAddExperience.sectionFooterHeight = UITableViewAutomaticDimension
        //self.tableViewAddExperience.estimatedSectionFooterHeight = 2000
        self.tableViewAddExperience.alwaysBounceVertical = false
        self.imgUser.layer.cornerRadius = 30.0
        self.imgUser.clipsToBounds = true
        self.imgUser.layer.borderColor = UIColor.black.cgColor
        self.imgUser.layer.borderWidth = 0.0
        self.imgUser.contentMode = .scaleToFill
        self.collectionPreview.delegate = self
        self.collectionPreview.dataSource = self
        self.collectionPreview.dragDelegate = self
        self.collectionPreview.dropDelegate = self
        self.collectionPreview.isScrollEnabled = true
        self.collectionPreview.dragInteractionEnabled = true
        self.collectionPreview.reorderingCadence = .fast
        if let layout = self.collectionPreview.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal  // .horizontal
        }
        //self.collectionPreview.addGestureRecognizer(tapped)
        
        self.txtExperienceTitle.delegate = self
        self.txtExperienceDescription.delegate = self
        self.txtCurrency.delegate = self
        self.txtCurrency.inputView = self.currencyPicker
        self.txtCurrency.inputAccessoryView = self.currencyToolBar
        self.txtExperienceEffort.inputView = self.effortPicker
        self.txtExperienceEffort.inputAccessoryView = self.effortToolBar
        self.txtPricePerPerson.delegate = self
        self.txtPricePerPersonHourly.delegate = self
        self.txtPricePerGroup.delegate = self
        self.txtPricePerGroupHourly.delegate = self
        self.imgPricePerPerson.image = #imageLiteral(resourceName: "uncheck_update").withRenderingMode(.alwaysOriginal)
        self.imgPricePerGroup.image = #imageLiteral(resourceName: "uncheck_update").withRenderingMode(.alwaysOriginal)
        self.txtExperienceEffort.delegate = self
        self.txtExperienceDuration.delegate = self
        DispatchQueue.main.async {
            self.txtExperienceDuration.text = "01:00"//"01:00 hrs"
        }
        self.addExperienceParameters[kExperienceDuration] = "01:00"

        self.txtLanguageOfExperience.delegate = self
        self.txtExperienceLangauge.delegate = self
        self.txtExperienceCollection.delegate = self
        self.txtCollectionOfExperience.delegate = self
        self.txtExperienceLocation.delegate = self
        self.txtLocationOfExperience.delegate = self
        self.txtExperienceMeetingAdd.delegate = self
        self.txtMeetingAddOfExperience.delegate = self
        self.txtExperiencePostalZip.delegate = self
        self.txtPostalZipOfExperience.delegate = self
        self.txtExperienceAddReference.delegate = self
        self.txtAddReferenceOfExperience.delegate = self
        self.txtExperienceRistriction.delegate = self
        self.txtRistrictionOfExperience.delegate = self
        //self.buttonLocation.layer.cornerRadius  = 20.0
        self.buttonLocation.clipsToBounds = true
        //self.buttonLocation.layer.borderWidth = 1.0
        //self.buttonLocation.layer.borderColor = UIColor.black.cgColor
        //self.buttonAddSchedule.layer.borderColor = UIColor.black.cgColor
        //self.buttonAddSchedule.layer.borderWidth = 1.0
        //self.buttonSave.layer.borderColor = UIColor.black.cgColor
        //self.buttonSave.layer.borderWidth = 1.0
        self.tableViewSchedule.delegate = self
        self.tableViewSchedule.dataSource = self
        self.tableViewSchedule.tableHeaderView = UIView()
        self.tableViewSchedule.tableFooterView = UIView()
        defer{
            //Configure MinMaxGuest
            self.configureMinMaxGuest()
            
            //Configure User Detail
             self.configureUserDetail()
            
            self.sizeFooterToFit()
            
            self.configureEditExperience()

        }
    }
    @objc func discriptionTapGesture(_ gesture:UITapGestureRecognizer){
        self.txtExperienceDescription.dataDetectorTypes = UIDataDetectorTypes(rawValue: 0)
        self.txtExperienceDescription.isEditable = true
        self.txtExperienceDescription.becomeFirstResponder()
    }
    func configureEditExperience(){
        guard let _ = self.editExperience,self.isEdit else{
            self.isActiveInActiveContainer.isHidden = true
            if let saveExperienceDetail = kUserDefault.value(forKey:kExperienceDetail) as? [String:Any]{
//                if let location = saveExperienceDetail["Location"] as? [String:Any]{
//                    self.selectedCountryDetail = CountyDetail.init(objJSON:location)
//                }
                self.configureEditExperienceDetail(experienceDetail: saveExperienceDetail)
            }
            return
        }
        self.buttonSave.setTitle(Vocabulary.getWordFromKey(key:"updateExperience"), for: .normal)
        self.lblTitle.text = Vocabulary.getWordFromKey(key:"updateExperience")
        self.isActiveInActiveContainer.isHidden = false
        //GET Experience Detail
        self.getExperienceDetail(experienceID:"\(self.editExperience!.id)")
    }
    func sizeFooterToFit() {
        if let footerView =  self.tableViewAddExperience.tableFooterView {
            footerView.setNeedsLayout()
            footerView.layoutIfNeeded()
            
            let height = footerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            var frame = footerView.frame
            frame.size.height = height
            footerView.frame = frame
            self.tableViewAddExperience.tableFooterView = footerView
        }
//        if let footerView =  self.tableViewAddExperience.tableFooterView {
//            self.tableViewAddExperience.tableFooterView = nil
//            if let objFooterView = self.tableViewFooterView{
//                var footerFrame:CGRect = objFooterView.frame
//                footerFrame.size.width = self.tableViewAddExperience.frame.size.width
//                footerView.setNeedsLayout()
//                footerView.layoutIfNeeded()
//
//                let height = footerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
//                var frame = objFooterView.frame
//                frame.size.height = height
//                footerView.frame = frame
//                self.tableViewAddExperience.tableFooterView = footerView
//            }
//        }
    }
    func updateSwitchValue(objSwitch:UISwitch){
        if objSwitch.tag == 1{ //Instant
            if objSwitch.isOn,!self.isInstant{
                self.isInstant = true
            }else{
                self.isInstant = false
            }
        }else if objSwitch.tag == 2{ //WheelChair
            if objSwitch.isOn,!self.isWheelChair{
                self.isWheelChair = true
            }else{
                self.isWheelChair = false
            }
        }else if objSwitch.tag == 3{ //PetFriendly
            if objSwitch.isOn,!self.isPetFriendly{
                self.isPetFriendly = true
            }else{
                self.isPetFriendly = false
            }
        }else if objSwitch.tag == 4{ //Freeforchildren
            if objSwitch.isOn,!self.isFreeforChildern{
                self.isFreeforChildern = true
            }else{
                self.isFreeforChildern = false
            }
        }else if objSwitch.tag == 5{ //Freeforelderly
            if objSwitch.isOn,!self.isFreeforElderly{
                self.isFreeforElderly = true
            }else{
                self.isFreeforElderly = false
            }
        }else if objSwitch.tag == 6{ //isActive
            if objSwitch.isOn,!self.isActiveExperience{
                self.isActiveExperience = true
            }else{
                self.isActiveExperience = false
            }
        }else{
            
        }
    }
    func configureMinMaxGuest(){
        let longpressReduceMinGuest = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressReduceMinGuest(gestureReconizer:)))
        let longpressAddMinGuest = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressAddMinGuest(gestureReconizer:)))
        let longpressReduceMaxGuest = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressReduceMaxGuest(gestureReconizer:)))
        let longpressAddMaxGuest = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressAddMaxGuest(gestureReconizer:)))
        
        self.configureBorderWithSelector(sender: self.buttonReduceMinGuest)
        self.addLongPressGestureToSelector(sender: self.buttonReduceMinGuest, longPressGesture: longpressReduceMinGuest)
        self.configureBorderWithSelector(sender: self.buttonAddMinGuest)
        self.addLongPressGestureToSelector(sender: self.buttonAddMinGuest, longPressGesture: longpressAddMinGuest)
        self.configureBorderWithSelector(sender: self.buttonReduceMaxGuest)
        self.addLongPressGestureToSelector(sender: self.buttonReduceMaxGuest, longPressGesture: longpressReduceMaxGuest)
        self.configureBorderWithSelector(sender: self.buttonAddMaxGuest)
        self.addLongPressGestureToSelector(sender: self.buttonAddMaxGuest, longPressGesture: longpressAddMaxGuest)
        
        
    }
    func configureBorderWithSelector(sender:UIButton){
//        sender.layer.borderColor = self.tintBorderColor.cgColor
//        sender.layer.borderWidth = 0.7
//        sender.layer.cornerRadius = 22.5
//        sender.clipsToBounds = true
    }
    func addLongPressGestureToSelector(sender:UIButton,longPressGesture:UILongPressGestureRecognizer){
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delaysTouchesBegan = true
        longPressGesture.delegate = self
        sender.addGestureRecognizer(longPressGesture)
    }
    func configureUserDetail(){
        guard User.isUserLoggedIn else{
            return
        }
        if let _ = User.getUserFromUserDefault(){
            self.currentUser = User.getUserFromUserDefault()!
            self.addExperienceParameters[kExperienceUserID] = "\(currentUser!.userID)"
            self.lblUserName.text = "\(self.currentUser!.userFirstName) \(self.currentUser!.userLastName)"
            self.imgUser.imageFromServerURL(urlString:self.currentUser!.userImageURL,placeHolder:UIImage.init(named:"ic_profile")!)
            
            self.lblUserCity.text = "\(self.currentUser!.userCurrentCity), \(self.currentUser!.userCurrentCountry)"
            
        }
        defer{
            //Configure Duration Picker
            self.configureDurationPicker()
        }
    }
    func configureDurationPicker(){
        self.durationPicker.locale = Locale(identifier: "en_GB")
        self.durationToolBar.sizeToFit()
//        self.durationToolBar.layer.borderColor = UIColor.darkGray.cgColor
//        self.durationToolBar.layer.borderWidth = 1.0
        
        self.durationToolBar.clipsToBounds = true
        self.durationPicker.datePickerMode = .time
        let doneButton = UIBarButtonItem(title: Vocabulary.getWordFromKey(key:"Done"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(AddExperienceViewController.donedatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let title = UILabel.init()
        title.attributedText = NSAttributedString.init(string:
            "Hrs / Min", attributes:[NSAttributedStringKey.font:UIFont.init(name:"Avenir-Heavy", size: 15.0)!])
            /*NSAttributedString.init(string:
            "\(Vocabulary.getWordFromKey(key:"Select")) \(Vocabulary.getWordFromKey(key: "duration"))", attributes:[NSAttributedStringKey.font:UIFont.init(name:"Avenir-Heavy", size: 15.0)!])*/
        title.sizeToFit()
        let cancelButton = UIBarButtonItem(title: Vocabulary.getWordFromKey(key:"Cancel"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(AddExperienceViewController.cancelDatePicker))
        self.durationToolBar.setItems([cancelButton,spaceButton,UIBarButtonItem.init(customView: title),spaceButton,doneButton], animated: false)
        self.txtExperienceDuration.inputView = self.durationPicker
        self.txtExperienceDuration.inputAccessoryView = self.durationToolBar
        
        self.durationPicker.addTarget(self, action: #selector(self.respondToPicker), for: .valueChanged)
    }
    @objc func respondToPicker(){
        let date =  self.durationPicker.date
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        if let _ = components.hour,let _ = components.minute{
            let hour = components.hour!
            let minute = components.minute!
            var strHour = "\(hour)"
            var strMinute = "\(minute)"
            if strHour.count == 1{
                strHour = "0\(strHour == "0" ? "1":strHour)"
            }
            if strMinute.count == 1{
                strMinute = "0\(strMinute)"
            }
            self.addExperienceParameters[kExperienceDuration] = "\(strHour):\(strMinute)"
            self.txtExperienceDuration.text = "\(strHour):\(strMinute)"//"\(strHour):\(strMinute) hrs"
            self.validTextField(textField: self.txtExperienceDuration)
        }
    }
    @objc func cancelDatePicker(){
        //cancel button dismiss datepicker dialog
        DispatchQueue.main.async {
            self.buttonForgroundShadow.isHidden = true
        }
        self.view.endEditing(true)
    }
    @objc func donedatePicker(){
        let date =  self.durationPicker.date
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        if let _ = components.hour,let _ = components.minute{
            let hour = components.hour!
            let minute = components.minute!
            var strHour = "\(hour)"
            var strMinute = "\(minute)"
            if strHour.count == 1{
                strHour = "0\(strHour == "0" ? "1":strHour)"
            }
            if strMinute.count == 1{
                strMinute = "0\(strMinute)"
            }
            self.addExperienceParameters[kExperienceDuration] = "\(strHour):\(strMinute)"
            self.txtExperienceDuration.text = "\(strHour):\(strMinute)"//"\(strHour):\(strMinute) hrs"
            self.validTextField(textField: self.txtExperienceDuration)
        }
        DispatchQueue.main.async {
            self.buttonForgroundShadow.isHidden = true
        }
        //dismiss date picker dialog
        self.view.endEditing(true)
    }
    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) else {
            handler(nil)
            
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mov
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
    }
    func configurePricePerPerson(){
        UIView.animate(withDuration: 0.2) {
            self.heightOfPricePerPersonHourly.constant = self.isPricePerPerson ? 60.0 : 0.0
        }
        self.viewPricePerPersonHourly.isHidden = !self.isPricePerPerson
        self.txtPricePerPerson.isEnabled = self.isPricePerPerson
        self.imgPricePerPerson.image = (self.isPricePerPerson) ? #imageLiteral(resourceName: "check_update").withRenderingMode(.alwaysOriginal): #imageLiteral(resourceName: "uncheck_update").withRenderingMode(.alwaysOriginal)
        if !(self.isPricePerPerson){
            self.addExperienceParameters[kExperiencePricePerson] = ""
            self.txtPricePerPerson.text = ""
            //self.txtPricePerPerson.tweePlaceholder = Vocabulary.getWordFromKey(key: "price")
            self.txtPricePerPerson.resignFirstResponder()
            
            self.addExperienceParameters[kExeriencePricePerPersonHourly] = ""
            self.txtPricePerPersonHourly.text = ""
            //self.txtPricePerPerson.tweePlaceholder = Vocabulary.getWordFromKey(key: "price")
            self.txtPricePerPersonHourly.resignFirstResponder()
        }
    }
    func configurePricePerGroup(){
        UIView.animate(withDuration: 0.2) {
            self.heightOfPricePerGroupHourly.constant = self.isPricePerGroup ? 60.0 : 0.0
        }
        self.viewGroupPriceHourly.isHidden = !self.isPricePerGroup
        self.txtPricePerGroup.isEnabled = self.isPricePerGroup
        self.imgPricePerGroup.image = (self.isPricePerGroup) ? #imageLiteral(resourceName: "check_update").withRenderingMode(.alwaysOriginal): #imageLiteral(resourceName: "uncheck_update").withRenderingMode(.alwaysOriginal)
        if !(self.isPricePerGroup){
            self.addExperienceParameters[kExperienceGroupPrice] = ""
            self.txtPricePerGroup.text = ""
            //self.txtPricePerGroup.tweePlaceholder = Vocabulary.getWordFromKey(key: "price")
            self.txtPricePerGroup.resignFirstResponder()
            
            self.addExperienceParameters[kExerienceGroupPriceHourly] = ""
            self.txtPricePerGroupHourly.text = ""
            //self.txtPricePerPerson.tweePlaceholder = Vocabulary.getWordFromKey(key: "price")
            self.txtPricePerGroupHourly.resignFirstResponder()
        }
    }
    func configureMinNumberOfGuest(){
        DispatchQueue.main.async {
            self.lblMinimumNumberOfGuest.text = "\(self.numberOfMinGuest)"
        }
        self.addExperienceParameters[kExperienceGroupSizeMin] = "\(self.numberOfMinGuest)"
        guard  self.numberOfMinGuest <= self.numberOfMaxGuest else{
            return
        }
        self.validMaxNumberOfGuest()

    }
    func configureMaxNumberOfGuest(){
        DispatchQueue.main.async {
            self.lblMaximumumberOfGuest.text = "\(self.numberOfMaxGuest)"
        }
        self.addExperienceParameters[kExperienceGroupSizeMax] = "\(self.numberOfMaxGuest)"
        guard  self.numberOfMinGuest <= self.numberOfMaxGuest else{
            return
        }
        self.validMaxNumberOfGuest()
    }
    func getDayOfSelected(day:String)->String{
        if day == "0"{
            return "Sunday"//"Monday"
        }else if day == "1"{
            return "Monday"//"Tuesday"
        }else if day == "2"{
            return "Tuesday"//"Wednesday"
        }else if day == "3"{
            return "Wednesday"//"Thursday"
        }else if day == "4"{
            return "Thursday"//"Friday"
        }else if day == "5"{
            return "Friday"//"Saturday"
        }else if day == "6"{
            return "Saturday"//"Sunday"
        }else{
            return "Monday"
        }
    }
    func isvalidNewExperience()->Bool{
        guard self.arrayOfImages.count > 1 else{
            DispatchQueue.main.async {
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "selectMin2Pics"))
            }
            return false
        }
        guard let experienceTitle = self.addExperienceParameters[kExperienceTitle] as? String,experienceTitle.count > 0 else {
            DispatchQueue.main.async {
                self.txtExperienceTitle.invalideField()
                self.invalidTextField(textField: self.txtTitleOfExperience)
                //Scroll down to enter a valid title for the experience
                ShowToast.show(toatMessage:"Scroll down to enter a valid title for the experience.")
                //ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "experienceTitleValidation"))
            }
            return false
        }
        guard let experienceCurrency = self.addExperienceParameters[kExperienceCurrency] as? String,experienceCurrency.count > 0 else {

            DispatchQueue.main.async {
                self.invalidTextField(textField: self.txtCurrency)
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "currencyValidation"))
            }
            return false
        }
        if self.isPricePerPerson{
            guard let experiencePricePerPerson = self.addExperienceParameters[kExperiencePricePerson] as? String,experiencePricePerPerson.count > 0, "\(experiencePricePerPerson)" != "0"else{
                
                DispatchQueue.main.async {
                    print(self.isPricePerPerson)
                    self.invalidTextField(textField: self.txtPricePerPerson)
                    ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "personPriceValidation"))
                }
                return false
            }
        }else{
            self.addExperienceParameters[kExperiencePricePerson] = ""
        }
        if self.isPricePerGroup{
            guard let experiencePriceGroup = self.addExperienceParameters[kExperienceGroupPrice] as? String,experiencePriceGroup.count > 0 ,"\(experiencePriceGroup)" != "0"else{
                DispatchQueue.main.async {
                    self.invalidTextField(textField: self.txtPricePerGroup)
                    ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "groupPriceValidation"))
                }
                return false
            }
        }else{
            self.addExperienceParameters[kExperienceGroupPrice] = ""
        }
        
        if (self.isPricePerPerson == false) && (self.isPricePerGroup == false){
            ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "NoPriceValidation"))
            return false
        }
        guard let experienceDiscription = self.addExperienceParameters[KExperienceDiscription] as? String,experienceDiscription.count > 0 else {
            DispatchQueue.main.async {
                self.txtExperienceDescription.invalideField()
                self.invalidTextField(textField: self.txtDescriptionOfExperience)
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "descriptionValidation"))
            }
            return false
        }
        guard let experienceDuration = self.addExperienceParameters[kExperienceDuration] as? String,experienceDuration.count > 0 else {
            DispatchQueue.main.async {
                self.invalidTextField(textField: self.txtExperienceDuration)
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "durationValidation"))
            }
            return false
        }
        guard let experienceEffort = self.addExperienceParameters[kExperienceEffort] as? String,experienceEffort.count > 0 else {
            DispatchQueue.main.async {
                self.invalidTextField(textField: self.txtExperienceEffort)
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "effortValidation"))
            }
            return false
        }
        guard  self.numberOfMinGuest <= self.numberOfMaxGuest else{
            DispatchQueue.main.async {
                self.invalidMaxNumberOfGuest()
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "minMaxGuest"))
            }
            return false
        }
        guard let experienceLanguage = self.addExperienceParameters[kExperienceLanguageId] as? [String],experienceLanguage.count > 0 else {
            
            DispatchQueue.main.async {
                self.invalidTextField(textField: self.txtLanguageOfExperience)
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "langaugeValidation"))
            }
            return false
        }
//        guard let experienceCollection = self.addExperienceParameters[kExperienceCollectionId] as? [String],experienceCollection.count > 0 else {
//
//            DispatchQueue.main.async {
//                self.invalidTextField(textField: self.txtCollectionOfExperience)
//                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "colletionValidation"))
//            }
//            return false
//        }
        guard let experienceLocationID = self.addExperienceParameters[kExperienceLocationID],"\(experienceLocationID)".count > 0 else {
            DispatchQueue.main.async {
                self.invalidTextField(textField: self.txtLocationOfExperience)
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "locationValidation"))
            }
            return false
        }
        guard let experienceMeetingAdd = self.addExperienceParameters[kExperienceMeetingAddress],"\(experienceMeetingAdd)".count > 0 else {
            DispatchQueue.main.async {
                self.invalidTextField(textField: self.txtMeetingAddOfExperience)
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "meetingAddressValidation"))
            }
            return false
        }
        guard let experiencePostal = self.addExperienceParameters[kExperiencePostal],"\(experiencePostal)".count > 0 else {
            DispatchQueue.main.async {
                self.invalidTextField(textField: self.txtPostalZipOfExperience)
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "postalValidation"))
            }
            return false
        }
//        guard let experienceRistriction = self.addExperienceParameters[kExperienceRistriction],"\(experienceRistriction)".count > 0 else {
//            DispatchQueue.main.async {
//                self.invalidTextField(textField: self.txtRistrictionOfExperience)
//                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "restrictionValidation"))
//            }
//            return false
//        }
        guard self.arrayOfSchedules.count > 0 else {
            DispatchQueue.main.async {
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "scheduleValidation"))
            }
            return false
        }
        self.addExperienceParameters[kExperienceOccurrences] = self.arrayOfSchedules
        defer{
            self.configureAddExperienceImagesAndVideo()
        }
        return true
    }
    func configureAddExperienceImagesAndVideo(){
        
        self.addExperienceParameters[kExperienceImages] = []
        var images:[[String:String]] = []
        
        for (index,imageUrl) in self.arrayOfImages.enumerated(){
            
            var imageDict:[String:String] = [:]
            imageDict["Image"] = "\(imageUrl)"
            if let imageIndex = self.arrayOfPreview.index(where: {$0 == imageUrl}){
              imageDict["Order"] = "\(imageIndex)"
            }
//            if let _ = imageUrl.accessibilityValue{
//             imageDict["Order"] = "\(imageUrl.accessibilityValue!)"
//            }
            
            if let mainImageIndex = self.mainImage{
                if mainImageIndex == index{
                    imageDict["MainImage"] = "1"
                }else{
                    imageDict["MainImage"] = "0"
                }
            }else{
                self.mainImage = 0
                imageDict["MainImage"] = "1"
            }
            images.append(imageDict)
        }
        self.addExperienceParameters[kExperienceImages] = images
        var videos:[[String:String]] = []
        for (index,videoURL) in self.arrayOfVideo.enumerated(){
            print(videoURL.accessibilityValue)
            var videoDict:[String:String] = [:]
            
            videoDict["VideoUrl"] = "\(videoURL)"
//             if let _ = videoURL.accessibilityValue{
////                videoDict["Order"] = "\(videoURL.accessibilityValue!)"
////            }
            if self.arrayOfThumNail.count > index{
                let thumbURL = self.arrayOfThumNail[index]
                videoDict["ThumbnailUrl"] = "\(thumbURL)"
                if let videoIndex = self.arrayOfPreview.index(where: {$0 == thumbURL}){
                    videoDict["Order"] = "\(videoIndex)"
                }
                //
            }
          
            videos.append(videoDict)
        }
        self.addExperienceParameters[kExperienceVideos] = videos
    }
    func invalidTextField(textField:TweeActiveTextField){
        textField.placeholderColor = .red
        textField.invalideField()
    }
    func validTextField(textField:TweeActiveTextField){
        textField.placeholderColor = UIColor.black
    }
    func invalidMaxNumberOfGuest(){
        DispatchQueue.main.async {
            self.lblMaximumumberOfGuestDesc.textColor = .red
            self.lblMaximumumberOfGuest.textColor = .red
        }
    }
    func validMaxNumberOfGuest(){
        DispatchQueue.main.async {
            self.lblMaximumumberOfGuest.textColor = .black
            self.lblMaximumumberOfGuestDesc.textColor = .black
        }
    }
    func configureSelectedLanguage(){
        if selectedLangauges.count > 0{
            var arrayLanID:[String] = []
            var arrayLanName:[String] = []
            for objLan in selectedLangauges{
                arrayLanID.append("\(objLan.langaugeID)")
                arrayLanName.append("\(objLan.langaugeName)")
            }
            defer{
                self.addExperienceParameters[kExperienceLanguageId] = arrayLanID
                self.txtExperienceLangauge.text = "\(arrayLanName.joined(separator: ", "))"
                
                self.validTextField(textField: txtLanguageOfExperience)
            }
            self.txtLanguageOfExperience.minimizePlaceholder()
        }else{
            self.txtExperienceLangauge.text = ""
            self.txtLanguageOfExperience.maximizePlaceholder()
            
        }
        defer{
            self.sizeFooterToFit()
        }
    }
    func configureSelectedCollections(){
        if selectedCollection.count > 0{
            var arrayCollectionID:[String] = []
            var arrayCollectionName:[String] = []
            for objCollection in selectedCollection{
                arrayCollectionID.append("\(objCollection.id)")
                arrayCollectionName.append("\(objCollection.title)")
            }
            defer{
                self.addExperienceParameters[kExperienceCollectionId] = arrayCollectionID
                self.txtExperienceCollection.text = "\(arrayCollectionName.joined(separator: ", "))"
                self.validTextField(textField: txtCollectionOfExperience)
            }
            self.txtCollectionOfExperience.minimizePlaceholder()
        }else{
            self.addExperienceParameters[kExperienceCollectionId]=[]
            if self.txtExperienceCollection.text.count > 0{
                self.txtExperienceCollection.text = ""
                self.txtCollectionOfExperience.maximizePlaceholder()
            }
        }
        defer{
            self.sizeFooterToFit()
        }
    }
    func configureSelectedLocation(){
        if let _ = self.selectedCountryDetail{
            self.addExperienceParameters[kExperienceLocationID] = "\(self.selectedCountryDetail!.locationID)"
            self.validTextField(textField: self.txtLocationOfExperience)
            self.txtExperienceLocation.text = "\(self.selectedCountryDetail!.defaultCity)" + " ," + " \(self.selectedCountryDetail!.countyName)"
            defer{
                self.getExploreCollection(locationID: "\(self.selectedCountryDetail!.locationID)")
                self.selectedCollection = []
                DispatchQueue.main.async {
                    self.configureSelectedCollections()
                }
                self.txtLocationOfExperience.minimizePlaceholder()
                self.sizeFooterToFit()
            }
        }
    }
    func configureEditExperienceDetail(experienceDetail:[String:Any]){
        self.editExperience = Experience.init(experienceDetail: experienceDetail)
        self.getExploreCollection(locationID: "\(self.editExperience!.locationId)")
        //self.addExperienceParameters = experienceDetail
         self.arrayOfImages = []
        var test:NSString = ""
        for (index,image) in self.editExperience!.images.enumerated(){
            if image.mainImage{
                self.mainImage = index
            }
            if image.orderIndex.count > 0,let objIndex = Int(image.orderIndex){
                image.imageURL.accessibilityValue  = "\(objIndex)"
            }else{
                image.imageURL.accessibilityValue = "\(index)"
            }
            self.arrayOfImages.append(image.imageURL)
        }
        
        self.arrayOfVideo = []
        self.arrayOfThumNail = []
        for(index,video) in self.editExperience!.videos.enumerated(){
            
            if video.orderIndex.count > 0,let objIndex = Int(video.orderIndex){
                video.videoUrl.accessibilityValue = "\(objIndex)"
                video.thumbnailUrl.accessibilityValue = "\(objIndex)"
            }else{
                var newindex = index + self.arrayOfImages.count
                video.videoUrl.accessibilityValue = "\(newindex)"
                video.thumbnailUrl.accessibilityValue = "\(newindex)"
            }
            self.arrayOfVideo.append(video.videoUrl)
            self.arrayOfThumNail.append(video.thumbnailUrl)
        }
       
        self.mediaDictionary["Video"] = self.arrayOfVideo
        self.mediaDictionary["Thumbnail"] = self.arrayOfThumNail
        self.mediaDictionary["Image"] = self.arrayOfImages
        self.arrayOfPreview = self.arrayOfImages + self.arrayOfThumNail
        
        let ans = arrayOfPreview.sorted {
            (first, second) in
            first.accessibilityValue!.compare(second.accessibilityValue!, options: .numeric) == ComparisonResult.orderedAscending
        }
        self.arrayOfPreview = ans
        
       
        DispatchQueue.main.async {
            self.currentSelectedPage = 0
            self.tableViewAddExperience.reloadData()
            self.collectionPreview.reloadData()
            self.tableViewAddExperience.setContentOffset(.zero, animated: true)
        }
        if let userID = experienceDetail["UserId"]{
            self.addExperienceParameters["UserId"] = "\(userID)"
        }
        if let locationID = experienceDetail["LocationId"]{
            self.addExperienceParameters["LocationId"] = "\(locationID)"
        }
        if let lat = experienceDetail[kExperienceLatitude]{
            self.addExperienceParameters[kExperienceLatitude] = "\(lat)"
        }
        if let long = experienceDetail[kExperienceLongitude]{
            self.addExperienceParameters[kExperienceLongitude] = "\(long)"
        }
        if let titleOfExperience = experienceDetail[kExperienceTitle],"\(titleOfExperience)".count > 0{
            self.addExperienceParameters[kExperienceTitle] = "\(titleOfExperience)"
            DispatchQueue.main.async {
                self.txtExperienceTitle.text = "\(titleOfExperience)"
                self.lblExperienceTitleLimit.isHidden = false
                self.lblExperienceTitleLimit.text = "\("\(titleOfExperience)".count)/\(self.experienceTitleMax)"
                self.txtTitleOfExperience.minimizePlaceholder()
            }
        }
        if let currencyOfExperience = experienceDetail[kExperienceCurrency],"\(currencyOfExperience)".count > 0{
            self.addExperienceParameters[kExperienceCurrency] = "\(currencyOfExperience)"
            DispatchQueue.main.async {
                self.txtCurrency.text = "\(currencyOfExperience)"
            }
        }
        //PricePersonHourly
        
        if let isPricePerson = experienceDetail[kExperienceIsPricePerPerson],let pricePerson = experienceDetail[kExperiencePricePerson]{
            DispatchQueue.main.async {
                self.isPricePerPerson = Bool.init("\(isPricePerson)")
                if Int("\(pricePerson)") != 0{
                    self.txtPricePerPerson.text = "\(pricePerson)"
                }
                
            }
            self.addExperienceParameters[kExperienceIsPricePerPerson] = Bool.init("\(isPricePerson)")
            self.addExperienceParameters[kExperiencePricePerson] = "\(pricePerson)"
        }
        if let pricePersonhourly = experienceDetail[kExeriencePricePerPersonHourly]{
            DispatchQueue.main.async {
                if Int("\(pricePersonhourly)") != 0{
                    self.txtPricePerPersonHourly.text = "\(pricePersonhourly)"
                }
                
            }
            self.addExperienceParameters[kExeriencePricePerPersonHourly] = "\(pricePersonhourly)"
        }
        if let isPriceGroup = experienceDetail[kExperienceIsGroupPrice],let priceGroup = experienceDetail[kExperienceGroupPrice]{
            DispatchQueue.main.async {
                self.isPricePerGroup = Bool.init("\(isPriceGroup)")
                if Int("\(priceGroup)") != 0{
                    self.txtPricePerGroup.text = "\(priceGroup)"
                }
                
            }
            self.addExperienceParameters[kExperienceIsGroupPrice] = Bool.init("\(isPriceGroup)")
            self.addExperienceParameters[kExperienceGroupPrice] = "\(priceGroup)"

        }
        if let groupPricehourly = experienceDetail[kExerienceGroupPriceHourly]{
            DispatchQueue.main.async {
                if Int("\(groupPricehourly)") != 0{
                    self.txtPricePerGroupHourly.text = "\(groupPricehourly)"
                }
            }
            self.addExperienceParameters[kExerienceGroupPriceHourly] = "\(groupPricehourly)"
        }
        if let experienceDiscription = experienceDetail[KExperienceDiscription],"\(experienceDiscription)".count > 0{
            self.addExperienceParameters[KExperienceDiscription] = "\(experienceDiscription)"

            DispatchQueue.main.async {
                self.lblExperienceDescriptionLimit.isHidden = false
                self.txtExperienceDescription.text = "\(experienceDiscription)"
                self.lblExperienceDescriptionLimit.text = "\("\(experienceDiscription)".count)/\(self.maximumTextLimit)"
                self.txtDescriptionOfExperience.minimizePlaceholder()
            }
        }
        if let experienceDuration = experienceDetail[kExperienceDuration]{
            DispatchQueue.main.async {
                self.txtExperienceDuration.text = "\(experienceDuration)"//"\(experienceDuration) hrs"
            }
            self.addExperienceParameters[kExperienceDuration] = "\(experienceDuration)"
        }
        if let experienceEffort = experienceDetail[kExperienceEffort]{
            DispatchQueue.main.async {
                self.txtExperienceEffort.text = "\(experienceEffort)"
            }
            self.addExperienceParameters[kExperienceEffort] = "\(experienceEffort)"
        }
        if let minGroupSize = experienceDetail[kExperienceGroupSizeMin],let _ = Int("\(minGroupSize)"){
            self.numberOfMinGuest = Int("\(minGroupSize)")!
            self.addExperienceParameters[kExperienceGroupSizeMin] = self.numberOfMinGuest
        }
        if let maxGroupSize = experienceDetail[kExperienceGroupSizeMax],let _ = Int("\(maxGroupSize)"){
            self.numberOfMaxGuest = Int("\(maxGroupSize)")!
            self.addExperienceParameters[kExperienceGroupSizeMax] = self.numberOfMaxGuest

        }
        if let _ = self.editExperience{
            self.selectedLangauges = []
            for objLanguage in self.editExperience!.languages{
                self.selectedLangauges.append(ExperienceLangauge.init(langaugeID: objLanguage.languageID, langaugeName: objLanguage.languageName, langaugeCode:""))
            }
            DispatchQueue.main.async {
                self.configureSelectedLanguage()
            }
            self.selectedCollection = []
            for objCollection in self.editExperience!.collections{
                self.selectedCollection.append(objCollection)
            }
            DispatchQueue.main.async {
                if self.selectedCollection.count > 0{
                    self.collectionViewContainer.isHidden = false
                    //self.bottomConstraintOfLocation.constant = 20
                }else{
                    self.collectionViewContainer.isHidden = true
                    //self.bottomConstraintOfLocation.constant = -50
                }
                //self.sizeFooterToFit()
            }
            DispatchQueue.main.async {
                self.configureSelectedCollections()
            }
            if let _ = self.editExperience!.location{
                DispatchQueue.main.async {
                    self.validTextField(textField: self.txtLocationOfExperience)
                    self.txtExperienceLocation.text = "\(self.editExperience!.location!.city)" + " ," + "\(self.editExperience!.location!.country)"
                    defer{
                        self.txtLocationOfExperience.minimizePlaceholder()
                        //self.sizeFooterToFit()
                    }
                }
            }
        }
        if let meetingAddOfExperience = experienceDetail[kExperienceMeetingAddress],"\(meetingAddOfExperience)".count > 0{
            self.addExperienceParameters[kExperienceMeetingAddress] = "\(meetingAddOfExperience)"
            DispatchQueue.main.async {
                self.txtExperienceMeetingAdd.text = "\(meetingAddOfExperience) "
                self.txtMeetingAddOfExperience.minimizePlaceholder()
            }
        }
        if let postalCode = experienceDetail[kExperiencePostal],"\(postalCode)".count > 0{
            self.addExperienceParameters[kExperiencePostal] = "\(postalCode)"
            DispatchQueue.main.async {
                self.txtExperiencePostalZip.text = "\(postalCode) "
                self.txtPostalZipOfExperience.minimizePlaceholder()
            }
        }
        if let addReference = experienceDetail[kExperienceAddressRef],!(addReference is NSNull),"\(addReference)".count > 0{
            self.addExperienceParameters[kExperienceAddressRef] = "\(addReference)"
            DispatchQueue.main.async {
                self.txtExperienceAddReference.text = "\(addReference)"
                self.lblExperienceAddRefLimit.text = "\("\(addReference)".count)/\(self.experienceDescriptionMax)"
                self.txtAddReferenceOfExperience.minimizePlaceholder()
                
            }
        }
        if let isInstant = experienceDetail[kInstant]{
            self.isInstant = Bool.init("\(isInstant)")
            DispatchQueue.main.async {
                self.objInstantSwitch.isOn = self.isInstant
            }
        }
        if let isChair = experienceDetail[kWheelChair]{
            self.isWheelChair = Bool.init("\(isChair)")
            DispatchQueue.main.async {
                self.objWheelChairSwitch.isOn = self.isWheelChair
           }
        }
        if let isPetFriendly = experienceDetail[kPetFriendly]{
            self.isPetFriendly = Bool.init("\(isPetFriendly)")
            DispatchQueue.main.async {
                self.objPetFriendlySwitch.isOn = self.isPetFriendly
            }
        }
        if let isFreeForChild = experienceDetail[kFreeForChildern]{
            self.isFreeforChildern = Bool.init("\(isFreeForChild)")
            DispatchQueue.main.async {
                self.objFreeForChildSwitch.isOn = self.isFreeforChildern
            }
        }
        if let isElderly = experienceDetail[kFreeForElderly]{
            self.isFreeforElderly = Bool.init("\(isElderly)")
            DispatchQueue.main.async {
                self.objFreeForEldertSwitch.isOn = self.isFreeforElderly
            }
        }
        if let isBlock = experienceDetail[kExperienceBlock]{
            self.isActiveExperience = !Bool.init("\(isBlock)")
            DispatchQueue.main.async {
                self.objActiveExperienceSwitch.isOn = self.isActiveExperience
            }
        }
        if let ristriction = experienceDetail[kExperienceRistriction],"\(ristriction)".count > 0,!(ristriction is NSNull){
            self.addExperienceParameters[kExperienceRistriction] = "\(ristriction)"
            DispatchQueue.main.async {
                self.txtExperienceRistriction.text = "\(ristriction)"
                self.lblExperienceRistrictionLimit.text = "\("\(ristriction)".count)/\(self.experienceDescriptionMax)"
                self.txtRistrictionOfExperience.minimizePlaceholder()
            }
        }
        if let numberOfOccurencne:[[String:Any]] = experienceDetail[kExperienceOccurrences] as? [[String:Any]]{
            DispatchQueue.main.async {
                self.arrayOfSchedules = []
                for objSchedule in numberOfOccurencne{
                    self.arrayOfSchedules.append(objSchedule)
                    self.tableViewScheduleHeight.constant = CGFloat(self.arrayOfSchedules.count * Int(self.tableViewScheduleRowHeight))
                }
                self.addExperienceParameters["Occurrences"] = self.arrayOfSchedules
                self.tableViewSchedule.reloadData()
            }
            

        }
        defer{
            DispatchQueue.main.async {
                self.sizeFooterToFit()
            }
        }
    }
    func saveExperienceProgress(){
        guard self.addExperienceParameters.count > 0 else {
            return
        }
        print("\(self.addExperienceParameters)")
        self.configureAddExperienceImagesAndVideo()
        var experienceParameters = self.addExperienceParameters
        if self.selectedLangauges.count > 0{
            experienceParameters[kExperienceLanguages] = self.configureSelectedLanguageJSON()
        }
        if let _ = self.selectedCountryDetail{
            experienceParameters["Location"] = self.configureSelectedLocationJSON()
        }else if let parameters = kUserDefault.value(forKey: kExperienceDetail) as? [String:Any]{
            if let objLocation = parameters["Location"] as? [String:Any]{
                experienceParameters["Location"] = objLocation
            }
        }
        if self.selectedCollection.count > 0{
            experienceParameters["Collections"] = self.configureSelectedCollectionJSON()
        }
        kUserDefault.setValue(experienceParameters, forKey:kExperienceDetail)
        kUserDefault.synchronize()
    }
    func configureSelectedLanguageJSON()->[[String:Any]]{
        var languages:[[String:Any]] = []
        for language in self.selectedLangauges{
            var objLanguage:[String:Any] = [:]
            objLanguage["Id"] = "\(language.langaugeCode)"
            objLanguage["LanguageId"] = "\(language.langaugeID)"
            objLanguage["ExperienceId"] = ""
            objLanguage["Language"] = "\(language.langaugeName)"
            languages.append(objLanguage)
        }
        return languages
    }
    func configureSelectedLocationJSON()->[String:Any]{
        var location:[String:Any] = [:]
        location["Id"] = "\(self.selectedCountryDetail!.countryID)"
        location["City"] = "\(self.selectedCountryDetail!.defaultCity)"
        location["Country"] = "\(self.selectedCountryDetail!.countyName)"
        location["State"] = "\(self.selectedCountryDetail!.stateName)"
        return location
    }
    func configureSelectedCollectionJSON()->[[String:Any]]{
        var collections:[[String:Any]] = []
        for collection in selectedCollection{
            var objCollection:[String:Any] = [:]
            objCollection["Id"] = "\(collection.id)"
            objCollection["Title"] = "\(collection.title)"
            objCollection["Color"] = "\(collection.color)"
            objCollection["LocationId"] = "\(collection.locationId)"
            objCollection["CreatedDate"] = "\(collection.createdDate)"
            collections.append(objCollection)
        }
        return collections
    }
    // MARK: - API request Methods
    //Upload Images
    func uploadImageRequest(imageData:Data,imageName:String){
        let parameters = [
            "file_name": "\(imageName)"
        ]
        APIRequestClient.shared.uploadImage(requestType: .POST, queryString: kUploadImage, parameter: parameters as [String : AnyObject], imageData: imageData, isHudeShow: true, success: { (sucessResponse) in
            
            
            if let successData = sucessResponse as? [String:Any],let uploadedImageURL = successData["AWSUrl"]{
                let imageURL = "\(uploadedImageURL)" as NSString
                imageURL.accessibilityValue = "\(self.arrayOfImages.count+self.arrayOfThumNail.count)"
                self.arrayOfImages.append(imageURL)
                self.mediaDictionary["Image"] = self.arrayOfImages
                self.arrayOfPreview = self.arrayOfImages + self.arrayOfThumNail
                let ans = self.arrayOfPreview.sorted {
                    (first, second) in
                    first.accessibilityValue!.compare(second.accessibilityValue!, options: .numeric) == ComparisonResult.orderedAscending
                }
                self.arrayOfPreview = ans
                DispatchQueue.main.async {
                    self.currentSelectedPage = self.arrayOfPreview.count-1
                    self.tableViewAddExperience.reloadData()
                    self.collectionPreview.reloadData()
                    self.tableViewAddExperience.setContentOffset(.zero, animated: true)
                    ProgressHud.hide()
                }
            }
        }) { (failResponse) in
            DispatchQueue.main.async {
                ProgressHud.hide()
            }
            if let failData = failResponse as? [String:Any],let failMessage = failData["Message"]{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "\(failMessage)")
                }
            }
        }
    }
    //Upload Video
    func uploadVideoRequest(videoData:Data,videoName:String){
        let parameters = [ "file_name":"\(videoName)"]
        APIRequestClient.shared.uploadVideo(requestType: .POST, queryString: kUploadVideo, parameter: parameters as [String : AnyObject], videoData: videoData, isHudeShow: true, success: { (sucessResponse) in
            
            if let success = sucessResponse as? [String:Any],let successData = success["data"] as? [String:Any],let urls = successData["videoUrl"] as? [String:Any],let videoURL = urls["VideoUrl"],let thumnailURL = urls["ThumbnialImageUrl"]{
                self.lblTesting.text = "Sucesss Video Uploaded"
                let objvideoURL = "\(videoURL)" as NSString
                let objthumnailURL = "\(thumnailURL)" as NSString
                objvideoURL.accessibilityValue = "\(self.arrayOfImages.count+self.arrayOfThumNail.count)"
                objthumnailURL.accessibilityValue = "\(self.arrayOfImages.count+self.arrayOfThumNail.count)"

                self.arrayOfVideo.append(objvideoURL)
                self.arrayOfThumNail.append(objthumnailURL)
                self.mediaDictionary["Video"] = self.arrayOfVideo
                self.mediaDictionary["Thumbnail"] = self.arrayOfThumNail
                self.arrayOfPreview = self.arrayOfImages + self.arrayOfThumNail
                let ans = self.arrayOfPreview.sorted {
                    (first, second) in
                    first.accessibilityValue!.compare(second.accessibilityValue!, options: .numeric) == ComparisonResult.orderedAscending
                }
                self.arrayOfPreview = ans
                DispatchQueue.main.async {
                    self.currentSelectedPage = self.arrayOfPreview.count-1
                    self.tableViewAddExperience.reloadData()
                    self.collectionPreview.reloadData()
                    self.tableViewAddExperience.setContentOffset(.zero, animated: true)
                    ProgressHud.hide()
                }
            }
        }) { (failResponse) in
            DispatchQueue.main.async {
                ProgressHud.hide()
            }
            
            if let arrayFail = failResponse as? NSArray , let fail = arrayFail.firstObject as? [String:Any],let errorMessage = fail["ErrorMessage"]{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "\(errorMessage)")
                }
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        }
    }
    //GET Currency
    func getCurrencyList(){
        //base/native/stripeallowcurrency
        //let getCurrencyList = "base/native/stripeallowcurrency"
        
        APIRequestClient.shared.sendRequest(requestType: .GET, queryString:kAllCurrency, parameter: nil , isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let arrayOfCurrency = successData["currency"] as? [[String:Any]]{
                DispatchQueue.main.async {
                    for currencyObject in arrayOfCurrency{
                        if let id = currencyObject["id"], let text = currencyObject["text"]{
                             let objCurrency = Currency.init(currencyId:"\(id)", currencyText: "\(text)")
                              self.arrayOfCurrency.append(objCurrency)
                        }
                    }
                    if let first = self.arrayOfCurrency.first{
                        self.currentCurrency = "\(first.currencyText)"
                    }
                    
                }
            }else{
                DispatchQueue.main.async {
                    //ShowToast.show(toatMessage:kCommonError)
                }
            }
        }) { (responseFail) in
            if let arrayFail = responseFail as? NSArray , let fail = arrayFail.firstObject as? [String:Any],let errorMessage = fail["ErrorMessage"]{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "\(errorMessage)")
                }
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        }
        defer{
            //GET Langauges
            self.getLanguages()
        }
    }
    func getLanguages(){
        //let getlangauge = "base/native/languages"
        APIRequestClient.shared.sendRequest(requestType: .GET, queryString:kAllLanguage, parameter: nil, isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let arayOfLanguage = successData["Language"] as? [[String:Any]]{
                self.arrayOfLanguage = []
                for objLangauge in arayOfLanguage{
                    if let languageID = objLangauge["id"],let langaugeName = objLangauge["name"],let langaugeCode = objLangauge["code"]{
                        
                        let langauge = ExperienceLangauge.init(langaugeID: "\(languageID)", langaugeName:"\(langaugeName)", langaugeCode: "\(langaugeCode)")
                     
                        self.arrayOfLanguage.append(langauge)
                    }
                }
            }else{
                DispatchQueue.main.async {
                   // ShowToast.show(toatMessage:kCommonError)
                }
            }
        }) { (responseFail) in
            if let arrayFail = responseFail as? NSArray , let fail = arrayFail.firstObject as? [String:Any],let errorMessage = fail["ErrorMessage"]{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "\(errorMessage)")
                }
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        }
        defer{
            //GET Collections
            //self.getExploreCollection()
        }
    }
    //GET Guide Languages
    func getGuideLanguages(){
        //let getlangauge = "base/native/languages"
        if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
            let requestURL = "guides/\(currentUser.userID)/native/languages"
            APIRequestClient.shared.sendRequest(requestType: .GET, queryString:requestURL, parameter: nil, isHudeShow: true, success: { (responseSuccess) in
                if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let arayOfLanguage = successData["Language"] as? [[String:Any]]{
                    for objLangauge in arayOfLanguage{
                        if let languageID = objLangauge["Id"],let langaugeName = objLangauge["Name"],let langaugeCode = objLangauge["Code"]{
                            
                            let langauge = ExperienceLangauge.init(langaugeID: "\(languageID)", langaugeName:"\(langaugeName)", langaugeCode: "\(langaugeCode)")
                            if !self.isEdit{
                                self.selectedLangauges.append(langauge)
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.presentLangaugePicker()
                    }
                }else{
                    DispatchQueue.main.async {
                        //ShowToast.show(toatMessage:kCommonError)
                    }
                }
            }) { (responseFail) in
                if let arrayFail = responseFail as? NSArray , let fail = arrayFail.firstObject as? [String:Any],let errorMessage = fail["ErrorMessage"]{
                    DispatchQueue.main.async {
                        ShowToast.show(toatMessage: "\(errorMessage)")
                    }
                }else{
                    DispatchQueue.main.async {
                        ShowToast.show(toatMessage:kCommonError)
                    }
                }
            }
        }
    }
    
    //Get Explore collection
    func getExploreCollection(locationID:String){
        let requestURL = "experience/native/\(locationID)/collection"
        let expoParameter = ["FreeTextSearch": ""]

        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:requestURL, parameter:expoParameter as [String : AnyObject], isHudeShow: false, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let array = successDate["collections"] as? [[String:Any]]{
                self.arrayOfExploreCollection = []
                for object in array{
                    let objectExperience = Collections.init(collectionDetail: object)
                    self.arrayOfExploreCollection.append(objectExperience)
                }
                if self.arrayOfExploreCollection.count > 0{
                    DispatchQueue.main.async {
                            self.collectionViewContainer.isHidden = false
                            self.bottomConstraintOfLocation.constant = 20
                    }
                    DispatchQueue.main.async {
                       // self.presentCollectionPicker()
                    }
                }else{
                    DispatchQueue.main.async {
                        self.collectionViewContainer.isHidden = true
                        self.bottomConstraintOfLocation.constant = -50
                        guard self.txtExperienceCollection.text.count > 0 else{
                            return
                        }
                        self.txtExperienceCollection.text = ""
                        self.txtCollectionOfExperience.maximizePlaceholder()
                    }
                }
                DispatchQueue.main.async {
                    self.sizeFooterToFit()
                }
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        }) { (responseFail) in
            if let arrayFail = responseFail as? NSArray , let fail = arrayFail.firstObject as? [String:Any],let errorMessage = fail["ErrorMessage"]{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "\(errorMessage)")
                }
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        }
    }
    func getExperienceDetail(experienceID:String){ //On experience edit
        if let _ = self.currentUser{
            let userID = "\(self.currentUser!.userID)"
            let requestURLExperienceDetail = "\(kExperience)/\(experienceID)/native/users/\(userID)"
            APIRequestClient.shared.sendRequest(requestType: .GET, queryString:requestURLExperienceDetail, parameter: nil, isHudeShow: true, success: { (responseSuccess) in
                if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let experienceDic = successDate["experience"] as? [String:Any]{
                    
                    self.configureEditExperienceDetail(experienceDetail:experienceDic)
                    
                }else{
                    DispatchQueue.main.async {
                        //ShowToast.show(toatMessage:kCommonError)
                    }
                }
            }) { (responseFail) in
                if let arrayFail = responseFail as? NSArray , let fail = arrayFail.firstObject as? [String:Any],let errorMessage = fail["ErrorMessage"]{
                    DispatchQueue.main.async {
                        ShowToast.show(toatMessage: "\(errorMessage)")
                    }
                }else{
                    DispatchQueue.main.async {
                        ShowToast.show(toatMessage:kCommonError)
                    }
                }
            }
        }
    }
    func updateExperienceAPIRequest(experienceID:String){
        if self.isvalidNewExperience(){
           let updateExperienceRequestURL = "experience/\(experienceID)/native/update"
            
            APIRequestClient.shared.sendRequest(requestType: .PUT, queryString:updateExperienceRequestURL , parameter: self.addExperienceParameters as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
                if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let _ = successData["Experience"] as? [String:Any]{
                    let backAlert = UIAlertController(title: Vocabulary.getWordFromKey(key: "updateExperience"), message: Vocabulary.getWordFromKey(key: "updateExperience.msg"),preferredStyle: UIAlertControllerStyle.alert)
                    backAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"ok.title"), style: .default, handler: { (action: UIAlertAction!) in
                        //PopToBackViewController
                        self.navigationController?.popViewController(animated: false)
                    }))
                    self.view.endEditing(true)
                    let titleAttrString = NSMutableAttributedString(string: Vocabulary.getWordFromKey(key: "updateExperience"), attributes: self.alertTitleFont)
                    let messageAttrString = NSMutableAttributedString(string: Vocabulary.getWordFromKey(key: "updateExperience.msg"), attributes: self.alertMessageFont)
                    
                    backAlert.setValue(titleAttrString, forKey: "attributedTitle")
                    backAlert.setValue(messageAttrString, forKey: "attributedMessage")
                    
                    backAlert.view.tintColor = UIColor(hexString: "#36527D")
                    self.present(backAlert, animated: true, completion: nil)
                }else{
                    DispatchQueue.main.async {
                        ShowToast.show(toatMessage:kCommonError)
                    }
                }
            }, fail: { (responseFail) in
                if let arrayFail = responseFail as? NSArray , let fail = arrayFail.firstObject as? [String:Any],let errorMessage = fail["ErrorMessage"]{
                    DispatchQueue.main.async {
                        ShowToast.show(toatMessage: "\(errorMessage)")
                    }
                }else{
                    DispatchQueue.main.async {
                        ShowToast.show(toatMessage:"Error "+kCommonError)
                    }
                }
            })
        }
    }
    func addNewExperienceAPIRequest(){
        if self.isvalidNewExperience(){
            
            APIRequestClient.shared.addNewExperience(requestType: .POST, queryString: kAddNewExperience, parameter: self.addExperienceParameters as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
                if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let _ = successData["Experience"] as? [String:Any]{
                    let backAlert = UIAlertController(title: Vocabulary.getWordFromKey(key: "newExperience"), message: successData["Message"] as? String,preferredStyle: UIAlertControllerStyle.alert)
                    backAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"ok.title"), style: .default, handler: { (action: UIAlertAction!) in
                        //PopToBackViewController
                        self.navigationController?.popViewController(animated: false)
                    }))
                    let titleAttrString = NSMutableAttributedString(string: Vocabulary.getWordFromKey(key: "newExperience"), attributes: self.alertTitleFont)
                    let messageAttrString = NSMutableAttributedString(string:"\(successData["Message"] ?? "")", attributes: self.alertMessageFont)
                    
                    backAlert.setValue(titleAttrString, forKey: "attributedTitle")
                    backAlert.setValue(messageAttrString, forKey: "attributedMessage")
                    backAlert.view.tintColor = UIColor(hexString: "#36527D")
                    kUserDefault.removeObject(forKey: kExperienceDetail)
                    kUserDefault.synchronize()
                    self.present(backAlert, animated: true, completion: nil)
                }else{
                    DispatchQueue.main.async {
                        ShowToast.show(toatMessage:kCommonError)
                    }
                }
            }) { (responseFail) in
                if let arrayFail = responseFail as? NSArray , let fail = arrayFail.firstObject as? [String:Any],let errorMessage = fail["ErrorMessage"]{
                    DispatchQueue.main.async {
                        ShowToast.show(toatMessage: "\(errorMessage)")
                    }
                }else{
                    DispatchQueue.main.async {
                        ShowToast.show(toatMessage:kCommonError)
                    }
                }
            }
        }
    }
    // MARK: - Selector Methods
    func hideKeyboardSelectorFromHeader() {
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
    }
    @IBAction func hideKeyBoardWithSelector(sender:UIButton){
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
    }
    @objc func hideKeyBoardSelector(){
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
    }
    @IBAction func buttonAddMediaSelector(sender:UIButton){
        
        //PresentMedia Selector
        let actionSheetController = UIAlertController.init(title: "", message: Vocabulary.getWordFromKey(key:"uploadimagevideo.hint"), preferredStyle: .actionSheet)
        let cancelSelector = UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"Cancel"), style: .cancel, handler:nil)
        cancelSelector.setValue(UIColor.init(hexString: "36527D"), forKey: "titleTextColor")
        actionSheetController.addAction(cancelSelector)
        let photosSelector = UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"Photos"), style: .default) { (_) in
            DispatchQueue.main.async {
                self.objImagePickerController = UIImagePickerController()
                self.objImagePickerController.sourceType = .savedPhotosAlbum
                self.objImagePickerController.delegate = self
                self.objImagePickerController.allowsEditing = false
                self.objImagePickerController.mediaTypes = [kUTTypeImage as String]
                self.view.endEditing(true)
                self.presentImagePickerController()
            }
        }
        photosSelector.setValue(UIColor.init(hexString: "36527D"), forKey: "titleTextColor")
        actionSheetController.addAction(photosSelector)
        let videoSelector = UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"Videos"), style: .default) { (_) in
            DispatchQueue.main.async {
                self.objImagePickerController = UIImagePickerController()
                self.objImagePickerController.delegate = self
                //self.objImagePickerController.allowsEditing = false
                self.objImagePickerController.sourceType = .photoLibrary
                self.objImagePickerController.mediaTypes = [kUTTypeMovie as String]
                self.presentImagePickerController()
            }
        }
        videoSelector.setValue(UIColor.init(hexString: "36527D"), forKey: "titleTextColor")
        actionSheetController.addAction(videoSelector)
        let cameraSelector = UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"Camera"), style: .default) { (_) in
            if CommonClass.isSimulator{
                DispatchQueue.main.async {
                    let noCamera = UIAlertController.init(title:Vocabulary.getWordFromKey(key:"Cameranotsupported"), message: "", preferredStyle: .alert)
                    noCamera.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"ok.title"), style: .cancel, handler: nil))
                    self.present(noCamera, animated: true, completion: nil)
                }
            }else{
                DispatchQueue.main.async {
                    self.objImagePickerController = UIImagePickerController()
                    self.objImagePickerController.delegate = self
                    self.objImagePickerController.allowsEditing = false
                    self.objImagePickerController.sourceType = .camera
                    self.objImagePickerController.mediaTypes = [kUTTypeImage as String,kUTTypeMovie as String]
                    self.presentImagePickerController()
                }
            }
        }
        cameraSelector.setValue(UIColor.init(hexString: "36527D"), forKey: "titleTextColor")
        actionSheetController.addAction(cameraSelector)
        self.view.endEditing(true)
        self.present(actionSheetController, animated: true, completion: nil)
        
    }
    @IBAction func buttonSwitchSelector(sender:UISwitch){
        self.updateSwitchValue(objSwitch: sender)
    }
    @IBAction func buttonBackSelector(sender:UIButton){
        
        let alertTitle = "\(self.isEdit ? "\(Vocabulary.getWordFromKey(key: "updateExperience"))":"\(Vocabulary.getWordFromKey(key: "leave.hint"))")"
        let alertMessage = "\(self.isEdit ? "\(Vocabulary.getWordFromKey(key:"addExperienceAlert.msg"))":"\(Vocabulary.getWordFromKey(key:"autoSaveExperience.hint"))")"
        let backAlert = UIAlertController(title: alertTitle, message:alertMessage,preferredStyle: UIAlertControllerStyle.alert)
        let yesAction = UIAlertAction(title:  "\(self.isEdit ? "\(Vocabulary.getWordFromKey(key: "yes"))":"\(Vocabulary.getWordFromKey(key: "save"))")".firstUppercased, style: .default, handler: { (action: UIAlertAction!) in
            if self.isEdit{
                
            }else{
                self.saveExperienceProgress()
            }
            //PopToBackViewController
            self.navigationController?.popViewController(animated: false)
        })
        
        yesAction.setValue(UIColor.init(hexString: "36527D"), forKey: "titleTextColor")
 
        let cancelAction = UIAlertAction(title: "\(self.isEdit ? "\(Vocabulary.getWordFromKey(key: "Cancel"))":"\(Vocabulary.getWordFromKey(key: "leave.hint"))")", style: .cancel, handler: {(action:UIAlertAction!) in
            if self.isEdit{
                
            }else{
                self.navigationController?.popViewController(animated: false)
            }
        })
        cancelAction.setValue(UIColor.init(hexString: "36527D"), forKey: "titleTextColor")
        let titleAttrString = NSMutableAttributedString(string: alertTitle, attributes: self.alertTitleFont)
        let messageAttrString = NSMutableAttributedString(string:alertMessage, attributes: self.alertMessageFont)
        backAlert.addAction(cancelAction)
        backAlert.addAction(yesAction)
        backAlert.setValue(titleAttrString, forKey: "attributedTitle")
        backAlert.setValue(messageAttrString, forKey: "attributedMessage")
        backAlert.view.tintColor = UIColor(hexString: "#36527D")
        present(backAlert, animated: true, completion: nil)
    }
    @IBAction func buttonPricePerPersonSelector(sender:UIButton){
        self.isPricePerPerson = !self.isPricePerPerson
    }
    @IBAction func buttonPricePerGroupSelector(sender:UIButton){
        self.isPricePerGroup = !self.isPricePerGroup
    }
    @IBAction func buttonReduceMinGuest(sender:UIButton){
        if self.numberOfMinGuest > 1{
            self.numberOfMinGuest -= 1
        }
    }
    @objc func handleLongPressReduceMinGuest(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state == UIGestureRecognizerState.began{
            if timerReduceMinGuest == nil{
             timerReduceMinGuest = Timer.scheduledTimer(timeInterval:0.3, target: self, selector: #selector(self.reduceMinGuest), userInfo: nil, repeats: true)
            }
        }
        if gestureReconizer.state == UIGestureRecognizerState.ended {
            if let _ = timerReduceMinGuest {
                timerReduceMinGuest!.invalidate()
                timerReduceMinGuest = nil
            }
        }
    }
    @objc func reduceMinGuest(){
        if self.numberOfMinGuest > 1{
            self.numberOfMinGuest -= 1
        }else {
            if let _ = timerReduceMinGuest {
                timerReduceMinGuest!.invalidate()
                timerReduceMinGuest = nil
            }
        }
    }
    @objc func handleLongPressAddMinGuest(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state == UIGestureRecognizerState.began{
            if timerAddMinGuest == nil{
                timerAddMinGuest = Timer.scheduledTimer(timeInterval:0.3, target: self, selector: #selector(self.addMinGuest), userInfo: nil, repeats: true)
            }
        }
        if gestureReconizer.state == UIGestureRecognizerState.ended {
            if let _ = timerAddMinGuest {
                timerAddMinGuest!.invalidate()
                timerAddMinGuest = nil
            }
        }
    }
    @objc func addMinGuest(){
        if self.numberOfMinGuest < self.maximumNumberOfGuest{
            self.numberOfMinGuest += 1
        }else {
            if let _ = timerAddMinGuest {
                timerAddMinGuest!.invalidate()
                timerAddMinGuest = nil
            }
        }
    }
    @IBAction func buttonAddMinGuest(sender:UIButton){
        if self.numberOfMinGuest < self.maximumNumberOfGuest{
            self.numberOfMinGuest += 1
        }
    }
    @objc func handleLongPressReduceMaxGuest(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state == UIGestureRecognizerState.began{
            if timerReduceMaxGuest == nil{
                timerReduceMaxGuest = Timer.scheduledTimer(timeInterval:0.3, target: self, selector: #selector(self.reduceMaxGuest), userInfo: nil, repeats: true)
            }
        }
        if gestureReconizer.state == UIGestureRecognizerState.ended {
            if let _ = timerReduceMaxGuest {
                timerReduceMaxGuest!.invalidate()
                timerReduceMaxGuest = nil
            }
        }
    }
    @objc func reduceMaxGuest(){
        if self.numberOfMaxGuest > 1{
            self.numberOfMaxGuest -= 1
        }else{
            if let _ = timerReduceMaxGuest {
                timerReduceMaxGuest!.invalidate()
                timerReduceMaxGuest = nil
            }
        }
    }
    @IBAction func buttonReduceMaxGuest(sender:UIButton){
        if self.numberOfMaxGuest > 1{
            self.numberOfMaxGuest -= 1
        }
    }
   
    @objc func handleLongPressAddMaxGuest(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state == UIGestureRecognizerState.began{
            if timerAddMaxGuest == nil{
                timerAddMaxGuest = Timer.scheduledTimer(timeInterval:0.3, target: self, selector: #selector(self.addMaxGuest), userInfo: nil, repeats: true)
            }
        }
        if gestureReconizer.state == UIGestureRecognizerState.ended {
            if let _ = timerAddMaxGuest {
                timerAddMaxGuest!.invalidate()
                timerAddMaxGuest = nil
            }
        }
    }
    @objc func addMaxGuest(){
        if self.numberOfMaxGuest < self.maximumNumberOfGuest{
            self.numberOfMaxGuest += 1
        }else{
            if let _ = timerAddMaxGuest {
                timerAddMaxGuest!.invalidate()
                timerAddMaxGuest = nil
            }
        }
    }
    @IBAction func buttonAddMaxGuest(sender:UIButton){
        if self.numberOfMaxGuest < self.maximumNumberOfGuest{
            self.numberOfMaxGuest += 1
        }
    }
    @IBAction func buttonLocationSelector(sender:UIButton){
        //Present GoogleLocationPicker
        var config:GMSPlacePickerConfig?
        if let lat = self.addExperienceParameters[kExperienceLatitude],let long = self.addExperienceParameters[kExperienceLongitude]{
            let center = CLLocationCoordinate2D(latitude:Double("\(lat)")!, longitude: Double("\(long)")!)
            let northEast = CLLocationCoordinate2D(latitude: center.latitude + 0.001,
                                                   longitude: center.longitude + 0.001)
            let southWest = CLLocationCoordinate2D(latitude: center.latitude - 0.001,
                                                   longitude: center.longitude - 0.001)
            let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
            config = GMSPlacePickerConfig(viewport: viewport)
        }else{
            config = GMSPlacePickerConfig(viewport: nil)
        }
        
        let placePicker = GMSPlacePickerViewController(config: config!)
        placePicker.delegate = self
        present(placePicker, animated: true, completion: nil)
    }
    @IBAction func buttonAddScheduleSelector(sender:UIButton){
        //PushToAdd ScheduleView
        self.pushTOScheduleViewController()
    }
    @IBAction func buttonSaveSelector(sender:UIButton){
        guard let _ = self.editExperience,self.isEdit else{
            self.addNewExperienceAPIRequest()
            return
        }
        self.updateExperienceAPIRequest(experienceID: "\(self.editExperience!.id)")
    }
    @IBAction func unwindToAddExperienceFromCurrency(segue:UIStoryboardSegue){
        if let _ = self.selectedCurrency{
            self.addExperienceParameters[kExperienceCurrency] = "\(self.selectedCurrency!.currencyText)"
            self.txtCurrency.text = "\(self.selectedCurrency!.currencyText)"
            self.validTextField(textField: self.txtCurrency)
        }
        defer{
            self.sizeFooterToFit()
        }
    }
    @IBAction func unwindToAddExperienceFromEffort(segue:UIStoryboardSegue){
        if self.selectedEffort.count > 0{
            self.addExperienceParameters[kExperienceEffort] = "\(self.selectedEffort)"
            self.txtExperienceEffort.text = "\(self.selectedEffort)"
            self.validTextField(textField: self.txtExperienceEffort)
        }
        defer{
            self.sizeFooterToFit()
        }
    }
    @IBAction func unwindToAddExperienceFromLangauge(segue:UIStoryboardSegue){
        DispatchQueue.main.async {
            self.configureSelectedLanguage()
        }
    }
    @IBAction func unwindToAddExperienceFromCollection(segue:UIStoryboardSegue){
        
        DispatchQueue.main.async {
            self.configureSelectedCollections()
        }
    }
    @IBAction func unwindToAddExperienceFromNewSchedule(segue:UIStoryboardSegue){
        if let _ = self.newScheduleParameters{
            self.arrayOfSchedules.append(self.newScheduleParameters!)
            self.tableViewScheduleHeight.constant = CGFloat(self.arrayOfSchedules.count * Int(self.tableViewScheduleRowHeight))
            self.tableViewAddExperience.scrollToBottom(animated: true)
            self.tableViewSchedule.reloadData()
            self.addExperienceParameters[kExperienceOccurrences] = self.arrayOfSchedules
        }
        defer{
            self.sizeFooterToFit()
        }
    }
    @IBAction func unwindToAddExperienceFromSearchLocation(segue:UIStoryboardSegue){
        DispatchQueue.main.async {
            self.configureSelectedLocation()
        }
    }
    @IBAction func unwindToAddExperienceFromLocation(segue:UIStoryboardSegue){
        DispatchQueue.main.async {
            self.configureSelectedLocation()
        }
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    func presentImagePickerController(){
        self.view.endEditing(true)
        self.present(self.objImagePickerController, animated: true, completion: nil)
       
    }
    func presentCurrencyPicker(){
        if let currencyPicker = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController{
            currencyPicker.modalPresentationStyle = .overFullScreen
            currencyPicker.objSearchType = .Currency
            currencyPicker.arrayOfCurrency = self.arrayOfCurrency
            self.view.endEditing(true)

            self.present(currencyPicker, animated: true, completion: nil)
        }
        defer{
            DispatchQueue.main.async {
            }
        }
    }
    func presentEfforPicker(){
        if let effortPicker = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController{
            effortPicker.objSearchType = .Effort
            effortPicker.modalPresentationStyle = .overFullScreen
            self.view.endEditing(true)
            self.present(effortPicker, animated: true, completion: nil)
        }
        
        
    }
    func presentPricePicker(){
        if let pricePicker = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController{
            pricePicker.modalPresentationStyle = .overCurrentContext
            pricePicker.objSearchType = .Price
            self.view.endEditing(true)
            self.present(pricePicker, animated: true, completion: nil)
        }
    }
    func presentLangaugePicker(){
        if let langaugePicker = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController{
            langaugePicker.modalPresentationStyle = .overFullScreen
            langaugePicker.objSearchType = .Langauge
            langaugePicker.arrayOfLanguage = self.arrayOfLanguage
            if self.selectedLangauges.count > 0{
                var arrayLanID:[String] = []
                for objLan in self.selectedLangauges{
                    arrayLanID.append("\(objLan.langaugeID)")
                }
                langaugePicker.selectedLangauges.addObjects(from: arrayLanID)
            }
            self.view.endEditing(true)
            self.present(langaugePicker, animated: true, completion: nil)
        }
       
    }
    func presentCollectionPicker(){
        if let collectionPicker = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController{
            collectionPicker.modalPresentationStyle = .overFullScreen
            collectionPicker.objSearchType = .Collection
            collectionPicker.arrayOfCollection = self.arrayOfExploreCollection
            if selectedCollection.count > 0{
                var arrayCollectionID:[String] = []
                for objCollection in selectedCollection{
                    arrayCollectionID.append("\(objCollection.id)")
                }
                collectionPicker.selectedCollections.addObjects(from: arrayCollectionID)
            }
            self.view.endEditing(true)
            self.present(collectionPicker, animated: true, completion: nil)
        }
        
    }
    func presentLocationPicker(){
        //let reqestLocationURL = kAllLocation+"/country/\(User.getUserFromUserDefault()!.userCurrentCountryID)"
        //Update as we need to remove location restriction
        let reqestLocationURL = kAllLocation+"/country/0"
        APIRequestClient.shared.sendRequest(requestType: .GET, queryString: reqestLocationURL, parameter: nil, isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let arraySuccess = successDate["location"] as? NSArray{
                var arrayOfLocation:[CountyDetail] = []
                for objCountry in arraySuccess{
                    if let jsonCountry = objCountry as? [String:Any]{
                        let countryDetail = CountyDetail.init(objJSON: jsonCountry)
                        arrayOfLocation.append(countryDetail)
                    }
                }
                DispatchQueue.main.async {
                    if let locationPicker = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController{
                        locationPicker.objSearchType = .Location
                        locationPicker.modalPresentationStyle = .overFullScreen
                        locationPicker.arrayOfLocation = arrayOfLocation
                        self.view.endEditing(true)
                        self.present(locationPicker, animated: true, completion: nil)
                    }
                }
            }else{
                DispatchQueue.main.async {
                    //ShowToast.show(toatMessage:kCommonError)
                }
            }
        }) { (responseFail) in
            if let arrayFail = responseFail as? NSArray , let fail = arrayFail.firstObject as? [String:Any],let errorMessage = fail["ErrorMessage"]{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "\(errorMessage)")
                }
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        }
        
        /*
            if let locationViewController = self.storyboard?.instantiateViewController(withIdentifier:"LocationViewController") as? LocationViewController {
                let locationNavigationView = UINavigationController.init(rootViewController: locationViewController)
                self.view.endEditing(true)
                self.navigationController?.present(locationNavigationView, animated: true, completion: nil)
            }
        */
    }
    func pushTOScheduleViewController(){
        if let schedulViewController = self.storyboard?.instantiateViewController(withIdentifier: "ScheduleViewController") as? ScheduleViewController{
            self.navigationController?.pushViewController(schedulViewController, animated: true)
        }
    }
}
extension AddExperienceViewController:GMSPlacePickerViewControllerDelegate{
    // To receive the results from the place picker 'self' will need to conform to
    // GMSPlacePickerViewControllerDelegate and implement this code.
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        defer{
            let (strAddress,strPostal) = self.getAddressAndPostalCode(place: place)
            DispatchQueue.main.async {
                self.txtMeetingAddOfExperience.minimizePlaceholder()
                self.txtExperienceMeetingAdd.text = "\(strAddress)"
                self.txtPostalZipOfExperience.minimizePlaceholder()
                self.txtExperiencePostalZip.text = "\(strPostal)"
                self.sizeFooterToFit()

            }
            self.addExperienceParameters[kExperiencePostal] = "\(strPostal)"
            self.addExperienceParameters[kExperienceMeetingAddress] = "\(strAddress)"
            self.addExperienceParameters[kExperienceLatitude] = "\(place.coordinate.latitude)"
            self.addExperienceParameters[kExperienceLongitude] = "\(place.coordinate.longitude)"
            self.validTextField(textField: self.txtMeetingAddOfExperience)
        }
    }
    func getAddressAndPostalCode(place: GMSPlace)->(String,String){
        // Get the address components.  
        var address:[String] = ["\(place.name)"]
        var postalCode:String = ""
        if let addressLines = place.addressComponents {
            // Populate all of the address fields we can find.
            for field in addressLines {
                switch field.type {
                case kGMSPlaceTypeStreetNumber:
                    let street_number = field.name
                    address.append(street_number)
                case kGMSPlaceTypeRoute:
                    let route = field.name
                    address.append(route)
                case kGMSPlaceTypeNeighborhood:
                    let neighborhood = field.name
                    address.append(neighborhood)
                case kGMSPlaceTypeLocality:
                    let locality = field.name
                    address.append(locality)
                case kGMSPlaceTypeSublocalityLevel1:
                    let subLocality = field.name
                    address.append(subLocality)
                case kGMSPlaceTypeAdministrativeAreaLevel1:
                    let administrative_area_level_1 = field.name
                    address.append(administrative_area_level_1)
                case kGMSPlaceTypeCountry:
                    let country = field.name
                    address.append(country)
                case kGMSPlaceTypePostalCode:
                    postalCode = field.name
                //address.append(postal_code)
                case kGMSPlaceTypePostalCodeSuffix:
                    let postal_code = field.name
                    print(postal_code)
                    //address.append(postal_code)
                // Print the items we aren't using.
                default:
                    print("Type: \(field.type), Name: \(field.name)")
                }
            }
        }
        return ("\(address.joined(separator:","))","\(postalCode)")
    }
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        defer{
            self.txtMeetingAddOfExperience.minimizePlaceholder()
            self.sizeFooterToFit()
        }
        
    }
}
extension AddExperienceViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate, CropViewControllerDelegate {
    
    func cropViewController(_ controller: CropViewController, didFinishCroppingImage image: UIImage) {
        let imageData = image.jpeg(.lowest)
        self.uploadImageRequest(imageData: imageData!, imageName:"image")
    }
    
    func cropViewController(_ controller: CropViewController, didFinishCroppingImage image: UIImage, transform: CGAffineTransform, cropRect: CGRect) {
        controller.dismiss(animated: false, completion: nil)
    }
    
    func cropViewControllerDidCancel(_ controller: CropViewController) {
        controller.dismiss(animated: false, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.lblTesting.text = "\(info)"
        let mediaType = info[UIImagePickerControllerMediaType] as! CFString
        
        switch mediaType {
        case kUTTypeImage:
            //                if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage,let imageData = editedImage.jpeg(.lowest){
            //                    print("\(Date().ticks)")
            //                    self.uploadImageRequest(imageData: imageData, imageName:"image")
            guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
                dismiss(animated: false, completion: nil)
                return
            }
            self.imageForCrop = image
            dismiss(animated: false) { [unowned self] in
                self.openEditor(nil, pickingViewTag: picker.view.tag)
            }
            break
        case kUTTypeMovie:
            if let videoURL = info[UIImagePickerControllerMediaURL] as? URL{
                
                guard let data = NSData(contentsOf: videoURL as URL) else {
                    DispatchQueue.main.async {
                        self.lblTesting.text = "No data"
                        ProgressHud.hide()
                    }
                    return
                }
                DispatchQueue.main.async {
                    ProgressHud.show()
                    self.lblTesting.text = "Video URL \(videoURL) \r File size before compression: \(Double(data.length / 1048576)) mb"
                }
                print("File size before compression: \(Double(data.length / 1048576)) mb")
                let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".m4v")
                self.compressVideo(inputURL: videoURL as URL, outputURL: compressedURL) { (exportSession) in
                    guard let session = exportSession else {
                        DispatchQueue.main.async {
                            self.lblTesting.text = "No exportSession"
                            ProgressHud.hide()
                        }
                        return
                    }
                    if session.status == .completed{
                        guard let compressedData = NSData(contentsOf: compressedURL) else {
                            DispatchQueue.main.async {
                                self.lblTesting.text = "No compress data"
                                ProgressHud.hide()
                            }
                            return
                        }
                        DispatchQueue.main.async {
                            ProgressHud.show()
                            self.lblTesting.text = "Start Uploading \r File size after compression: \(Double(compressedData.length / 1048576)) mb"
                        }
                        self.uploadVideoRequest(videoData: compressedData as Data, videoName:"\(videoURL.lastPathComponent)")
                    }else{
                        DispatchQueue.main.async {
                            ProgressHud.hide()
                            ShowToast.show(toatMessage:kCommonError)
                        }
                    }
                }
                
            }
            break
        case kUTTypeLivePhoto:
            
            break
        default:
            break
        }
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        
    }
}
extension AddExperienceViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableViewAddExperience{
            guard let _ = self.editExperience,self.isEdit else{
                return 1
            }
            return 1//(self.arrayOfPreview.count > 0) ? 1:0
        }else if tableView == self.tableViewSchedule{
            return self.arrayOfSchedules.count
        }else{
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView ==  self.tableViewAddExperience{ // Page Control Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookDetailHeaderCell") as! BookDetailHeaderCell
            cell.openImageDelegate = self
            cell.addExperienceDelegate = self
            cell.isForAddExperience = false
            DispatchQueue.main.async {
                
                if let mediaDict = self.mediaDictionary as? [String:[String]],(self.arrayOfImages+self.arrayOfVideo).count > 0{
                    
                    cell.arrayOfPreview = self.arrayOfPreview
                    cell.scrMain.isHidden = false
                    UIView.animate(withDuration: 0.2, animations: {
                        cell.loadScrollView(mediaDic: mediaDict)
                        cell.layoutIfNeeded()
                    })
                    
                    cell.lblHintLable.isHidden = true
                    cell.hintView.isHidden = true
                    cell.pageControl.isHidden = false
                    cell.pageControl.currentPage = self.currentSelectedPage
                    if let _ = self.mainImage{
                        cell.mainImage = self.mainImage!
                    }else{
                        cell.mainImage = nil
                    }
                    cell.pageChanged()
                }else{
                    self.mainImage = nil
                    cell.lblHintLable.isHidden = false
                    cell.hintView.isHidden = false
                    cell.videoImg.isHidden = true
                    cell.hideAll()
                }
                
            }
            return cell
        }else if tableView == self.tableViewSchedule{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleTableViewCell") as! ScheduleTableViewCell
            guard indexPath.row < self.arrayOfSchedules.count else{
                return cell
            }
            let schedule:[String:Any] = self.arrayOfSchedules[indexPath.row]
            
            if let occurence = schedule[kRecurrence] as? String,let time24 = schedule[kTime] as? String,let occurenceDay = schedule[kRecurrenceDay] as? [String]{
                let time = time24.converTo12hoursFormate()
                var strDay = "day"
                if occurenceDay.count > 1{
                    strDay = "days"
                }else{
                    strDay = "day"
                }
                //    var arrayOfScheduleTypes:[String] = ["Once","Daily","Weekly","Weekdays","Monthly"]
                if occurence.compareCaseInsensitive(str: "\(Vocabulary.getWordFromKey(key:"Custom"))"){
                    
                    if time.count > 0,time != "None"{
                        cell.lblScheduleName.text = "\(occurence) on \(occurenceDay.count) \(strDay) at \(time)"
                    }else{
                        cell.lblScheduleName.text = "\(occurence) on \(occurenceDay.count) \(strDay)"
                    }
                }else if occurence.compareCaseInsensitive(str: "\(Vocabulary.getWordFromKey(key:"Once"))"){
                    let usaDate = self.getUSADateFormate(mmddyyyyDate: "\(occurenceDay.first!)")
                    if time.count > 0,time != "None"{
                        cell.lblScheduleName.text = "\(occurence) on \(usaDate) at \(time)"
                    }else{
                        cell.lblScheduleName.text = "\(occurence) on \(usaDate)"
                    }
                }else if occurence.compareCaseInsensitive(str: "\(Vocabulary.getWordFromKey(key:"Daily"))"){
                        cell.lblScheduleName.text = "\(occurence) at \(time)"
                }else if occurence.compareCaseInsensitive(str:"\(Vocabulary.getWordFromKey(key:"Weekly"))"){
                    cell.lblScheduleName.text = "\(occurence) on \(self.getDayOfSelected(day:occurenceDay.first!)) at \(time)"
                }else if occurence.compareCaseInsensitive(str:"\(Vocabulary.getWordFromKey(key:"Weekdays"))"){
                    cell.lblScheduleName.text = "\(occurence) at \(time)"
                }else if occurence.compareCaseInsensitive(str:"\(Vocabulary.getWordFromKey(key:"Monthly"))"){
                    if time.count > 0,time != "None"{
                        cell.lblScheduleName.text = "\(occurence) on \(occurenceDay.count) \(strDay) at \(time)"
                    }else{
                        cell.lblScheduleName.text = "\(occurence) on \(occurenceDay.count) \(strDay)"
                    }
                }else{
                    
                }
            }
            if let startDate = schedule["StartDate"],"\(startDate)".count > 0,let endDate = schedule["EndDate"],"\(endDate)".count > 0{
                let fromText = Vocabulary.getWordFromKey(key: "from.hint")+":"
                let toText = Vocabulary.getWordFromKey(key: "to.hint")+":"
                let strokeTextAttributes: [NSAttributedStringKey: Any] = [
                    .foregroundColor : UIColor.init(hexString:"36527D"),
                    NSAttributedStringKey.font : UIFont(name: "Avenir-Roman", size: 12)!
                ]
                let usaStartDate = self.getUSADateFormate(mmddyyyyDate: "\(startDate)")
                let usaEndDate = self.getUSADateFormate(mmddyyyyDate: "\(endDate)")
                
                let fromAttributtted =  NSMutableAttributedString.init(string: fromText, attributes: strokeTextAttributes)
                let toAttributted = NSAttributedString.init(string: toText, attributes: strokeTextAttributes)
                let startDateAttributted = NSAttributedString.init(string: " \(usaStartDate) ", attributes: strokeTextAttributes)
                let endDateAttrcibutted = NSAttributedString.init(string: " \(usaEndDate) ", attributes: strokeTextAttributes)
                fromAttributtted.append(startDateAttributted)
                fromAttributtted.append(toAttributted)
                fromAttributtted.append(endDateAttrcibutted)
                cell.lblStartEndDate.attributedText = fromAttributtted//"\(fromAttributtted): \(startDate) \(toAttributted): \(endDate)"
            }else{
                cell.lblStartEndDate.text = ""
            }
            cell.tag = indexPath.row
            cell.scheduleTableViewDelegate = self
            //cell.showSeparator()
            return cell
        }else{
            return UITableViewCell()
        }
    }
    func getUSADateFormate(mmddyyyyDate:String)->String{
        let objDateFormate = DateFormatter()
        objDateFormate.dateFormat = "MM/dd/yyyy"
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        if let objMediumDate = objDateFormate.date(from:"\(mmddyyyyDate)"){
            let strDate = dateFormatter.string(from: objMediumDate)
            return strDate
            
        }
        return "\(mmddyyyyDate)"
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableViewAddExperience{
            return tableViewRowheight
        }else if tableView == self.tableViewSchedule{
            return tableViewScheduleRowHeight
        }else{
            return 0
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableViewSchedule,self.arrayOfSchedules.count > indexPath.row{
            let schedule:[String:Any] = self.arrayOfSchedules[indexPath.row]
            if let occurence = schedule[kRecurrence] as? String,let time = schedule[kTime] as? String,let occurenceDay = schedule[kRecurrenceDay] as? [String]{
                //    var arrayOfScheduleTypes:[String] = ["Once","Daily","Weekly","Weekdays","Monthly"]
                if occurence.compareCaseInsensitive(str: "\(Vocabulary.getWordFromKey(key:"Custom"))") || occurence.compareCaseInsensitive(str: "\(Vocabulary.getWordFromKey(key:"Monthly"))"){ //ScheduleDates.hint
                    var strTitle:String = ""
                    var strMSG:String = ""
                    if occurence.compareCaseInsensitive(str: "\(Vocabulary.getWordFromKey(key:"Custom"))"){
                        strTitle =  Vocabulary.getWordFromKey(key:"ScheduleDays.hint")
                        let usaDateArray = occurenceDay.map { (day) -> String in
                                        return self.getUSADateFormate(mmddyyyyDate: day)
                                        }
                        //let usaDateArray = occurenceDay.map(self.getUSADateFormate(mmddyyyyDate:$0))
                        strMSG = "\n"+usaDateArray.joined(separator: "\n\n")
                    }else{
                        strTitle = Vocabulary.getWordFromKey(key:"ScheduleDates.hint")
                        strMSG = "\n"+self.getDaysFromSelectedDates(dates: occurenceDay).joined(separator: "\n\n")
                    }
                    let deleteAlert = UIAlertController(title: strTitle, message: strMSG,preferredStyle: UIAlertControllerStyle.alert)
                     if let startDate = schedule["StartDate"],"\(startDate)".count > 0,let endDate = schedule["EndDate"],"\(endDate)".count > 0{
                        let fromText = "\n\n\n"+Vocabulary.getWordFromKey(key: "from.hint")+":"
                        let toText = Vocabulary.getWordFromKey(key: "to.hint")+":"
                        let strokeTextAttributes: [NSAttributedStringKey: Any] = [
                            .foregroundColor : UIColor.init(hexString:"36527D"),
                            NSAttributedStringKey.font : UIFont(name: "Avenir-Roman", size: 12)!
                        ]
                        let strokeBlackTextAttributes: [NSAttributedStringKey: Any] = [
                            .foregroundColor : UIColor.black,
                        ]
                        let alertAttributtedMSG = NSMutableAttributedString.init(string: "\(strMSG)",attributes: strokeBlackTextAttributes)
                        
                        let usaStartDate = self.getUSADateFormate(mmddyyyyDate: "\(startDate)")
                        let usaEndDate = self.getUSADateFormate(mmddyyyyDate: "\(endDate)")
                        
                        let fromAttributtted =  NSMutableAttributedString.init(string: fromText, attributes: strokeTextAttributes)
                        let toAttributted = NSAttributedString.init(string: toText, attributes: strokeTextAttributes)
                        let startDateAttributted = NSAttributedString.init(string: " \(usaStartDate) ", attributes: strokeTextAttributes)
                        let endDateAttrcibutted = NSAttributedString.init(string: " \(usaEndDate) ", attributes: strokeTextAttributes)
                        fromAttributtted.append(startDateAttributted)
                        fromAttributtted.append(toAttributted)
                        fromAttributtted.append(endDateAttrcibutted)
                        alertAttributtedMSG.append(fromAttributtted)
                        deleteAlert.setValue(alertAttributtedMSG, forKey: "attributedMessage")

                     }
                    /*
                     let fromText = Vocabulary.getWordFromKey(key: "from.hint")+":"
                     let toText = Vocabulary.getWordFromKey(key: "to.hint")+":"
                     let strokeTextAttributes: [NSAttributedStringKey: Any] = [
                     .foregroundColor : UIColor.init(hexString:"36527D")
                     ]
                     let strokeBlackTextAttributes: [NSAttributedStringKey: Any] = [
                     .foregroundColor : UIColor.black
                     ]
                     let usaStartDate = self.getUSADateFormate(mmddyyyyDate: "\(startDate)")
                     let usaEndDate = self.getUSADateFormate(mmddyyyyDate: "\(endDate)")
                     
                     let fromAttributtted =  NSMutableAttributedString.init(string: fromText, attributes: strokeTextAttributes)
                     let toAttributted = NSAttributedString.init(string: toText, attributes: strokeTextAttributes)
                     let startDateAttributted = NSAttributedString.init(string: " \(usaStartDate) ", attributes: strokeTextAttributes)
                     let endDateAttrcibutted = NSAttributedString.init(string: " \(usaEndDate) ", attributes: strokeTextAttributes)
                     fromAttributtted.append(startDateAttributted)
                     fromAttributtted.append(toAttributted)
                     fromAttributtted.append(endDateAttrcibutted)
                     */
                    
                    deleteAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"Cancel"), style: .cancel, handler: nil))
                    deleteAlert.view.tintColor = UIColor.init(hexString: "#36527D")
                    self.present(deleteAlert, animated: true, completion: nil)
                }
            }
        }
    }
    func getDaysFromSelectedDates(dates:[String])->[String]{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let selectedDays:NSMutableSet = NSMutableSet()
        for strDate in dates {
            if let date = dateFormatter.date(from: strDate){
                let day = Calendar.current.component(.day, from: date)
                selectedDays.add("\(day.ordinal) day of every month")
            }
        }
        return selectedDays.allObjects as! [String]
    }
}
extension AddExperienceViewController:UICollectionViewDragDelegate{
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let photo = self.arrayOfPreview[indexPath.item]
        let item =  NSItemProvider.init(object:"\(photo)" as NSString)//NSItemProvider.init(contentsOf: URL.init(string: "\(photo)"))
        let drageItem = UIDragItem.init(itemProvider: item)
        drageItem.localObject = "\(photo)"
        return [drageItem]
    }
}
extension AddExperienceViewController:UICollectionViewDropDelegate{
//    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
//        return true
//    }
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag{
            return UICollectionViewDropProposal.init(operation: .move, intent: .insertAtDestinationIndexPath)
        }else{
            return UICollectionViewDropProposal.init(operation: .forbidden)

        }
    }
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator){
        
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath.init(row: 0, section: 0)
        switch coordinator.proposal.operation {
        case .move:
            self.reorderItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath)
            break
        default:
            return
        }

    }
    private func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath)
    {
        let items = coordinator.items
        if items.count == 1, let item = items.first, let sourceIndexPath = item.sourceIndexPath
        {
            var dIndexPath = destinationIndexPath
            if dIndexPath.row >= self.collectionPreview.numberOfItems(inSection: 0)
            {
                dIndexPath.row = self.collectionPreview.numberOfItems(inSection: 0) - 1
            }
            self.collectionPreview.performBatchUpdates({
                let objCurrentURL = self.arrayOfPreview[self.currentSelectedPage]

                self.arrayOfPreview.remove(at: sourceIndexPath.row)
                var local = item.dragItem.localObject as! NSString
                local.accessibilityValue = "\(dIndexPath.row)"
                self.arrayOfPreview.insert(item.dragItem.localObject as! NSString, at: dIndexPath.row)
                self.arrayOfPreview[sourceIndexPath.row].accessibilityValue = "\(sourceIndexPath.row)"
                
                //self.arrayOfPreview.insert(str, at: dIndexPath.row)
                 self.collectionPreview.deleteItems(at: [sourceIndexPath])
                 self.collectionPreview.insertItems(at: [dIndexPath])
                if let imageIndex = self.arrayOfPreview.index(where: {$0 == objCurrentURL}){
                    self.currentSelectedPage = imageIndex
                }
                let indexPath = IndexPath(item: 0, section: 0)
                self.tableViewAddExperience.reloadRows(at: [indexPath], with: .none)
                 //self.tableViewAddExperience.reloadData()
            })
            coordinator.drop(items.first!.dragItem, toItemAt: dIndexPath)
        }
    }
    
}
extension AddExperienceViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
       return true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.arrayOfPreview.count > 09 {
            self.buttonAddMediaWidth.constant = 0
        }else{
            self.buttonAddMediaWidth.constant = 60
        }
        return self.arrayOfPreview.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let previewCell = collectionView.dequeueReusableCell(withReuseIdentifier:"PreViewCollectionViewCell", for: indexPath) as! PreViewCollectionViewCell
        //previewCell.layer.borderWidth = 2.0
        previewCell.clipsToBounds = true
        if self.arrayOfPreview.count > indexPath.item{
            
            DispatchQueue.main.async {
                previewCell.imagePreView.imageFromServerURL(urlString: "\(self.arrayOfPreview[indexPath.item])")
            }
            if indexPath.item == self.currentSelectedPage{
                previewCell.shadowView.isHidden = true
                //previewCell.alpha = 1.0//UIColor.init(hexString:"34c4de").cgColor
            }else{
                previewCell.shadowView.isHidden = false
                //previewCell.alpha = 0.7//UIColor.clear.cgColor
            }
            previewCell.imagePreView.contentMode = .scaleAspectFill
        }
        return previewCell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize.init(width: collectionView.bounds.size.height, height: collectionView.bounds.size.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsets.init(top: 0, left:15, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 15
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.currentSelectedPage = indexPath.item
        DispatchQueue.main.async {
            self.collectionPreview.reloadData()
            self.tableViewAddExperience.reloadRows(at: [IndexPath.init(row: 0, section: 0)], with: .none)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.tableViewAddExperience.setContentOffset(.zero, animated: true)
            }
        }
    }
}
extension AddExperienceViewController:openImgaeFromSelectionofPageControl{
    func openNewImageView(imgUrl: String, isvideo: Bool, currentPage: Int, imageArray: [String], videoArray: [String]) {
    //func openNewImageView(imgUrl: String, isvideo: Bool,currentPage:Int) {
        let instantViewController = UIStoryboard(name: "BooknowDetailSB", bundle: nil).instantiateViewController(withIdentifier: "InstantOpenController") as! InstantOpenController
        instantViewController.urlString = imgUrl
        instantViewController.isVideo = isvideo
        instantViewController.previewMediaDelegate = self
        instantViewController.currentPage = currentPage
        instantViewController.isFromAddExperience = true
        instantViewController.arrayOfPreview = self.arrayOfPreview
        instantViewController.thumbnailArr = self.arrayOfThumNail
        self.present(instantViewController, animated: false, completion: nil)
    }
    func currentPageSetter(currentPage: Int) {
        self.currentSelectedPage = currentPage
    }
}

extension AddExperienceViewController:UITextViewDelegate{
    func textViewDidEndEditing(_ textView: UITextView) {
            if textView == self.txtExperienceTitle{
                if textView.text.count == 0{
                    self.txtTitleOfExperience.resignFirstResponder()
                    self.txtTitleOfExperience.maximizePlaceholder()
                    textView.resignFirstResponder()
                }else{
                    self.txtTitleOfExperience.minimizePlaceholder()
                }
            }else if textView == self.txtExperienceDescription{
                self.txtExperienceDescription.isEditable = false
                self.txtExperienceDescription.dataDetectorTypes = .all
                if textView.text.count == 0{
                    self.txtDescriptionOfExperience.resignFirstResponder()
                    self.txtDescriptionOfExperience.maximizePlaceholder()
                    textView.resignFirstResponder()
                }else{
                    self.txtDescriptionOfExperience.minimizePlaceholder()
                }
            }else if textView == self.txtExperienceLangauge{
                if textView.text.count == 0{
                    self.txtLanguageOfExperience.resignFirstResponder()
                    self.txtLanguageOfExperience.maximizePlaceholder()
                    textView.resignFirstResponder()
                }else{
                    self.txtLanguageOfExperience.minimizePlaceholder()
                }
            }else if textView == self.txtExperienceCollection{
                if textView.text.count == 0{
                    self.txtCollectionOfExperience.resignFirstResponder()
                    DispatchQueue.main.async {
                        //self.txtCollectionOfExperience.maximizePlaceholder()
                    }
                    textView.resignFirstResponder()
                }else{
                    self.txtCollectionOfExperience.minimizePlaceholder()
                }
            }else if textView == self.txtExperienceLocation{
                if textView.text.count == 0{
                    self.txtLocationOfExperience.resignFirstResponder()
                    self.txtLocationOfExperience.maximizePlaceholder()
                    textView.resignFirstResponder()
                }else{
                    self.txtLocationOfExperience.minimizePlaceholder()
                }
            }else if textView == self.txtExperienceMeetingAdd{
                if textView.text.count == 0{
                    self.txtMeetingAddOfExperience.resignFirstResponder()
                    self.txtMeetingAddOfExperience.maximizePlaceholder()
                    textView.resignFirstResponder()
                }else{
                    self.txtMeetingAddOfExperience.minimizePlaceholder()
                }
            }else if textView == self.txtExperiencePostalZip{
                if textView.text.count == 0{
                    self.txtPostalZipOfExperience.resignFirstResponder()
                    self.txtPostalZipOfExperience.maximizePlaceholder()
                    textView.resignFirstResponder()
                }else{
                    self.txtPostalZipOfExperience.minimizePlaceholder()
                }
            }else if textView == self.txtExperienceAddReference{
                if textView.text.count == 0{
                    self.txtAddReferenceOfExperience.resignFirstResponder()
                    self.txtAddReferenceOfExperience.maximizePlaceholder()
                    textView.resignFirstResponder()
                }else{
                    self.txtAddReferenceOfExperience.minimizePlaceholder()
                }
            }else if textView == self.txtExperienceRistriction{
                if textView.text.count == 0{
                    self.txtRistrictionOfExperience.resignFirstResponder()
                    self.txtRistrictionOfExperience.maximizePlaceholder()
                    textView.resignFirstResponder()
                }else{
                    self.txtRistrictionOfExperience.minimizePlaceholder()
                }
            }
        defer {
            self.sizeFooterToFit()
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == self.txtExperienceTitle{
                self.txtTitleOfExperience.resignFirstResponder()
                self.txtTitleOfExperience.minimizePlaceholder()
                textView.becomeFirstResponder()
        }else if textView == self.txtExperienceDescription{
                self.txtDescriptionOfExperience.resignFirstResponder()
                self.txtDescriptionOfExperience.minimizePlaceholder()
                textView.becomeFirstResponder()
        }else if textView == self.txtExperienceLangauge{
                self.txtLanguageOfExperience.resignFirstResponder()
                self.txtLanguageOfExperience.minimizePlaceholder()
                textView.resignFirstResponder()
                //PresentLanguagePicker
                self.getGuideLanguages()
        }else if textView == self.txtExperienceCollection {
            self.txtCollectionOfExperience.resignFirstResponder()
            textView.resignFirstResponder()
          
            if self.isEdit,let _ = self.editExperience{
                self.presentCollectionPicker()
                /*
                if let _ = self.selectedCountryDetail{
                    self.presentCollectionPicker()
                }else{
                    //self.getExploreCollection(locationID: self.editExperience!.locationId)
                    self.presentCollectionPicker()
                }*/
            }else if let _ = self.selectedCountryDetail{
                //self.txtCollectionOfExperience.minimizePlaceholder()
                //self.getExploreCollection(locationID: self.selectedCountryDetail!.locationID)
                //PresentCollectionPicker
                self.presentCollectionPicker()
            }else if let saveExperienceDetail = kUserDefault.value(forKey:kExperienceDetail) as? [String:Any]{
                if let _ =  saveExperienceDetail["Location"]{
                    self.presentCollectionPicker()
                }
            }
        }else if textView == self.txtExperienceLocation{
            self.txtLocationOfExperience.resignFirstResponder()
            self.txtLocationOfExperience.minimizePlaceholder()
            textView.resignFirstResponder()
            //PresentCollectionPicker
            self.presentLocationPicker()
        }else if textView == self.txtExperienceMeetingAdd{
            self.txtMeetingAddOfExperience.resignFirstResponder()
            self.txtMeetingAddOfExperience.minimizePlaceholder()
            textView.becomeFirstResponder()
        }else if textView == self.txtExperiencePostalZip{
            self.txtPostalZipOfExperience.resignFirstResponder()
            self.txtPostalZipOfExperience.minimizePlaceholder()
            textView.becomeFirstResponder()
        }else if textView == self.txtExperienceAddReference{
            self.txtAddReferenceOfExperience.resignFirstResponder()
            self.txtAddReferenceOfExperience.minimizePlaceholder()
            textView.becomeFirstResponder()
        }else if textView == self.txtExperienceRistriction{
            self.txtRistrictionOfExperience.resignFirstResponder()
            self.txtRistrictionOfExperience.minimizePlaceholder()
            textView.becomeFirstResponder()
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let typpedString = ((textView.text)! as NSString).replacingCharacters(in: range, with: text)
        
        if text == "\n"{
            textView.resignFirstResponder()
            return true
        }
        if textView == self.txtExperienceTitle{
            self.lblExperienceTitleLimit.isHidden = false
            self.lblExperienceTitleLimit.text = "\(typpedString.count)/\(self.experienceTitleMax)"
            self.addExperienceParameters[kExperienceTitle] = "\(typpedString)"
            if typpedString.count > 0{
                self.validTextField(textField:self.txtTitleOfExperience)
            }else{
                self.lblExperienceTitleLimit.isHidden = true
            }
            return typpedString.count < self.experienceTitleMax
        }else if textView == self.txtExperienceDescription{
            self.lblExperienceDescriptionLimit.isHidden = false
            self.lblExperienceDescriptionLimit.text = "\(typpedString.count)/\(self.maximumTextLimit)"
            self.addExperienceParameters[KExperienceDiscription] = "\(typpedString)"
            if typpedString.count > 0{
                self.validTextField(textField:self.txtDescriptionOfExperience)
            }else{
                self.lblExperienceDescriptionLimit.isHidden = true
            }
            return typpedString.count < self.maximumTextLimit
        }else if textView == self.txtExperienceLocation{
            self.addExperienceParameters[kExperienceLocationID] = "\(typpedString)"
            return true
        }else if textView == self.txtExperienceMeetingAdd{
            self.addExperienceParameters[kExperienceMeetingAddress] = "\(typpedString)"
            self.validTextField(textField: self.txtMeetingAddOfExperience)
            return true
        }else if textView == self.txtExperiencePostalZip{
            self.addExperienceParameters[kExperiencePostal] = "\(typpedString)"
            if typpedString.count > 0{
                self.validTextField(textField: self.txtPostalZipOfExperience)
            }
            return typpedString.count < self.experiencePostalCodeMax
        }else if textView == self.txtExperienceAddReference{
            self.lblExperienceAddRefLimit.text = "\(typpedString.count)/\(self.experienceDescriptionMax)"
            self.addExperienceParameters[kExperienceAddressRef] = "\(typpedString)"
            return typpedString.count < self.experienceDescriptionMax
        }else if textView == self.txtExperienceRistriction{
            self.lblExperienceRistrictionLimit.text = "\(typpedString.count)/\(self.experienceDescriptionMax)"
            self.addExperienceParameters[kExperienceRistriction] = "\(typpedString)"
            if typpedString.count > 0{
                self.validTextField(textField: self.txtRistrictionOfExperience)
            }
            return  typpedString.count < self.experienceDescriptionMax
        }else{
            return true
        }
    }
}
extension AddExperienceViewController:UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {

    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.txtCurrency{
            //Open Currency Picker
            self.buttonForgroundShadow.isHidden = false
            //self.presentCurrencyPicker()
            return true
        }else if textField == self.txtExperienceEffort{
            //Present Effort picker
             self.buttonForgroundShadow.isHidden = false
            //textField.resignFirstResponder()
            //self.view.endEditing(true)
            //self.presentEfforPicker()
            return true
        } else if textField == self.txtExperienceDuration {
            self.buttonForgroundShadow.isHidden = false
        }
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
         let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
        guard textField != self.txtPricePerPerson else{
            
            self.addExperienceParameters[kExperiencePricePerson] = "\(typpedString)"
            if typpedString.count > 0{
                self.validTextField(textField: self.txtPricePerPerson)
            }
            
            let aSet = NSCharacterSet(charactersIn:"0123456789.").inverted
            let compSepByCharInSet = typpedString.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            return typpedString == numberFiltered && typpedString.count < 8
            
        }
        guard textField != self.txtPricePerPersonHourly else{
            self.addExperienceParameters[kExeriencePricePerPersonHourly] = "\(typpedString)"
            if typpedString.count > 0{
                self.validTextField(textField: self.txtPricePerPersonHourly)
            }
            let aSet = NSCharacterSet(charactersIn:"0123456789.").inverted
            let compSepByCharInSet = typpedString.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            return typpedString == numberFiltered && typpedString.count < 8
        }
        guard textField != self.txtPricePerGroup else{
            self.addExperienceParameters[kExperienceGroupPrice] = "\(typpedString)"
            if typpedString.count > 0{
                self.validTextField(textField: self.txtPricePerGroup)
            }
            let aSet = NSCharacterSet(charactersIn:"0123456789.").inverted
            let compSepByCharInSet = typpedString.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            return typpedString == numberFiltered && typpedString.count < 8
        }
        guard textField != self.txtPricePerGroupHourly else{
            self.addExperienceParameters[kExerienceGroupPriceHourly] = "\(typpedString)"
            if typpedString.count > 0{
                self.validTextField(textField: self.txtPricePerGroupHourly)
            }
            let aSet = NSCharacterSet(charactersIn:"0123456789.").inverted
            let compSepByCharInSet = typpedString.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            return typpedString == numberFiltered && typpedString.count < 8
        }
        return true
    }
    
}
extension AddExperienceViewController:PreViewMediaDelegate{
    func setMainImageDelegatePreview(currentPage: Int) {
        self.dismiss(animated: true, completion: nil)
        self.mainImage = currentPage
        
    }
    func deleteMediaDelegate(currentPage: Int, isVideo: Bool) {
        let deleteAlert = UIAlertController(title: Vocabulary.getWordFromKey(key:"Experience.title"), message: Vocabulary.getWordFromKey(key:"delete.msg"),preferredStyle: UIAlertControllerStyle.alert)
        deleteAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"yes"), style: .default, handler: { (action: UIAlertAction!) in
            if isVideo{
                var videoCurrentPage:Int = 0
                if self.arrayOfImages.count > 0{
                    videoCurrentPage = currentPage - self.arrayOfImages.count
                }else{
                    videoCurrentPage = currentPage
                }
                self.arrayOfVideo.remove(at: videoCurrentPage)
                self.arrayOfThumNail.remove(at: videoCurrentPage)
                self.mediaDictionary["Video"] = self.arrayOfVideo
                self.mediaDictionary["Thumbnail"] = self.arrayOfThumNail
                self.arrayOfPreview = self.arrayOfImages + self.arrayOfThumNail
                let ans = self.arrayOfPreview.sorted {
                    (first, second) in
                    first.accessibilityValue!.compare(second.accessibilityValue!, options: .numeric) == ComparisonResult.orderedAscending
                }
                self.arrayOfPreview = ans
                DispatchQueue.main.async {
                    self.tableViewAddExperience.reloadData()
                    self.collectionPreview.reloadData()
                    self.tableViewAddExperience.setContentOffset(.zero, animated: true)
                }
            }else{
                if let mainIndex = self.mainImage,mainIndex == currentPage{
                    self.mainImage = nil
                }
                if let mainIndex = self.mainImage,mainIndex > currentPage{
                    self.mainImage! -= 1
                }
                self.arrayOfImages.remove(at: currentPage)
                self.mediaDictionary["Image"] = self.arrayOfImages
                self.arrayOfPreview = self.arrayOfImages + self.arrayOfThumNail
                let ans = self.arrayOfPreview.sorted {
                    (first, second) in
                    first.accessibilityValue!.compare(second.accessibilityValue!, options: .numeric) == ComparisonResult.orderedAscending
                }
                self.arrayOfPreview = ans
                DispatchQueue.main.async {
                    self.tableViewAddExperience.reloadData()
                    self.collectionPreview.reloadData()
                    self.tableViewAddExperience.setContentOffset(.zero, animated: true)
                }
            }
        }))
        deleteAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"no"), style: .cancel, handler: nil))
        self.view.endEditing(true)
        let titleAttrString = NSMutableAttributedString(string: Vocabulary.getWordFromKey(key: "Experience.title"), attributes: self.alertTitleFont)
        let messageAttrString = NSMutableAttributedString(string:Vocabulary.getWordFromKey(key:"delete.msg"), attributes: self.alertMessageFont)
        
        deleteAlert.setValue(titleAttrString, forKey: "attributedTitle")
        deleteAlert.setValue(messageAttrString, forKey: "attributedMessage")
        deleteAlert.view.tintColor = UIColor(hexString: "#36527D")
        present(deleteAlert, animated: true, completion: nil)
        
    }
}
extension AddExperienceViewController:AddExperienceDelegate{
    func setMainImageDelegate(currentPage: Int) {
        self.mainImage = currentPage
        DispatchQueue.main.async {
            self.tableViewAddExperience.reloadData()
        }
    }
    
    func deleteMediaDelegatePreview(currentPage: Int, isVideo: Bool) {
        self.dismiss(animated: true, completion: nil)
        if isVideo{
            var videoCurrentPage:Int = 0
            if self.arrayOfImages.count > 0{
                videoCurrentPage = currentPage - self.arrayOfImages.count
            }else{
                videoCurrentPage = currentPage
            }
            self.arrayOfVideo.remove(at: videoCurrentPage)
            self.arrayOfThumNail.remove(at: videoCurrentPage)
            self.mediaDictionary["Video"] = self.arrayOfVideo
            self.mediaDictionary["Thumbnail"] = self.arrayOfThumNail
            self.arrayOfPreview = self.arrayOfImages + self.arrayOfThumNail
            let ans = arrayOfPreview.sorted {
                (first, second) in
                first.accessibilityValue!.compare(second.accessibilityValue!, options: .numeric) == ComparisonResult.orderedAscending
            }
            self.arrayOfPreview = ans
            DispatchQueue.main.async {
                self.tableViewAddExperience.reloadData()
                self.collectionPreview.reloadData()
                self.tableViewAddExperience.setContentOffset(.zero, animated: true)
            }
        }else{
            if let mainIndex = self.mainImage,mainIndex == currentPage{
                self.mainImage = nil
            }
            if let mainIndex = self.mainImage,mainIndex > currentPage{
                self.mainImage! -= 1
            }
            self.arrayOfImages.remove(at: currentPage)
            self.mediaDictionary["Image"] = self.arrayOfImages
            self.arrayOfPreview = self.arrayOfImages + self.arrayOfThumNail
            let ans = arrayOfPreview.sorted {
                (first, second) in
                first.accessibilityValue!.compare(second.accessibilityValue!, options: .numeric) == ComparisonResult.orderedAscending
            }
            self.arrayOfPreview = ans
            DispatchQueue.main.async {
                self.tableViewAddExperience.reloadData()
                self.collectionPreview.reloadData()
                self.tableViewAddExperience.setContentOffset(.zero, animated: true)
            }
            
        }
        /*
        let deleteAlert = UIAlertController(title: Vocabulary.getWordFromKey(key:"Experience.title"), message: Vocabulary.getWordFromKey(key:"delete.msg"),preferredStyle: UIAlertControllerStyle.alert)
        deleteAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"yes"), style: .default, handler: { (action: UIAlertAction!) in
            if isVideo{
                var videoCurrentPage:Int = 0
                if self.arrayOfImages.count > 0{
                    videoCurrentPage = currentPage - self.arrayOfImages.count
                }else{
                    videoCurrentPage = currentPage
                }
                self.arrayOfVideo.remove(at: videoCurrentPage)
                self.arrayOfThumNail.remove(at: videoCurrentPage)
                self.mediaDictionary["Video"] = self.arrayOfVideo
                self.mediaDictionary["Thumbnail"] = self.arrayOfThumNail
                self.arrayOfPreview = self.arrayOfImages + self.arrayOfThumNail
                DispatchQueue.main.async {
                    self.tableViewAddExperience.reloadData()
                    self.collectionPreview.reloadData()
                    self.tableViewAddExperience.setContentOffset(.zero, animated: true)
                }
            }else{
                if let mainIndex = self.mainImage,mainIndex == currentPage{
                    self.mainImage = nil
                }
                if let mainIndex = self.mainImage,mainIndex > currentPage{
                    self.mainImage! -= 1
                }
                self.arrayOfImages.remove(at: currentPage)
                self.mediaDictionary["Image"] = self.arrayOfImages
                self.arrayOfPreview = self.arrayOfImages + self.arrayOfThumNail
                DispatchQueue.main.async {
                    self.tableViewAddExperience.reloadData()
                    self.collectionPreview.reloadData()
                    self.tableViewAddExperience.setContentOffset(.zero, animated: true)
                }
            }
        }))
        deleteAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"no"), style: .cancel, handler: nil))
        self.view.endEditing(true)
        let titleAttrString = NSMutableAttributedString(string: Vocabulary.getWordFromKey(key: "Experience.title"), attributes: self.alertTitleFont)
        let messageAttrString = NSMutableAttributedString(string:Vocabulary.getWordFromKey(key:"delete.msg"), attributes: self.alertMessageFont)
        
        deleteAlert.setValue(titleAttrString, forKey: "attributedTitle")
        deleteAlert.setValue(messageAttrString, forKey: "attributedMessage")
        deleteAlert.view.tintColor = UIColor(hexString: "#36527D")
       // UIApplication.shared.keyWindow?.rootViewController
        //UIApplication.shared.keyWindow?.rootViewController?
        //self.dismiss(animated: true, completion: nil)
        self.present(deleteAlert, animated: true, completion: nil)
      */
    }
    func deleteOnlyMediaDelegate(currentPage: Int, isVideo: Bool) {
        if isVideo{
            
        }else{
            
        }
    }
}
extension AddExperienceViewController:UIGestureRecognizerDelegate{
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
extension AddExperienceViewController:ScheduleTableViewCellDelegate{
    func buttonDeleteSelector(index:Int) {
        let deleteAlert = UIAlertController(title: Vocabulary.getWordFromKey(key:"ExperienceSchedule"), message: Vocabulary.getWordFromKey(key:"ExperienceSchedule.msg"),preferredStyle: UIAlertControllerStyle.alert)
        deleteAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"yes"), style: .default, handler: { (action: UIAlertAction!) in
            self.arrayOfSchedules.remove(at: index)
            DispatchQueue.main.async {
                self.tableViewScheduleHeight.constant = CGFloat(self.arrayOfSchedules.count * Int(self.tableViewScheduleRowHeight))
                self.sizeFooterToFit()
                self.tableViewAddExperience.scrollToBottom(animated: true)
                self.tableViewSchedule.reloadData()
            }
        }))
        deleteAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"no"), style: .cancel, handler: nil))
        let strDelete = Vocabulary.getWordFromKey(key: "delete")
        let strSchedule = Vocabulary.getWordFromKey(key: "Schedule")
        let titleAttrString = NSMutableAttributedString(string:"\(strDelete) \(strSchedule)", attributes: self.alertTitleFont)
        let messageAttrString = NSMutableAttributedString(string:Vocabulary.getWordFromKey(key:"ExperienceSchedule.msg"), attributes: self.alertMessageFont)
        
        deleteAlert.setValue(titleAttrString, forKey: "attributedTitle")
        deleteAlert.setValue(messageAttrString, forKey: "attributedMessage")
        deleteAlert.view.tintColor = UIColor(hexString: "#36527D")
        present(deleteAlert, animated: true, completion: nil)
    }
    
}
extension AddExperienceViewController:UIPickerViewDelegate,UIPickerViewDataSource{
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == self.currencyPicker{
            return "\(self.arrayOfCurrency[row].currencyText)"
        }else if pickerView == self.effortPicker{
            return "\(self.araryOfEffort[row])"
        }else{
            return ""
        }
        
    }
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 150.0
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30.0
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.currencyPicker{
            return self.arrayOfCurrency.count
        }else if pickerView == self.effortPicker{
            return self.araryOfEffort.count
        }else{
            return 0
        }
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == self.currencyPicker{
            self.currentCurrency = "\(self.arrayOfCurrency[row].currencyText)"
            self.currencyPicker.selectRow(row, inComponent: component, animated: true)
        }else if pickerView == self.effortPicker{
            self.currentEffort = "\(self.araryOfEffort[row])"
            self.effortPicker.selectRow(row, inComponent: component, animated: true)
        }else{
            
        }
    }
}
extension Int {
    
    var ordinal: String {
        var suffix: String
        let ones: Int = self % 10
        let tens: Int = (self/10) % 10
        if tens == 1 {
            suffix = "th"
        } else if ones == 1 {
            suffix = "st"
        } else if ones == 2 {
            suffix = "nd"
        } else if ones == 3 {
            suffix = "rd"
        } else {
            suffix = "th"
        }
        return "\(self)\(suffix)"
    }
    
}
//PreviewTableViewCell
protocol ScheduleTableViewCellDelegate {
    func buttonDeleteSelector(index:Int)
}
class ScheduleTableViewCell: UITableViewCell {
    
    @IBOutlet var lblScheduleName:UILabel!
    @IBOutlet var btnDeleteScheduleSelector:UIButton!
    @IBOutlet var deleteImageView:UIImageView!
    @IBOutlet var lblStartEndDate:UILabel!
    var scheduleTableViewDelegate:ScheduleTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
         //self.deleteImageView.image = #imageLiteral(resourceName: "close_dark").withRenderingMode(.alwaysTemplate)
         //self.deleteImageView.tintColor = .red
         self.deleteImageView.contentMode = .scaleAspectFit
        DispatchQueue.main.async {
            self.addDynamicFont()
        }
    }
    func addDynamicFont(){
        self.lblScheduleName.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblScheduleName.adjustsFontForContentSizeCategory = true
        self.lblScheduleName.adjustsFontSizeToFitWidth = true
    }
    //Selector Methods
    @IBAction func buttonDeleteSelector(button:UIButton){
        if let _ = self.scheduleTableViewDelegate{
            self.scheduleTableViewDelegate?.buttonDeleteSelector(index: self.tag)
        }
    }
}
//PreViewCollectionViewCell
class PreViewCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imagePreView:ImageViewForURL!
    @IBOutlet var shadowView:UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.imagePreView.layer.cornerRadius = 5.0
            self.imagePreView.clipsToBounds = true
            self.isUserInteractionEnabled = true
            self.shadowView.backgroundColor = UIColor.init(hexString: "C4C4C4").withAlphaComponent(0.3)
        }
    }
}


extension String{
    struct Holder {
        static var index:Int = 0
    }
    var orderIndex:Int{
        get {
            return Holder.index
        }
        set{
            Holder.index = newValue
        }
    }
    
}
