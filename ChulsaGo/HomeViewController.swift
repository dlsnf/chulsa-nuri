//
//  ViewController.swift
//  LovePet
//
//  Created by Nu-Ri Lee on 2017. 5. 29..
//  Copyright © 2017년 nuri lee. All rights reserved.
//

import UIKit
import MapKit
import SDWebImage

//search map
protocol HandleMapSearch: class {
    func dropPinZoomIn(_ placemark:MKPlacemark)
}



class HomeViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, ZoomTransitionProtocol, UINavigationControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource{
    
    
    
    
    func updateSearchResults(for searchController: UISearchController) {
    }
    
    
    
    //당기면 새로고침
    private let refreshControl = UIRefreshControl()
    
    
    //map search
    var selectedPin: MKPlacemark?
    var resultSearchController: UISearchController!
    var resultListSearchController: UISearchController!
    
    
    
    @objc func btnSearchPress(){
        present(resultSearchController, animated: true, completion: nil)
    }
    
    @objc func btnListSearchPress(){
        resultListSearchController.searchBar.text = self.listSearchText;
        present(resultListSearchController, animated: true, completion: nil)
    }
    
    
    var firstListViewBool : Bool = false;
    
    @IBOutlet weak var homeListSegmented: UISegmentedControl!
    var homeListSegIndex : Int = 0;
    //지도, 리스트 세그먼트 컨트롤
    @IBAction func homeListSegmentedPress(_ sender: UISegmentedControl) {
        DispatchQueue.main.async() {

            self.homeListSegIndex = sender.selectedSegmentIndex;
            
            //hot
            if ( self.homeListSegIndex == 0 ){
                self.homeListSegmented.tintColor = UIColor(red: 255/255.0, green: 119/255.0, blue: 97/255.0, alpha: 1.0)
                self.set_type2 = "hot";
                self.homeTableView.isUserInteractionEnabled = false;
                self.first_num = 0;
                self.last_num = 20;
                DispatchQueue.main.async() {
                    self.tableGetAjax(status: "init");
                }
            }else{ //new
                self.homeListSegmented.tintColor = UIColor(red: 32/255.0, green: 178/255.0, blue: 113/255.0, alpha: 1.0)
                self.set_type2 = "new";
                self.homeTableView.isUserInteractionEnabled = false;
                self.first_num = 0;
                self.last_num = 20;
                DispatchQueue.main.async() {
                    self.tableGetAjax(status: "init");
                }
            }
        }//sync
    }
    var homeSegIndex : Int = 0;
    @IBAction func homeSegmentedPress(_ sender: UISegmentedControl) {
        
        DispatchQueue.main.async() {

            self.homeSegIndex = sender.selectedSegmentIndex;
            
            //지도볼때
            if ( self.homeSegIndex == 0 ){
                self.listView.isHidden = true;
                self.listView.isUserInteractionEnabled = false;
            }else{ //리스트 볼때
                
                if ( self.firstListViewBool == false )
                {
                    
                    self.firstListViewBool = true;
                    self.tableGetAjax(status:"init");
                    self.homeTableView.delegate = self;
                    self.homeTableView.dataSource = self;
                    self.listSearchText = "";
                }else{
                    //self.tableGetAjax(status:"init");
                    
                }
                
                self.listView.isHidden = false;
                self.listView.isUserInteractionEnabled = true;
                
                //지도 핀 전체 해제
                let selectedAnnotations = self.mapView.selectedAnnotations
                for annotationView in selectedAnnotations{
                    self.mapView.deselectAnnotation(annotationView, animated: true)
                }
                
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    //지도 핀 전체 해제
                    let selectedAnnotations = self.mapView.selectedAnnotations
                    for annotationView in selectedAnnotations{
                        self.mapView.deselectAnnotation(annotationView, animated: true)
                    }
                    
                    //당기면 새로고침
                    self.homeTableView.refreshControl = self.refreshControl;
                    self.refreshControl.addTarget(self, action: #selector(self.didRefresh), for: UIControlEvents.valueChanged)
                    //refreshControl.backgroundColor = UIColor.red;
                    //refreshControl.attributedTitle = NSAttributedString(string: "Last updated on : "+String(describing: Date()));
                    
                }
                
                
            }
            
        }//sync
        
    }
    
    @IBOutlet weak var pinTypeLabel: UILabel!
    
    @IBOutlet weak var listLoadingView: UIView!
    
    @IBOutlet weak var listLoadingViewActivity: UIActivityIndicatorView!
    
    @IBOutlet weak var noDataLabel: UILabel!
    
    @IBOutlet weak var listSearchTextLabel: UILabel!
    
    @IBOutlet weak var homeTableView: UITableView!
    
    @IBOutlet weak var listView: UIView!
    
    @IBOutlet weak var btnSearch: UIView!
    
    @IBOutlet weak var btnListSearch: UIView!
    
    @IBOutlet weak var menuButtonView: UIView!
    @IBOutlet weak var menuButton: HamburgerButton!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var addPinView: UIView!
    
    @IBOutlet weak var myLocationView: UIView!
    
    @IBOutlet weak var myLocationImage: UIImageView!
    
    
    var zoomTransType : String = "infoView";
    var animationController : ZoomTransition?;
    func viewForTransition() -> UIView {
        if ( zoomTransType == "infoView" )
        {
            return InfoClass.infoVC.imageView2
        }else{
            //선택셀 태그 가져오기
            let indexPath = homeTableView.indexPathForSelectedRow ?? IndexPath();
            let currentCell = homeTableView.cellForRow(at: indexPath) as! HomeTableViewCell;
            
            return currentCell.imageView22
        }
        
    }
    
    
    var coreLocationManger = CLLocationManager()
    var locationManager:LocationManager!
    
    var myLocationBool : Bool = false;
    
    var infoSeq : String = "1";
    
    var pin_type : String = enum_pin_type.chulsa.rawValue;
    
    var showDetailSeq : Int = -1;
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
        
        let initCheck = UserDefaults.standard.object(forKey: "initCheck") as? Bool ?? false;
        
        if (initCheck)
        {
        
            //화면 완전히 종료 할때
            self.locationManager = nil
            
            self.mapView.mapType = MKMapType.hybrid
            self.mapView.mapType = MKMapType.standard
            self.mapView.showsUserLocation = false
            self.mapView.delegate = nil
            self.mapView.removeFromSuperview()
            self.mapView = nil
            
            self.homeTableView.delegate = nil;
            self.homeTableView.removeFromSuperview();
            self.homeTableView = nil;
            
            self.coreLocationManger.delegate = nil;
            self.resultListSearchController.searchBar.delegate = nil;
            self.resultSearchController.searchBar.delegate = nil;
            
            self.resultListSearchController = nil;
            self.resultSearchController = nil;
            self.animationController = nil;
            self.selectedPin = nil
            
            UserDefaults.standard.set(false, forKey: "initCheck");
        }
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        if ( MenuClass.menuBool == false ){
            //status bar
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
                UIView.animate(withDuration: 0.2,
                               delay: 0,
                               options: .curveEaseInOut,
                               animations: {
                                
                                
                                statusBar.alpha = 0.0;
                })
            }
        }else{
            //status bar
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
                UIView.animate(withDuration: 0.2,
                               delay: 0,
                               options: .curveEaseInOut,
                               animations: {


                                statusBar.alpha = 1.0;
                })
            }
        }
        
        
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.pinTypeLabel.text = NSLocalizedString(self.pin_type, comment: "pin_type")
        //빈 테이블 없애기
        homeTableView.tableFooterView = UIView(frame: CGRect.zero);
        
        AppDelegate.homePinType = self.pin_type;
        print(pin_type);
        
        


        
        resultSearchController = ({
            // 1
            
            let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
            let controller = UISearchController(searchResultsController: locationSearchTable)
            controller.searchResultsUpdater = locationSearchTable
            
            controller.hidesNavigationBarDuringPresentation = false
            controller.dimsBackgroundDuringPresentation = true
            definesPresentationContext = true
            
            controller.searchBar.tag = 0;
            
            locationSearchTable.mapView = self.mapView
            
            locationSearchTable.handleMapSearchDelegate = self
            
            
            //클릭시 배경 색상
            controller.searchBar.barTintColor = UIColor.lightText;
            
            
            
            
            //텍스트필드 창
            let textFieldInsideSearchBar = controller.searchBar.value(forKey: "searchField") as? UITextField
            
            //placeholder 라벨
            let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
            textFieldInsideSearchBarLabel?.text = NSLocalizedString("place search", comment: "place search");
            textFieldInsideSearchBarLabel?.textColor = UIColor.lightGray;
            
            //textFieldInsideSearchBar?.textColor = UIColor.red;
            textFieldInsideSearchBar?.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
            textFieldInsideSearchBar?.borderStyle = UITextBorderStyle.roundedRect;
            
            
            
            //검색 아이콘 색 변경
            let glassIconView = textFieldInsideSearchBar?.leftView as! UIImageView
            glassIconView.image = glassIconView.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            glassIconView.tintColor = UIColor.lightGray
            
            
            return controller
            
        })()
        resultSearchController.searchBar.delegate = self;
        
        resultListSearchController = ({
            
            let controller = UISearchController(searchResultsController: nil)
            
            controller.hidesNavigationBarDuringPresentation = false
            controller.dimsBackgroundDuringPresentation = true
            definesPresentationContext = true
            
            controller.searchBar.tag = 1;
            
            //클릭시 배경 색상
            controller.searchBar.barTintColor = UIColor.lightText;
            
            
            
            
            //텍스트필드 창
            let textFieldInsideSearchBar = controller.searchBar.value(forKey: "searchField") as? UITextField
            
            //placeholder 라벨
            let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
            textFieldInsideSearchBarLabel?.text = NSLocalizedString("address search", comment: "address search");
            textFieldInsideSearchBarLabel?.textColor = UIColor.lightGray;
            
            //textFieldInsideSearchBar?.textColor = UIColor.red;
            textFieldInsideSearchBar?.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
            textFieldInsideSearchBar?.borderStyle = UITextBorderStyle.roundedRect;
            
            
            
            //검색 아이콘 색 변경
            let glassIconView = textFieldInsideSearchBar?.leftView as! UIImageView
            glassIconView.image = glassIconView.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            glassIconView.tintColor = UIColor.lightGray
            
            
            return controller
            
        })()
        resultListSearchController.searchBar.delegate = self;
        
        
        
        
        
        //menuButton
        self.menuButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        menuButton.isUserInteractionEnabled = false;
        let menuButtonTap = UITapGestureRecognizer(target: self, action:#selector(self.menuToggle(_:)))
        menuButtonView.addGestureRecognizer(menuButtonTap)

        
        //init
        MenuClass.menuInit();
        InfoClass.infoInit();
        
        
        //Tap
        let myLocationTap = UITapGestureRecognizer(target: self, action:#selector(self.myLocationToggle))
        myLocationView.addGestureRecognizer(myLocationTap)

        let addPinTap = UITapGestureRecognizer(target: self, action:#selector(self.addPin))
        addPinView.addGestureRecognizer(addPinTap)

        let pinInfoViewTap = UITapGestureRecognizer(target: self, action:#selector(self.pinInfoViewTap))
        InfoClass.infoVC.infoView.addGestureRecognizer(pinInfoViewTap)

        let pinInfoViewswipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.pinInfoViewswipeUp))
        pinInfoViewswipeUp.direction = UISwipeGestureRecognizerDirection.up
        InfoClass.infoVC.infoView.addGestureRecognizer(pinInfoViewswipeUp)

        let btnSearchViewTap = UITapGestureRecognizer(target: self, action:#selector(self.btnSearchPress))
        self.btnSearch.addGestureRecognizer(btnSearchViewTap)
        let btnListSearchViewTap = UITapGestureRecognizer(target: self, action:#selector(self.btnListSearchPress))
        self.btnListSearch.addGestureRecognizer(btnListSearchViewTap)
        
        let listSearchTextLabelTap = UITapGestureRecognizer(target: self, action:#selector(self.btnListSearchPress))
        self.listSearchTextLabel.addGestureRecognizer(listSearchTextLabelTap)
    
        
        
        
        
        
        
        
        
        //ZoomTransitionProtocol
        if let navigationController = self.navigationController {
            animationController = ZoomTransition(navigationController: navigationController)
        }
        self.navigationController?.delegate = animationController
        
        
        
        
        
        //noti
        let name = Notification.Name("loginToAddPin");
        NotificationCenter.default.addObserver(self, selector: #selector(loginToAddPin), name: name, object: nil)

        let name2 = Notification.Name("pinInit");
        NotificationCenter.default.addObserver(self, selector: #selector(pinInit), name: name2, object: nil)

        let name3 = Notification.Name("mapViewMove");
        NotificationCenter.default.addObserver(self, selector: #selector(mapViewMove), name: name3, object: nil)

        let name4 = Notification.Name("infoLikeReload");
        NotificationCenter.default.addObserver(self, selector: #selector(infoLikeReload), name: name4, object: nil)

        let name5 = Notification.Name("listLikeReload");
        NotificationCenter.default.addObserver(self, selector: #selector(listLikeReload), name: name5, object: nil)
        
        
        let name6 = Notification.Name("statusBarHide");
        NotificationCenter.default.addObserver(self, selector: #selector(statusBarHide), name: name6, object: nil)
        
        
        
        
        //map init
        mapView.delegate = self;
        
        coreLocationManger.delegate = self
        
        locationManager = LocationManager.sharedInstance
        
        let authorizationCode = CLLocationManager.authorizationStatus()
        
        //authorizationCode.rawValue = 0  - 위치 허용 물어보기전 notDetermined
        //authorizationCode.rawValue = 1  - 한정적 위치 restricted
        //authorizationCode.rawValue = 2  - 위치 허용 안했을때 denied
        //authorizationCode.rawValue = 3  - 모든 위치 허용 했을때 authorizedAlways
        //authorizationCode.rawValue = 4  - 사용시에만 허용 했을때 restricted
        if authorizationCode == CLAuthorizationStatus.notDetermined && coreLocationManger.responds(to: #selector(CLLocationManager.requestAlwaysAuthorization)) || coreLocationManger.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)){
            
            if Bundle.main.object(forInfoDictionaryKey: "NSLocationWhenInUseUsageDescription") != nil {
                //coreLocationManger.requestAlwaysAuthorization()
                
                coreLocationManger.requestWhenInUseAuthorization()
                
                
            }else{
                print("No descirption provided")
            }
            
        }else{
            
            
            //나의 위치
            myLocation()
            
            
            
            
        }
        
        
        //인터넷 연결 체크
        if ConnectionCheck.isConnectedToNetwork() {
            //print("Connected")
            pinInit();
            
        }
        else{
            //print("disConnected")
            let alertController = UIAlertController(title: NSLocalizedString("waiting", comment: "waiting"), message: NSLocalizedString("network error", comment: "network error"), preferredStyle: .alert)
            let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .cancel , handler: { (action) -> Void in
            })
            alertController.addAction(okButton)
            self.present(alertController, animated: true, completion: nil)
            
        }
        
        
        
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addPin" {
            let nav = segue.destination as! UINavigationController;
            let vc = nav.viewControllers[0] as! addPinMapViewController;
            vc.locationManager2 = locationManager;
            vc.pin_type = self.pin_type;
        }
        
        if segue.identifier == "showPinDetail" {
            zoomTransType = "infoView";
            
            let secondVC = segue.destination as! pinDetailViewController;
            secondVC.image = InfoClass.infoVC.imageView2.image!;
            secondVC.pin_seq = InfoClass.infoVC.infoView.tag;
            secondVC.pin_type = self.pin_type;
        }
        
        if segue.identifier == "showListDetail" {
            zoomTransType = "listView";
            
            //선택셀 태그 가져오기
            let indexPath = homeTableView.indexPathForSelectedRow ?? IndexPath();
            let indexPathRow = indexPath.row;
            let currentCell = homeTableView.cellForRow(at: indexPath) as! HomeTableViewCell;
            let selectCellTag = currentCell.tag;
            let selectCellImage = currentCell.imageView22.image!;
            
        
            let secondVC = segue.destination as! pinDetailViewController;
            secondVC.image = selectCellImage;
            secondVC.pin_seq = selectCellTag;
            secondVC.pin_type = self.pin_type;
            secondVC.showType = "showListDetail";
            
            
        }
        
    }
    
//MARK: - my function
    
    
    
    @objc func didRefresh(){
        
        if (self.tableGetAjaxBool == true)
        {
            self.homeTableView.isUserInteractionEnabled = false;
            self.first_num = 0;
            self.last_num = 20;
            self.tableJson = [[String:Any]]();
            self.tableGetAjax(status: "refresh");
        }else{
            self.refreshControl.endRefreshing();
        }
        
    }
    
    var listSearchText : String = "";
    var listSearchInitBool : Bool = true;
    func listSearchInit(text : String){
        
        self.listSearchText = text;
        self.homeTableView.isUserInteractionEnabled = false;
        self.first_num = 0;
        self.last_num = 20;
        self.tableJson = [[String:Any]]();
        self.tableGetAjax(status: "search");
        self.listSearchInitBool = false;
        
    }
    
    
    
    var pinTitleLoadBool : Bool = false;
    @objc func pinTitleViewTap(_ sender : MyTapGestureRecognizer){
//        let pin_seq = sender.number!;
//        
//        print(pin_seq);
        
        //버그 거르기
        if InfoClass.infoVC.imageView.image?.size.height != 0{
            //print("not nil");
            if self.pinTitleLoadBool {
                if InfoClass.infoVC.imageView.image?.size.height != 0{
                    if InfoClass.infoVC.imageView2.image?.size.height != 0{
                        self.performSegue(withIdentifier: "showPinDetail", sender: self);
                    }
                }
            }
        }else{
            //print("nil");
        }
    }
    
    @objc func pinInfoViewswipeUp(){
        
        
        //버그 거르기
        if InfoClass.infoVC.imageView.image?.size.height != 0{
            if InfoClass.infoVC.imageView2.image?.size.height != 0{
            //print("not nil");
                self.performSegue(withIdentifier: "showPinDetail", sender: self);
            }
        }else{
            //print("nil");
        }
    }
    
    @objc func pinInfoViewTap(){
        
        //버그 거르기
        if InfoClass.infoVC.imageView.image?.size.height != 0{
            if InfoClass.infoVC.imageView2.image?.size.height != 0{
            //print("not nil");
                self.performSegue(withIdentifier: "showPinDetail", sender: self);
            }
        }else{
            //print("nil");
        }
    }
    
    @objc func loginToAddPin(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            UserDefaults.standard.set(false, forKey: "loginToAddPin");
            self.performSegue(withIdentifier: "addPin", sender: self);
        }
    }
    
    @objc func addPin(){
        
        let loginSesseion = UserDefaults.standard.object(forKey: "loginSesstion") as? Int ?? -1;
        
        if loginSesseion == -1{
            //print("로그인이 필요합니다");
            
            UserDefaults.standard.set(false, forKey: "loginToAddPin");
            
            let alertController = UIAlertController(title: NSLocalizedString("alert", comment: "alert"), message: NSLocalizedString("need login", comment: "need login"), preferredStyle: .alert)
            
            let cancelButton = UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"), style: .default, handler: { (action) -> Void in
                //print("Ok button tapped")
            })
            let loginButton = UIAlertAction(title: NSLocalizedString("login", comment: "login"), style: .default, handler: { (action) -> Void in
                //print("Ok button tapped")
                UserDefaults.standard.set(true, forKey: "loginToAddPin");
                self.performSegue(withIdentifier: "login", sender: self);
            })
            
            alertController.addAction(cancelButton)
            alertController.addAction(loginButton)
            
            
            self.present(alertController, animated: true, completion: nil)
        }else{
            print("ㅇㅋ");
            self.performSegue(withIdentifier: "addPin", sender: self);
        }
    }
    
    @objc func menuToggle(_ sender: AnyObject!) {
        //self.menuButton.showsMenu = !self.menuButton.showsMenu
        
        if MenuClass.menuBool{
            MenuClass.showMenu();
        }else{
            MenuClass.closeMenu();
        }

    }
    
    
    @objc func myLocationToggle(){
        
        //GPS접근권한 설정되었을때
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
        
        
            if myLocationBool{
                myLocationImage.image = UIImage(named: "myLocation_off");
                myLocationBool = false;
                
                self.mapView.setUserTrackingMode(MKUserTrackingMode.none, animated: true)
                
                
            }else{
                self.mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
                myLocationImage.image = UIImage(named: "myLocation_on");
                myLocationBool = true;
                
                
            }
        }else{
            
            //사용자 위치 접근 허용 필요 메시지
            let alertController = UIAlertController(title: NSLocalizedString("need user location", comment: "need user location"), message: NSLocalizedString("setting info location", comment: "setting info location"), preferredStyle: .alert)
            let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .cancel , handler: { (action) -> Void in
            })
            let settingButton = UIAlertAction(title: NSLocalizedString("setting", comment: "setting"), style: .default, handler: { (action) -> Void in
                
                let settingsUrl = URL(string:"App-Prefs:root=Privacy&path=LOCATION")! as URL
                UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                
                
            })
            
            alertController.addAction(settingButton)
            alertController.addAction(okButton)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func myLocation(){
        
        var currentLocation = CLLocation()
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            
            //print(coreLocationManger.location!);
            
            
            //사용자 위치 가져올 수 있는지 체크
            if coreLocationManger.location != nil{
                
                //자기 좌표 가져오기
                currentLocation = coreLocationManger.location!;
                
                //맵 이동
                mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude), span: MKCoordinateSpanMake(0.3, 0.3)), animated: true)
                
                self.mapView.showsUserLocation = true;
                
                self.mapView.userLocation.title = "";
                

                
            }else{
                
//                let alertController = UIAlertController(title: "사용자 위치 접근 불가", message: "사용자 위치를 찾을 수 없습니다.", preferredStyle: .alert)
//                let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .cancel , handler: { (action) -> Void in
//                })
//                
//                alertController.addAction(okButton)
//                self.present(alertController, animated: true, completion: nil)
                
            }
            
            
            
            
            
            
            
            
        }else{
            print("자기 위치 설정 안됨");
            //사용자 위치 접근 허용 필요 메시지
//            let alertController = UIAlertController(title: "사용자 위치 접근 허용 필요", message: "설정 - 개인 정보 보호 - 위치 서비스 에서 설정할 수 있습니다.", preferredStyle: .alert)
//            let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .cancel , handler: { (action) -> Void in
//            })
//            let settingButton = UIAlertAction(title: "설정", style: .default, handler: { (action) -> Void in
//                
//                let settingsUrl = URL(string:"App-Prefs:root=Privacy&path=LOCATION")! as URL
//                UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
//                
//                
//            })
//            
//            alertController.addAction(settingButton)
//            alertController.addAction(okButton)
//            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc func mapViewMove(){
        let latitude = UserDefaults.standard.object(forKey: "latitude") as? Double ?? -1;
        let longitude = UserDefaults.standard.object(forKey: "longitude") as? Double ?? -1;
        
        if latitude != -1 {
            //맵 이동
            mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2DMake(latitude, longitude), span: MKCoordinateSpanMake(0.03, 0.03)), animated: true)
        }
        
    }
    
    
    
    
    @objc func statusBarHide(){
        if ( MenuClass.menuBool == false ){
            //status bar
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
                UIView.animate(withDuration: 0.2,
                               delay: 0,
                               options: .curveEaseInOut,
                               animations: {
                                
                                
                                statusBar.alpha = 0.0;
                })
            }
        }else{
            
        }//if
    }
    
    
    @objc func pinInit(){
        //var pinJson : [[String:Any]] = [[String:Any]]();
        
        //자기 위치
//        var currentLocation = CLLocation()
//        currentLocation = coreLocationManger.location!;
        //지도 핀 제거
        if let annotations : [MKAnnotation] = mapView.annotations {
            for annotation in annotations {
                if let annotation = annotation as? CustomPointAnnotation
                {
                    if ( annotation.type == "pin"){
                        self.mapView.removeAnnotation(annotation)
                    }
                }
            }
        }
        
        
        
        let key : String = "nuri";
        let type : String = "hot";
        let pin_type : String = self.pin_type;
        let user_seq : String = String(UserDefaults.standard.object(forKey: "loginSesstion") as? Int ?? -1);
        
        
        
        let param : String = "key="+key+"&type="+type+"&pin_type="+pin_type+"&user_seq="+user_seq;
        
        
        Ajax.forecast(withUrl: AppDelegate.serverUrl + "/chulsago/pin_chulsa_select.php", withParam: param) { (results:[[String:Any]]) in
            
            for result in results{
                if (result["error"] != nil){
                    //에러발생시
                    print(result["error"] ?? "error")
                    let alertController = UIAlertController(title: NSLocalizedString("waiting", comment: "waiting"), message: "\(String(describing: result["error"]!))", preferredStyle: .alert)
                    
                    let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .cancel , handler: { (action) -> Void in
                    })
                    
                    alertController.addAction(okButton)
                    
                    
                    self.present(alertController, animated: true, completion: nil)
                }else{
                    //print(result["seq"]!)
                    let seq : String = String(describing: result["seq"]!)
                    let pin_color : String = String(describing: result["pin_color"]!)
                    let latitude : String = String(describing: result["latitude"]!)
                    let longitude : String = String(describing: result["longitude"]!)
                    
                    let latitude2 : Double = Double(latitude)!;
                    let longitude2 : Double = Double(longitude)!;
                    
                    
//                    let locationPinCoord2 = CLLocationCoordinate2D(latitude: latitude2, longitude: longitude2)
//                    var pinJson1 : [String:Any] = [String:Any]();
//                    pinJson1 = ["title" : " ", "subtitle" : " ", "imageName" : "nuri", "tag" : seq, "type" : "pin", "pin_color" : pin_color, "coordinate" : locationPinCoord2];
//
//                    pinJson.append(pinJson1);
                    
                    DispatchQueue.main.async() {
                        //핀 추가
                        let locationPinCoord = CLLocationCoordinate2D(latitude: latitude2, longitude: longitude2)

                        let annotation = CustomPointAnnotation()
                        annotation.title = " ";
                        annotation.subtitle = " ";
                        annotation.imageName = "nuri";
                        annotation.tag = seq;
                        annotation.type = "pin";
                        annotation.pin_color = pin_color;
                        annotation.coordinate = locationPinCoord
                        DispatchQueue.main.async() {
                            self.mapView.addAnnotation(annotation)
                        }

                    }

                    
                }
            }
            
            //self.text1(json : pinJson);
            
            
        }//Ajax
        
        
    }
    
    
//    func text1(json : [[String:Any]]){
//
//
//        for result in json{
//            let title : String = String(describing: result["title"]!)
//            let subtitle : String = String(describing: result["subtitle"]!)
//            let imageName : String = String(describing: result["imageName"]!)
//            let tag  : String = String(describing: result["tag"]!)
//            let type : String = String(describing: result["type"]!)
//            let pin_color : String = String(describing: result["pin_color"]!)
//            let coordinate : CLLocationCoordinate2D = result["coordinate"]! as! CLLocationCoordinate2D
//
//
//            let annotation = CustomPointAnnotation()
//            annotation.title = title;
//            annotation.subtitle = subtitle;
//            annotation.imageName = imageName;
//            annotation.tag = tag
//            annotation.type = type;
//            annotation.pin_color = pin_color;
//            annotation.coordinate = coordinate
//            self.mapView.addAnnotation(annotation)
//
//
//        }
//
//    }
    
    func profileInit(user_seq : String){
        
        let param : String = "key=nuri&seq=" + user_seq;
        
        Ajax.forecast(withUrl: AppDelegate.serverUrl + "/chulsago/user_select.php", withParam: param) { (results:[[String:Any]]) in
            
            for result in results{
                if (result["error"] != nil){
                    //에러발생시
                    print(result["error"] ?? "error")
                    let alertController = UIAlertController(title: NSLocalizedString("waiting", comment: "waiting"), message: "\(String(describing: result["error"]!))", preferredStyle: .alert)
                    
                    let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .cancel , handler: { (action) -> Void in
                    })
                    
                    alertController.addAction(okButton)
                    
                    
                    self.present(alertController, animated: true, completion: nil)
                }else{
                    //let seq : String = (result["seq"] as? String)!;
                    //let name : String = (result["name"] as? String)!;
                    let thumbnail_image : String = (result["thumbnail_image"] as? String)!;
                    
                    
                    //레이아웃 바꿀때 충돌 방지
                    DispatchQueue.main.async() {
                        
                        //프로필 사진 추가
                        if thumbnail_image != ""{
                            
                            InfoClass.infoVC.profileImageView.contentMode = UIViewContentMode.scaleAspectFill
                            InfoClass.infoVC.profileImageView.downloadAndResizeImageFrom(thumbnail_image, contentMode: .scaleAspectFill, newWidth: 200)
                        }else{
                            InfoClass.infoVC.profileImageView.contentMode = UIViewContentMode.center
                            InfoClass.infoVC.profileImageView.image = UIImage(named: "nonProfileSmall");
                        }
                                                
                    }
                    
                    
                }
            }
        }//ajax
    }
    
    
    func pinLoadContent(pin_seq : String){
        
        InfoClass.infoVC.imageView.image = UIImage();
        InfoClass.infoVC.imageView2.image = UIImage();
        
        let key : String = "nuri";
        let type : String = "one";
        let pin_type : String = self.pin_type;
        let pin_seq : String = pin_seq;
        
        let param : String = "key="+key+"&type="+type+"&pin_type="+pin_type+"&pin_seq="+pin_seq;
        
        
        Ajax.forecast(withUrl: AppDelegate.serverUrl + "/chulsago/pin_chulsa_select.php", withParam: param) { (results:[[String:Any]]) in
            
            for result in results{
                if (result["error"] != nil){
                    //에러발생시
                    print(result["error"] ?? "error")
                    let alertController = UIAlertController(title: NSLocalizedString("waiting", comment: "waiting"), message: "\(String(describing: result["error"]!))", preferredStyle: .alert)
                    
                    let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .cancel , handler: { (action) -> Void in
                    })
                    
                    alertController.addAction(okButton)
                    
                    
                    self.present(alertController, animated: true, completion: nil)
                }else{
                    //print(result["seq"]!)
                    let seq : String = String(describing: result["seq"]!)
                    let user_seq : String = String(describing: result["user_seq"]!)
                    let image_name : String = String(describing: result["image_name"]!)
                    let body : String = String(describing: result["body"]!)
                    let like : String = String(describing: result["like"]!)
                    let date_ : String = String(describing: result["date_"]!)
                    
                    //print(seq+"핀");
                    
                    let image_url : String = AppDelegate.serverUrl + "/chulsago/upload/img/thumbnail/400_" + image_name;
                    var image_url2 : String!
                    DispatchQueue.main.async() {
                        let screenWidth = self.view.frame.size.width;
                    
                    
                        if screenWidth >= 768 { //아이패드일때
                            image_url2 = AppDelegate.serverUrl + "/chulsago/upload/img/thumbnail/1200_" + image_name;
                        }else{
                            image_url2 = AppDelegate.serverUrl + "/chulsago/upload/img/thumbnail/800_" + image_name;
                        }
                        
                    }
                    //시간 포멧
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let date = dateFormatter.date(from: date_)
                    
                    dateFormatter.amSymbol="AM";
                    dateFormatter.pmSymbol = "PM";
                    dateFormatter.dateFormat = "yyyy-MM-dd  h:mm a"
                    let newDate = dateFormatter.string(from: date!)
                    
                    
                    
                    //print(image_url);
                    DispatchQueue.main.async() {
                        
                        
                        if image_name != ""{
                            InfoClass.infoVC.imageView.downloadAndResizeImageFrom(image_url, contentMode: .scaleAspectFill , newWidth: 200)
                            
                            InfoClass.infoVC.imageView2.downloadAndResizeImageFrom(image_url2, contentMode: .scaleAspectFit , newWidth: 800)
                            
                            
                        }
                        
                        
                        //좋아요 초기화
                        self.infoLikeInit(pin_seq: seq, like: like);
                        self.infoCommentInit(pin_seq: seq);
                        
                        InfoClass.infoVC.labelBody.text = body;
                        InfoClass.infoVC.labelDate.text = newDate;
                        InfoClass.infoVC.infoView.tag = Int(seq)!;
                        
                        //profile load
                        self.profileInit(user_seq : user_seq);
                        
                        //InfoClass.infoVC.loadingView.isHidden = true;
                        
                        
                    }
                    
                    
                    
                    
                }
            }
            
        }//Ajax
        
        
        
    }
    
    
    
    func infoLikeInit(pin_seq : String, like : String){
        
        DispatchQueue.main.async() {
            InfoClass.infoVC.likeView.image = UIImage(named: "btn_like");
        }
        
        if like != "0" {
            
            
//            InfoClass.infoVC.likeView.isHidden = false;
//InfoClass.infoVC.likeLabelConstraint.isActive = true;
            //InfoClass.infoVC.labelLike.textColor = UIColor.darkText;
            InfoClass.infoVC.labelLike.text = NSLocalizedString("like", comment: "like") + " " + like + NSLocalizedString("gae", comment: "gae");
            
            
            let loginSesseion = UserDefaults.standard.object(forKey: "loginSesstion") as? Int ?? -1;
            
            if loginSesseion != -1{ //로그인이 되어있을때
                
                //좋아요 상태 조회
                let key : String = "nuri";
                let user_seq : String = String(loginSesseion);
                let pin_type : String = self.pin_type;
                let pin_seq : String = pin_seq;
                
                let param : String = "key="+key+"&user_seq="+user_seq+"&pin_type="+pin_type+"&pin_seq="+pin_seq;
                
                
                Ajax.forecast(withUrl: AppDelegate.serverUrl + "/chulsago/like_pin_select.php", withParam: param) { (results:[[String:Any]]) in
                    
                    for result in results{
                        if (result["error"] != nil){
                            //에러발생시
                            print(result["error"] ?? "error")
                            let alertController = UIAlertController(title: NSLocalizedString("waiting", comment: "waiting"), message: "\(String(describing: result["error"]!))", preferredStyle: .alert)
                            
                            let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .cancel , handler: { (action) -> Void in
                            })
                            
                            alertController.addAction(okButton)
                            
                            
                            self.present(alertController, animated: true, completion: nil)
                        }else{
                            //print(result["seq"]!)
                            
                            let status : String = String(describing: result["status"]!)
                            
                            if status == "ok" { //좋아요가 있을때
                                DispatchQueue.main.async() {
                                    InfoClass.infoVC.likeView.image = UIImage(named: "btn_like_on");
                                }
                            }else{ //좋아요가 없을때
                                DispatchQueue.main.async() {
                                    InfoClass.infoVC.likeView.image = UIImage(named: "btn_like");
                                }
                            }
                            
                            
                        }
                    }
                    
                    
                }//ajax
                
            }else{//로그인 안되어있을때
                
            }
            
            
        }else{
//            InfoClass.infoVC.likeView.isHidden = true;
//            InfoClass.infoVC.likeLabelConstraint.isActive = false;
            //InfoClass.infoVC.labelLike.textColor = UIColor.lightGray;
            InfoClass.infoVC.labelLike.text = NSLocalizedString("like", comment: "like") + " " + like + NSLocalizedString("gae", comment: "gae");
        }
  
        
    }
    
    
    
    func infoCommentInit(pin_seq : String){
        
        //댓글 상태 조회
        let key : String = "nuri";
        let pin_type : String = self.pin_type;
        let pin_seq : String = pin_seq;
        
        let param : String = "key="+key+"&pin_type="+pin_type+"&pin_seq="+pin_seq;
        
        
        Ajax.forecast(withUrl: AppDelegate.serverUrl + "/chulsago/comment_count_select.php", withParam: param) { (results:[[String:Any]]) in
            
            for result in results{
                if (result["error"] != nil){
                    //에러발생시
                    print(result["error"] ?? "error")
                    let alertController = UIAlertController(title: NSLocalizedString("waiting", comment: "waiting"), message: "\(String(describing: result["error"]!))", preferredStyle: .alert)
                    
                    let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .cancel , handler: { (action) -> Void in
                    })
                    
                    alertController.addAction(okButton)
                    
                    
                    self.present(alertController, animated: true, completion: nil)
                }else{
                    //print(result["seq"]!)
                    let count : String = String(describing: result["count"]!)
                    DispatchQueue.main.async() {
                        InfoClass.infoVC.labelComment.text = NSLocalizedString("comment", comment: "comment") + " " + count + NSLocalizedString("gae", comment: "gae");
                    }
                }
            }
            
            
        }//ajax
        
    }
    
    var tableJsonIndex : Int = -1
    var tableJsonOneReload : Bool = false;
    
    
    //디테일뷰에서 돌아올때 좋아요 상태 체크하기
    @objc func listLikeReload(){
        
        
            if ( self.showDetailSeq != -1 ){
                
                let loginSesseion = UserDefaults.standard.object(forKey: "loginSesstion") as? Int ?? -1;
                
                if loginSesseion != -1{ //로그인이 되어있을때
                    
                    
                        let key : String = "nuri";
                        let type : String = "one";
                        let pin_type : String = self.pin_type;
                        let pin_seq : String = String(self.showDetailSeq);
                        
                        let param : String = "key="+key+"&type="+type+"&pin_type="+pin_type+"&pin_seq="+pin_seq;
                        
                        
                        Ajax.forecast(withUrl: AppDelegate.serverUrl + "/chulsago/pin_chulsa_select.php", withParam: param) { (results:[[String:Any]]) in
                            
                            for result in results{
                                if (result["error"] != nil){
                                    //에러발생시
                                    print(result["error"] ?? "error")
                                    let alertController = UIAlertController(title: NSLocalizedString("waiting", comment: "waiting"), message: "\(String(describing: result["error"]!))", preferredStyle: .alert)
                                    
                                    let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .cancel , handler: { (action) -> Void in
                                    })
                                    
                                    alertController.addAction(okButton)
                                    
                                    
                                    self.present(alertController, animated: true, completion: nil)
                                }else{
                                    //print(result["seq"]!)
                                    let like : String = String(describing: result["like"]!)
                                    let commentCount : String = String(describing: result["comment_count"]!)
                                    self.tableJson[self.tableJsonIndex]["comment_count"] = commentCount;
                                    self.tableJson[self.tableJsonIndex]["like"] = like;
                                    
                                        self.tableJsonOneReload = false;
                                        DispatchQueue.main.async() {
                                            self.homeTableView.reloadData()
                                            DispatchQueue.main.async() {
                                                self.tableGetAjaxBool = true;
                                                self.showDetailSeq = -1;
                                            }
                                        }
                                       
                                    
                                    }
                            }
                            
                        }//Ajax
                    
                    
                }//loginSesseion
                
            }//if
        
    }
    
    @objc func infoLikeReload(){
        
        
        let key : String = "nuri";
        let type : String = "one";
        let pin_type : String = self.pin_type;
        let pin_seq : String = self.infoSeq;
        
        let param : String = "key="+key+"&type="+type+"&pin_type="+pin_type+"&pin_seq="+pin_seq;
        
        
        Ajax.forecast(withUrl: AppDelegate.serverUrl + "/chulsago/pin_chulsa_select.php", withParam: param) { (results:[[String:Any]]) in
            
            for result in results{
                if (result["error"] != nil){
                    //에러발생시
                    print(result["error"] ?? "error")
                    let alertController = UIAlertController(title: NSLocalizedString("waiting", comment: "waiting"), message: "\(String(describing: result["error"]!))", preferredStyle: .alert)
                    
                    let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .cancel , handler: { (action) -> Void in
                    })
                    
                    alertController.addAction(okButton)
                    
                    
                    self.present(alertController, animated: true, completion: nil)
                }else{
                    //print(result["seq"]!)
                    let seq : String = String(describing: result["seq"]!)
                    let like : String = String(describing: result["like"]!)
                    
                    
                    //print(image_url);
                    DispatchQueue.main.async() {
                        
                        
                        //좋아요 초기화
                        self.infoLikeInit(pin_seq: seq, like: like);
                        self.infoCommentInit(pin_seq: seq);
                    }
                    
                }
            }
            
        }//Ajax
        
        
        
    }
    
    
    //MARK: - search
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let tagSearchBar = searchBar.tag;
        
        
        //리스트에서 검색 버튼 눌렀을때
        if (tagSearchBar == 1){
            listSearchInit(text : searchBar.text!);
            
            self.resultListSearchController.isActive = false;
            self.listSearchTextLabel.text = self.listSearchText;
            
            
        }
        
    }
    
    
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        
        
        if ( self.listSearchInitBool != true ){
            if ( self.listSearchText == "" )
            {
                
                self.listSearchTextLabel.text = self.listSearchText;
                self.homeTableView.isUserInteractionEnabled = false;
                self.first_num = 0;
                self.last_num = 20;
                self.tableJson = [[String:Any]]();
                self.tableGetAjax(status: "search");
                self.listSearchInitBool = true;
                self.listSearchText = "";
            }
        }
        
        return true;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if ( homeSegIndex == 1 )
        {
            self.listSearchText = searchText;
        }
        
    }
    
    
//MARK: - mapView
    
    var pinShowOn : Bool = true;
    var pinHideOn : Bool = true;

    //핀을 눌렀을때
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        
        
        self.pinTitleLoadBool = false;
       
        
        
        if let annotation = view.annotation as? CustomPointAnnotation {
            
//            print("select");
            //print(annotation.type)
            
            let pinLocation = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude);
            
            //지도상의 정보 가져오기
            locationManager.reverseGeocodeLocationWithCoordinates(pinLocation, onReverseGeocodingCompletionHandler: { (reverseGecodeInfo, placemark, error) -> Void in
                
                //let address = reverseGecodeInfo?.object(forKey: "formattedAddress") as! String
                //print(address)
                
                //let country = placemark?.country ?? "null";
                //print(country)
                
                //let city = placemark?.administrativeArea ?? "null";
                //print(city)
                
                //let subCity = placemark?.locality ?? "null";
                //print(subCity)
                
                //let dong = placemark?.subLocality ?? "null";
                //print(dong)
//
//                let name = placemark?.name ?? "null";
//
//                let cityString = name;
//
                let address = reverseGecodeInfo?.object(forKey: "formattedAddress") as? String ?? "null";
                
                var pinHot = String();
                if annotation.pin_color == "red" {
                    pinHot = "HOT";
                }else if annotation.pin_color == "green" {
                    pinHot = "NEW";
                }
                
                annotation.title = pinHot;
                annotation.subtitle = address;
                
                self.pinTitleLoadBool = true;
                
                
            })
            
            
            if ( annotation.type == "pin" )
            {
            
                pinHideOn = false;
                
                if pinShowOn == true{
                    
                    
                        InfoClass.showInfo()
                    
                    
                    UIView.animate(withDuration: 0.3,
                                   delay: 0,
                                   usingSpringWithDamping:2,
                                   initialSpringVelocity:0,
                                   options: .curveEaseInOut,
                                   animations: {
                                    
                                    self.myLocationView.transform = CGAffineTransform(translationX: 0, y: -InfoClass.height)
                                    
                                    self.addPinView.transform = CGAffineTransform(translationX: 0, y: -InfoClass.height)
                                    
                                    
                                    
                    }, completion: { (finished) -> Void in
                        //print("end");
                        
                    })
                    
                }
                
                
                //load content
                let pin_seq : String = String(annotation.tag);
                let pin_seq_int : Int = Int(annotation.tag)!;
                pinLoadContent(pin_seq : pin_seq);
                
                infoSeq = pin_seq;
                
                
                //pin title view tap
                let pinTitleViewTap = MyTapGestureRecognizer(target: self, action:#selector(self.pinTitleViewTap(_:)))
                pinTitleViewTap.number = pin_seq_int;
                view.addGestureRecognizer(pinTitleViewTap)
            
            
            }
            
            
            
            
            
            
            
        }
        
        
    }
    
    
    //선택해제시
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        
        
        
        
        if let annotation = view.annotation as? CustomPointAnnotation {
            
            //print(annotation.type);
            
            if ( annotation.type == "pin" )
            {
                
                //title view에 적용된 탭 제스쳐 삭제
                view.removeGestureRecognizer(view.gestureRecognizers!.first!)
                
                pinShowOn = false;
                pinHideOn = true;
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) {
                    self.pinShowOn = true;
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) {
                    if self.pinHideOn == true{
                        InfoClass.hideInfo()
                        
                        
                        UIView.animate(withDuration: 0.3,
                                       delay: 0,
                                       usingSpringWithDamping:2,
                                       initialSpringVelocity:0,
                                       options: .curveEaseInOut,
                                       animations: {
                                        
                                        self.myLocationView.transform = CGAffineTransform.identity
                                        
                                        self.addPinView.transform = CGAffineTransform.identity
                                        
                                        
                        }, completion: { (finished) -> Void in
                            //print("end");
                            
                        })
                    }
                }
            }//"pin"
            
            
        }
        
  
        
    }
    
    
    
    
    
    
    
    var textInt = 0;
    
    //핀 꾸미기
    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        
        
        
        let cpa = annotation as? CustomPointAnnotation
        //let pin_seq = Int((cpa?.tag)!);
        
        //print(pin_seq);
        
        
        
        
        if (cpa?.type)! == "pin" {
            
            //일반 핀 설정
            let reuseId = "pin"
            
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
            
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                pinView!.canShowCallout = true
                //pinView!.calloutOffset = CGPoint(x: -10, y: 5)
                //pinView!.leftCalloutAccessoryView = UIButton.init(type: UIButtonType.detailDisclosure) as UIView
                //pinView!.leftCalloutAccessoryView = UIImageView(image : UIImage(named: "map_low"));
                
                
//                let myFirstButton = UIButton()
//                myFirstButton.setTitle("nuri", for: .normal)
//                myFirstButton.setTitleColor(UIColor.blue, for: .normal)
//                myFirstButton.frame = CGRect(x: 0,y: 0,width: 40,height: 20)
//                myFirstButton.tag = Int((cpa?.tag)!)!;
//                myFirstButton.addTarget(self, action: #selector(pressed(sender:)), for: .touchUpInside);
//
                //pinView!.rightCalloutAccessoryView = myFirstButton as UIView
                
                if ( (cpa?.pin_color)! == "red" ){
                    pinView!.pinTintColor = .red;
                }else if ( (cpa?.pin_color)! == "green" ){
                    pinView!.pinTintColor = UIColor.init(red: 68/255.0, green: 235/255.0, blue: 115/255.0, alpha: 1);
                }
                
                pinView!.animatesDrop = true
                //pinView!.pinTintColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 1);
                
                
                
            } else {
                if ( (cpa?.pin_color)! == "red" ){
                    pinView!.pinTintColor = .red;
                }else if ( (cpa?.pin_color)! == "green" ){
                    pinView!.pinTintColor = UIColor.init(red: 68/255.0, green: 235/255.0, blue: 115/255.0, alpha: 1);
                }
                pinView!.annotation = cpa
            }
            
            
            return pinView
            
        }else if (cpa?.type)! == "location" {
            
            //location 핀 설정
            let reuseId = "location"
            
            let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
            if pinView == nil {
                
                pinView?.pinTintColor = UIColor.orange
                pinView?.canShowCallout = true
                let smallSquare = CGSize(width: 30, height: 30)
                var button: UIButton?
                button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
                button?.setBackgroundImage(UIImage(named: "car"), for: UIControlState())
                //네비
                //button?.addTarget(self, action: #selector(HomeViewController.getDirections), for: .touchUpInside)
                pinView?.leftCalloutAccessoryView = button
                
            }
            else {
                pinView!.annotation = annotation
            }
            
            return pinView
        }else{
            
            let annotationReuseId = "fail"
            var anView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationReuseId)
            if anView == nil {
                anView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationReuseId)
            } else {
                anView!.annotation = annotation
            }
            return anView
        }
        
        
        
        
    }
    
    func pressed(sender:UIButton) {
        let message = String(sender.tag);
        let alertController = UIAlertController(title: NSLocalizedString("alert", comment: "alert"), message: message, preferredStyle: .alert)
        
        let sendButton = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            //print("Ok button tapped")
        })
        
        alertController.addAction(sendButton)
        
        
        self.present(alertController, animated: true, completion: nil)
        
        
        
    }
    
    
    //위치 권한 바꼈을때
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        
        //print(status);
        //print(status.rawValue);
        if status != CLAuthorizationStatus.notDetermined || status != CLAuthorizationStatus.denied || status != CLAuthorizationStatus.restricted{
            
            myLocation()
            
        }
    }
    
    
    
    //트래킹모드가 바뀔때
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        if myLocationBool{
            myLocationToggle()
        }
    }
    
    
    
    
    //MARK: - Table
    
    
    var tableCount : Int = 0; //사진 갯수
    var first_num : Int = 0;
    var last_num_Init : Int = 20;
    var last_num : Int = 20; //불러올 사진 갯수
    var moreLoadCount : Int = 20;//더 가져올 사진 수
    var numberOfCell: CGFloat = 3; //한줄에 뜨는 사진 수
    var tableGetAjaxBool : Bool = false; //에이젝스 로딩체크
    var lastCheckBool : Bool = false; //마지막 체크
    
    var tableJson : [[String:Any]] = [[String:Any]]();
    
    var set_type2 = "hot";
    func tableGetAjax(status : String){
        
        self.lastCheckBool = false;
        
        tableGetAjaxBool = false;
        
        if ( status == "init"){
            self.listLoadingView.alpha = 1.0;
            self.tableJson = [[String:Any]]();
        }//if
        self.homeTableView.isUserInteractionEnabled = false;
        self.homeListSegmented.isUserInteractionEnabled = false;
        
        
        
        let key : String = "nuri";
        let type : String = "nuriList";
        let type2 : String = self.set_type2;
        let search_text : String = self.listSearchText;
        let pin_type : String = self.pin_type;
        let first_num : String = String(self.first_num);
        let last_num : String = String(self.last_num);
        let user_seq : String = String(UserDefaults.standard.object(forKey: "loginSesstion") as? Int ?? -1);
        
        let param : String = "key="+key+"&type="+type+"&type2="+type2+"&pin_type="+pin_type+"&first_num="+first_num+"&last_num="+last_num+"&search_text="+search_text+"&user_seq="+user_seq;
        
        
        Ajax.forecast(withUrl: AppDelegate.serverUrl + "/chulsago/pin_chulsa_select.php", withParam: param) { (results:[[String:Any]]) in
            
            for result in results{
                if (result["error"] != nil){
                    //에러발생시
                    print(result["error"] ?? "error")
                    let alertController = UIAlertController(title: NSLocalizedString("waiting", comment: "waiting"), message: "\(String(describing: result["error"]!))", preferredStyle: .alert)
                    
                    let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .cancel , handler: { (action) -> Void in
                    })
                    
                    alertController.addAction(okButton)
                    
                    
                    self.present(alertController, animated: true, completion: nil)
                }else{
                    //print(result["seq"]!)
                    self.tableJson.append(result);
                }
            }
            
            if (results.count != 0){
                //cell 재설정
                DispatchQueue.main.async() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        
                        self.tableGetAjaxBool = true;
                        self.homeTableView.reloadData();
                        
                        
                        if ( status == "init"){
                            //listLoadingView Alpha
                            UIView.animate(withDuration: 0.3,
                                           delay: 0,
                                           options: .curveEaseInOut,
                                           animations: {
                                            
                                            self.listLoadingView.alpha = 0.0;
                            }, completion: { (finished) -> Void in
                                //print("end");
                            })
                        }//if
                        
                    }
                    
                }
            }else{ //아무런 값이 없을때
                
                //마지막 체크
                DispatchQueue.main.async() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.tableGetAjaxBool = true;
                        self.lastCheckBool = true;
                        self.homeTableView.reloadData();
                        
                        if ( status == "init"){
                            //listLoadingView Alpha
                            UIView.animate(withDuration: 0.3,
                                           delay: 0,
                                           options: .curveEaseInOut,
                                           animations: {
                                            
                                            self.listLoadingView.alpha = 0.0;
                            }, completion: { (finished) -> Void in
                                //print("end");
                            })
                        }//if
                    }
                    
                }
            }
            
            //새로고침
            if (status == "refresh") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.refreshControl.endRefreshing();
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self.homeTableView.isUserInteractionEnabled = true;
                    self.homeListSegmented.isUserInteractionEnabled = true;
                }
            }else if ( status == "init"){
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.homeTableView.isUserInteractionEnabled = true;
                    self.homeListSegmented.isUserInteractionEnabled = true;
                }
            }else if( status == "more" ){
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.homeTableView.isUserInteractionEnabled = true;
                    self.homeListSegmented.isUserInteractionEnabled = true;
                }
            }else if ( status == "search"){
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.homeTableView.isUserInteractionEnabled = true;
                    self.homeListSegmented.isUserInteractionEnabled = true;
                }
            }
            
            //데이터가 있는지 없는지 체크
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.11) {
                let cellCount = self.tableJson.count;
                
                if ( cellCount == 0 ){
                    self.noDataLabel.isHidden = false;
                    //self.noDataLabel.text = "데이터가 없습니다.";
                }else{
                    self.noDataLabel.isHidden = true;
                }
            }
            
            
        }//Ajax
        
        
    }
    
    
    //세션 갯수
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    
    //셀 갯수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        tableCount = self.tableJson.count;
        return tableCount;
        
    }
    
    
    //셀 연결
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        let Cell = tableView.dequeueReusableCell(withIdentifier: "homeTableViewCell", for: indexPath) as! HomeTableViewCell
        
        
        let index : Int = indexPath.row;
        
        //Cell.imageView.image = UIImage(named: "스크린샷 2017-07-14 오후 1.13.13.png");
        
        
        if ( self.tableGetAjaxBool == true && self.tableJson.count > 0 )
        {
            DispatchQueue.main.async() {
                
                
                let result = self.tableJson[index];
                let seq : String = String(describing: result["seq"]!)
                let body : String = String(describing: result["body"]!)
                let like : String = String(describing: result["like"]!)
                let commentCount : String = String(describing: result["comment_count"]!)
                let image_name : String = String(describing: result["image_name"]!)
                let thumbnail_image : String = String(describing: result["thumbnail_image"]!)


                let date_ : String = String(describing: result["date_"]!)

                //시간 포멧
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let date = dateFormatter.date(from: date_)

                dateFormatter.amSymbol="AM";
                dateFormatter.pmSymbol = "PM";
                dateFormatter.dateFormat = "yyyy-MM-dd  h:mm a"
                let newDate = dateFormatter.string(from: date!)
                
                


                let image_url : String = AppDelegate.serverUrl + "/chulsago/upload/img/thumbnail/400_" + image_name;
                
                var image_url2 : String = String();
                
                let screenWidth = self.view.frame.size.width;
                
                if screenWidth >= 768 { //아이패드일때
                    image_url2 = AppDelegate.serverUrl + "/chulsago/upload/img/thumbnail/1200_" + image_name;
                }else{
                    image_url2 = AppDelegate.serverUrl + "/chulsago/upload/img/thumbnail/800_" + image_name;
                }
                

                Cell.tag = Int(seq)!;
                
                if image_name != ""{
                    Cell.imageView11.sd_setImage(with: URL(string: image_url), placeholderImage: nil,options: [.continueInBackground, .progressiveDownload], completed: { (image, error, cacheType, imageURL) in
                        //print("뿡");
                    })
                    
                    Cell.imageView22.sd_setImage(with: URL(string: image_url), placeholderImage: nil,options: [.continueInBackground, .progressiveDownload], completed: { (image, error, cacheType, imageURL) in
                        //print("뿡");
                    })
                
                    
                    
                    
                    //Cell.imageView11.downloadAndResizeImageFrom(image_url, contentMode: .scaleAspectFill, newWidth: 200)
                    //Cell.imageView22.downloadAndResizeImageFrom(image_url2, contentMode: .scaleAspectFit , newWidth: 800)
                    //Cell.imageView22.downloadAndResizeImageFrom(image_url, contentMode: .scaleAspectFit , newWidth: 200)
                }
                
                Cell.labelBody.text = body;
                //Cell.labelBody.text = String(index);
                Cell.labelComment.text = NSLocalizedString("comment", comment: "comment") + " " + commentCount + NSLocalizedString("gae", comment: "gae");
                Cell.labelDate.text = newDate;

                //프로필 사진 추가
                if thumbnail_image != ""{

                    Cell.profileImageView.contentMode = UIViewContentMode.scaleAspectFill
                    Cell.profileImageView.sd_setImage(with: URL(string: thumbnail_image), placeholderImage: nil,options: [.continueInBackground, .progressiveDownload], completed: { (image, error, cacheType, imageURL) in
                        //print("뿡");
                    })
                }else{
                    Cell.profileImageView.contentMode = UIViewContentMode.center
                    Cell.profileImageView.image = UIImage(named: "nonProfileSmall");
                }

                
                DispatchQueue.main.async() {
                    
                    //좋아요 상태체크
                    if like != "0" {

                        DispatchQueue.main.async() {
                            Cell.labelLike.text = NSLocalizedString("like", comment: "like") + " " + like + NSLocalizedString("gae", comment: "gae");
                        }


                        let loginSesseion = UserDefaults.standard.object(forKey: "loginSesstion") as? Int ?? -1;

                        if loginSesseion != -1{ //로그인이 되어있을때

                            //좋아요 상태 조회
                            let key : String = "nuri";
                            let user_seq : String = String(loginSesseion);
                            let pin_type : String = self.pin_type;
                            let pin_seq : String = seq;

                            let param : String = "key="+key+"&user_seq="+user_seq+"&pin_type="+pin_type+"&pin_seq="+pin_seq;


                            Ajax.forecast(withUrl: AppDelegate.serverUrl + "/chulsago/like_pin_select.php", withParam: param) { (results:[[String:Any]]) in

                                for result in results{
                                    if (result["error"] != nil){
                                        //에러발생시
                                        print(result["error"] ?? "error")
                                        let alertController = UIAlertController(title: NSLocalizedString("waiting", comment: "waiting"), message: "\(String(describing: result["error"]!))", preferredStyle: .alert)

                                        let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .cancel , handler: { (action) -> Void in
                                        })

                                        alertController.addAction(okButton)


                                        self.present(alertController, animated: true, completion: nil)
                                    }else{
                                        //print(result["seq"]!)

                                        let status : String = String(describing: result["status"]!)

                                        if status == "ok" { //좋아요가 있을때
                                            DispatchQueue.main.async() {
                                                Cell.likeView.image = UIImage(named: "btn_like_on");
                                            }
                                        }else{ //좋아요가 없을때
                                            DispatchQueue.main.async() {
                                                Cell.likeView.image = UIImage(named: "btn_like");
                                            }
                                        }


                                    }
                                }



                            }//ajax

                        }else{//로그인 안되어있을때

                        }
                        


                    }else{
                        DispatchQueue.main.async() {
                            Cell.labelLike.text = NSLocalizedString("like", comment: "like") + " " + like + NSLocalizedString("gae", comment: "gae");
                            Cell.likeView.image = UIImage(named: "btn_like");
                        }
                    }
                    
                }//async



            }//async
            
            
        }//if

        //하나만 테이블 셀 리로드
        if ( self.tableJsonOneReload == true ) {

            if ( self.tableJsonIndex == index ) {
                
                print("------바뀐셀-\(index)");

                self.tableJsonOneReload = false;
                
                DispatchQueue.main.async() {

                    let result = self.tableJson[index];
                    let seq : String = String(describing: result["seq"]!)
                    let like : String = String(describing: result["like"]!)


                    //좋아요 상태체크
                    if like != "0" {

                        DispatchQueue.main.async() {
                            Cell.labelLike.text = NSLocalizedString("like", comment: "like") + " " + like + NSLocalizedString("gae", comment: "gae");
                        }

                        
                        DispatchQueue.main.async() {
                            
                        let loginSesseion = UserDefaults.standard.object(forKey: "loginSesstion") as? Int ?? -1;

                        if loginSesseion != -1{ //로그인이 되어있을때

                            //좋아요 상태 조회
                            let key : String = "nuri";
                            let user_seq : String = String(loginSesseion);
                            let pin_type : String = self.pin_type;
                            let pin_seq : String = seq;

                            let param : String = "key="+key+"&user_seq="+user_seq+"&pin_type="+pin_type+"&pin_seq="+pin_seq;


                            Ajax.forecast(withUrl: AppDelegate.serverUrl + "/chulsago/like_pin_select.php", withParam: param) { (results:[[String:Any]]) in

                                for result in results{
                                    if (result["error"] != nil){
                                        //에러발생시
                                        print(result["error"] ?? "error")
                                        let alertController = UIAlertController(title: NSLocalizedString("waiting", comment: "waiting"), message: "\(String(describing: result["error"]!))", preferredStyle: .alert)

                                        let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .cancel , handler: { (action) -> Void in
                                        })

                                        alertController.addAction(okButton)


                                        self.present(alertController, animated: true, completion: nil)
                                    }else{
                                        //print(result["seq"]!)

                                        let status : String = String(describing: result["status"]!)

                                        if status == "ok" { //좋아요가 있을때
                                            DispatchQueue.main.async() {
                                                Cell.likeView.image = UIImage(named: "btn_like_on");
                                            }
                                        }else{ //좋아요가 없을때
                                            DispatchQueue.main.async() {
                                                Cell.likeView.image = UIImage(named: "btn_like");
                                            }
                                        }


                                    }
                                }



                            }//ajax
                            
                            
                            

                        }else{//로그인 안되어있을때

                        }

                        }
                        
                    }else{
                        DispatchQueue.main.async() {
                            Cell.labelLike.text = NSLocalizedString("like", comment: "like") + " " + like + NSLocalizedString("gae", comment: "gae");
                            Cell.likeView.image = UIImage(named: "btn_like");
                        }
                    }



                }//sync


            }//if

        }//if
        
        
        
        

        return Cell
        

        
    }
    
    //셀 선택 취소
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
    //셀 선택
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print( indexPath.row);
        
        //선택셀 태그 가져오기
        //print(homeTableView.cellForRow(at: indexPath)?.tag ?? 0)
        DispatchQueue.main.async() {
            self.showDetailSeq = -1;
            
            //선택셀 조회
            let indexPathRow = indexPath.row;
            let currentCell = self.homeTableView.cellForRow(at: indexPath) as! HomeTableViewCell;
            let selectCellTag = currentCell.tag;
            
            self.showDetailSeq = selectCellTag;
            self.tableJsonIndex = indexPathRow;
            
            //print("------------------ 선택셀 - \(self.tableJsonIndex)");
            
            if (currentCell.imageView22.image != nil) {
                self.performSegue(withIdentifier: "showListDetail", sender: self);
            }
        }
        
        
    }
    
    //셀 높이
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120;
    }

    
    //맨밑 체크
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.item == (self.tableCount - 1) {
            //print("맨밑");
            
            
            //reload
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if ( self.lastCheckBool == false && self.tableGetAjaxBool == true) { //마지막이 아닐때 and ajax 로딩 다 되었을때

                        self.first_num = self.tableCount;
                        self.last_num = self.moreLoadCount;
                        self.tableGetAjax(status:"more");
                    
                }
            }//reload
        }
        
    }
    
    
    
//    //섹션 header 초기화
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerCell = tableView.dequeueReusableCell(withIdentifier: "memoHeader") as! MainHeaderCell
//        //headerCell.headerCell.textColor = UIColor.white;
//        headerCell.backgroundColor = UIColor(red: (219/255.0), green: (244/255.0), blue: (254/255.0), alpha: 1.000)
//
//
//        switch (section) {
//        case 0:
//            headerCell.headerCell.text = "memo";
//        //return sectionHeaderView
//        case 1:
//            headerCell.headerCell.text = "Europe";
//        //return sectionHeaderView
//        case 2:
//            headerCell.headerCell.text = "Europe";
//        //return sectionHeaderView
//        default:
//            headerCell.headerCell.text = "Other";
//        }
//
//        return headerCell
//    }
//
//    //섹션 Header 높이설정
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 0;
//    }
//
//    //섹션 footer 초기화
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//
//        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40) )
//        footerView.backgroundColor = UIColor.clear;
//
//        return footerView
//    }
//    //섹션 footer height
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 0.0
//    }
//
    
    
    //Table_End
    

}




//search map
extension HomeViewController: HandleMapSearch {
    
    func dropPinZoomIn(_ placemark: MKPlacemark){
        // cache the pin
        selectedPin = placemark
        
        
        //지도 핀 제거
        if let annotations : [MKAnnotation] = mapView.annotations {
            for annotation in annotations {
                if let annotation = annotation as? CustomPointAnnotation
                {
                    if ( annotation.type == "location"){
                        self.mapView.removeAnnotation(annotation)
                    }
                }
            }
        }
        
        
        
        
        
        let annotation = CustomPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        annotation.type = "location";
        
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        
        mapView.addAnnotation(annotation)
        
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
    
}




//Common


class CustomPointAnnotation: MKPointAnnotation {
    var imageName: String!
    var tag: String = "1";
    var type: String = "pin";
    var pin_color: String = "red";
}


func maskRoundedImage(image: UIImage, radius: Float) -> UIImage {
    let imageView: UIImageView = UIImageView(image: image)
    var layer: CALayer = CALayer()
    layer = imageView.layer
    
    layer.masksToBounds = true
    layer.cornerRadius = CGFloat(radius)
    layer.borderWidth = 2.0
    layer.borderColor = UIColor.gray.cgColor
    layer.backgroundColor = UIColor.white.cgColor;
    
    
    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, 0);
    layer.render(in: UIGraphicsGetCurrentContext()!)
    let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return roundedImage!
}

func imageResize (image:UIImage, sizeChange:CGSize)-> UIImage{
    
    let hasAlpha = true
    let scale: CGFloat = 0.0 // Use scale factor of main screen
    
    UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
    image.draw(in: CGRect(origin: .zero, size: sizeChange))
    
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    return scaledImage!
}





