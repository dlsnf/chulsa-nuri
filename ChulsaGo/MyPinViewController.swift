//
//  MyPinViewController.swift
//  ChulsaGo
//
//  Created by nuri Lee on 2018. 1. 1..
//  Copyright © 2018년 nuri lee. All rights reserved.
//

import UIKit
import MapKit

class MyPinViewController : UIViewController, ZoomTransitionProtocol,  CLLocationManagerDelegate, MKMapViewDelegate{
    
    @IBOutlet weak var myPinMapView: MKMapView!
    
    @IBOutlet weak var myLocationView: UIView!
    
    @IBOutlet weak var myLocationImageView: UIImageView!
    
    
    var myPinCoreLocationManger = CLLocationManager()
    var myPinLocationManager:LocationManager!
    
    var myLocationBool : Bool = false;
    var infoSeq : String = "1";
    var pin_type : String = enum_pin_type.chulsa.rawValue;
    
    var user_seq : String = "0";
    
    
    
    
    var zoomTransType : String = "infoView";
    var animationController : ZoomTransition?;
    func viewForTransition() -> UIView {
        
        return InfoClass2.infoVC.imageView2
        
        
    }
    
    
    var homeSegIndex : Int = 0;
    @IBAction func homeSegmentedPress(_ sender: UISegmentedControl) {
        
        DispatchQueue.main.async() {
            
            self.homeSegIndex = sender.selectedSegmentIndex;
            
            //지도볼때
            if ( self.homeSegIndex == 0 ){
                self.pin_type = enum_pin_type.chulsa.rawValue;
                 DispatchQueue.main.async() {
                    self.pinInit();
                }
            }else{ //리스트 볼때
                self.pin_type = enum_pin_type.food.rawValue;
                DispatchQueue.main.async() {
                    self.pinInit();
                }
            }
        
        }//sync
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //화면 완전히 종료 할때
        if ( self.outViewBool == true ){
            
            self.myPinLocationManager = nil
            
            self.myPinMapView.mapType = MKMapType.hybrid
            self.myPinMapView.mapType = MKMapType.standard
            self.myPinMapView.showsUserLocation = false
            self.myPinMapView.delegate = nil
            self.myPinMapView.removeFromSuperview()
            self.myPinMapView = nil
            
            self.myPinCoreLocationManger.delegate = nil;
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        

    }
    
    
    var outViewBool : Bool = false;
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        self.outViewBool = true;
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //print(user_seq);
        //print(pin_type);
        
        InfoClass2.infoInit(uiView: self.view);
        
        //Tap
        let myLocationTap = UITapGestureRecognizer(target: self, action:#selector(self.myLocationToggle))
        myLocationView.addGestureRecognizer(myLocationTap)
        
        
        let pinInfoViewTap = UITapGestureRecognizer(target: self, action:#selector(self.pinInfoViewTap))
        InfoClass2.infoVC.infoView.addGestureRecognizer(pinInfoViewTap)
        
        let pinInfoViewswipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.pinInfoViewswipeUp))
        pinInfoViewswipeUp.direction = UISwipeGestureRecognizerDirection.up
        InfoClass2.infoVC.infoView.addGestureRecognizer(pinInfoViewswipeUp)
        
        
        
        
        let name = Notification.Name("infoLikeReload2");
        NotificationCenter.default.addObserver(self, selector: #selector(infoLikeReload), name: name, object: nil)
        
        
        
        
        //ZoomTransitionProtocol
        if let navigationController = self.navigationController {
            animationController = ZoomTransition(navigationController: navigationController)
        }
        self.navigationController?.delegate = animationController
        
        
        
        
        //map init
        self.myPinMapView.delegate = self;
        
        myPinCoreLocationManger.delegate = self
        
        myPinLocationManager = LocationManager.sharedInstance
        
        let authorizationCode = CLLocationManager.authorizationStatus()
        
        //authorizationCode.rawValue = 0  - 위치 허용 물어보기전 notDetermined
        //authorizationCode.rawValue = 1  - 한정적 위치 restricted
        //authorizationCode.rawValue = 2  - 위치 허용 안했을때 denied
        //authorizationCode.rawValue = 3  - 모든 위치 허용 했을때 authorizedAlways
        //authorizationCode.rawValue = 4  - 사용시에만 허용 했을때 restricted
        if authorizationCode == CLAuthorizationStatus.notDetermined && myPinCoreLocationManger.responds(to: #selector(CLLocationManager.requestAlwaysAuthorization)) || myPinCoreLocationManger.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)){
            
            if Bundle.main.object(forInfoDictionaryKey: "NSLocationWhenInUseUsageDescription") != nil {
                //coreLocationManger.requestAlwaysAuthorization()
                
                myPinCoreLocationManger.requestWhenInUseAuthorization()
                
                
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
        
        
        
        
        
    }//didload
    
    
    
    
    
    @objc func pinInit(){
        //var pinJson : [[String:Any]] = [[String:Any]]();
        
        //자기 위치
        //        var currentLocation = CLLocation()
        //        currentLocation = coreLocationManger.location!;
        //지도 핀 제거
        if let annotations : [MKAnnotation] = self.myPinMapView.annotations {
            for annotation in annotations {
                if let annotation = annotation as? CustomPointAnnotation
                {
                    if ( annotation.type == "pin"){
                        self.myPinMapView.removeAnnotation(annotation)
                    }
                }
            }
        }
        
        
        
        let key : String = "nuri";
        let type : String = "my_pin";
        let pin_type : String = self.pin_type;
        let user_seq : String = self.user_seq;
        
        
        
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
                            self.myPinMapView.addAnnotation(annotation)
                        }
                        
                    }
                    
                    
                }
            }
            
            //self.text1(json : pinJson);
            
            
        }//Ajax
        
        
    }
    
    
    
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showPinDetail" {
            zoomTransType = "infoView";
            self.outViewBool = false;
            
            let secondVC = segue.destination as! pinDetailViewController;
            secondVC.image = InfoClass2.infoVC.imageView2.image!;
            secondVC.pin_seq = InfoClass2.infoVC.infoView.tag;
            secondVC.pin_type = self.pin_type;
            secondVC.showType = "myPinView";
        }
        
        
    }
    
    
    
    
    var pinTitleLoadBool : Bool = false;
    @objc func pinTitleViewTap(_ sender : MyTapGestureRecognizer){
        //        let pin_seq = sender.number!;
        //
        //        print(pin_seq);
        
        //버그 거르기
        if InfoClass2.infoVC.imageView.image?.size.height != 0{
            //print("not nil");
            if self.pinTitleLoadBool {
                if InfoClass2.infoVC.imageView.image?.size.height != 0{
                    if InfoClass2.infoVC.imageView2.image?.size.height != 0{
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
        if InfoClass2.infoVC.imageView.image?.size.height != 0{
            if InfoClass2.infoVC.imageView2.image?.size.height != 0{
                //print("not nil");
                self.performSegue(withIdentifier: "showPinDetail", sender: self);
            }
        }else{
            //print("nil");
        }
    }
    
    @objc func pinInfoViewTap(){
        
        //버그 거르기
        if InfoClass2.infoVC.imageView.image?.size.height != 0{
            if InfoClass2.infoVC.imageView2.image?.size.height != 0{
                //print("not nil");
                self.performSegue(withIdentifier: "showPinDetail", sender: self);
            }
        }else{
            //print("nil");
        }
    }
    
    @objc func myLocationToggle(){
        
        //GPS접근권한 설정되었을때
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            
            
            if myLocationBool{
                myLocationImageView.image = UIImage(named: "myLocation_off");
                myLocationBool = false;
                
                self.myPinMapView.setUserTrackingMode(MKUserTrackingMode.none, animated: true)
                
                
            }else{
                self.myPinMapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
                myLocationImageView.image = UIImage(named: "myLocation_on");
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
            if myPinCoreLocationManger.location != nil{
                
                //자기 좌표 가져오기
                currentLocation = myPinCoreLocationManger.location!;
                
                //맵 이동
                self.myPinMapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude), span: MKCoordinateSpanMake(0.3, 0.3)), animated: true)
                
                self.myPinMapView.showsUserLocation = true;
                
                self.myPinMapView.userLocation.title = "";
                
                
                
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
            self.myPinMapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2DMake(latitude, longitude), span: MKCoordinateSpanMake(0.03, 0.03)), animated: true)
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
            myPinLocationManager.reverseGeocodeLocationWithCoordinates(pinLocation, onReverseGeocodingCompletionHandler: { (reverseGecodeInfo, placemark, error) -> Void in
                
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
                    
                    
                    InfoClass2.showInfo()
                    
                    
                    UIView.animate(withDuration: 0.3,
                                   delay: 0,
                                   usingSpringWithDamping:2,
                                   initialSpringVelocity:0,
                                   options: .curveEaseInOut,
                                   animations: {
                                    
                                    self.myLocationView.transform = CGAffineTransform(translationX: 0, y: -InfoClass2.height)
                                    
                                    //                                    self.addPinView.transform = CGAffineTransform(translationX: 0, y: -InfoClass2.height)
                                    
                                    
                                    
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
                            
                            InfoClass2.infoVC.profileImageView.contentMode = UIViewContentMode.scaleAspectFill
                            InfoClass2.infoVC.profileImageView.downloadAndResizeImageFrom(thumbnail_image, contentMode: .scaleAspectFill, newWidth: 200)
                        }else{
                            InfoClass2.infoVC.profileImageView.contentMode = UIViewContentMode.center
                            InfoClass2.infoVC.profileImageView.image = UIImage(named: "nonProfileSmall");
                        }
                        
                    }
                    
                    
                }
            }
        }//ajax
    }
    
    
    func pinLoadContent(pin_seq : String){
        
        InfoClass2.infoVC.imageView.image = UIImage();
        InfoClass2.infoVC.imageView2.image = UIImage();
        
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
                            InfoClass2.infoVC.imageView.downloadAndResizeImageFrom(image_url, contentMode: .scaleAspectFill , newWidth: 200)
                            
                            InfoClass2.infoVC.imageView2.downloadAndResizeImageFrom(image_url2, contentMode: .scaleAspectFit , newWidth: 800)
                            
                            
                        }
                        
                        
                        //좋아요 초기화
                        self.infoLikeInit(pin_seq: seq, like: like);
                        self.infoCommentInit(pin_seq: seq);
                        
                        InfoClass2.infoVC.labelBody.text = body;
                        InfoClass2.infoVC.labelDate.text = newDate;
                        InfoClass2.infoVC.infoView.tag = Int(seq)!;
                        
                        //profile load
                        self.profileInit(user_seq : user_seq);
                        
                        //InfoClass2.infoVC.loadingView.isHidden = true;
                        
                        
                    }
                    
                    
                    
                    
                }
            }
            
        }//Ajax
        
        
        
    }
    
    
    func infoLikeInit(pin_seq : String, like : String){
        
        DispatchQueue.main.async() {
            InfoClass2.infoVC.likeView.image = UIImage(named: "btn_like");
        }
        
        if like != "0" {
            
            
            //            InfoClass2.infoVC.likeView.isHidden = false;
            //InfoClass2.infoVC.likeLabelConstraint.isActive = true;
            //InfoClass2.infoVC.labelLike.textColor = UIColor.darkText;
            InfoClass2.infoVC.labelLike.text = NSLocalizedString("like", comment: "like") + " " + like + NSLocalizedString("gae", comment: "gae");
            
            
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
                                    InfoClass2.infoVC.likeView.image = UIImage(named: "btn_like_on");
                                }
                            }else{ //좋아요가 없을때
                                DispatchQueue.main.async() {
                                    InfoClass2.infoVC.likeView.image = UIImage(named: "btn_like");
                                }
                            }
                            
                            
                        }
                    }
                    
                    
                }//ajax
                
            }else{//로그인 안되어있을때
                
            }
            
            
        }else{
            //            InfoClass2.infoVC.likeView.isHidden = true;
            //            InfoClass2.infoVC.likeLabelConstraint.isActive = false;
            //InfoClass2.infoVC.labelLike.textColor = UIColor.lightGray;
            InfoClass2.infoVC.labelLike.text = NSLocalizedString("like", comment: "like") + " " + like + NSLocalizedString("gae", comment: "gae");
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
                        InfoClass2.infoVC.labelComment.text = NSLocalizedString("comment", comment: "comment") + " " + count + NSLocalizedString("gae", comment: "gae");
                    }
                }
            }
            
            
        }//ajax
        
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
                        InfoClass2.hideInfo()
                        
                        
                        UIView.animate(withDuration: 0.3,
                                       delay: 0,
                                       usingSpringWithDamping:2,
                                       initialSpringVelocity:0,
                                       options: .curveEaseInOut,
                                       animations: {
                                        
                                        self.myLocationView.transform = CGAffineTransform.identity
                                        
                                        //                                      self.addPinView.transform = CGAffineTransform.identity
                                        
                                        
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
    
    
    
    
    
    
    
    
    
    
    
}




