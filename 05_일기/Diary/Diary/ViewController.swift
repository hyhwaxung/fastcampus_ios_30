//
//  ViewController.swift
//  Diary
//
//  Created by 정현화 on 2022/10/11.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var diarylist = [Diary]() {
        didSet {
            self.saveDiaryList()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionView()
        self.loadDiaryList()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(editDiaryNotifiaction(_:)),
            name: NSNotification.Name("editDiary"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(starDiaryNotification(_:)),
            name: NSNotification.Name("starDiary"),
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deleteDiaryNotification(_:)),
            name: NSNotification.Name("deleteDiary"),
            object: nil)
    }
    
    private func configureCollectionView() {
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    @objc func editDiaryNotifiaction(_ notification: Notification){
        guard let diary = notification.object as? Diary else {return}
//        guard let row = notification.userInfo?["indexPath.row"] as? Int else {return}
//        self.diarylist[row] = diary
        guard let index = self.diarylist.firstIndex(where: { $0.uuidString == diary.uuidString }) else {return}
        self.diarylist[index] = diary
        self.diarylist = self.diarylist.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending // 최신순으로 정렬
        })
        self.collectionView.reloadData()
    }
    
    @objc func starDiaryNotification(_ notification: Notification){
        guard let starDiary = notification.object as? [String: Any] else {return}
        guard let isStar = starDiary["isStar"] as? Bool else {return}
//        guard let indexPath = starDiary["indexPath"] as? IndexPath else {return}
//        self.diarylist[indexPath.row].isStar = isStar
        guard let uuidString = starDiary["uuidString"] as? String else {return}
        guard let index = self.diarylist.firstIndex(where: { $0.uuidString == uuidString }) else {return}
        self.diarylist[index].isStar = isStar
    }
    
    @objc func deleteDiaryNotification(_ notification: Notification){
//        guard let indexPath = notification.object as? IndexPath else {return}
//        self.diarylist.remove(at: indexPath.row)
        guard let uuidString = notification.object as? String else {return}
        guard let index = self.diarylist.firstIndex(where: { $0.uuidString == uuidString }) else {return}
        self.diarylist.remove(at: index)
//        self.collectionView.deleteItems(at: [indexPath])
        self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
    }

    // segueway 방식으로 화면 이동하기 때문에 필요
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let writeDiaryViewcontroller = segue.destination as? WriteDiaryViewController {
            writeDiaryViewcontroller.delegate = self
        }
    }
    
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    private func saveDiaryList() {
        let date = self.diarylist.map {
            [
                "uuidString": $0.uuidString,
                "title": $0.title,
                "contents": $0.contents,
                "date": $0.date,
                "isStar": $0.isStar
            ]
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(date, forKey: "diaryList")
    }
    
    private func loadDiaryList() {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "diaryList") as? [[String: Any]] else { return }
        self.diarylist = data.compactMap {
            guard let uuidString = $0["uuidString"] as? String else {return nil}
            guard let title = $0["title"] as? String else { return nil }
            guard let contents = $0["contents"] as? String else { return nil}
            guard let isStar = $0["isStar"] as? Bool else { return nil }
            guard let date = $0["date"] as? Date else { return nil }
            return Diary(uuidString: uuidString, title: title, contents: contents, date: date, isStar: isStar)
        }
        self.diarylist = self.diarylist.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
    }
}

extension ViewController: WriteDiaryViewDelegate {
    func didSelectRegister(diary: Diary) {
        self.diarylist.append(diary)
        self.collectionView.reloadData()
        self.diarylist = self.diarylist.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.diarylist.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryCell", for: indexPath) as? DiaryCell else { return UICollectionViewCell() }
        let diary = self.diarylist[indexPath.row]
        cell.titleLabel.text = diary.title
        cell.dateLabel.text = self.dateToString(date: diary.date)
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // didSelectItemAt : 특정 cell이 선택되었음을 알리는 method
        guard let viewController = self.storyboard?.instantiateViewController(identifier: "DiaryDetailViewController") as? DiaryDetailViewController else {return} // viewController를 instance화 하고 DiaryDetailViewController 타입으로 타입 캐스팅
        let diary = self.diarylist[indexPath.row] // 선택한 row 넘겨주기
        viewController.diary = diary
        viewController.indexPath = indexPath
//        viewController.delegate = self
        self.navigationController?.pushViewController(viewController, animated: true) // 일기장 상세화면으로 이동하도록 push
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width / 2) - 20 , height: 200)
    }
}

//extension ViewController: DiaryDetailViewDelegate {
//    func didSelectDelete(indexPath: IndexPath) {
//        self.diarylist.remove(at: indexPath.row)
//        self.collectionView.deleteItems(at: [indexPath])
//    }
//    
////    func didSelectStar(indexPath: IndexPath, isStar: Bool) {
////        self.diarylist[indexPath.row].isStar = isStar
////    }
//}
