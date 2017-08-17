//
//  Mailable.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/17.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import UIKit
import MessageUI

protocol Mailsendable: MFMailComposeViewControllerDelegate {
    func configuredMailComposeViewController() -> MFMailComposeViewController
    func showSendMailErrorAlert()
    func presentErrorMailReport()
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
}

// Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
extension Mailsendable where Self: UIViewController {
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        let currentDevice = UIDevice.current

        
        var systemInfo = "傳送自：\(currentDevice.model), \(currentDevice.systemName): \(currentDevice.systemVersion)  \n"
        
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            systemInfo += "AppVersion: \(appVersion)"
        }
        
        mailComposerVC.setToRecipients(["pbikemapvision@gmail.com"])
        mailComposerVC.setSubject("Gogoro電池站 - feedback")
        mailComposerVC.setMessageBody("我們非常感謝您使用此App，歡迎寫下您希望的功能/錯誤回報或是您的感想，謝謝\n\n\n\n\(systemInfo)", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let alertController = UIAlertController(title: "無法傳送Email", message: "目前無法傳送郵件，請檢查E-mail設定並在重試", preferredStyle: UIAlertControllerStyle.alert)
        //Replace UIAlertControllerStyle.Alert by UIAlertControllerStyle.alert
        let DestructiveAction = UIAlertAction(title: "OK",
                                              style: UIAlertActionStyle.destructive) {
            (_ : UIAlertAction) -> Void in
            print("Destructive")
        }
        
        alertController.addAction(DestructiveAction)
        
    }
    
    func presentErrorMailReport() {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            present(mailComposeViewController, animated: true, completion: nil)
        } else {
            showSendMailErrorAlert()
        }
    }
    
    
}

extension MenuController: Mailsendable {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
