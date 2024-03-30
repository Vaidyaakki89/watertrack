

import UIKit

class CalenderController: UIViewController {
    
    
    var logvalue = 0
    
    @IBOutlet weak var statuslbl: UILabel!
    
    @IBOutlet weak var datepicker: UIDatePicker!
    

    @IBOutlet weak var progressview: UIProgressView!
    
    @IBOutlet weak var complstatuslbl: UILabel!
    
    
    @IBOutlet weak var remarklbl: UILabel!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var loggers = [Waterlogger]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        getData()
     
    }
    
    
   func getData(){
        
       fetchdata()
       let date = datepicker.date.getdate()
       print(date)
       
       if let entry = loggers.filter({$0.date == date}).first{
           statuslbl.text = "Goal \(entry.glassratio)% complete"
           let ratio = (Float(entry.glassratio)/100)
           progressview.setProgress(ratio, animated: true)
           complstatuslbl.text = "Consumption \(entry.glass) glasses (\(entry.glassize ?? ""))"
           
           if entry.glassratio < 100{
               
               remarklbl.text = "Goal incomplete"
               remarklbl.textColor = .red
           }
           else{
               
               remarklbl.text = "Goal complete"
               remarklbl.textColor = .green
           }
           //progressview.isHidden = false
       }
       else{
           statuslbl.text = "Goal 0% complete"
           complstatuslbl.text = "Consumption 0 glasses"
           remarklbl.text = "Goal incomplete"
           remarklbl.textColor = .red
           progressview.setProgress(0, animated: true)
//
//           progressview.isHidden = true
//           statuslbl.isHidden = true
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
    

    @IBAction func datechanged(_ sender: Any) {
        
        print(datepicker.date)
        
        getData()
    }
    
}
