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
//  CTAudioInputTableViewController.swift
//  chatea
//
//  Created by Luca Cipressi (lucaji) on 21/11/2018.
//  Open Source adaption edited by Luca Cipressi on 07/03/2021.
//





import UIKit
import AVFoundation

class CTAudioInputTableViewController: UITableViewController {
  
    let displayInputsOnly = true
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return displayInputsOnly ? 1 : 2
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Audio Inputs"
        }
        return "Audio Outputs"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if AVAudioSession.sharedInstance().isInputAvailable {
                return AVAudioSession.sharedInstance().availableInputs?.count ?? 0
            } else {
                return 1
            }
        } else {
            return AVAudioSession.sharedInstance().outputDataSources?.count ?? 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if let inputs = AVAudioSession.sharedInstance().availableInputs {
                let cell = tableView.dequeueReusableCell(withIdentifier: "inputDeviceCell", for: indexPath)
                let device = inputs[indexPath.row]
                cell.textLabel?.text = device.portName
                if AVAudioSession.sharedInstance().preferredInput == device {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "inputDeviceCell", for: indexPath)
                cell.textLabel?.text = "No inputs available."
                cell.accessoryType = .checkmark
                return cell
            }
        } else {
            if let outputs = AVAudioSession.sharedInstance().outputDataSources {
                let cell = tableView.dequeueReusableCell(withIdentifier: "inputDeviceCell", for: indexPath)
                let device = outputs[indexPath.row]
                cell.textLabel?.text = device.dataSourceName
                if AVAudioSession.sharedInstance().outputDataSource == device {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "inputDeviceCell", for: indexPath)
                cell.textLabel?.text = "No outputs available."
                cell.accessoryType = .checkmark
                return cell
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let cell = tableView.cellForRow(at: indexPath)
            if let name = cell?.textLabel?.text {
                if let error = CTChatAudioPlayerRecorder.singleton().chooseDefaultInputDevice(withName: name, storeAsDefault: true) {
                    self.alert(title: name, message: "Cannot set as input device: \(error).")
                }
            }
            if let inputs = AVAudioSession.sharedInstance().availableInputs {
                let device = inputs[indexPath.row]
                let name = device.portName
                do {
                    try AVAudioSession.sharedInstance().setPreferredInput(device)
                } catch {
                    self.alert(title: name, message: "Cannot set as input device: \(error).")
                }
            }
        } else {
            if let outputs = AVAudioSession.sharedInstance().outputDataSources {
                let device = outputs[indexPath.row]
                let name = device.dataSourceName
                do {
                    try AVAudioSession.sharedInstance().setOutputDataSource(device)
                } catch {
                    self.alert(title: name, message: "Cannot set as output device: \(error).")
                }
            }
        }
        tableView.reloadData()
    }
    
    func alert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in }
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }

}
