//
//  RegisterorloginViewController.swift
//  BuddyApp
//
//  Created by Ti Technologies on 19/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class RegisterorloginViewController: UIViewController,UIScrollViewDelegate{
    
    @IBOutlet weak var pagecontrole: UIPageControl!
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var viewone: UIView!
    @IBOutlet weak var registr_btn: UIButton!
    @IBOutlet weak var login_btn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if userDefaults.value(forKey: "devicetoken") != nil
        {
            appDelegate.DeviceToken = userDefaults.value(forKey: "devicetoken") as! String
            
            print("TOKEN 1",appDelegate.DeviceToken)
            
        }
        else{
            appDelegate.DeviceToken = "1234567890"
        }

       
        
        login_btn.layer.cornerRadius = 5
        login_btn.layer.borderColor = UIColor.darkGray.cgColor
        login_btn.layer.borderWidth = 2
        login_btn.clipsToBounds = true
        
        registr_btn.layer.cornerRadius = 5
        registr_btn.clipsToBounds = true
        
        //1
        self.scrollview.frame = CGRect(x:0, y:0, width:self.viewone.frame.width, height:self.viewone.frame.height)
        let scrollViewWidth:CGFloat = self.scrollview.frame.width
        let scrollViewHeight:CGFloat = self.scrollview.frame.height
        //2
        //        textView.textAlignment = .center
        //        textView.text = "Sweettutos.com is your blog of choice for Mobile tutorials"
        //        textView.textColor = .black
        //        self.startButton.layer.cornerRadius = 4.0
        //3
        let imgOne = UIImageView(frame: CGRect(x:0, y:0,width:scrollViewWidth, height:scrollViewHeight))
        imgOne.image = UIImage(named: "Splash_Screen")
        let imgTwo = UIImageView(frame: CGRect(x:scrollViewWidth, y:0,width:scrollViewWidth, height:scrollViewHeight))
        imgTwo.image = UIImage(named: "Splash_Screen")
        let imgThree = UIImageView(frame: CGRect(x:scrollViewWidth*2, y:0,width:scrollViewWidth, height:scrollViewHeight))
        imgThree.image = UIImage(named: "Splash_Screen")
        let imgFour = UIImageView(frame: CGRect(x:scrollViewWidth*3, y:0,width:scrollViewWidth, height:scrollViewHeight))
        imgFour.image = UIImage(named: "Splash_Screen")
        
        self.scrollview.addSubview(imgOne)
        self.scrollview.addSubview(imgTwo)
        self.scrollview.addSubview(imgThree)
        self.scrollview.addSubview(imgFour)
        self.viewone.addSubview(self.scrollview)
        //4
        self.scrollview.contentSize = CGSize(width:self.scrollview.frame.width * 4, height:self.scrollview.frame.height)
        self.scrollview.delegate = self
        self.pagecontrole.currentPage = 0
        
        
        
        
        
        
    }
    func moveToNextPage (){
        
        let pageWidth:CGFloat = self.scrollview.frame.width
        let maxWidth:CGFloat = pageWidth * 4
        let contentOffset:CGFloat = self.scrollview.contentOffset.x
        
        var slideToX = contentOffset + pageWidth
        
        if  contentOffset + pageWidth == maxWidth{
            slideToX = 0
        }
        self.scrollview.scrollRectToVisible(CGRect(x:slideToX, y:0, width:pageWidth, height:self.scrollview.frame.height), animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UIScrollView Delegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        // Test the offset and calculate the current page after scrolling ends
        let pageWidth:CGFloat = scrollView.frame.width
        let currentPage:CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1
        // Change the indicator
        self.pagecontrole.currentPage = Int(currentPage);
        // Change the text accordingly
        if Int(currentPage) == 0{
           // textView.text = "Sweettutos.com is your blog of choice for Mobile tutorials"
        }else if Int(currentPage) == 1{
           // textView.text = "I write mobile tutorials mainly targeting iOS"
        }else if Int(currentPage) == 2{
          //  textView.text = "And sometimes I write games tutorials about Unity"
        }else{
           // textView.text = "Keep visiting sweettutos.com for new coming tutorials, and don't forget to subscribe to be notified by email :)"
            // Show the "Let's Start" button in the last slide (with a fade in animation)
            UIView.animate(withDuration: 1.0, animations: { () -> Void in
               // self.startButton.alpha = 1.0
            })
        }
    }
  
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) { }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let controller = segue.destination as! RegisterChoiceViewController

        if segue.identifier == "register" {
            controller.choice = "register"
        }else{
            controller.choice = "login"
        }
    }
}
