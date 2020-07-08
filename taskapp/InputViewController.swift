import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource{
    
    //pickerViewのプロトコル
    // UIPickerViewの列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    // UIPickerViewの行数、要素の全数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataList.count
    }
    // UIPickerViewに表示する配列
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataList[row]
    }
    
    
    // UIPickerViewのRowが選択された時の挙動
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // 処理
        print(" \(dataList[row]) が選択された。")
        selectedCategory = dataList[row]
    }
    
    var dataList = ["日本", "アメリカ", "ドイツ"]
    
    @IBOutlet weak var titleTextField: UITextField!
    

    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var pickerView: UIPickerView!
    

    @IBAction func textField1(_ sender: Any) {
    }
    
    
    let realm = try! Realm()
    var task: Task!
    var selectedCategory: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        
        //
        
        //PickerViewを使用するためにDelegateを設定する
        pickerView.delegate = self
        //PickerViewを使用するためにDataSourceを設定する
        pickerView.dataSource = self
        //PickerViewをViewに追加する
        self.view.addSubview(pickerView)
        
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            
           // self.task.category = self.selectedCategory
            
            self.realm.add(self.task, update: .modified)
        }
        
        setNotification(task: task)   // 追加
        super.viewWillDisappear(animated)
    }
    // タスクのローカル通知を登録する --- ここから ---
    func setNotification(task: Task) {
        let content = UNMutableNotificationContent()
        // タイトルと内容を設定(中身がない場合メッセージ無しで音だけの通知になるので「(xxなし)」を表示する)
        if task.title == "" {
            content.title = "(タイトルなし)"
        } else {
            content.title = task.title
        }
        if task.contents == "" {
            content.body = "(内容なし)"
        } else {
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default
        
        // ローカル通知が発動するtrigger（日付マッチ）を作成
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)
        
        // ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録 OK")  // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
        }
        
        // 未通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/---------------")
                print(request)
                print("---------------/")
            }
        }
    } // --- ここまで追加 ---
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
}

