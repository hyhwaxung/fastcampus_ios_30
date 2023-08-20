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
    var timer: DispatchSourceTimer?
    var currentSeconds = 0
    
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
    
    func startTimer() {
        if self.timer == nil {
            self.timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
            self.timer?.schedule(deadline: .now(), repeating: 1) // 3초 후에 실행시키고 싶으면 .now() + 3 이런식으로 가능
            self.timer?.setEventHandler(handler: { [weak self] in
                self?.currentSeconds -= 1
                debugPrint(self?.currentSeconds)
                
                if self?.currentSeconds ?? 0 <= 0 {
                    self?.stopTimer()
                }
            })
            self.timer?.resume()
        }
    }
    
    func stopTimer() {
        if self.timerStatus == .pause {
            self.timer?.resume()
        }
        self.timerStatus = .end
        self.cancelButton.isEnabled = false
        self.setTimerInfoViewVisible(isHidden: true)
        self.datePicker.isHidden = false
        self.toggelButton.isSelected = false
        self.timer?.cancel()
        self.timer = nil
    }
    
    @IBAction func tapCancelButton(_ sender: Any) {
        switch self.timerStatus {
        case .start, .pause:
            self.stopTimer()
            
        default:
            break
        }
    }
    
    @IBAction func tapToggleButton(_ sender: Any) {
        self.duration = Int(self.datePicker.countDownDuration)
        
        switch self.timerStatus {
        case .end:
            self.currentSeconds = self.duration
            self.timerStatus = .start
            self.setTimerInfoViewVisible(isHidden: false)
            self.datePicker.isHidden = true
            self.toggelButton.isSelected = true
            self.cancelButton.isEnabled = true
            self.startTimer()
        
        case .start:
            self.timerStatus = .pause
            self.toggelButton.isSelected = false
            self.timer?.suspend()
            
        case .pause:
            self.timerStatus = .start
            self.toggelButton.isSelected = true
            self.timer?.resume()
        }
    }
    
    
}

