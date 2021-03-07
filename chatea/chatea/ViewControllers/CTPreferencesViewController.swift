/*
    chatea - messaging mobile app
    Copyright (C) 2015-2021  Luca Cipressi [lucaji][@][mail.ru]

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

//
//  CTPreferencesViewController.swift
//  chatea
//
//  Created by Luca Cipressi (lucaji) on 18/11/2018.
//  Open Source adaption edited by Luca Cipressi on 07/03/2021.
//




import UIKit

class PreferencesTableViewController: UITableViewController {
    
    @IBOutlet weak var walkieTalkieModeSwitch: UISwitch!
    @IBAction func walkieTalkieSwitchAction(_ sender: UISwitch) {
        CTNetworkManager.singleton().persistAutoPlayReceivedChatMessages(sender.isOn)
    }
    
    
    @IBOutlet weak var speakerphoneModeSegmentControl: UISegmentedControl!
    @IBAction func speakerphoneModeSegmentControlAction(_ sender: UISegmentedControl) {
        switch (sender.selectedSegmentIndex) {
        case 0:
            CTChatAudioPlayerRecorder.singleton().persistSpeakerphoneMode(.off)
        case 1:
            CTChatAudioPlayerRecorder.singleton().persistSpeakerphoneMode(.normal)
        default:
            CTChatAudioPlayerRecorder.singleton().persistSpeakerphoneMode(.loud)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        walkieTalkieModeSwitch.isOn = CTNetworkManager.singleton().autoPlayReceivedChatMessages
        speakerphoneModeSegmentControl.selectedSegmentIndex = CTChatAudioPlayerRecorder.singleton().speakerphoneMode.rawValue
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let autoplay = !walkieTalkieModeSwitch.isOn
                CTNetworkManager.singleton().persistAutoPlayReceivedChatMessages(autoplay)
                walkieTalkieModeSwitch.isOn = autoplay
            } else if indexPath.row == 2 {
                self.performSegue(withIdentifier: "segueToAudioSettings", sender: self)
            }
        } else {
            if indexPath.row == 0 {
                self.performSegue(withIdentifier: "segueToPrivacy", sender: self)
            } else {
                self.performSegue(withIdentifier: "segueToAbout", sender: self)
            }
        }
    }
    
    

}
