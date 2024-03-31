//
//  SettingController.swift
//  Hydrationtracker
//
//  Created by AKSHAY VAIDYA on 30/03/24.

import UIKit

class SettingController: UIViewController {
 
    
    
    
    @IBOutlet weak var goallbl: UILabel!
    
    @IBOutlet weak var goalstepper: UIStepper!
    
    @IBOutlet weak var glasspicker: UIPickerView!
    
    
    @IBOutlet weak var notificationswitch: UISwitch!
    let glassSizes: [String] = ["4oz", "6oz", "8oz", "9oz", "10oz", "12oz", "14oz", "16oz"]
    let durations: [String] = ["1 min", "10 min", "30 min", "1 hr", "3 hr", "6 hr"]
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var loggers = [Waterlogger]()
    let center = UNUserNotificationCenter.current()
    var glasssize = ""
    var loggerentry = Waterlogger()
    var glass:Int16 = 0
    var totalglass:Int16 = 0
    var date1 = ""
    var ratio:Int16 = 0
    
    var picker = UIPickerView()
    var selectedtime = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        goallbl.text = "10 glasses per day"
        goalstepper.value = 10
        
        glasspicker.dataSource = self
        glasspicker.delegate = self
        
        notificationswitch.isOn = false
       
        //getData()
    }
    

    override func viewWillAppear(_ animated: Bool) {
        getData()
    }
    
 
    
    
    
    @IBAction func stepperaction(_ sender: Any) {
        goallbl.text = "\(Int(goalstepper.value)) glasses per day"
        totalglass = Int16(goalstepper.value)
    }
    
    @IBAction func notificationtrigger(_ sender: Any) {
        if notificationswitch.isOn{
           // triggerNotification()
            
            showAlert2()
            
        }
//        else{
//            
//            center.removeAllPendingNotificationRequests()
//        }
        
      
    }
    
    @IBAction func applyaction(_ sender: Any) {
        
      showAlert()
    }
    
    
 
    
    func getData(){
         
        fetchdata()
         
        let date = Date().getdate()
        
        if let entry = loggers.filter({$0.date == date}).first{
            glasssize = entry.glassize ?? ""
            totalglass = entry.totalglass
            glass = entry.glass
        
            date1 = entry.date ?? ""
            notificationswitch.isOn = entry.isnotification
            goallbl.text = "\(entry.totalglass) glasses per day"
            goalstepper.value = Double(entry.totalglass)
            let index = glassSizes.firstIndex(of: entry.glassize ?? "4oz") ?? 0
            print("")
            glasspicker.selectRow(index, inComponent: 0, animated: false)
        }
         
     }
    
   
    
    
    func triggerNotification(interval:TimeInterval)
    {
     
            
            let content = UNMutableNotificationContent()
            
        content.title = "Daily Hydrate Reminder"
        content.body = "Don't forget to log your consumption and complete your daily goal!"
      
        content.sound = .default
     // content.badge = 1
            
            
            let date = Date().addingTimeInterval(1)
            
            let component = Calendar.current.dateComponents([.year,.month,.day,.hour,.second], from: date)
            
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval:interval, repeats: true)
            
            let uuid = UUID().uuidString
            
            let request = UNNotificationRequest(identifier: uuid, content: content, trigger: trigger)
            
            center.add(request){error in
                
                if error != nil{
                    
                    print("Notification failed")
                }
                
                
          //  }
        }
    }
    
    
    func arrangeData(){
        
        fetchdata()
        
        
        let date = Date().getdate()
        
        if let entry = loggers.filter({$0.date == date}).first{
         
           
            
            context.delete(entry)
            
            saveData()
            
            let item = Waterlogger(context: context)
            
            item.date = date1
            item.glass = glass
            item.totalglass = totalglass
            item.glassratio = Int16((Double(glass)/Double(totalglass)) * 100)
            item.glassize = glasssize
            item.isnotification = notificationswitch.isOn
            saveData()
        }
        
      
        
        
        
    }
    
}


extension SettingController: UIPickerViewDelegate,UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == picker{
            
            return durations.count
        }else{
            return glassSizes.count
            
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == picker{
            return durations[row]
        }
        else{
            return glassSizes[row]
            
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == picker{
          selectedtime = durations[row]
        }
        else{
            glasssize = glassSizes[row]
            
        }
       
    }
    
}


extension SettingController{
    
    func saveData(){
        do{
            try context.save()
            
        }
        catch{
            
            print(error.localizedDescription)
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
    
    
    
    func showAlert(){
        
        let alert = UIAlertController(title: "Save Changes", message: "", preferredStyle: .alert)
        
        let yesaction = UIAlertAction(title: "Yes", style: .default, handler: { [self]_ in
            
            NotificationCenter.default
                        .post(name: NSNotification.Name("isvaluechanged"),
                              object: nil,userInfo: ["value":goalstepper.value, "size":glasssize])
            
            arrangeData()
            
            if notificationswitch.isOn{
                
                let interval = getinterval(time: selectedtime)
                triggerNotification(interval:interval)
            }
            else
            {
                center.removeAllPendingNotificationRequests()
                
            }
            
        })
        let noaction = UIAlertAction(title: "No", style: .cancel)
        
        alert.addAction(yesaction)
        alert.addAction(noaction)
        
        self.present(alert, animated: true)
    }
    
    func showAlert2(){
        
        let alert = UIAlertController(title: "Choose time interval of notification", message: "\n\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        picker.delegate = self
        picker.dataSource = self
        alert.view.addSubview(picker)
        picker.frame = CGRect(x: ((alert.view.frame.width/2) - 100), y: 30, width: 200, height: 200)
     //  picker.frame = alert.view.bounds
        let yesaction = UIAlertAction(title: "Ok", style: .default, handler: { [self]_ in
//            let interval = getinterval(time: selectedtime)
//            triggerNotification(interval:interval)
            
        })
        alert.addAction(yesaction)
        
        present(alert, animated: true)
    }
    
    func getinterval(time:String)-> TimeInterval{
        
        switch time{
            
        case "1 min":
            return 60
        case "10 min":
            return 600
        case "30 min":
            return 1800
        case "1 hr":
            return 3600
        case "3 hr":
            return 10800
            
        default:
            return 21600
            
        }
        
    }

    
}
