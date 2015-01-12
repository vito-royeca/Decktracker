//
//  DecksTableViewCell.swift
//  Decktracker
//
//  Created by Jovit Royeca on 1/5/15.
//  Copyright (c) 2015 Jovito Royeca. All rights reserved.
//

import UIKit

class DecksTableViewCell: UITableViewCell, CPTPlotDataSource {

    @IBOutlet weak var imgGraph: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblCreator: UILabel!
    @IBOutlet weak var lblFormat: UILabel!    
    @IBOutlet weak var lblPrice: UILabel!
    
    
    var deck:Deck?
    var conciseData:Array<Dictionary<String, Int>>?
    var conciseColors: Array<String>?
    var hostView:CPTGraphHostingView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func displayDeck(deck: Deck) {
        self.deck = deck
        self.conciseData = self.deck!.colorDistribution(false) as? Array<Dictionary<String, Int>>
        self.conciseColors = self.deck!.cardColors(false) as? Array<String>
        
        lblName.text = deck.name
        lblCreator.text = deck.originalDesigner != nil && countElements(deck.originalDesigner) > 0 ? "by \(deck.originalDesigner)" : ""
        lblFormat.text = deck.format
        lblPrice.text = deck.averagePrice()
        
        let imgPath = FileManager.sharedInstance().tempPath() + "/" + deck.name + ".png"
        var image:UIImage?
        
        if !NSFileManager.defaultManager().fileExistsAtPath(imgPath) {
            self.configureHost()
            self.configureGraph()
            self.configureChart()
            self.hostView!.hostedGraph.reloadData()
            
            let graph = self.hostView!.hostedGraph
            image = graph.imageOfLayer()
            let png = UIImagePNGRepresentation(image)
            png.writeToFile(imgPath, atomically: true)
            self.hostView!.removeFromSuperview()

        }
        
        image = UIImage(contentsOfFile: imgPath)
        self.imgGraph.image = image
    }
    
    func configureHost() {
        let frame = CGRect(x: self.imgGraph.frame.origin.x, y: self.imgGraph.frame.origin.y, width: self.imgGraph.frame.size.width, height: self.imgGraph.frame.size.height)
        self.hostView = CPTGraphHostingView(frame: frame)
        self.hostView!.allowPinchScaling = false
        self.addSubview(self.hostView!)
    }
    
    func configureGraph() {
        // 1 - Create and initialize graph
        let graph = CPTXYGraph(frame: self.hostView!.bounds)
        self.hostView!.hostedGraph = graph
        graph.paddingLeft   = 0.0
        graph.paddingTop    = 0.0
        graph.paddingRight  = 0.0
        graph.paddingBottom = 0.0
        graph.axisSet = nil
        
        graph.applyTheme(CPTTheme(named: kCPTPlainWhiteTheme))
        graph.plotAreaFrame.borderLineStyle = nil
    }
    
    func configureChart() {
        // 1 - Get reference to graph
        let graph = self.hostView!.hostedGraph
        
        // 2 - Create chart
        let pieChart = CPTPieChart()
        pieChart.dataSource = self
        pieChart.delegate = self
        pieChart.pieRadius = (self.hostView!.bounds.size.width * 0.7) / 2
        pieChart.startAngle = CGFloat(M_PI_4)
        pieChart.sliceDirection = CPTPieDirectionClockwise
        
        // 3 - Create gradient
        var overlayGradient = CPTGradient()
        overlayGradient.gradientType = CPTGradientTypeRadial
        overlayGradient = overlayGradient.addColorStop(CPTColor.blackColor().colorWithAlphaComponent(0.0), atPosition: 0.98)
        overlayGradient = overlayGradient.addColorStop(CPTColor.blackColor().colorWithAlphaComponent(0.4), atPosition: 1.0)
        pieChart.overlayFill = CPTFill(gradient: overlayGradient)
        
        // 4 - Add chart to graph
        graph.addPlot(pieChart)
    }
    
    // CPTPlotDataSource methods
    func numberOfRecordsForPlot(plot: CPTPlot) -> UInt {
        return UInt(conciseData!.count)
    }
    
    func numberForPlot(plot: CPTPlot, field fieldEnum: UInt, recordIndex index: UInt) -> NSNumber {
        let dict = conciseData![Int(index)]
        let keys = dict.keys
        let part = Double(dict[keys.first!]!)
        
        // compute the totalCount
        let data = conciseData
        var totalCount = 0
        for d in data! {
            let ks = d.keys
            totalCount += Int(d[ks.first!]!)
        }
        
        return (part / Double(totalCount))*100
    }
    
    func sliceFillForPieChart(pieChart: CPTPieChart, recordIndex idx: UInt) -> CPTFill {
        var fill:CPTFill?
        var colors = conciseColors
        
        if colors != nil {
            let color = colors![Int(idx)]
            
            if color == "Black" {
                return CPTFill(color: CPTColor.blackColor())
            } else if color == "Blue" {
                return CPTFill(color: CPTColor.blueColor())
            } else if color == "Red" {
                return CPTFill(color: CPTColor.redColor())
            } else if color == "Green" {
                return CPTFill(color: CPTColor.greenColor())
            } else if color == "White" {
                return CPTFill(color: CPTColor.whiteColor())
            } else if color == "Gold" {
                return CPTFill(color: CPTColor.yellowColor())
            } else if color == "Colorless" {
                return CPTFill(color: CPTColor.grayColor())
            }
        }
        
        return CPTFill(color: CPTPieChart.defaultPieSliceColorForIndex(idx))
    }
}
