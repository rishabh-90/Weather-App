//
//  SummaryViewController.swift
// Assignment3
//
//  Created by Rishabh Aggarwal on 2016-10-29.
//  Copyright © 2016 Default Profile. All rights reserved.
//

import UIKit

class SummaryViewController: UIViewController {

    
    @IBOutlet weak var Xmlsview: UITextView!
    var summary: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        summary = summary.stringByReplacingOccurrencesOfString("<b>", withString: "")
        summary = summary.stringByReplacingOccurrencesOfString("</b>", withString: " ")
        summary = summary.stringByReplacingOccurrencesOfString("<br/>", withString: "\n")
        summary = summary.stringByReplacingOccurrencesOfString("&deg;", withString: "°w")
        
        Xmlsview.text = summary
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
