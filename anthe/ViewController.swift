//
//  ViewController.swift
//  anthe
//
//  Created by Mart Ryan Civil on 2021/12/11.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Shared.shared.ViewController = self

        let mainView = MainView( frame: self.view.frame )
        mainView.setup()
        self.view.addSubview( mainView )
        
//        let studentView      = StudentView( frame: self.view.frame )
//        do {
//            let imageFile = try ImageFile( fileId: File.generateID(), uiimage: UIImage(named: "blackhole")!)
//            studentView.setup(info: ["a":1] as! NSDictionary, imageFile: imageFile)
//            self.view.addSubview( studentView )
//        } catch _ as Error {}
    }
}
