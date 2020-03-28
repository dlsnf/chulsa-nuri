//
//  addPinMapViewController.swift
//  ChulsaGo
//
//  Created by Nu-Ri Lee on 2017. 6. 18..
//  Copyright © 2017년 nuri lee. All rights reserved.
//

import UIKit
import MapKit

//search map
protocol HandleMapSearchAddPin: class {
    func dropPinZoomIn(_ placemark:MKPlacemark)
}


class addPinMapViewController : UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, URLSessionDelegate, URLSessionTaskDelegate , URLSessionDataDelegate, UISearchBarDelegate {
    
    
    //map search
    var selectedPin: MKPlacemark?
    var resultSearchController: UISearchController!
    
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var myLocationView: UIView!
    
    @IBOutlet weak var myLocationImage: UIImageView!
    
    @IBOutlet weak var locationLabelView: UIView!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var pinHere: UIImageView!
    
    @IBOutlet weak var mapViewConstraintBottom: NSLayoutConstraint!
    
    @IBOutlet weak var step2View: UIView!
    @IBOutlet weak var step2AddressView: UIView!
    @IBOutlet weak var step2Address: UILabel!
    @IBOutlet weak var step2InfoAddress: UILabel!
    
    @IBOutlet weak var step2SelectImageView: UIView!
    
    @IBOutlet weak var step2InfoSelectImage: UILabel!
    @IBOutlet weak var step2SelectImage: UIImageView!
    @IBOutlet weak var step2ImageCancel: RoundButton!
    @IBOutlet weak var step2TextView: UITextView!
    @IBOutlet weak var step2BlackBlur: UIVisualEffectView!
    
    @IBOutlet weak var step2SelectImageBtn: UIButton!
    
    @IBOutlet weak var step2BorderBottom1: UIView!
    @IBOutlet weak var step2BorderBottom2: UIView!
    
    @IBOutlet weak var uploadEffectView: UIVisualEffectView!
    @IBOutlet weak var uploadPregressView: UIProgressView!
    @IBOutlet weak var uploadPregressLabel: UILabel!
    
    @IBOutlet weak var btnSearch: UIView!
    
    @IBAction func step2SelectImagBtnClick(_ sender: Any) {
        //사진 고르기
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(myPickerController, animated: true, completion: nil)
        
    }
    
    @IBAction func step2ImageCancelBtn(_ sender: Any) {
        step2SelectImage.image = nil;
        btnImageCancel();
    }
    
    var coreLocationManger = CLLocationManager()
    var locationManager2 : LocationManager!
    
    var myLocationBool : Bool = false;
    
    
    var GlobalMyLatitude : Double!
    var GlobalMyLongitude : Double!
    
    
    var GlobalStep : Int!
    
    var editingText : Bool = false;
    
    var step2ImageBool : Bool = false;
    
    var textViewEmpty : Bool = true;
    
    var pin_type = String();
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        
        
        resultSearchController = ({
            // 1
            
            let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable_2") as! LocationSearchTable_2
            let controller = UISearchController(searchResultsController: locationSearchTable)
            controller.searchResultsUpdater = locationSearchTable
            
            controller.hidesNavigationBarDuringPresentation = false
            controller.dimsBackgroundDuringPresentation = true
            definesPresentationContext = true
            
            controller.searchBar.tag = 0;
            
            locationSearchTable.mapView = self.mapView
            
            locationSearchTable.handleMapSearchDelegate = self;
            
            
            //클릭시 배경 색상
            controller.searchBar.barTintColor = UIColor.lightText;
            
            
            
            
            //텍스트필드 창
            let textFieldInsideSearchBar = controller.searchBar.value(forKey: "searchField") as? UITextField
            
            //placeholder 라벨
            let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
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
        //검색창 작동시 네비게이션바 숨기기
        resultSearchController.hidesNavigationBarDuringPresentation = true;
        
        
        
        //step
        GlobalStep = 1;
        
        uploadEffectView.isHidden = true;
        
        //navigation item
        step();
        
        
        self.step2BlackBlur.isHidden = true;
        self.step2BlackBlur.alpha = 0;
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
            
        step2TextView.delegate = self
        step2TextView.text = NSLocalizedString("input body", comment: "input body")
        step2TextView.textColor = UIColor.lightGray
        
        
        
        //그림자
        locationLabelView.layer.cornerRadius = 4
        locationLabelView.clipsToBounds = false
        
        locationLabelView.layer.shadowColor = UIColor.black.cgColor
        locationLabelView.layer.shadowOpacity = 0.15
        locationLabelView.layer.shadowOffset = CGSize.zero
        locationLabelView.layer.shadowRadius = 2.5
        
        
        //탭 제스쳐 추가
        let myLocationTap = UITapGestureRecognizer(target: self, action:#selector(self.myLocationToggle))
        myLocationView.addGestureRecognizer(myLocationTap)
        
        let blackBlurTap = UITapGestureRecognizer(target: self, action:#selector(self.blackBlurTap))
        step2BlackBlur.addGestureRecognizer(blackBlurTap)
        
        let btnSearchViewTap = UITapGestureRecognizer(target: self, action:#selector(self.btnSearchPress))
        self.btnSearch.addGestureRecognizer(btnSearchViewTap)
        
        
        
        myLocation();
        
    }
    
    
    
    @objc func btnSearchPress(){
        present(resultSearchController, animated: true, completion: nil)
    }
    
    
    
    //이미지 피커
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        step2SelectImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        self.dismiss(animated: true, completion: nil)
        
        btnImageCancel();
        
        
        
    }
    
    
    //이미지 업로드
    func myImageUploadRequest()
    {
        
        
        let myUrl = NSURL(string: AppDelegate.serverUrl + "/chulsago/upload_img.php");
        
        let request = NSMutableURLRequest(url:myUrl! as URL);
        request.httpMethod = "POST";
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let loginSesseion = UserDefaults.standard.object(forKey: "loginSesstion") as? Int ?? -1;
        
        let key : String = "nuri";
        let pin_type : String = self.pin_type;
        let seq : String = String(loginSesseion);
        var body : String = String(step2TextView.text);

        if textViewEmpty { //텍스트창이 비어있을때
            body = "";
        }
        let latitude : String = String(GlobalMyLatitude);
        let longitude : String = String(GlobalMyLongitude);
        let address : String = self.step2Address.text!;
        
        let param = [
            "key"   : key,
            "pin_type" : pin_type,
            "seq" : seq,
            "latitude" : latitude,
            "longitude" : longitude,
            "address" : address,
            "body" : body
        ]
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        
        let imageData = UIImageJPEGRepresentation(step2SelectImage.image!, 1)
        
        if(imageData==nil)  { return; }
        
        request.httpBody = createBodyWithParameters(parameters: param, filePathKey: "file", imageDataKey: imageData! as NSData, boundary: boundary) as Data
        
//        myActivityIndicator.isHidden = false;
//        myActivityIndicator.startAnimating();
//        uploadPregressView.progress = 0;
//        uploadLabel.text = "0 %";
        
        
        var session:URLSession?
        let configuration = URLSessionConfiguration.default
        let manqueue = OperationQueue.main
        session = URLSession(configuration: configuration, delegate:self, delegateQueue: manqueue)
        
        
        let task = session?.dataTask(with: request as URLRequest ){
            //let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil {
                print("error=\(String(describing: error))")
                return
            }
            
            // You can print out response object
            //print("******* response = \(String(describing: response!))")
            
            
            
            let json : Any?
            
            do{
                json = try JSONSerialization.jsonObject(with: data!, options: [])
                
                //성공
                if let array = json as? [[String:Any]] {
                    for result in array{
                        
                        print("****** response data = ");
                        print(result["seq"]!)
                        print(result["body"]!)
                        print(result["status"]!)
                    }
                    
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        UserDefaults.standard.set(self.GlobalMyLatitude, forKey: "latitude");
                        UserDefaults.standard.set(self.GlobalMyLongitude, forKey: "longitude");
                        
                        let noti = Notification.init(name : Notification.Name(rawValue: "mapViewMove"));
                        NotificationCenter.default.post(noti);
                    }
                    
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        let noti2 = Notification.init(name : Notification.Name(rawValue: "pinInit"));
                        NotificationCenter.default.post(noti2);
                    }
                    
                    self.presentingViewController?.dismiss(animated: true);
                    
                }
                
                
                // Print out reponse body
//                let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
//                print("****** response data = \(responseString!)")
                
            }catch{
                //print("Error: \(error)")
                //print(String(data: data!, encoding: .utf8)!);
                
                let array: [[String: Any]] = [
                    ["error": String(data: data!, encoding: .utf8)!]
                ]
                print(array[0]["error"]!)
                let alertController = UIAlertController(title: NSLocalizedString("waiting", comment: "waiting"), message: "\(String(describing: array[0]["error"]!))", preferredStyle: .alert)
                
                let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .cancel , handler: { (action) -> Void in
                })
                
                alertController.addAction(okButton)
                
                
                self.present(alertController, animated: true, completion: nil)
                
                DispatchQueue.main.async() {
                    
                    self.GlobalStep = 1;
                    let backButton = UIBarButtonItem(title: NSLocalizedString("cancel", comment: "cancel"), style: .plain, target: self, action: #selector(self.btnBack))
                    self.navigationItem.leftBarButtonItem = backButton
                    
                    let nextButton = UIBarButtonItem(title: "", style: .plain, target: self, action:nil)
                    self.navigationItem.rightBarButtonItem = nextButton
                    
//                    self.myActivityIndicator.isHidden = true;
//                    self.myActivityIndicator.stopAnimating();
                    
                }
            }
            
            
            
            
            
        }
        
        task?.resume()
    }
    
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString(string: "--\(boundary)\r\n")
                body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString(string: "\(value)\r\n")
            }
        }
        
        let filename = "user-profile.jpg"
        let mimetype = "image/jpg"
        
        body.appendString(string: "--\(boundary)\r\n")
        body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey as Data)
        body.appendString(string: "\r\n")
        
        
        
        body.appendString(string: "--\(boundary)--\r\n")
        
        return body
    }
    
    
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    
    
    
    
    
    
    
    //key board
    @objc func blackBlurTap(){
        if editingText {
            step2TextView.resignFirstResponder();
        }
    }
    
    @objc func textViewDone(){
        step2TextView.resignFirstResponder();
    }
    
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        editingText = true;
        
        self.navigationItem.title = NSLocalizedString("explanation", comment: "explanation");
        self.step2BlackBlur.isHidden = false;
        
        DispatchQueue.main.async() {
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping:2,
                           initialSpringVelocity:0,
                           options: .curveEaseInOut,
                           animations: {
                            self.step2BlackBlur.alpha = 0.7;
                            
                            
            }, completion: { (finished) -> Void in
                //print("end");
            })
        }
        
        
        
        let backButton = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationItem.leftBarButtonItem = backButton
        
        let nextButton = UIBarButtonItem(title: NSLocalizedString("done", comment: "done"), style: .plain, target: self, action: #selector(textViewDone))
        navigationItem.rightBarButtonItem = nextButton
        
        
        
        if step2TextView.textColor == UIColor.lightGray {
            step2TextView.text = ""
            step2TextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        
        
        self.navigationItem.title = NSLocalizedString("select image", comment: "select image");
        DispatchQueue.main.async() {
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping:2,
                           initialSpringVelocity:0,
                           options: .curveEaseInOut,
                           animations: {
                            self.step2BlackBlur.alpha = 0;
                            
                            
            }, completion: { (finished) -> Void in
                //print("end");
                self.step2BlackBlur.isHidden = true;
                self.editingText = false;
            })
        }
        
        
        let image = UIImage(named: "btn_back");
        let backButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(btnBack))
        navigationItem.leftBarButtonItem = backButton
        
        let nextButton = UIBarButtonItem(title: NSLocalizedString("comfirm", comment: "comfirm"), style: .plain, target: self, action: #selector(btnNext))
        navigationItem.rightBarButtonItem = nextButton
        
        
        if step2TextView.text == "" {
            textViewEmpty = true;
            step2TextView.text = NSLocalizedString("input body", comment: "input body")
            step2TextView.textColor = UIColor.lightGray
        }else{
            textViewEmpty = false;
        }
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            if view.frame.origin.y == 0{
                if UIDevice.current.userInterfaceIdiom == .phone{
                    //폰일때만 뷰 위로 올리기
                    self.view.frame.origin.y -= keyboardSize.height/2
                }
                
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y != 0{
                //뷰 아래로 내리기
                self.view.frame.origin.y = 0
                
            }
        }
    }
    
    
    
    
    
    
    
    func shortMap(){
        
        let center = mapView.centerCoordinate;
        GlobalMyLatitude = Double(center.latitude);
        GlobalMyLongitude = Double(center.longitude);
        
        
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
        
        
        
        mapView.isUserInteractionEnabled = false;
        
        

        
        DispatchQueue.main.async() {
            self.mapViewConstraintBottom.isActive = false;
            self.mapView.heightAnchor.constraint(equalToConstant: 140).isActive = true;
            
            
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping:2,
                           initialSpringVelocity:0,
                           options: .curveEaseInOut,
                           animations: {
                            
                            //self.mapView.frame.size.height = 140;
                            
                            self.view.layoutIfNeeded()
                            
                            self.locationLabelView.alpha = 0;
                            self.myLocationView.alpha = 0;
                            self.btnSearch.alpha = 0;
                            
                            
                            
            }, completion: { (finished) -> Void in
                //print("end");
                self.locationLabelView.isHidden = true;
                self.myLocationView.isHidden = true;
                self.btnSearch.isHidden = true;
                
            })
        }
    }
    
    func longMap(){
        
        mapView.isUserInteractionEnabled = true;
        locationLabelView.isHidden = false;
        myLocationView.isHidden = false;
        self.btnSearch.isHidden = false;
        
        DispatchQueue.main.async() {
            self.mapView.heightAnchor.constraint(equalToConstant: 140).isActive = false;
            self.mapViewConstraintBottom.isActive = true;
            
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping:2,
                           initialSpringVelocity:0,
                           options: .curveEaseInOut,
                           animations: {
                            
                            self.view.layoutIfNeeded()
                            
                            
                            self.locationLabelView.alpha = 1;
                            self.myLocationView.alpha = 1;
                            self.btnSearch.alpha = 1;
                            
                            
                            
            }, completion: { (finished) -> Void in
                //print("end");
                
            })
        }
        
    }
    
    
    func step(){
        //네비게이션 타이틀 애니메이션
        let transition = CATransition()
        transition.duration = 0.2
        transition.type = kCATransitionFade
        navigationController?.navigationBar.layer.add(transition, forKey: "fadeText")
        
        switch (GlobalStep){
        case 1 :
            
            navigationItem.title = NSLocalizedString(self.pin_type, comment: "pin_type") + " " + NSLocalizedString("checkin", comment: "checkin");
            
            let backButton = UIBarButtonItem(title: NSLocalizedString("cancel", comment: "cancel"), style: .plain, target: self, action: #selector(btnBack))
            navigationItem.leftBarButtonItem = backButton
            
            let nextButton = UIBarButtonItem(title: NSLocalizedString("next", comment: "next"), style: .plain, target: self, action: #selector(btnNext))
            navigationItem.rightBarButtonItem = nextButton
            
            step2View.isHidden = true;
            
        break;
        case 2 :
            navigationItem.title = NSLocalizedString("select image", comment: "select image");
            
            let image = UIImage(named: "btn_back");
            let backButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(btnBack))
            navigationItem.leftBarButtonItem = backButton
            
            let nextButton = UIBarButtonItem(title: NSLocalizedString("comfirm", comment: "comfirm"), style: .plain, target: self, action: #selector(btnNext))
            navigationItem.rightBarButtonItem = nextButton
            
            
            
            let myLocation = CLLocation(latitude: GlobalMyLatitude, longitude: GlobalMyLongitude);
            
            //지도상의 정보 가져오기
            locationManager2.reverseGeocodeLocationWithCoordinates(myLocation, onReverseGeocodingCompletionHandler: { (reverseGecodeInfo, placemark, error) -> Void in
                
                if error != nil {
                    
                    //print("nil");
                    
                }else{
                    let address = reverseGecodeInfo?.object(forKey: "formattedAddress") as? String ?? "null";
                    self.step2Address.text = address;
                    //print("not nil");
                }
                
            })
            
            step2View.isHidden = false;
            step2View.alpha = 0;
            
            UIView.animate(withDuration: 0.2,delay: 0, options: .curveEaseInOut, animations: {
                self.step2View.alpha = 1;
            }, completion: nil)
            
            
            
            var delayCounter = 1;
            
            step2BorderBottom1.alpha = 0;
            step2BorderBottom2.alpha = 0;
            
            step2AddressView.backgroundColor = UIColor.clear
            step2SelectImageView.backgroundColor = UIColor.clear
            
            UIView.animate(withDuration: 0.5,delay: 0.2, options: .curveEaseInOut, animations: {
                self.step2AddressView.backgroundColor = UIColor.white
                self.step2SelectImageView.backgroundColor = UIColor.white
                self.step2BorderBottom1.alpha = 1;
                self.step2BorderBottom2.alpha = 1;
            }, completion: nil)
            
            
            
            //밑에서 위쪽으로 나오는 애니메이션
            let uiLabelArray : [UILabel] = [ step2InfoAddress, step2Address, step2InfoSelectImage ];
            
            for uiLabel in uiLabelArray{
                uiLabel.alpha = 0;
                uiLabel.transform = CGAffineTransform(translationX: 0, y: 20)
            }
            
            for uiLabel in uiLabelArray{
                //print(cell.text);
                
                UIView.animate(withDuration: 0.2,delay: Double(delayCounter) * 0.05, options: .curveEaseInOut, animations: {
                    uiLabel.alpha = 1;
                    uiLabel.transform = CGAffineTransform.identity;
                }, completion: nil)
                delayCounter += 1;
            }
            
            let uiImageViewArray : [UIImageView] = [ step2SelectImage ];
            
            for uiImageView in uiImageViewArray{
                uiImageView.alpha = 0;
                uiImageView.transform = CGAffineTransform(translationX: 0, y: 20)
            }
            
            step2SelectImageBtn.alpha = 0;
            step2SelectImageBtn.transform = CGAffineTransform(translationX: 0, y: 20)
            
            step2ImageCancel.alpha = 0;
            step2ImageCancel.transform = CGAffineTransform(translationX: 0, y: 20)
            
            for uiImageView in uiImageViewArray{
                //print(cell.text);
                
                UIView.animate(withDuration: 0.2,delay: Double(delayCounter) * 0.05, options: .curveEaseInOut, animations: {
                    uiImageView.alpha = 1;
                    uiImageView.transform = CGAffineTransform.identity;
                    
                    self.step2SelectImageBtn.alpha = 1;
                    self.step2SelectImageBtn.transform = CGAffineTransform.identity;
                    self.step2ImageCancel.alpha = 1;
                    self.step2ImageCancel.transform = CGAffineTransform.identity;
                }, completion: nil)
                delayCounter += 1;
            }
            
            
            
            
            
            let uiTextViewArray : [UITextView] = [ step2TextView ];
            
            for uiTextView in uiTextViewArray{
                uiTextView.alpha = 0;
                //uiTextView.transform = CGAffineTransform(translationX: 0, y: 20)
            }
            
            for uiTextView in uiTextViewArray{
                //print(cell.text);
                
                UIView.animate(withDuration: 0.5,delay: Double(delayCounter) * 0.05, options: .curveEaseInOut, animations: {
                    uiTextView.alpha = 1;
                    //uiTextView.transform = CGAffineTransform.identity;
                }, completion: nil)
                delayCounter += 1;
            }
            
            btnImageCancel();
            
            
            break;
        default :
            break;
        }
    }
    
    func btnImageCancel(){
        
        if step2SelectImage.image != nil {
            step2ImageCancel.isHidden = false;
            step2SelectImageBtn.isHidden = true;
        }else{
            step2ImageCancel.isHidden = true;
            step2SelectImageBtn.isHidden = false;
        }
    }
    
    @objc func btnBack() {
        switch (GlobalStep){
        case 1 :
            outAddPin();
            break;
        case 2 :
            GlobalStep = 1;
            longMap();
            step();
            break;
        default :
            break;
        }
        
    }
    
    
    @objc func btnNext() {
        switch (GlobalStep){
        case 1 :
            GlobalStep = 2;
            shortMap();
            step();
            break;
        case 2 : //submit
            
            if step2SelectImage.image != nil{
                
                //네비게이션 타이틀 애니메이션
                let transition = CATransition()
                transition.duration = 0.2
                transition.type = kCATransitionFade
                navigationController?.navigationBar.layer.add(transition, forKey: "fadeText")
                
                navigationItem.title = NSLocalizedString("upload...", comment: "upload...");
                    
                let backButton = UIBarButtonItem(title: "", style: .plain, target: self, action:nil)
                navigationItem.leftBarButtonItem = backButton
                
                let nextButton = UIBarButtonItem(title: "", style: .plain, target: self, action:nil)
                navigationItem.rightBarButtonItem = nextButton
                
                myImageUploadRequest();
                
                uploadEffectView.isHidden = false;
                UIView.animate(withDuration: 0.3,delay: 0,usingSpringWithDamping:0.8, initialSpringVelocity:0, options: .curveEaseInOut, animations: {
                    self.uploadEffectView.alpha = 1;
                }, completion: nil)
                
                
                
                
            }else{
                //print("nil");
                let alertController = UIAlertController(title: NSLocalizedString("alert", comment: "alert"), message: NSLocalizedString("select image.", comment: "select image."), preferredStyle: .alert)
                
                let Button = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .default , handler: { (action) -> Void in
                    
                })
                
                alertController.addAction(Button)
                
                
                self.present(alertController, animated: true, completion: nil)
            }
            
            break;
        default :
            break;
        }
    }
    
    
    func outAddPin(){
        let alertController = UIAlertController(title: NSLocalizedString("alert", comment: "alert"), message: NSLocalizedString("cancel checkin", comment: "cancel checkin"), preferredStyle: .alert)
        
        let cancelButton = UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"), style: .cancel, handler: { (action) -> Void in
            //print("Ok button tapped")
        })
        let outButton = UIAlertAction(title: NSLocalizedString("exit", comment: "exit"), style: .destructive, handler: { (action) -> Void in
            self.presentingViewController?.dismiss(animated: true);
        })
        
        alertController.addAction(cancelButton)
        alertController.addAction(outButton)
        
        
        self.present(alertController, animated: true, completion: nil)
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
                let alertController = UIAlertController(title: NSLocalizedString("not user location", comment: "not user location"), message: NSLocalizedString("not find user location", comment: "not find user location"), preferredStyle: .alert)
                let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .cancel , handler: { (action) -> Void in
                })
                
                alertController.addAction(okButton)
                self.present(alertController, animated: true, completion: nil)
            }
            
            
        }else{
            print("자기 위치 설정 안됨");
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
    
    
    
    //mapView
    
    //트래킹모드가 바뀔때
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        if myLocationBool{
            myLocationToggle()
        }
    }
    
    
    //지도 움직이기 전
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        if GlobalStep == 1 {
            self.navigationItem.rightBarButtonItem?.isEnabled = false;
        }
    }
    
    //지도 움직임 멈췄을때 정중앙 좌표 구하기
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if GlobalStep == 1 {
            let center = mapView.centerCoordinate
            
            //위도 경도 출력 좌표
            //let location = CLLocation(latitude: center.latitude, longitude: center.longitude)
            let myLatitude = Double(center.latitude);
            let myLongitude = Double(center.longitude);
    //        print(myLatitude);
    //        print(myLongitude);
            
            
            //소수점 반올림
            let numberOfPlaces = 5.0
            let multiplier = pow(10.0, numberOfPlaces)
            
            let myLatitudeShort = round(myLatitude * multiplier) / multiplier
            let myLongitudeShort = round(myLongitude * multiplier) / multiplier
            
            
            locationLabel.text = NSLocalizedString("latitude", comment: "latitude") + ": \(myLatitudeShort)     " + NSLocalizedString("longitude", comment: "longitude") + ": \(myLongitudeShort)";
            self.navigationItem.rightBarButtonItem?.isEnabled = true;
        }
        
        
    }
    
    
    
    
    // urlSesstion
    
    // urlSesstion Error
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
    {
        let myAlert = UIAlertView(title: "Alert", message: error?.localizedDescription, delegate: nil, cancelButtonTitle: "Ok")
        myAlert.show()
    }
    
    
    // urlSesstion Error
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64)
    {
        
        //print("didSendBodyData")
        let uploadProgress:Float = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        uploadPregressView.progress = uploadProgress
        let progressPercent = Int(uploadProgress*100)
        uploadPregressLabel.text = String(progressPercent) + " %";
        //print(uploadProgress)
        
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        print("didReceiveResponse")
        print(response);
    }
    
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        print("didReceiveData")
    }
    
    
    

    
}




//search map
extension addPinMapViewController: HandleMapSearchAddPin {
    
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

