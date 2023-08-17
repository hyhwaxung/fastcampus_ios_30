//
//  ViewController.swift
//  pomodoro
//
//  Created by 정현화 on 2023/08/15.
//

import UIKit

enum TimerStatus {
    case start
    case pause
    case end
}

class ViewController: UIViewController {

    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var toggelButton: UIButton!
    
    // 타이머에 설정된 시간을 초로 저장하는 프로퍼티
    // 60으로 초기화 하는 이유는 DatePicker의 default 값이 1min 이기 때문에
    var duration = 60
    var timerStatus: TimerStatus = .end
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureToggleButton()
    }
    
    func setTimerInfoViewVisible(isHidden: Bool) {
        self.timerLabel.isHidden = isHidden
        self.progressView.isHidden = isHidden
    }
    
    func configureToggleButton() {
        self.toggelButton.setTitle("시작", for: .normal) // 초기 상태면 "시작"
        self.toggelButton.setTitle("일시정지", for: .selected) // 선택된 상태면 "일시정지
    }
    
    @IBAction func tapCancelButton(_ sender: Any) {
        switch self.timerStatus {
        case .start, .pause:
            self.timerStatus = .end
            self.cancelButton.isEnabled = false
            self.setTimerInfoViewVisible(isHidden: true)
            self.datePicker.isHidden = false
            self.toggelButton.isSelected = false
            
        default:
            break
        }
    }
    
    @IBAction func tapToggleButton(_ sender: Any) {
        self.duration = Int(self.datePicker.countDownDuration)
        
        switch self.timerStatus {
        case .end:
            self.timerStatus = .start
            self.setTimerInfoViewVisible(isHidden: false)
            self.datePicker.isHidden = true
            self.toggelButton.isSelected = true
            self.cancelButton.isEnabled = true
        
        case .start:
            self.timerStatus = .pause
            self.toggelButton.isSelected = false
            
        case .pause:
            self.timerStatus = .start
            self.toggelButton.isSelected = true
            
        default:
            break
        }
    }
    
    
}

