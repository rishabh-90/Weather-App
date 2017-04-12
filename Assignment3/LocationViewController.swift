//
//  LocationViewController.swift
// Assignment3
//
//  Created by Rishabh Aggarwal on 2016-10-29.
//  Copyright © 2016 Default Profile. All rights reserved.
//

import UIKit
import CoreData

class LocationViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var objModel: Model = Model()
    var cities: [String] = []

    
    @IBOutlet weak var objPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cites_get()
        self.objPickerView.delegate = self
        self.objPickerView.dataSource = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cities.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        
        objModel.cityName = cities[row]
        return objModel.cityName
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        objModel.cityName = cities[row]
        
        
    }
    func cites_get() -> Void {
        
        var cityCount: Int = 0
        var cityName: String = ""
        var provinceName: String = ""
        let appDel: AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext
        let entityDescription = NSEntityDescription.entityForName("CsvData", inManagedObjectContext: context)
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entityDescription
        fetchRequest.propertiesToFetch = ["city"]
        do {
            let personList = try context.executeFetchRequest(fetchRequest)
            cityCount = personList.count
        }
        catch {
            let fetchError = error as NSError
                print(fetchError)
        }
        
        
        let request = NSFetchRequest(entityName: "CsvData")
        do{
            if cityCount > 0 {
                for count in 1..<cityCount
                {
                   
                    request.returnsObjectsAsFaults = false;
                   
                    request.predicate = NSPredicate(format: "id = %@", String(count))
    
                    let data = try context.executeFetchRequest(request) as! [NSManagedObject]
                    if data.count > 0 {
                        let res = data[0] as NSManagedObject

                        
                        cities.append(res.valueForKey("city") as! String)
                        
                    }else{
                        print("No Data for: ")
                    }
                   
                }
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    @IBAction func btnFrenchClicked(sender: AnyObject) {
        objModel.language = "French"
       self.performSegueWithIdentifier("SetLocation", sender: objModel)
    }
    @IBAction func btnSubmitClicked(sender: AnyObject) {
        objModel.language = "English"
        self.performSegueWithIdentifier("SetLocation", sender: objModel)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        if (segue.identifier == "SetLocation")
        {
            let MainVC: ViewController = segue.destinationViewController as! ViewController
            let data = sender as! Model
            MainVC.objModel = data
            
        }
    }
}
