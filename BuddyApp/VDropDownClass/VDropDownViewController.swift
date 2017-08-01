//
//  VDropDownViewController.swift
//  VDropDown
//
//  Created by Vishal Kalola on 04/07/17.
//  Copyright © 2017 Vishal Kalola. All rights reserved.
//

import UIKit

protocol VDropDown {
    
    func VDropDownDidSelect(_ tableView:UITableView,View:UIView, Index:IndexPath, SelectedItem:String, MultipleSelectedItems:Array<String>,isMulple:Bool)
    func VDropDownHide()
    //func textFieldShouldBeginEditing:(UITextField)
    
}

class VDropDownViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIGestureRecognizerDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnTopTitle: UILabel!
    
    private static var NIBDropDownViewCell = "DropDownViewCell"
    private static var SingleCellID = "idDropDownViewCellSingle"
    private static var NIBMultiPleCellID = "DropDownViewCellMultiple"
    private static var MultipleCellID = "idDropDownViewCellMultiple"
    private static var CellHeight:CGFloat = 30
    
    var VC = UIViewController()
    var mAryData : Array<String> = Array<String>()
    var mAryPassedData : NSMutableOrderedSet = NSMutableOrderedSet()
    var isMultipleSelectionAllow : Bool = Bool()
    var delegate : VDropDown?
    let objUserDefault = UserDefaults.standard
    var btnHideView = UIButton()
    var selectedIndexArray = Array<String>()
    var selectedData = Array<String>()
    var openView: UIView!
    var userdefault = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.alpha = 0.0
        tblView.register(UINib.init(nibName: VDropDownViewController.NIBDropDownViewCell, bundle: nil), forCellReuseIdentifier: VDropDownViewController.SingleCellID)
        tblView.register(UINib.init(nibName: VDropDownViewController.NIBMultiPleCellID, bundle: nil), forCellReuseIdentifier:VDropDownViewController.MultipleCellID)
        tblView.reloadData()
    }
    
    //MARK: custom Method
    func ShowDropDown(_ vc:UIViewController, OnView:UIView) -> Void {
        
        openView = OnView;
        mAryData = Array<String>()
        for strData in mAryPassedData {
            mAryData.append(strData as! String)
        }
        AddTap(vc: vc)
        var height : CGFloat = 300.0
        var yPOS = CGFloat()
        if mAryData.count < 10 {
            height = CGFloat(mAryData.count) * VDropDownViewController.CellHeight
        }
        
        if vc.view.frame.size.height - (OnView.frame.origin.y + OnView.frame.size.height) < height  {
            yPOS = OnView.frame.origin.y - height
        }else{
            yPOS = OnView.frame.origin.y + OnView.frame.size.height
        }
        
        self.view.frame = CGRect.init(x: OnView.frame.origin.x, y: yPOS, width: OnView.frame.size.width, height: height)
        self.DrawShadow()
        UIView .animate(withDuration: 0.2) {
            self.view.alpha = 1.0
            vc.view.addSubview(self.view)
        }
        self.tblView.reloadData()
    }
    
    private func AddTap(vc:UIViewController) -> Void {
        btnHideView = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: vc.view.frame.size.width, height: vc.view.frame.size.height))
        btnHideView.addTarget(self, action: #selector(Handletap), for: .touchUpInside)
        btnHideView.backgroundColor = UIColor.clear
        vc.view.addSubview(btnHideView)
    }
    
    
    @objc func Handletap() -> Void {
        HideDropDown()
    }
    
    private func HideDropDown() -> Void {
        UIView.animate(withDuration: 0.2, animations: {
            self.btnHideView.removeFromSuperview()
            self.view.alpha = 0.0
        }, completion: { (finished) in
            if finished {
                self.view.removeFromSuperview()
                self.delegate?.VDropDownHide()
            }
        })
    }
    
    private func DrawShadow() -> Void {
        self.view.layer.borderColor = UIColor.lightGray.cgColor
        self.view.layer.borderWidth = 0.5
        self.view.layer.cornerRadius = 3.0
        let shadowPath = UIBezierPath(roundedRect: self.view.bounds, cornerRadius: 2.0)
        self.view.layer.masksToBounds = false
        self.view.layer.shadowColor = UIColor.black.cgColor
        self.view.layer.shadowOffset = CGSize(width: 1.0, height: 1.0);
        self.view.layer.shadowOpacity = 0.5
        self.view.layer.shadowPath = shadowPath.cgPath
    }
    
    private func isDataAvailabel(data : String) -> Array<String> {
        if selectedData.contains(data) {
            if let index = selectedData.index(of: data) {
                selectedData.remove(at: index)
            }
        }else{
            selectedData.append(data)
        }
        return selectedData
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Tableview Delegate & DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mAryData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if !isMultipleSelectionAllow {
            let tblCell = tableView.dequeueReusableCell(withIdentifier: VDropDownViewController.SingleCellID) as! VTableViewCell
            tblCell.lblTitle.text = mAryData[indexPath.row]
            if userdefault.value(forKey: "SelectedSingle") != nil {
                if mAryData[indexPath.row] == userdefault.value(forKey: "SelectedSingle") as! String
                {
                    tblCell.imgTickMark.isHidden = false
                }else{
                    tblCell.imgTickMark.isHidden = true
                }
            }else{
                tblCell.imgTickMark.isHidden = true
            }
            return tblCell
        }else{
            let tblCell = tableView.dequeueReusableCell(withIdentifier: VDropDownViewController.MultipleCellID) as! VTableViewCell
            tblCell.lblTitle.text = mAryData[indexPath.row]
            
            if selectedData.count > 0{
                if selectedData.contains(mAryData[indexPath.row])
                {
                    tblCell.btnMultipleSelection.isSelected = true
                }else{
                    tblCell.btnMultipleSelection.isSelected = false
                }
            }
            return tblCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isMultipleSelectionAllow {
            let strSelectedItem = mAryData[indexPath.row]
            userdefault.set(strSelectedItem, forKey: "SelectedSingle")
            self.delegate?.VDropDownDidSelect(tableView,View:openView, Index: indexPath, SelectedItem: strSelectedItem, MultipleSelectedItems:Array<String>(),isMulple:isMultipleSelectionAllow)
            HideDropDown()
        }else{
            let tblCell = tableView.cellForRow(at: indexPath) as! VTableViewCell
            tblCell.btnMultipleSelection.isSelected = !tblCell.btnMultipleSelection.isSelected
            let strData = mAryData[indexPath.row]
            let SelectedOriginalValueArray = isDataAvailabel(data: strData)
            self.delegate?.VDropDownDidSelect(tableView,View:openView, Index: indexPath, SelectedItem: "", MultipleSelectedItems:SelectedOriginalValueArray,isMulple:isMultipleSelectionAllow)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(VDropDownViewController.CellHeight)
    }
}
