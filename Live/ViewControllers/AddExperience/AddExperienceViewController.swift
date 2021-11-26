//
//  AddExperienceViewController.swift
//  Live
//
//  Created by ips on 04/05/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit

class AddExperienceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
    @IBOutlet weak var addExperienceDetailTblView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK:- Selector Methods
    @IBAction func backBtnPressed(_ sender: Any) {
        
    }
    
    // MARK:- UITableViewDataSource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
