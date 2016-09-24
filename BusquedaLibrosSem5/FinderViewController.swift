//
//  FinderViewController.swift
//  BusquedaLibros
//
//  Created by Erick Rodríguez Ramos on 04/09/16.
//  Copyright © 2016 Erick Rodríguez Ramos. All rights reserved.
//

import UIKit
import CoreData
class FinderViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var managedObjectContext: NSManagedObjectContext? = nil
    
    @IBOutlet weak var txtISBN: UITextField!
    @IBOutlet weak var lblTitulo: UILabel!
    @IBOutlet weak var imgPortada: UIImageView!
    @IBOutlet weak var tvAutores: UITableView!
    @IBOutlet var auts: NSArray!
    @IBOutlet var autores: [NSString]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.txtISBN.delegate = self
        self.tvAutores.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true);
        //Buscar Libro
        let libroEntidad = NSEntityDescription.entityForName("Libros", inManagedObjectContext: self.managedObjectContext!)
        let peticion = libroEntidad?.managedObjectModel.fetchRequestFromTemplateWithName("petLibro", substitutionVariables: ["isbn": self.txtISBN.text!])
        
        do{
            let libroEntidad2 = try self.managedObjectContext?.executeFetchRequest(peticion!)
            if (libroEntidad2?.count > 0) {
                for libroEnt in libroEntidad2!{
                    self.lblTitulo.text = libroEnt.valueForKey("nombre")!.description
                    self.imgPortada.image = UIImage(data: libroEnt.valueForKey("portada")! as! NSData)
                    let autoresEntidad = libroEnt.valueForKey("tiene") as! Set<NSObject>
                    
                    self.autores = [NSString]()
                    for autorEntidad in autoresEntidad{
                        self.autores.append(autorEntidad.valueForKey("nombre") as! String)
                    }
                }
            }
            else{
                let url1 = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"
                let url2 = self.txtISBN.text!
                let urls = url1 + url2
                
                let url = NSURL(string: urls)
                let datos:NSData? = NSData(contentsOfURL: url!)
                
                do{
                    let json = try NSJSONSerialization.JSONObjectWithData(datos!, options: NSJSONReadingOptions.MutableLeaves)
                    //Validar json OK
                    if NSJSONSerialization.isValidJSONObject(json){
                        let resp = json as! NSDictionary
                        //Validar si el diccionario contiene elementos
                        if resp.allKeys.count > 0 {
                            let book = resp["ISBN:" + self.txtISBN.text!] as! NSDictionary
                            //Aqui se obtiene el titulo
                            self.lblTitulo.text = book["title"] as! NSString as String
                            
                            //Aqui se obtiene la portada
                            self.imgPortada.image = nil
                            if let url = NSURL(string: "http://covers.openlibrary.org/b/ISBN/" + self.txtISBN.text! + "-M.jpg") {
                                if let data = NSData(contentsOfURL: url) {
                                    self.imgPortada.image = UIImage(data: data)
                                }
                            }
                            
                            //Obtiene autor(es)
                            self.auts = book["authors"] as! NSArray
                            
                            let context = self.managedObjectContext!
                            let entidadLibro = NSEntityDescription.insertNewObjectForEntityForName("Libros", inManagedObjectContext: context)
                            
                            entidadLibro.setValue(self.txtISBN.text!, forKey: "isbn")
                            entidadLibro.setValue(self.lblTitulo.text, forKey: "nombre")
                            entidadLibro.setValue(UIImageJPEGRepresentation(self.imgPortada.image!, 1.0), forKey: "portada")
                            
                            var entidades = Set<NSObject>()
                            self.autores = [NSString]()
                            
                            for autor in self.auts{
                                let autorEntidad = NSEntityDescription.insertNewObjectForEntityForName("Autores", inManagedObjectContext: self.managedObjectContext!)
                                
                                autorEntidad.setValue(autor["name"] as! String, forKey: "nombre")
                                entidades.insert(autorEntidad)
                                self.autores.append(autor["name"] as! String)
                            }
                            
                            entidadLibro.setValue(entidades, forKey: "tiene")
                            
                            // Guarda context.
                            do {
                                try context.save()
                            } catch {
                                abort()
                            }
                            
                        }
                        else{
                            msgNoEncontrado()
                        }
                        
                    }
                    else{
                        msgNoEncontrado()
                    }
                }
                catch _ {
                    let alert = UIAlertController(title: "Error", message: "Error de comunicación!!!", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
        catch{
        
        }
        self.tvAutores.reloadData()
        return false;
    }
    
    func msgNoEncontrado(){
        self.lblTitulo.text = ""
        self.imgPortada.image = nil
        self.auts = nil;
        self.tvAutores.reloadData()
        
        let alert = UIAlertController(title: "Busqueda", message: "ISBN No encontrado.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

}
