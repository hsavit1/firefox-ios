/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import MessageUI
import Shared

class DebuggingAppDelegate: AppDelegate {

    override func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        if DebugSettingsBundleOptions.emailLogsOnLaunch && MFMailComposeViewController.canSendMail() {
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
            self.window!.backgroundColor = UIColor.whiteColor()
            self.window!.backgroundColor = UIConstants.AppBackgroundColor
            presentEmailComposerWithLogs()
            return true
        } else {
            return super.application(application, willFinishLaunchingWithOptions: launchOptions)
        }
    }

    private func presentEmailComposerWithLogs() {
        if let buildNumber = NSBundle.mainBundle().objectForInfoDictionaryKey(String(kCFBundleVersionKey)) as? NSString {
            let mailComposeViewController = MFMailComposeViewController()
            mailComposeViewController.mailComposeDelegate = self
            mailComposeViewController.setSubject("Email logs for iOS client version v\(appVersion) (\(buildNumber))")

            do {
                let logNamesAndData = try Logger.diskLogFilenamesAndData()
                logNamesAndData.forEach { nameAndData in
                    if let data = nameAndData.1 {
                        mailComposeViewController.addAttachmentData(data, mimeType: "text/plain", fileName: nameAndData.0)
                    }
                }
            } catch _ {
                print("Failed to retrieve logs from device")
            }

            window?.rootViewController?.presentViewController(mailComposeViewController, animated: true, completion: nil)
        }
    }
}

extension DebuggingAppDelegate: MFMailComposeViewControllerDelegate {

    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {

    }
}
