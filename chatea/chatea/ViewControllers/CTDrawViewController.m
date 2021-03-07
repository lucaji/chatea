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
//  CTDrawViewController.m
//  chatea
//
//  Created by Luca Cipressi (lucaji) on 15/08/2017.
//  Open Source adaption edited by Luca Cipressi on 07/03/2021.
//




#import "CTDrawViewController.h"
#import "DrawView.h"

@interface CTDrawViewController () {
    IBOutlet DrawView *drawingView;
}

@end

@implementation CTDrawViewController
- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)undoAction:(id)sender {
    [drawingView undoDrawing];
}

- (void)viewDidLoad{
    [super viewDidLoad];
//    self.navigationItem.title = @"Drawing View";
//    UIBarButtonItem *animateButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:drawingView action:@selector(clearDrawing)];
//    self.navigationItem.rightBarButtonItem = animateButton;
//    UIBarButtonItem *archivedButton = [[UIBarButtonItem alloc] initWithTitle:@"Load" style:UIBarButtonItemStylePlain target:self action:@selector(loadArchived:)];
//    self.navigationItem.leftBarButtonItem = archivedButton;
    // Drawing view setup.
    drawingView.strokeColor = [UIColor redColor];
    drawingView.strokeWidth = 20.0f;
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    [drawingView clearDrawing];
}

- (IBAction)loadArchived:(id)sender{
    // Load an archived array of bezier paths
//    UIBezierPath *path = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"test-path" ofType:@"txt"]];
//    [drawingView drawBezier:path];
}
- (IBAction)animateDrawing:(id)sender{
    [drawingView animatePath];
}
- (IBAction)saveDrawing:(id)sender {
    UIAlertController*alertController = [UIAlertController alertControllerWithTitle:@"Share and save" message:@"Share this drawing..." preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action) {}];
    [alertController addAction:cancelAction];
}

- (IBAction)sendAction:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.delegate) {
        [self.delegate drawviewHasDismissed:drawingView];
    }
}

-(void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [drawingView refreshCurrentMode];
}

//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
//}

@end
