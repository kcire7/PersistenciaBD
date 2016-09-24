//
//  DetailViewController.swift
//  BusquedaLibros
//
//  Created by Erick Rodríguez Ramos on 04/09/16.
//  Copyright © 2016 Erick Rodríguez Ramos. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var lblTitulo: UILabel!
    @IBOutlet weak var imgPortada: UIImageView!
    @IBOutlet weak var tvAutores: UITableView!

    @IBOutlet var autores: [NSString]!

    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.valueForKey("isbn")!.description
            }
            if let label = self.lblTitulo{
                label.text = detail.valueForKey("nombre")!.description
            }
            if let img = self.imgPortada{
                img.image = UIImage(data: detail.valueForKey("portada")! as! NSData)
            }
            
            let autoresEntidad = detail.valueForKey("tiene") as! Set<NSObject>
            
            self.autores = [NSString]()
            for autorEntidad in autoresEntidad{
                self.autores.append(autorEntidad.valueForKey("nombre") as! String)
            }

        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tvAutores.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.autores != nil){
            return (self.autores.count as Int)
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tvAutores.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!
        
        cell.textLabel?.text = self.autores[indexPath.row] as String
        
        return cell
        
    }
}

