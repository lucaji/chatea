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
//  CTVolumePopoverViewController.swift
//  chatea
//
//  Created by Luca Cipressi (lucaji) on 21/11/2018.
//  Open Source adaption edited by Luca Cipressi on 07/03/2021.
//



import UIKit
import MediaPlayer

class CTVolumePopoverViewController: UIViewController {

    @IBOutlet weak var volumeView: UIView!
    var myVolumeView : MPVolumeView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //volumeView.backgroundColor = UIColor.clear
        myVolumeView = MPVolumeView(frame: volumeView.bounds)
        myVolumeView.showsRouteButton = true
        myVolumeView.showsVolumeSlider = true
        volumeView.addSubview(myVolumeView)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        myVolumeView.removeFromSuperview()
        super.viewDidDisappear(animated)
    }
}
