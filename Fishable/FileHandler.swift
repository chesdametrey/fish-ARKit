//
//  FileHandler.swift
//  FishARKit
//
//  Created by CHESDAMETREY on 25/9/17.
//  Copyright © 2017 com.chesdametrey. All rights reserved.
//

import UIKit
import Foundation
import CSV
import SceneKit

class FileHandler {
    
    init() {
    }
    
    // functino to write feature point to csv
    func writeNodeToCSV(fishArray: [[Float]],url: URL,append: Bool){
        
        //let exists = FileManager.default.fileExists(atPath: filePath)
        
        let stream = OutputStream(url: url, append: append)!
        let csv = try! CSVWriter(stream: stream)
        
        // write out the passed in fishArray to CSV with the provided URL
        for i in fishArray {
            
                let strTwoX = String(i[0])
                let strTwoY = String(i[1])
                let strDeptX = String(i[2])
                let strDeptY = String(i[3])
                let strDeptZ = String(i[4])
                try! csv.write(row: [strTwoX, strTwoY, strDeptX, strDeptY,strDeptZ])
            
        }
        
        csv.stream.close()
    }
    
    
    func readFrom(url: URL){
        let stream = InputStream(url: url)!
        let csv = try! CSVReader(stream: stream)
        
        while let row = csv.next(){
            print(row)
        }
        
    }
    
    // read CSV file and return it in SCNVector3
    func readToSCNVector(url: URL) -> [[Float]]{
        
        var fishNodeArray = [[Float]]()
        var formArray = [Float]()
        
        let stream = InputStream(url: url)!
        let csv = try! CSVReader(stream: stream)
        
        while let row = csv.next(){
            print(row)
            
            let X = Float(row[0])!
            let Y = Float(row[1])!
            let floatX = Float(row[2])!
            let floatY = Float(row[3])!
            let floatZ = Float(row[4])!
            
            formArray = [X, Y, floatX, floatY, floatZ]
            fishNodeArray.append(formArray)
            //fishNodeArray.append(SCNVector3Make(floatX! , floatY!, floatZ!))
        }
        
        return fishNodeArray
    }
    
    
    // function to return a document directory
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print(paths.count)
        
        return paths[0]
    }
    
}
