//
//  ViewController.swift
// Assignment3
//
//  Created by Rishabh Aggarwal on 2016-10-29.
//  Copyright © 2016 Default Profile. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, NSXMLParserDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var lblCityName: UILabel!
    var SelectedCityUrl: String = ""
    var objModel: Model = Model()
    @IBOutlet weak var tbData: UITableView!
    
    
    var parser = NSXMLParser()
    var xmlfeedp = NSMutableArray()
    var keys = NSMutableDictionary()
    var element = NSString()
    var weektitle = NSMutableString()
    var weektitle2 = NSMutableString()
    var check_xml: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (objModel.cityName != "") {
            lblCityName.text = objModel.cityName
            SelectedCityUrl = csvURL(objModel.cityName)
            tbData?.dataSource = self
            tbData?.delegate = self
            self.begin_Parsing()
        }
        if core_data_cc() == 0 {
           
            parse_csv()
        }
      
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
            }
    
    @IBAction func btnSetLocationClicked(sender: AnyObject) {
        self.performSegueWithIdentifier("GetLocation", sender: objModel)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        if (segue.identifier == "GetLocation")
        {
            let CityLocationVC: LocationViewController = segue.destinationViewController as! LocationViewController
            let data = sender as! Model
           
        }
        if segue.identifier == "XmlSummary" {
            
            let destination = segue.destinationViewController as! SummaryViewController
            destination.summary = sender as! String
            
        }
        super.prepareForSegue(segue, sender: sender)
    }
    
    
    
    func parse_csv(){
        
        let path = NSBundle.mainBundle().pathForResource("feeds", ofType: "csv")!
        
        do{
            let csv = try CSV(contentsOfURL: path)
            let row = csv.rows
            var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            var managedContext = appDelegate.managedObjectContext
            
            // Get data entity
            var entity =  NSEntityDescription.entityForName("CsvData",
                                                            inManagedObjectContext:managedContext)
            // Manage text via context
            var textdata = NSManagedObject(entity: entity!,
                                           insertIntoManagedObjectContext: managedContext)
            
            for row_test in row {
                appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                managedContext = appDelegate.managedObjectContext
                
                // Get data entity
                entity =  NSEntityDescription.entityForName("CsvData",
                                                            inManagedObjectContext:managedContext)
                // Manage text via context
                textdata = NSManagedObject(entity: entity!,
                                           insertIntoManagedObjectContext: managedContext)
                
                let csv_url = row_test["url"]
                let csv_urlfr = row_test["urlfr"]
                let csv_city = row_test["city"]
                let csv_prov = row_test["prov"]
                let csv_id = row_test["id"]
               
                textdata.setValue(csv_city, forKey: "city")
                textdata.setValue(csv_url, forKey: "url")
                textdata.setValue(csv_urlfr, forKey: "urlfr")
                textdata.setValue(csv_prov, forKey: "prov")
                textdata.setValue(csv_id, forKey: "id")
            }
            do
            {
                try managedContext.save()
            }
            catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
            
            print("Saved...")
        }
        catch
        {
            
        }
        
    }
    
    
    
    func csvURL(city: String) -> String {
        
        var cityCount: Int = 0
        let appDel: AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext
        let entityDescription = NSEntityDescription.entityForName("CsvData", inManagedObjectContext: context)
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entityDescription
        if objModel.language == "English" {
            fetchRequest.propertiesToFetch = ["url"]
            
        }
        else {
            fetchRequest.propertiesToFetch = ["urlfr"]
            
        }
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
                                        request.predicate = NSPredicate(format: "city = %@", city)
                    
                    let data = try context.executeFetchRequest(request) as! [NSManagedObject]
                    if data.count > 0 {
                        let res = data[0] as NSManagedObject
                        if objModel.language == "English" {
                            return res.valueForKey("url") as! String
                        }
                        else{
                            return res.valueForKey("urlfr") as! String
                            
                        }
                        
                    }else{
                        print("No Data for: ")
                    }
                                    }
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        
        return "https://weather.gc.ca/rss/city/bc-74_e.xml"
    }
    func begin_Parsing()
    {
        xmlfeedp = []
        parser = NSXMLParser(contentsOfURL:(NSURL(string:SelectedCityUrl))!)!
        parser.delegate = self
        parser.parse()
        tbData!.reloadData()
    }
    
    //XMLParser Methods
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        element = elementName
        if (elementName as NSString).isEqualToString("entry")
        {
            keys = NSMutableDictionary()
            keys = [:]
            weektitle = NSMutableString()
            weektitle = ""
            weektitle2 = NSMutableString()
            weektitle2 = ""
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        if (elementName as NSString).isEqualToString("entry") {
            if !weektitle.isEqual(nil) {
                keys.setObject(weektitle, forKey: "title")
            }
            if !weektitle2.isEqual(nil) {
                keys.setObject(weektitle2, forKey: "summary")
            }
            
            
            
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String)
    {
        if element.isEqualToString("title") {
            if (string.rangeOfString("Current") != nil || string.rangeOfString("Sunday:") != nil || string.rangeOfString("Wednesday:") != nil || string.rangeOfString("Monday:") != nil || string.rangeOfString("Tuesday:") != nil || string.rangeOfString("Thursday:") != nil || string.rangeOfString("Friday:") != nil || string.rangeOfString("Saturday:") != nil || string.rangeOfString("Lundi:") != nil || string.rangeOfString("Mardi:") != nil || string.rangeOfString("Mercredi:") != nil || string.rangeOfString("Jeudi:") != nil || string.rangeOfString("Vendredi:") != nil || string.rangeOfString("Samedi:") != nil || string.rangeOfString("Dimanche:") != nil ) {
                
                weektitle.appendString(string)
                
                check_xml = 1
            }
            
        }
        
        if element.isEqualToString("summary") {
            if(check_xml == 1)
            {
                weektitle2.appendString(string)
                xmlfeedp.addObject(keys)
                check_xml = 0
            }
        }
    }
    
    //Tableview Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return xmlfeedp.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell")!
        
        if(cell.isEqual(NSNull)) {
            cell = NSBundle.mainBundle().loadNibNamed("Cell", owner: self, options: nil)[0] as! UITableViewCell;
        }
        
        cell.textLabel?.text = xmlfeedp.objectAtIndex(indexPath.row).valueForKey("title") as! NSString as String
        cell.detailTextLabel?.text = xmlfeedp.objectAtIndex(indexPath.row).valueForKey("summary") as! NSString as String
       
        return cell as UITableViewCell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let summary = tableView.cellForRowAtIndexPath(indexPath)?.detailTextLabel?.text
        
        performSegueWithIdentifier("XmlSummary", sender: summary)
    }
    
    
    func core_data_cc() -> Int {
        var cityCount: Int = 0
        let appDel: AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext
        let entityDescription = NSEntityDescription.entityForName("CsvData", inManagedObjectContext: context)
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entityDescription
        if objModel.language == "English" {
            fetchRequest.propertiesToFetch = ["url"]
            
        }
        else {
            fetchRequest.propertiesToFetch = ["urlfr"]
            
        }
                do {
            let personList = try context.executeFetchRequest(fetchRequest)
            cityCount = personList.count
        }
        catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        return cityCount
    }
}

