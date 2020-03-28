//
//  ViewController.swift
//  ZoomTransition
//
//  Created by Nu-Ri Lee on 2017. 5. 24..
//  Copyright © 2017년 nuri lee. All rights reserved.
//

import UIKit
import MapKit
import SDWebImage

class pinDetailViewController : UIViewController, ZoomTransitionProtocol, UIScrollViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    func viewForTransition() -> UIView {
        return imageView
    }
    var image = UIImage();
    var pin_seq = Int();
    var pin_type = String();
    var pin_user_seq = String();
    var pin_user_seq_click = String();
    var globalLoginSesstion = Int();
    var showType = String();
    
    var showNavi : Bool = false;
    var dismissViewBool : Bool = false;
    
    var selectedPlaceMark : MKPlacemark?;
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet var imageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageBlurView: UIView!
    @IBOutlet weak var imageBlur: UIImageView!
    
    @IBOutlet weak var imageBlurEffect: UIVisualEffectView!
    @IBOutlet var imageBlurViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var btnDismiss: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var tempViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tempView: UIView!
    @IBOutlet weak var likeView: UIView!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnComment: UIButton!
    @IBOutlet weak var labelLike: UILabel!
    @IBOutlet weak var labelComment: UILabel!
    @IBOutlet weak var nuriNavigationBar: UIView!
    @IBOutlet weak var nuriNaviAddress: UILabel!
    @IBOutlet weak var nuriNavilatitude: UILabel!
    
    @IBOutlet weak var viewCountImageView: UIImageView!
    @IBOutlet weak var viewCountLabel: UILabel!
    
    @IBOutlet weak var infoBody: UILabel!
    @IBOutlet weak var infoProfile: UILabel!
    @IBOutlet weak var infoCheckIn: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    @IBOutlet weak var fixedNickName: UILabel!
    @IBOutlet weak var nickName: UILabel!
    
    @IBOutlet weak var fixedRating: UILabel!
    @IBOutlet weak var rating: UILabel!
    
    @IBOutlet weak var fixedAddress: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var fixedDateLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var profileView: ProfileView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var instarView: UIView!
    
    @IBOutlet weak var instarListView: UIStackView!
    
    
    @IBOutlet weak var menuCheckInView: UIView!
    
    @IBOutlet weak var menuInstarView: UIView!
    @IBOutlet weak var menuInstarListView: UIView!
    
    @IBOutlet weak var menuCheckInImageView: UIImageView!
    
    @IBOutlet weak var menuInstarImageView: UIImageView!
    
    @IBOutlet weak var menuInstarListImageView: UIImageView!
    
    @IBOutlet weak var menuCheckInBottom: UIView!
    @IBOutlet weak var menuInstarBottom: UIView!
    @IBOutlet weak var menuInstarListBottom: UIView!
    @IBOutlet var contentViewBottomSpace: NSLayoutConstraint!
    
    @IBOutlet var instarViewBottomSpace: NSLayoutConstraint!
    
    @IBOutlet var instarListViewBottomSpace: NSLayoutConstraint!
    
    @IBOutlet weak var likeHeartView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var tableHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var editTextView: UIView!
    
    @IBOutlet var editTextBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var commentTextView: RoundTextView!
    @IBOutlet weak var btnCommentSubmit: UIButton!
    @IBOutlet var commentTextViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var commentNotLoginView: UIView!
    
    @IBOutlet var editTextViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableHeader: UIView!
    
    @IBOutlet weak var btnMoreMenu: UIButton!
    
    
    @IBAction func btnMorePress(_ sender: UIButton) {
        moreMenu(sender : sender);
    }
    
    func moreMenu(sender : UIButton){
        
        let globalPoint = sender.superview?.convert(sender.frame.origin, to: self.view)
        
        
        guard let selectedPlaceMark = self.selectedPlaceMark else { return } //MKPlacemark
        
        let latitude: CLLocationDegrees = (selectedPlaceMark.location?.coordinate.latitude)!;
        let longitude: CLLocationDegrees = (selectedPlaceMark.location?.coordinate.longitude)!;
        
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = self.address.text;
        


        let alertController = UIAlertController();

        
        
        
        let  appleMapButton = UIAlertAction(title: NSLocalizedString("open applemap", comment: "open applemap"), style: .default , handler: { (action) -> Void in
            //print("Delete button tapped")
            
            
            mapItem.openInMaps(launchOptions: options)
            
        })
        
        alertController.addAction(appleMapButton)
        
        let  googleMapButton = UIAlertAction(title: NSLocalizedString("open googlemap", comment: "open googlemap"), style: .default , handler: { (action) -> Void in
            //print("Delete button tapped")
            
            
            if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
                let urlString = "comgooglemaps://?center=\(latitude),\(longitude)&zoom=14&views=traffic&q=\(latitude),\(longitude)";
                UIApplication.shared.open(URL(string:urlString)!, options: [:], completionHandler: nil)
            } else {
                print("Can't use comgooglemaps://");
                UIApplication.shared.open(URL(string:
                    "https://maps.google.com/?q=@\(Float(latitude)),\(Float(longitude))")! as URL)
            }
            
        })
        
        alertController.addAction(googleMapButton)
        
        
        
        //loginSesstion
        let loginSesseion = UserDefaults.standard.object(forKey: "loginSesstion") as? Int ?? -1;
        
        if ( String(loginSesseion) == self.pin_user_seq || loginSesseion == 1){ //본인 또는 관리자
            
            //본인
            let  pinReportButton = UIAlertAction(title: NSLocalizedString("delete", comment: "delete"), style: .destructive , handler: { (action) -> Void in
                
                let alertController = UIAlertController(title: NSLocalizedString("delete post", comment: "delete post"), message: NSLocalizedString("delete?", comment: "delete?"), preferredStyle: .alert)
                
                
                let  deleteButton = UIAlertAction(title: NSLocalizedString("delete", comment: "delete"), style: .destructive, handler: { (action) -> Void in
                    
                    //삭제
                    Common.pinDelete(pin_seq: String(self.pin_seq), pin_type: self.pin_type){ (result:String) in
                        
                        
                        if( result == "ok")
                        {
                            let alertController = UIAlertController(title: NSLocalizedString("delete success", comment: "delete success"), message: NSLocalizedString("delete post success", comment: "delete post success"), preferredStyle: .alert)
                            
                            let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .cancel , handler: { (action) -> Void in
                                print("delete success");
                                //self.dismiss(animated: true, completion: nil);
                            })
                            
                            alertController.addAction(okButton)
                            
                            self.present(alertController, animated: true, completion: nil)
                        }else{ //에러발생
                            
                            let alertController = UIAlertController(title: NSLocalizedString("waiting", comment: "waiting"), message: "\(result)", preferredStyle: .alert)
                            let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .cancel , handler: { (action) -> Void in
                            })
                            alertController.addAction(okButton)
                            self.present(alertController, animated: true, completion: nil)
                            
                            
                        }
                    }//delete
                    
                })
                
                let cancelButton = UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"), style: .cancel, handler: { (action) -> Void in
                    //print("Cancel button tapped")
                })
                
                
                alertController.addAction(deleteButton)
                alertController.addAction(cancelButton)
                
                self.present(alertController, animated: true, completion: nil)
                
                
            })
            alertController.addAction(pinReportButton)
            
            
        }else{
            
            //일반 사용자
            let  pinReportButton = UIAlertAction(title: NSLocalizedString("report", comment: "report"), style: .destructive , handler: { (action) -> Void in
                //print("Delete button tapped")
                
                self.performSegue(withIdentifier: "showReporter", sender: self);
                
                
            })
            alertController.addAction(pinReportButton)
            
        }
        
        
        
        
        


        let cancelButton = UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"), style: .cancel, handler: { (action) -> Void in
            //print("Cancel button tapped")
        })
        alertController.addAction(cancelButton)

        
        //ipad 일때 위치 잡아주기
        if let popoverPresentationController = alertController.popoverPresentationController {

            let commentTextViewRect = CGRect(x: (globalPoint?.x)! , y: (globalPoint?.y)!  , width: 1, height: 1);

            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = commentTextViewRect;
            //popoverPresentationController.permittedArrowDirections = .down
        }

        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    
    
    @IBAction func btnCommentSubmitClick(_ sender: UIButton) {
        
        DispatchQueue.main.async() {
            self.btnCommentSubmit.isEnabled = false;
            self.commentTextView.isUserInteractionEnabled = false;
            self.commentTextView.resignFirstResponder();
        }
        
        
        let key : String = "nuri";
        let user_seq : String = String(globalLoginSesstion);
        let pin_type : String = self.pin_type;
        let pin_seq : String = String(self.pin_seq);
        let body : String = String(commentTextView.text);
        
        
        let param : String = "key="+key+"&user_seq="+user_seq+"&pin_type="+pin_type+"&pin_seq="+pin_seq+"&body="+body;
        
        
        Ajax.forecast(withUrl: AppDelegate.serverUrl + "/chulsago/comment_pin_insert.php", withParam: param) { (results:[[String:Any]]) in
            
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
                    //let status : String = String(describing: result["status"]!)
                    
                    DispatchQueue.main.async() {
                     
                        //스크롤 가장 아래로
                        self.commentLoad(scrollDownBool : true);
                        self.commentInit();
                        
                    }
                }
            }
            
            
            
        }//ajax
        
        
        
        
    }
    
    @IBAction func dismissView(_ sender: Any) {
        //InfoClass.infoVC.view.alpha = 1.0;
        //네비게이션 뒤로가기
        //self.presentingViewController?.dismiss(animated: true)
        dismissView();
        
    }
    
    @IBAction func btnComment(_ sender: Any) {
        let tag = (sender as AnyObject).tag;
        
        if tag == 1{ //like 눌렀을때
            pressLikeButton();
        }else if tag == 2{ //댓글버튼 눌렀을때
            let loginSesseion = UserDefaults.standard.object(forKey: "loginSesstion") as? Int ?? -1;
            
            if loginSesseion != -1{ //로그인이 되어있을때
                
                let globalPoint = self.tableHeader.superview?.convert(self.tableHeader.frame.origin, to: self.view)
                let mapViewPositionY = CGPoint(x: 0, y: ((globalPoint?.y)! - 80 ))
                //self.scrollView.setContentOffset(mapViewPositionY, animated: true)
                commentTextView.becomeFirstResponder();
            }else{//로그인이 안되어있을때
                loginAlert();
            }
        }
    }
    
    var imageViewHeight : CGFloat!
    
    var touchDownBool : Bool = false;
    var scrollDownDismissBool : Bool = false;
    
    var coreLocationManger = CLLocationManager()
    var locationManager3 : LocationManager!
    
    var menuViewStep : Int = 1;
    
    var likeAble : Bool = true;
    var likeBool : Bool = false;
    var showHeartBool : Bool = true;
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true;
        
        if ( showNavi ){
            //status bar
            let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
            statusBar.alpha = 1.0;
            
        }else{
            //status bar
            let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
            statusBar.alpha = 0.0;
        }
        
        
        globalLoginSesstion = UserDefaults.standard.object(forKey: "loginSesstion") as? Int ?? -1;
        likeInit();
        commentInit();
        commentNotLoginViewInit();
        addObservers();
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers();
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        globalLoginSesstion = UserDefaults.standard.object(forKey: "loginSesstion") as? Int ?? -1;
        
        
        
        contentView.isHidden = false;
        instarView.isHidden = true;
        instarListView.isHidden = true;
        
        
        imageView.image = image;
        imageSizeInit();
        getAjax();
        viewCountUp(pin_seq: String(self.pin_seq));
        
        imageBlur.image = image;
        scrollView.delegate = self;
        
        commentTextView.delegate = self;
       
        //tap
        let menuCheckInViewTap = MyTapGestureRecognizer(target: self, action:#selector(self.menuViewTap(_:)))
        menuCheckInViewTap.number = 1;
        menuCheckInView.addGestureRecognizer(menuCheckInViewTap)
        
        let menuInstarViewTap = MyTapGestureRecognizer(target: self, action:#selector(self.menuViewTap(_:)))
        menuInstarViewTap.number = 2;
        menuInstarView.addGestureRecognizer(menuInstarViewTap)
        
        let menuInstarListViewTap = MyTapGestureRecognizer(target: self, action:#selector(self.menuViewTap(_:)))
        menuInstarListViewTap.number = 3;
        menuInstarListView.addGestureRecognizer(menuInstarListViewTap)
        
        
        let scrollViewTap = MyTapGestureRecognizer(target: self, action:#selector(self.scrollViewTap(_:)))
        scrollView.addGestureRecognizer(scrollViewTap)
        
        let commentNotLoginViewTap = MyTapGestureRecognizer(target: self, action:#selector(self.loginAlert))
        commentNotLoginView.addGestureRecognizer(commentNotLoginViewTap)
        
        let showMyPageTap = MyTapGestureRecognizer(target: self, action:#selector(self.showMyPageTap))
        nickName.addGestureRecognizer(showMyPageTap)
        profileView.addGestureRecognizer(showMyPageTap)
        
        let mapViewTap = MyTapGestureRecognizer(target: self, action:#selector(self.openMap(recognizer:)))
        self.mapView.addGestureRecognizer(mapViewTap);
        
//        let addressTap = MyTapGestureRecognizer(target: self, action:#selector(self.openMap(recognizer:)))
//        self.address.addGestureRecognizer(addressTap);
        
//        let nuriNaviAddressTap = MyTapGestureRecognizer(target: self, action:#selector(self.openMap))
//        self.nuriNaviAddress.addGestureRecognizer(nuriNaviAddressTap);
//
//        let nuriNavilatitudeTap = MyTapGestureRecognizer(target: self, action:#selector(self.openMap(recognizer:)))
//        self.nuriNavilatitude.addGestureRecognizer(nuriNavilatitudeTap);
        
        
        
        //gesture drag edge
//        let panEdgeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(draggedEdgeView(_:)))
//        panEdgeGesture.edges = .left;
//        self.view.addGestureRecognizer(panEdgeGesture);
        
        
        
        
        let doubleImageViewTap = MyTapGestureRecognizer(target: self, action:#selector(self.doubleImageViewTap(_:)))
        doubleImageViewTap.numberOfTapsRequired = 2;
        tempView.addGestureRecognizer(doubleImageViewTap)
        
        let tempViewLongPress = UILongPressGestureRecognizer(target: self, action:#selector(self.tempViewLongPress(_:)))
       // tempViewLongPress.minimumPressDuration = 2.0;
//        tempViewLongPress.numberOfTouchesRequired = 1;
//        tempViewLongPress.numberOfTapsRequired = 1;
        tempViewLongPress.allowableMovement = 1;
        self.tempView.addGestureRecognizer(tempViewLongPress);
        
        
        
        
        
        
        animation();
       
        likeInit();
        commentInit();
        
        commentNotLoginViewInit();
        
        
        tableView.estimatedRowHeight = 100;
        tableView.rowHeight = UITableViewAutomaticDimension
        
        commentLoad(scrollDownBool : false);
        
        
    }//view did load
    
    
    
    @objc func tempViewLongPress(_ sender : UILongPressGestureRecognizer){
        self.moreMenu(sender: btnMoreMenu)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "showMyPage" {
            let nav = segue.destination as! UINavigationController;
            let vc = nav.viewControllers[0] as! MyPageViewController;
            vc.get_seq = self.pin_user_seq;
        }
        
        if segue.identifier == "showMyPage_click" {
            let nav = segue.destination as! UINavigationController;
            let vc = nav.viewControllers[0] as! MyPageViewController;
            vc.get_seq = self.pin_user_seq_click;
        }
        
        if segue.identifier == "showReporter" {
            
            let loginSesseion = UserDefaults.standard.object(forKey: "loginSesstion") as? Int ?? -1;
            
            let nav = segue.destination as! UINavigationController;
            let vc = nav.viewControllers[0] as! PinReporterViewController;
            vc.pin_seq = String(self.pin_seq);
            vc.pin_type = self.pin_type;
            vc.pin_user_seq = self.pin_user_seq;
            vc.reporter_seq = String(loginSesseion);
            
        }
        
        if segue.identifier == "showLikeViewList" {
            
            let nav = segue.destination as! UINavigationController;
            let vc = nav.viewControllers[0] as! LikeViewController;
            vc.pin_seq = String(self.pin_seq);
            vc.pin_type = self.pin_type;
            
        }
        
        
        
    }
    
    @objc func openMap(recognizer : UITapGestureRecognizer){
        
        let point = recognizer.location(in: view);
        
        guard let selectedPlaceMark = self.selectedPlaceMark else { return } //MKPlacemark

        let latitude: CLLocationDegrees = (selectedPlaceMark.location?.coordinate.latitude)!;
        let longitude: CLLocationDegrees = (selectedPlaceMark.location?.coordinate.longitude)!;

        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = self.address.text;
        
        
        
        
        
        
        
        let alertController = UIAlertController();
        
        let  appleMapButton = UIAlertAction(title: "Apple", style: .default , handler: { (action) -> Void in
            //print("Delete button tapped")
            
            
            mapItem.openInMaps(launchOptions: options)
            
        })
        
        let  googleMapButton = UIAlertAction(title: "Google", style: .default , handler: { (action) -> Void in
            //print("Delete button tapped")
            
            
            if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
                let urlString = "comgooglemaps://?center=\(latitude),\(longitude)&zoom=14&views=traffic&q=\(latitude),\(longitude)";
                UIApplication.shared.open(URL(string:urlString)!, options: [:], completionHandler: nil)
            } else {
                print("Can't use comgooglemaps://");
                UIApplication.shared.open(URL(string:
                    "https://maps.google.com/?q=@\(Float(latitude)),\(Float(longitude))")! as URL)
            }
            
        })
//
//        let  naverMapButton = UIAlertAction(title: "Naver", style: .default , handler: { (action) -> Void in
//            //print("Delete button tapped")
//
//            if (UIApplication.shared.canOpenURL(URL(string:"navermaps://")!)) {
//                let title = self.address.text!;
//
//                //길찾기
//                //                let urlString = "navermaps://?menu=route&routeType=4&elat=\(latitude)&elng=\(longitude)&etitle=\(String(describing: title))";
//                let urlString = "navermaps://?menu=location&elat=\(latitude)&elng=\(longitude)&etitle=\(String(describing: title))";
//
//                let textEncode = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
//                if let encode = textEncode {
//                    if let url = NSURL.init(string: encode) {
//                        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
//                    }
//                }
//            }else{
//                print("Can't use navermaps://");
//            }
//
//
//
//        })
//
//        let  kakaoMapButton = UIAlertAction(title: "Kakao", style: .default , handler: { (action) -> Void in
//            //print("Delete button tapped")
//
//            if (UIApplication.shared.canOpenURL(URL(string:"daummaps://")!)) {
//                let title = self.address.text!;
//
//                let urlString = "daummaps://search?q=\(title)&p=\(latitude),\(longitude)";
//                let textEncode = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
//                if let encode = textEncode {
//                    if let url = NSURL.init(string: encode) {
//                        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
//                    }
//                }
//            }else{
//                print("Can't use daummaps://");
//            }
//
//
//
//        })
        
        
        
        
        
        
        let cancelButton = UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"), style: .cancel, handler: { (action) -> Void in
            //print("Cancel button tapped")
        })
        
        alertController.title = NSLocalizedString("another map", comment: "another map");
        alertController.addAction(appleMapButton)
        alertController.addAction(googleMapButton)
//        alertController.addAction(naverMapButton)
//        alertController.addAction(kakaoMapButton)
        alertController.addAction(cancelButton)
        
        //ipad 일때 위치 잡아주기
        if let popoverPresentationController = alertController.popoverPresentationController {
            
            //let globalPoint = self.mapView.superview?.convert(self.mapView.frame.origin, to: self.view)
            let globalPoint = point;
            let commentTextViewRect = CGRect(x: (globalPoint.x) , y: (globalPoint.y)  , width: 1, height: 1);
            
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = commentTextViewRect;
            //popoverPresentationController.permittedArrowDirections = .down
        }
        
        self.present(alertController, animated: true, completion: nil)
        
        
    
        
        
    }
    
    
    
    
    func draggedEdgeView(_ recognizer : UIScreenEdgePanGestureRecognizer){
        let translation = recognizer.translation(in: view);
        
        //print(translation);
        
        dismissView();
        
    }
    
    
    
    @objc func showMyPageTap(){
        self.performSegue(withIdentifier: "showMyPage", sender: self);
    }
    
    func commentNotLoginViewInit(){
        if globalLoginSesstion == -1{ //로그인이 안되어 있으면 뷰 활성화
            commentNotLoginView.isUserInteractionEnabled = true;
        }else{
            commentNotLoginView.isUserInteractionEnabled = false;
        }
    }
    
    
    var commentJson : [[String:Any]]!
    func commentLoad(scrollDownBool : Bool){
        
        commentJson = [[String:Any]]();
        
        
        let key : String = "nuri";
        let pin_type : String = self.pin_type;
        let pin_seq : String = String(self.pin_seq);
        let user_seq : String = String(UserDefaults.standard.object(forKey: "loginSesstion") as? Int ?? -1);
        
        let param : String = "key="+key+"&pin_type="+pin_type+"&pin_seq="+pin_seq+"&user_seq="+user_seq;
        
        
        Ajax.forecast(withUrl: AppDelegate.serverUrl + "/chulsago/comment_pin_select.php", withParam: param) { (results:[[String:Any]]) in
            
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
                    //let seq : String = String(describing: result["seq"]!)
                    
                    self.commentJson.append(result)
                    
                }
            }
            
            DispatchQueue.main.async() {
                
                
                self.tableView.reloadData();
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.tableView.reloadData();
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    if scrollDownBool {
                        self.scrollView.scrollToBottom();
                        
                        self.commentTextView.text = NSLocalizedString("input comment", comment: "input comment");
                        self.commentTextView.textColor = UIColor.lightGray;
                        self.commentTextView.isUserInteractionEnabled = true;
                        self.textViewEmpty = true;
                    
                        
                    }
                }
                
                
                
            }
            
            
        }//ajax
        
        
    }
    
    //로그인이 필요합니다
    @objc func loginAlert(){
        let alertController = UIAlertController(title: NSLocalizedString("alert", comment: "alert"), message: NSLocalizedString("need login", comment: "need login"), preferredStyle: .alert)
        
        let cancelButton = UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"), style: .default, handler: { (action) -> Void in
            //print("Ok button tapped")
        })
        let loginButton = UIAlertAction(title: NSLocalizedString("login", comment: "login"), style: .default, handler: { (action) -> Void in
            //print("Ok button tapped")
            self.performSegue(withIdentifier: "login", sender: self);
        })
        
        alertController.addAction(cancelButton)
        alertController.addAction(loginButton)
        
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    
    @objc func scrollViewTap(_ sender : MyTapGestureRecognizer){
        if key_check{
            commentTextView
                .resignFirstResponder();
        }
    }
    
    func addObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    func removeObservers()
    {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    //키보드 새로운 방법
    var key_check:Bool = false;
    @objc func keyboardWillShow(notification: NSNotification) {
        if key_check == false{
            adjustingHeight(true, notification: notification as Notification)
        }
    }
    
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if key_check == true{
            adjustingHeight(false, notification: notification as Notification)
        }
    }
    
    func adjustingHeight(_ show:Bool, notification:Notification) {
        
        let keyboardFrame: NSValue = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)!
        let keyboardRectangle = keyboardFrame.cgRectValue;
        let keyboardHeight = keyboardRectangle.height;
        
        
        if show{
            //self.editTextView.frame.origin.y -= changeInHeight;
            self.editTextBottomSpace.constant = keyboardHeight;
            
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: .curveEaseInOut,
                           animations: {
                            self.view.layoutIfNeeded()
            })
            
            
            
            
            self.scrollView.contentInset.bottom += keyboardHeight
            self.scrollView.scrollIndicatorInsets.bottom += keyboardHeight
            self.key_check = true;
        
        }else{
        
            //self.editTextView.frame.origin.y += changeInHeight;
            self.editTextBottomSpace.constant = 0;
            
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: .curveEaseInOut,
                           animations: {
                            self.view.layoutIfNeeded()
            })
            
            self.scrollView.contentInset.bottom -= keyboardHeight
            self.scrollView.scrollIndicatorInsets.bottom -= keyboardHeight
            self.key_check = false;
        
        }
        
    }
    
    
    
    func pressLikeButton(){
        
        let loginSesseion = UserDefaults.standard.object(forKey: "loginSesstion") as? Int ?? -1;
        
        if loginSesseion != -1{ //로그인이 되어있을때
            
        
            if likeAble { //좋아요 버튼 활성화
                
                //likeAble = false;
                
                    
                let key : String = "nuri";
                let user_seq : String = String(loginSesseion);
                let pin_type : String = self.pin_type;
                let pin_seq : String = String(self.pin_seq);
                let pin_user_seq : String = self.pin_user_seq;
                
                let param : String = "key="+key+"&user_seq="+user_seq+"&pin_type="+pin_type+"&pin_seq="+pin_seq+"&pin_user_seq="+pin_user_seq;
                
                
                Ajax.forecast(withUrl: AppDelegate.serverUrl + "/chulsago/like_pin.php", withParam: param) { (results:[[String:Any]]) in
                    
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
                            //print(status);
                            if status == "add"{
                                if self.showHeartBool{
                                    self.showHeart()
                                }
                            }
                            self.likeInit();
                        }
                    }
                    
                    //self.likeAble = true;
                    
                }//ajax
                
            }else{ //좋아요버튼 비활성화 상태
                
            }
            
        }else{//로그인이 안되어있을때
            loginAlert();
        }
        
    }
    
    
    func commentInit(){
        
        //댓글 상태 조회
        let key : String = "nuri";
        let pin_type : String = self.pin_type;
        let pin_seq : String = String(self.pin_seq);
        
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
                        if Int(count)! > 0 {
                            self.labelComment.text = NSLocalizedString("comment", comment: "comment") + " " + count + NSLocalizedString("gae", comment: "gae");
                        }else{
                            self.labelComment.text = "";
                        }
                    }
                }
            }
            
            
        }//ajax
        
    }
    
    
    
    func likeInit(){
        
        self.dismissViewBool = false;
        
        let loginSesseion = UserDefaults.standard.object(forKey: "loginSesstion") as? Int ?? -1;
        
        if loginSesseion != -1{ //로그인이 되어있을때
            
            //좋아요 상태 조회
            let key : String = "nuri";
            let user_seq : String = String(loginSesseion);
            let pin_type : String = self.pin_type;
            let pin_seq : String = String(self.pin_seq);
            
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
                        
                        self.likeCountInit();
                        
                        
                        if status == "ok" { //좋아요가 있을때
                            DispatchQueue.main.async() {
                                self.btnLike.setImage(UIImage(named: "btn_like_on"), for: .normal);
                            }
                            
                            self.likeBool = true;
                        }else{ //좋아요가 없을때
                            DispatchQueue.main.async() {
                                self.btnLike.setImage(UIImage(named: "btn_like"), for: .normal);
                            }
                            self.likeBool = false;
                        }
                        DispatchQueue.main.async() {
                            self.scrollView.scrollToTop_1(animated: false);
                        }
                        
                        
                    }
                }
                
                
            }//ajax
            
        }else{//로그인이 안되어있을때
            DispatchQueue.main.async() {
                self.dismissViewBool = true;
            }
        }
        
        
    }
    
    func likeCountInit(){
        let key : String = "nuri";
        let type : String = "one";
        let pin_type : String = self.pin_type;
        let pin_seq : String = String(self.pin_seq);
        
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
                    
                    
                    //print(image_url);
                    DispatchQueue.main.async() {
                        
                        if like != "0" {
                            self.labelLike.textColor = UIColor.darkText;
                            self.labelLike.text = NSLocalizedString("like", comment: "like") + " " + like + NSLocalizedString("gae", comment: "gae");
                            
                            let labelLikeTap = UITapGestureRecognizer(target: self, action:#selector(self.labelLikeTap))
                            self.labelLike.addGestureRecognizer(labelLikeTap);
                            
                        }else{
                            self.labelLike.textColor = UIColor.lightGray;
                            self.labelLike.text = NSLocalizedString("first press like", comment: "first press like");
                            
                            //제스쳐 제거
                            if let recognizers = self.labelLike.gestureRecognizers {
                                for recognizer in recognizers {
                                    self.labelLike.removeGestureRecognizer(recognizer as UIGestureRecognizer)
                                }
                            }
                        }
                        DispatchQueue.main.async() {
                            
                            self.dismissViewBool = true;
                        }
                        
                    }
                    
                    
                    
                    
                }
            }
            
        }//ajax
    }
    
    //라이크 눌렀을때
    @objc func labelLikeTap(){
        self.performSegue(withIdentifier: "showLikeViewList", sender: self);
    }
    
    @objc func doubleImageViewTap(_ sender : MyTapGestureRecognizer){
        if likeAble { //좋아요 버튼 활성화
            if self.likeBool == false{ //좋아요 없을때만 좋아요 추가
                pressLikeButton();
            }else{//좋아요 상태일때
                DispatchQueue.main.async() {
                    self.btnLike.setImage(UIImage(named: "btn_like"), for: .normal);
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.btnLike.setImage(UIImage(named: "btn_like_on"), for: .normal);

                }
                
                
            }
            
            if showHeartBool && globalLoginSesstion != -1{
                showHeart()
            }
            
            DispatchQueue.main.async() {
                self.scrollView.scrollToTop_1(animated: false);
            }
            
            
            
        }
        
        
    }
    
    func showHeart(){
        DispatchQueue.main.async() {
            self.showHeartBool = false;

            self.likeHeartView.isHidden = false;
            self.likeHeartView.alpha = 0;

            //그림자
            self.likeHeartView.layer.shadowColor = UIColor.black.cgColor
            self.likeHeartView.layer.shadowOpacity = 0.2
            self.likeHeartView.layer.shadowOffset = CGSize.zero
            self.likeHeartView.layer.shadowRadius = 10

            self.likeHeartView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)

            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping:0.5,
                initialSpringVelocity:3,
                options: .curveEaseInOut,
                animations: {
                    self.likeHeartView.transform = CGAffineTransform.identity;
                    self.likeHeartView.alpha = 1;

            }, completion: { (finished) -> Void in

                    UIView.animate(
                        withDuration: 0.1,
                        delay: 0.2,
                        options: .curveEaseInOut,
                        animations: {
                            self.likeHeartView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                            self.likeHeartView.alpha = 0;

                    }, completion: { (finished) -> Void in
                        self.likeHeartView.isHidden = true;
                        self.showHeartBool = true;
                    })

            })
        }

        
    }
    
    
    
    func menuInit(step : Int){
        if step == 1{
            if menuViewStep != 1{
                
                DispatchQueue.main.async() {
                    self.menuCheckInImageView.image = UIImage(named: "logo_skull_small_on");
                    self.menuInstarImageView.image = UIImage(named: "instar_off");
                    self.menuInstarListImageView.image = UIImage(named: "instar_list_off");
                }
                
                menuCheckInBottom.alpha = 0;
                menuInstarBottom.alpha = 1;
                menuInstarListBottom.alpha = 1;
                
                contentView.isHidden = false;
                instarView.isHidden = true;
                instarListView.isHidden = true;
                
                self.contentView.alpha = 1;
                self.instarView.alpha = 0;
                self.instarListView.alpha = 0;
                
                menuViewStep = 1;
                
                self.contentViewBottomSpace.isActive = true;
                self.instarViewBottomSpace.isActive = false;
                self.instarListViewBottomSpace.isActive = false;
                self.view.layoutIfNeeded();
                
                
                
                
                
            }
        }else if step == 2{
            
            if menuViewStep != 2{
                
                
                DispatchQueue.main.async() {
                    self.menuCheckInImageView.image = UIImage(named: "logo_skull_small_off");
                    self.menuInstarImageView.image = UIImage(named: "instar_on");
                    self.menuInstarListImageView.image = UIImage(named: "instar_list_off");
                }
                
                
                menuCheckInBottom.alpha = 1;
                menuInstarBottom.alpha = 0;
                menuInstarListBottom.alpha = 1;
                
                contentView.isHidden = true;
                instarView.isHidden = false;
                instarListView.isHidden = true;
                
                
                self.contentView.alpha = 0;
                self.instarView.alpha = 1;
                self.instarListView.alpha = 0;
                
                menuViewStep = 2;
                
                self.contentViewBottomSpace.isActive = false;
                self.instarViewBottomSpace.isActive = true;
                self.instarListViewBottomSpace.isActive = false;
                self.view.layoutIfNeeded();
                
            }
        }else if step == 3{
            
            if menuViewStep != 3{
                
                
                DispatchQueue.main.async() {
                    self.menuCheckInImageView.image = UIImage(named: "logo_skull_small_off");
                    self.menuInstarImageView.image = UIImage(named: "instar_off");
                    self.menuInstarListImageView.image = UIImage(named: "instar_list_on");
                }
                
                
                menuCheckInBottom.alpha = 1;
                menuInstarBottom.alpha = 1;
                menuInstarListBottom.alpha = 0;
                
                
                contentView.isHidden = true;
                instarView.isHidden = true;
                instarListView.isHidden = false;
                
                self.contentView.alpha = 0;
                self.instarView.alpha = 0;
                self.instarListView.alpha = 1;
                
                menuViewStep = 3;
                
                self.contentViewBottomSpace.isActive = false;
                self.instarViewBottomSpace.isActive = false;
                self.instarListViewBottomSpace.isActive = true;
                self.view.layoutIfNeeded();
            }
        }
    }
    
    @objc func menuViewTap(_ sender : MyTapGestureRecognizer){
        menuInit( step: sender.number!);
    }
    
    func getAjax(){
        let key : String = "nuri";
        let type : String = "one";
        let pin_type : String = self.pin_type;
        let pin_seq : String = String(self.pin_seq);
        
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
                    
                    DispatchQueue.main.async() {
                        
                        self.dismissViewBool = true;
                    }
                    
                }else{
                    //print(result["seq"]!)
                    let seq : String = String(describing: result["seq"]!)
                    self.pin_type = String(describing: result["type"]!)
                    self.pin_user_seq = String(describing: result["user_seq"]!)
                    let latitude : String = String(describing: result["latitude"]!)
                    let longitude : String = String(describing: result["longitude"]!)
                    let address : String = String(describing: result["address"]!)
                    let image_name : String = String(describing: result["image_name"]!)
                    let body : String = String(describing: result["body"]!)
                    let like : String = String(describing: result["like"]!)
                    let view_count : String = String(describing: result["view_count"]!)
                    let date_ : String = String(describing: result["date_"]!)
                    
                    
                    let image_url : String = AppDelegate.serverUrl + "/chulsago/upload/img/thumbnail/400_" + image_name;
                    let image_url2 : String = AppDelegate.serverUrl + "/chulsago/upload/img/thumbnail/800_" + image_name;
                    let latitude2 : Double = Double(latitude)!;
                    let longitude2 : Double = Double(longitude)!;
                    
                    
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
                        
                        //맵 초기화
                        self.mapInit(latitude: latitude2, longitude: longitude2);
                        
                        //소수점 반올림
                        let numberOfPlaces = 5.0
                        let multiplier = pow(10.0, numberOfPlaces)
                        
                        let myLatitudeShort = round(latitude2 * multiplier) / multiplier
                        let myLongitudeShort = round(longitude2 * multiplier) / multiplier
                        
                        self.nuriNavilatitude.text = NSLocalizedString("latitude", comment: "latitude") + ": \(myLatitudeShort)｜ " + NSLocalizedString("longitude", comment: "longitude") + ": \(myLongitudeShort)";
                        
                        //고화질 변경
                        if ( self.showType == "showListDetail" ){
                            if ( self.imageGaro == true )
                            {
                                self.imageView.downloadAndResizeImageFrom(image_url2, contentMode: .scaleAspectFill , newWidth: 800);
                                
                            }else{
                                self.imageView.downloadAndResizeImageFrom(image_url2, contentMode: .scaleAspectFit , newWidth: 800);
                            }
                            
                            
                        }
                        DispatchQueue.main.async() {
                            
                            self.dismissViewBool = true;
                        }
                        
//                        if image_name != nil{
//                            InfoClass.infoVC.imageView.downloadAndResizeImageFrom(image_url, contentMode: .scaleAspectFill , newWidth: 200)
//                            
//                            InfoClass.infoVC.imageView2.downloadAndResizeImageFrom(image_url2, contentMode: .scaleAspectFit , newWidth: 800)
//                            
//                            
//                        }
                        
                        self.viewCountLabel.text = view_count;
                        
                        if like != "0" {
                            self.labelLike.textColor = UIColor.darkText;
                            self.labelLike.text = NSLocalizedString("like", comment: "like") + " " + like + NSLocalizedString("gae", comment: "gae");
                        }else{
                            self.labelLike.textColor = UIColor.lightGray;
                            self.labelLike.text = NSLocalizedString("first press like", comment: "first press like");
                        }
                        self.profileInit(user_seq: self.pin_user_seq);
                        
                        if body == ""{
                            self.bodyLabel.text = " ";
                        }else{
                            self.bodyLabel.text = body;
                        }
                        
                        
                        if address == ""{
                            
                            self.address.text = " ";
                            self.nuriNaviAddress.text = NSLocalizedString("detail", comment: "detail");
                            
                        }else{
                            self.address.text = address;
                            self.nuriNaviAddress.text = address;
                        }
                        
                        self.dateLabel.text = newDate;
                        
                        
                        
                    }
                    
                    
                    
                }
            }
            
        }//ajax
        
        
        
        
    }
    
    func viewCountUp(pin_seq : String){
        let key : String = "nuri";
        let type : String = "view_count_up";
        let pin_type : String = self.pin_type;
        let pin_seq : String = pin_seq;
        
        let param : String = "key="+key+"&type="+type+"&pin_type="+pin_type+"&pin_seq="+pin_seq;
        
        
        Ajax.forecast(withUrl: AppDelegate.serverUrl + "/chulsago/pin_chulsa_view_count_up.php", withParam: param) { (results:[[String:Any]]) in
            
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
                    //let info : String = String(describing: result["info"]!)
                    //print(info)
                   
                    
                }
            }
            
        }//ajax
        
        
        
        
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
                    let seq : String = (result["seq"] as? String)!;
                    let name : String = (result["name"] as? String)!;
                    let point : String = (result["point"] as? String)!;
                    let thumbnail_image : String = (result["thumbnail_image"] as? String)!;
                    
                    let point2 : Int = Int(point)!;
                    
                    //레이아웃 바꿀때 충돌 방지
                    DispatchQueue.main.async() {
                        
                        //프로필 사진 추가
                        if thumbnail_image != ""{
                            self.profileImageView.contentMode = UIViewContentMode.scaleAspectFill
                            self.profileImageView.downloadAndResizeImageFrom(thumbnail_image, contentMode: .scaleAspectFill, newWidth: 200)
                        }else{
                            self.profileImageView.contentMode = UIViewContentMode.center
                            self.profileImageView.image = UIImage(named: "nonProfile");
                        }
                        
                        //프로필 텍스트 추가
                        if name != ""{
                            let profileText = name;
                            self.nickName.text = profileText;
                        }else{
                            let profileText = "NULL";
                            self.nickName.text = profileText;
                        }
                        
                        let showMyPageTap = MyTapGestureRecognizer(target: self, action:#selector(self.showMyPageTap))
                        self.nickName.addGestureRecognizer(showMyPageTap);
                        
                        
                        
                        //등급 가져오기
                        let rating: String = RatingClass.rating(point: point2) + " (P. " + String(point2) + ")";
                        self.rating.text = rating;
                        
                        
                        
                    }
                    
                    
                }
            }
        }//ajax
    }
    
    
    func mapInit(latitude: Double, longitude : Double){
        
        let currentLocation = CLLocation(latitude: latitude, longitude: longitude);
        
        //플레이스 마크 저장
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        self.selectedPlaceMark = MKPlacemark(coordinate: coordinates, addressDictionary: nil);
        
        
        
        //맵 이동
        mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude), span: MKCoordinateSpanMake(0.01, 0.01)), animated: true)
        
        DispatchQueue.main.async() {
            //핀 추가
            let locationPinCoord = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
            
            let annotation = CustomPointAnnotation()
            annotation.coordinate = locationPinCoord
            self.mapView.addAnnotation(annotation)
        }
        
    }
    
    func dismissView(){
        DispatchQueue.main.async() {
            
            if ( self.dismissViewBool == true) {
                
                if ( self.showType == "myPinView" )
                {
                    //infoLikeReload2
                    let noti3 = Notification.init(name : Notification.Name(rawValue: "infoLikeReload2"));
                    NotificationCenter.default.post(noti3);
                    
                }else if ( self.showType == "showListDetail" )
                {
                    //listLikeReload
                    let noti2 = Notification.init(name : Notification.Name(rawValue: "listLikeReload"));
                    NotificationCenter.default.post(noti2);
                }else{
                    //infoLikeReload
                    let noti = Notification.init(name : Notification.Name(rawValue: "infoLikeReload"));
                    NotificationCenter.default.post(noti);
                }
                
                self.navigationController?.popViewController(animated: true)
                //self.dismiss(animated: true, completion: nil)
            }
            
        }
        
    
    }
    
    
    
    
    func animation(){
        btnDismiss.alpha = 0;
        
        
        UIView.animate(withDuration: 0.2,
                       delay: 0.5,
                       options: .curveEaseOut ,
                       animations: {
                        self.btnDismiss.alpha = 1;
        })
        
        
        contentView.alpha = 0;
        menuView.alpha = 0;
        UIView.animate(withDuration: 0.2,
                       delay: 0.2,
                       options: .curveEaseOut,
                       animations: {
                        self.contentView.alpha = 1;
                        self.menuView.alpha = 1;
                        
        })
        
        
        
        
        var delayCounter = 3;
        
        let uiButtonArray : [UIButton] = [ btnLike, btnComment ]
        
        for uiButton in uiButtonArray{
            uiButton.alpha = 0;
            uiButton.transform = CGAffineTransform(translationX: 0, y: 20)
        }
        
        for uiButton in uiButtonArray{
            
            UIView.animate(withDuration: 0.2,delay: Double(delayCounter) * 0.05, options: .curveEaseOut, animations: {
                uiButton.alpha = 1;
                uiButton.transform = CGAffineTransform.identity;
            }, completion: nil)
            delayCounter += 1;
        }
        
        
        let uiImageViewArray : [UIImageView] = [ viewCountImageView ]
        
        for uiImageView in uiImageViewArray{
            uiImageView.alpha = 0;
            uiImageView.transform = CGAffineTransform(translationX: 0, y: 20)
        }
        
        for uiImageView in uiImageViewArray{
            
            UIView.animate(withDuration: 0.2,delay: Double(delayCounter) * 0.05, options: .curveEaseOut, animations: {
                uiImageView.alpha = 1;
                uiImageView.transform = CGAffineTransform.identity;
            }, completion: nil)
            delayCounter += 1;
        }
        
        
        
        
        
        
        
        
        let uiLabelArray : [UILabel] = [ viewCountLabel, labelLike, labelComment, infoBody, bodyLabel, infoProfile, fixedNickName, nickName, fixedRating, rating ]
        
        for uiLabel in uiLabelArray{
            uiLabel.alpha = 0;
            uiLabel.transform = CGAffineTransform(translationX: 0, y: 20)
        }
        
        var count : Int = 0;
        for uiLabel in uiLabelArray{
            count = count + 1;
            UIView.animate(withDuration: 0.2,delay: Double(delayCounter) * 0.05, options: .curveEaseOut, animations: {
                uiLabel.alpha = 1;
                uiLabel.transform = CGAffineTransform.identity;
            }, completion: nil)
            
            if count == 7 || count == 9{
                
            }else{
                delayCounter += 1;
            }
        }
        
        
        
        let uiViewArray : [UIView] = [ profileView ]
        
        for uiView in uiViewArray{
            uiView.alpha = 0;
            uiView.transform = CGAffineTransform(translationX: 0, y: 20)
        }
        
        for uiView in uiViewArray{
            UIView.animate(withDuration: 0.2,delay: Double(delayCounter) * 0.05, options: .curveEaseOut, animations: {
                uiView.alpha = 1;
                uiView.transform = CGAffineTransform.identity;
            }, completion: nil)
            delayCounter += 1;
        }
        
        
        
        
        
        let uiLabelArray2 : [UILabel] = [ infoCheckIn, fixedAddress, address, fixedDateLabel, dateLabel ]
        
        for uiLabel2 in uiLabelArray2{
            uiLabel2.alpha = 0;
            uiLabel2.transform = CGAffineTransform(translationX: 0, y: 20)
        }
        
        var count2 : Int = 0;
        for uiLabel2 in uiLabelArray2{
            count2 = count2 + 1;
            UIView.animate(withDuration: 0.2,delay: Double(delayCounter) * 0.05, options: .curveEaseOut, animations: {
                uiLabel2.alpha = 1;
                uiLabel2.transform = CGAffineTransform.identity;
            }, completion: nil)
            
            if count == 2 || count == 4 {
                
            }else{
                delayCounter += 1;
            }
        }
        
        
        
        let uiMkMapViewArray : [MKMapView] = [ mapView ]
        
        for uiMkMapView in uiMkMapViewArray{
            uiMkMapView.alpha = 0;
            uiMkMapView.transform = CGAffineTransform(translationX: 0, y: 20)
        }
        
        for uiMkMapView in uiMkMapViewArray{
            
            UIView.animate(withDuration: 0.2,delay: Double(delayCounter) * 0.05, options: .curveEaseOut, animations: {
                uiMkMapView.alpha = 1;
                uiMkMapView.transform = CGAffineTransform.identity;
            }, completion: nil)
            delayCounter += 1;
        }
        
        
        
        
        
        
        
    }
    
    var imageGaro : Bool = true;
    func imageSizeInit(){
        
        if let image2 = imageView.image {
            
            let ratio = image2.size.width / image2.size.height
            
            if image2.size.width >= image2.size.height { //가로
                //print("가로");
                self.imageGaro = true;
                
                //let newHeight = imageView.frame.width / ratio
                
                let newHeight = self.view.frame.width / ratio
                
                
                //imageView.frame.size = CGSize(width: imageView.frame.width, height: 600)
                imageView.contentMode = .scaleAspectFill
                
                imageViewHeight = newHeight;
                
                
                imageViewHeightConstraint.constant = newHeight;
                tempViewHeightConstraint.constant = newHeight;
                imageBlurViewHeightConstraints.constant = newHeight;
                
                
            }else{ // 세로
                //print("세로");
                self.imageGaro = false;

                imageView.contentMode = .scaleAspectFit
                
                //let newHeight = imageView.frame.width / ratio
                let newHeight = self.view.frame.width / ratio
                if newHeight >= 400 {
                    
                    imageViewHeightConstraint.constant = 400;
                    tempViewHeightConstraint.constant = 400;
                    imageBlurViewHeightConstraints.constant = 400;
                    
                    imageViewHeight = 400;
                    
                }else{
                    
                    imageViewHeightConstraint.constant = newHeight;
                    tempViewHeightConstraint.constant = newHeight;
                    imageBlurViewHeightConstraints.constant = newHeight;
                    
                    imageViewHeight = newHeight;
                }
                
                
                //blur image
                UIView.animate(withDuration: 0.3,
                               delay: 0.3,
                               options: .curveEaseInOut,
                               animations: {
                                self.imageBlurView.alpha = 1;
                                
                })
                
            }
            
            
            
            
        }
    }
    
    //MARK: - viewWillTrans
    
    //화면 크기 변경시
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: nil) { _ in
            self.imageSizeInit();
        }
        
    }
    
    
    
    //MARK: - scroll
    
    var scrollDismissBool : Bool = false;
    //스크롤 드래그 멈춘 시점
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let scrollOffsetY = scrollView.contentOffset.y;
        //print(scrollOffsetY);
        
        if scrollOffsetY <= -60 {
            dismissView()
            self.scrollDismissBool = true;
        }
    }
    
    //스크롤 픽셀구하기
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollOffsetY = self.scrollView.contentOffset.y;
        //print(scrollOffsetY);
        
        if scrollOffsetY <= 0 {
            
            let newHeight = imageViewHeight + ( -1 * scrollOffsetY );
            DispatchQueue.main.async() {
                self.imageView.frame.size.height = newHeight;
                self.imageBlurEffect.frame.size.height = newHeight;
            }
            
            
            //print(imageBlur.frame.height);
        }else{
            
        }
        
        //스크롤시 뒷배경 가리기
        if scrollOffsetY >= imageViewHeight + 100{
            imageView.alpha = 0.0;
            imageBlurEffect.alpha = 0.0;
            imageBlur.alpha = 0.0;
        }else{
            imageView.alpha = 1.0;
            imageBlurEffect.alpha = 1.0;
            imageBlur.alpha = 1.0;
        }
        
        //스크롤시 네비게이션바 나오기
        if scrollOffsetY >= 2{
            
            let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
            showNavi = true;
            self.nuriNavigationBar.isUserInteractionEnabled = true;
            
            UIView.animate(withDuration: 0.2,
                           delay: 0.3,
                           options: .curveEaseInOut,
                           animations: {
                            
                                statusBar.alpha = 1.0;
                            
                            
                            //self.btnDismiss.tintColor = UIColor(red: 0/255.0, green: 122/255.0, blue: 255/255.0, alpha: 1.0);
                            self.btnDismiss.tintColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0);
                            self.nuriNavigationBar.alpha = 1.0;
            })
            
            
            
        }else{
            
            let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
            showNavi = false;
            self.nuriNavigationBar.isUserInteractionEnabled = false;
            
            UIView.animate(withDuration: 0.2,
                           delay: 0.3,
                           options: .curveEaseInOut,
                           animations: {
                            
                            
                            if ( self.scrollDismissBool != true ){
                                statusBar.alpha = 0.0;
                            }
                            self.btnDismiss.tintColor = .white;
                            self.nuriNavigationBar.alpha = 0.0;
                            
            })
            
        }
        
    }
    
    
    @objc func cellProfileImageViewTap(recognizer : UITapGestureRecognizer){
        
        let view = recognizer.view;
        let user_seq : String = String(describing: (view?.tag)!);
        
        self.pin_user_seq_click = user_seq;
        self.performSegue(withIdentifier: "showMyPage_click", sender: self);
        
    }
    
    @objc func cellViewTap(recognizer : UILongPressGestureRecognizer){
        
        let view = recognizer.view;
        let user_seq : String = String(describing: (view?.tag)!);
        
        
        
    }
    
    
    //MARK: - Table
    
    //세션 갯수
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    
    //셀 갯수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if commentJson.count > 0{
            return commentJson.count;
        }else{
            return 1;
        }
        
        
        
    }
    
    //테이블 높이 자동조절을 위한 몸부림
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension;
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension;
    }
    
    //셀 연결
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let Cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentCell
        
        let index : Int = indexPath.row;
        
        if self.commentJson.count > 0{
            let result = self.commentJson[index];
            let seq : String = String(describing: result["seq"]!)
            let user_seq : String = String(describing: result["user_seq"]!)
            let user_name : String = String(describing: result["user_name"]!)
            let body : String = String(describing: result["body"]!)
            let user_thumbnail_image : String = String(describing: result["user_thumbnail_image"]!)
            let date_ : String = String(describing: result["date_"]!)
            
            
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
                
                Cell.profileLabel.isHidden = false;
                Cell.profileView.isHidden = false;
                Cell.commentDateLabel.isHidden = false;
                
                
                
                if user_thumbnail_image != ""{
                    Cell.profileImageView.contentMode = UIViewContentMode.scaleAspectFill;
                    //Cell.profileImageView.downloadAndResizeImageFrom(user_thumbnail_image, contentMode: .scaleAspectFill , newWidth: 200)
                    
                    Cell.profileImageView.sd_setImage(with: URL(string: user_thumbnail_image), placeholderImage: nil,options: [.continueInBackground, .progressiveDownload], completed: { (image, error, cacheType, imageURL) in
                        //print("뿡");
                    })
                    
                }else{
                    Cell.profileImageView.contentMode = UIViewContentMode.center;
                    Cell.profileImageView.image = UIImage(named: "nonProfileSmall");
                }
                
                Cell.profileImageView.tag = Int(user_seq)!;
                Cell.tag = Int(seq)!;
                Cell.profileLabel.text = user_name;
                Cell.commentLabel.text = body;
                Cell.commentDateLabel.text = newDate;
                
                
                
            }
            
            let cellProfileImageViewTap = MyTapGestureRecognizer(target: self, action:#selector(self.cellProfileImageViewTap(recognizer:)))
            Cell.profileImageView.addGestureRecognizer(cellProfileImageViewTap);
            
            let cellViewTap = UILongPressGestureRecognizer(target: self, action:#selector(self.cellViewTap(recognizer:)))
            Cell.addGestureRecognizer(cellViewTap);
            
            
            
            
        }else{//값이 존재하지 않을때
            Cell.profileLabel.isHidden = true;
            Cell.profileView.isHidden = true;
            Cell.commentDateLabel.isHidden = true;
            Cell.commentLabel.text = NSLocalizedString("first comment", comment: "first comment");
        }
        
        
        
        
        return Cell;
        
    }
    
    //셀이 다 끝났을때 did load
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //print(self.tableView.contentSize.height);
        
        //print(cell.contentView.frame.height);
        
        if  self.tableHeightConstraint.constant != self.tableView.contentSize.height {
            self.tableHeightConstraint.constant = self.tableView.contentSize.height;
        }
    }
    
    
    
    //테이블셀 에디팅 스타일
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        
        
        //자기자신만 삭제 가능
        let selectCell = tableView.cellForRow(at: indexPath)  as! CommentCell;
        let cellTag = selectCell.tag;
        let cellUserSeq = selectCell.profileImageView.tag;
        let loginSesstion = globalLoginSesstion;
        
        if ( cellUserSeq == loginSesstion || loginSesstion == 1){ //또는 관리자도 가능
            
            return UITableViewCellEditingStyle.delete
        }else{
            return UITableViewCellEditingStyle.none
        }
        
    }
    
    
    //테이블 셀 슬라이드창
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            
            
            //댓글 삭제
            let selectCell = tableView.cellForRow(at: indexPath)  as! CommentCell;
            let cellTag = selectCell.tag;
            let cellUserSeq = selectCell.profileImageView.tag;
            let loginSesstion = globalLoginSesstion;
            
            if ( cellUserSeq == loginSesstion || loginSesstion == 1){ //또는 관리자도 가능
                //댓글 삭제
                
                
                let alertController = UIAlertController(title: NSLocalizedString("delete comment", comment: "delete comment"), message: NSLocalizedString("delete?", comment: "delete?"), preferredStyle: .alert)
                
                
                let  deleteButton = UIAlertAction(title: NSLocalizedString("delete", comment: "delete"), style: .destructive, handler: { (action) -> Void in
                    
                    //댓글 삭제
                    Common.pinCommmentDelete(pin_seq: String(cellTag), pin_type: self.pin_type){ (result:String) in
                        
                        
                        if( result == "ok")
                        {
                            let alertController = UIAlertController(title: NSLocalizedString("delete success", comment: "delete success"), message: NSLocalizedString("delete comment success", comment: "delete comment success"), preferredStyle: .alert)
                            
                            let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .cancel , handler: { (action) -> Void in
                                //print("delete success");
                                
                                self.commentLoad(scrollDownBool: false);
                                
                                //self.dismiss(animated: true, completion: nil);
                            })
                            
                            alertController.addAction(okButton)
                            
                            self.present(alertController, animated: true, completion: nil)
                        }else{ //에러발생
                            
                            let alertController = UIAlertController(title: NSLocalizedString("waiting", comment: "waiting"), message: "\(result)", preferredStyle: .alert)
                            let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .cancel , handler: { (action) -> Void in
                            })
                            alertController.addAction(okButton)
                            self.present(alertController, animated: true, completion: nil)
                            
                            
                        }
                    }//delete
                    
                })
                
                let cancelButton = UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"), style: .cancel, handler: { (action) -> Void in
                    //print("Cancel button tapped")
                })
                
                
                alertController.addAction(deleteButton)
                alertController.addAction(cancelButton)
                
                self.present(alertController, animated: true, completion: nil)
                
                
            }else{
                
            }
            
        }
    }

    
    
    
    //MARK: - TextView
    
    func textViewDidChange(_ textView: UITextView) {
        
        //text view auto height
        let size = commentTextView.contentSize;
        if size.height <= 67{
            commentTextViewHeightConstraint.constant = size.height;
            editTextViewHeightConstraint.constant = commentTextViewHeightConstraint.constant + 16;
        }
        
        //빈값이거나 로그인이 안되어 있을때
        if commentTextView.text == "" || globalLoginSesstion == -1 {
            self.btnCommentSubmit.isEnabled = false;
        }else{
            self.btnCommentSubmit.isEnabled = true;
        }
        
    }
    
    
    var editingText : Bool = false;
    var textViewEmpty : Bool = true;
    //텍스트뷰 시작할때
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textViewEmpty {
            commentTextView.text = "";
            commentTextView.textColor = UIColor.black
        }
        
        
        
        let size = commentTextView.contentSize;
        if size.height >= 67{
            commentTextViewHeightConstraint.constant = 67;
            editTextViewHeightConstraint.constant = commentTextViewHeightConstraint.constant + 16;
        }else{
            commentTextViewHeightConstraint.constant = size.height;
            editTextViewHeightConstraint.constant = commentTextViewHeightConstraint.constant + 16;
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if commentTextView.text == "" {
            textViewEmpty = true;
            commentTextView.text = NSLocalizedString("input comment", comment: "input comment")
            commentTextView.textColor = UIColor.lightGray
        }else{
            textViewEmpty = false;
        }
        
        commentTextViewHeightConstraint.constant = 33;
        editTextViewHeightConstraint.constant = commentTextViewHeightConstraint.constant + 16;
        
    }
    
    
    
    
    

    
    
}



class MyTapGestureRecognizer: UITapGestureRecognizer {
    var number: Int?
}






