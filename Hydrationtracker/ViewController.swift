//
//  ViewController.swift
//  Hydrationtracker
//
//  Created by AKSHAY VAIDYA on 30/03/24.


import UIKit

class ViewController: UIViewController {

   
    @IBOutlet weak var dropimagview: UIImageView!
    
    @IBOutlet weak var progressview: UIProgressView!
    
    
    @IBOutlet weak var toplbl: UILabel!
    @IBOutlet weak var progresslbl: UILabel!
    
    @IBOutlet weak var glsratiolbl: UILabel!
    
    
    @IBOutlet weak var stepper: UIStepper!
    
    var totalglass = 10.0
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var loggers = [Waterlogger]()
    var glasssize = "4oz"
    var isnotification = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        progressview.transform = progressview.transform.rotated(by: 270 * .pi / 180)
        progressview.transform = progressview.transform.scaledBy(x: 1.8, y: 50)
        
//        progressview.setProgress(0.0, animated: true)
//        toplbl.text = "Current Daily Goal: \(Int(totalglass)) glasses"
        
      //  glsratiolbl.text = "\(Int(stepper.value))/\(Int(totalglass))"
        
        print(Date().getdate())
     
    }

    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default
                          .addObserver(self,
                                       selector: #selector(triggervalue(_:)),
                         name: NSNotification.Name ("isvaluechanged"),                                           object: nil)
        
        getData()
    }
    
    @objc func triggervalue(_ notification: Notification)
   {
        
       totalglass = notification.userInfo?["value"] as? Double ?? 0
       glasssize = notification.userInfo?["size"] as? String ?? ""
       
       toplbl.text = "Current Daily Goal: \(Int(totalglass)) glasses (\(glasssize))"
       
       glsratiolbl.text = "\(Int(stepper.value))/\(Int(totalglass))"
       
       let ratio = (stepper.value/totalglass) * 100
       
       progressview.setProgress(Float((stepper.value/totalglass)), animated: true)
       
       progresslbl.text = "\(Int(ratio))%"
    }
    
    
    @IBAction func steppervaluechanged(_ sender: Any) {
        if stepper.value <= totalglass{
            print(stepper.value)
            
            glsratiolbl.text = "\(Int(stepper.value))/\(Int(totalglass))"
            
            let ratio = (stepper.value/totalglass) * 100
            
            progressview.setProgress(Float((stepper.value/totalglass)), animated: true)
            
            progresslbl.text = "\(Int(ratio))%"
        }
        
        else{
            stepper.value = totalglass
            
        }
        
        arrangeData()
    }
    
    func arrangeData(){
        
        fetchdata()
        
        let date = Date().getdate()
        
        if let entry = loggers.filter({$0.date == date}).first{
            
            context.delete(entry)
            
            saveData()
        }
        
        let item = Waterlogger(context: context)
        
        item.date = date
        item.glass = Int16(stepper.value)
        item.totalglass = Int16(totalglass)
        item.glassratio = Int16(((stepper.value/totalglass) * 100))
        item.glassize = glasssize
        item.isnotification = isnotification
        saveData()
        
        
        
    }
    
   func getData(){
        
       fetchdata()
        
       let date = Date().getdate()
       
       if let entry = loggers.filter({$0.date == date}).first{
           
           totalglass = Double(entry.totalglass)
           toplbl.text = "Current Daily Goal: \(Int(totalglass)) glasses (\(entry.glassize ?? ""))"
           glasssize = entry.glassize ?? ""
           glsratiolbl.text = "\(Int(entry.glass))/\(Int(totalglass))"
           isnotification = entry.isnotification
           let ratio = (Double(entry.glass)/totalglass) * 100
           
           progressview.setProgress(Float((Double(entry.glass)/totalglass)), animated: true)
           
           progresslbl.text = "\(entry.glassratio)%"
           stepper.value = Double(entry.glass)
       }
        
    }
    
    
    func fetchdata(){
        do{
            loggers = try context.fetch(Waterlogger.fetchRequest())
            
        }
        catch{
            
            print(error.localizedDescription)
        }
    }
    
    func saveData(){
        do{
            try context.save()
            
        }
        catch{
            
            print(error.localizedDescription)
        }
        
    }
    
 
        deinit {
          NotificationCenter.default
           .removeObserver(self, name:  NSNotification.Name("isvaluechanged"), object: nil)
    }
   

}



extension Date{
    
    func getdate()->String{
      
        var formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
//
//        var date = formatter.date(from: self)

        formatter.dateFormat = "dd/MM/yyyy"
        
        var str = formatter.string(from: self as Date)
        
       
        return str
        
        
    }
    
}

